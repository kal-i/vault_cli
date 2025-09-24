import 'package:cryptography/cryptography.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/vault_failure.dart';
import '../../../../core/services/crypto_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/utils/guard_repository_call.dart';
import '../../../../core/utils/vault_entry_crypto_mapper.dart';
import '../../../../core/utils/vault_entry_entity_extensions.dart';
import '../../../../core/utils/vault_entry_extensions.dart';
import '../../../vault/data/data_sources/local/vault_local_data_source.dart';
import '../../domain/entity/master_password_entity.dart';
import '../../domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.secureStorageService,
    required this.cryptoService,
    required this.vaultLocalDataSource,
  });

  final SecureStorageService secureStorageService;
  final CryptoService cryptoService;
  final VaultLocalDataSource vaultLocalDataSource;

  @override
  Future<Either<Failure, SecretKey>> initializeVault({
    required MasterPasswordEntity masterPassword,
  }) {
    return guardRepositoryCall(
      () async {
        final existingHash = await secureStorageService.getMasterPassword();
        if (existingHash != null) {
          throw const VaultFailure(message: 'Vault already initialized');
        }

        final salt = cryptoService.generateSalt();
        final derivedKey = await cryptoService.deriveKey(
          masterPassword.password,
          salt,
        );

        final derivedKeyBytes = await derivedKey.extractBytes();
        final derivedHash = cryptoService.bytesToBase64(derivedKeyBytes);

        final hashedRecoveryAnswer = await cryptoService.hashString(
          masterPassword.recoveryAnswer,
        );

        await secureStorageService.saveSalt(cryptoService.bytesToBase64(salt));

        await secureStorageService.saveMasterPasswordEntity(
          masterPasswordEntity: MasterPasswordEntity(
            password: derivedHash,
            recoveryQuestion: masterPassword.recoveryQuestion,
            recoveryAnswer: hashedRecoveryAnswer,
          ),
        );

        return derivedKey;
      },
      name: 'AuthRepository.initializeVault',
      onError: (error, stack) {
        return VaultFailure(message: 'Failed to initialize a vault: $error');
      },
    );
  }

  @override
  Future<Either<Failure, dynamic>> unlockVault({
    required String masterPassword,
  }) {
    return guardRepositoryCall(
      () async {
        final storedSalt = await secureStorageService.getSalt();
        final storedHash = await secureStorageService.getMasterPassword();

        if (storedSalt == null || storedHash == null) {
          throw const VaultFailure(message: 'Vault not initialized');
        }

        final derivedKey = await cryptoService.deriveKey(
          masterPassword,
          cryptoService.base64ToBytes(storedSalt),
        );

        final derivedKeyBytes = await derivedKey.extractBytes();
        final derivedHash = cryptoService.bytesToBase64(derivedKeyBytes);

        if (derivedHash != storedHash) {
          throw const VaultFailure(message: 'Invalid master password');
        }

        return derivedKey;
      },
      name: 'AuthRepository.unlockVault',
      onError: (error, stack) {
        return VaultFailure(message: 'Failed to unlock vault: $error');
      },
    );
  }

  @override
  Future<Either<Failure, String>> retrieveRecoveryQuestion() {
    return guardRepositoryCall(
      () async {
        final recoveryQuestion = await secureStorageService
            .getRecoveryQuestion();
        if (recoveryQuestion == null) {
          throw const VaultFailure(message: 'No recovery question found');
        }
        return recoveryQuestion;
      },
      name: 'AuthRepository.retrieveRecoveryQuestion',
      onError: (error, stack) {
        return VaultFailure(
          message: 'Failed to retrieve recovery question: $error',
        );
      },
    );
  }

  @override
  Future<Either<Failure, bool>> verifyRecoveryAnswer({
    required String recoveryAnswer,
  }) {
    return guardRepositoryCall(
      () async {
        final storedAnswerHash = await secureStorageService.getRecoveryAnswer();

        if (storedAnswerHash == null) {
          throw const VaultFailure(message: 'No recovery answer found');
        }

        final inputHash = await cryptoService.hashString(recoveryAnswer);

        if (inputHash != storedAnswerHash) {
          throw const VaultFailure(message: 'Incorrect recovery answer');
        }

        return true;
      },
      name: 'AuthRepository.passwordRecovery',
      onError: (error, stack) {
        return VaultFailure(message: 'Failed to recover password: $error');
      },
    );
  }

  @override
  Future<Either<Failure, dynamic>> setupNewMasterPassword({
    required String newMasterPassword,
    String? newRecoveryQuestion,
    String? newRecoveryAnswer,
  }) {
    return guardRepositoryCall(
      () async {
        // Get stored credentials
        final storedSalt = await secureStorageService.getSalt();
        final storedHash = await secureStorageService.getMasterPassword();
        final storedRecoveryQuestion = await secureStorageService
            .getRecoveryQuestion();
        final storedRecoveryAnswer = await secureStorageService
            .getRecoveryAnswer();

        if (storedSalt == null ||
            storedHash == null ||
            storedRecoveryQuestion == null ||
            storedRecoveryAnswer == null) {
          throw const VaultFailure(message: 'Vault not initialized');
        }

        // Reconstruct old derived key from stored hash
        final oldDerivedKey = SecretKey(
          cryptoService.base64ToBytes(storedHash),
        );

        // Decrypt existing entries
        final encryptedVaultEntries = await vaultLocalDataSource
            .getAllVaultEntries();
        final oldMapper = VaultEntryCryptoMapper(
          cryptoService: cryptoService,
          secretKey: oldDerivedKey,
        );
        final decryptedVaultEntryEntities = await Future.wait(
          encryptedVaultEntries
              .map(
                (encryptedVaultEntry) async => await oldMapper.decryptEntity(
                  encryptedVaultEntry.toVaultEntryEntity(),
                ),
              )
              .toList(),
        );

        // Derive new key from new master password
        final newSalt = cryptoService.generateSalt();
        final newDerivedKey = await cryptoService.deriveKey(
          newMasterPassword,
          newSalt,
        );
        final newDerivedKeyBytes = await newDerivedKey.extractBytes();
        final newDerivedKeyBase64 = cryptoService.bytesToBase64(
          newDerivedKeyBytes,
        );

        final newMapper = VaultEntryCryptoMapper(
          cryptoService: cryptoService,
          secretKey: newDerivedKey,
        );

        // Re-encrypt entries with the new derive key
        final reEncryptedEntryEntries = await Future.wait(
          decryptedVaultEntryEntities
              .map((e) => newMapper.encryptEntity(e))
              .toList(),
        );
        final reDecryptVaultEntryEntities = await Future.wait(
          reEncryptedEntryEntries
              .map((e) => newMapper.decryptEntity(e))
              .toList(),
        );

        await vaultLocalDataSource.updateVaultEntries(
          entries: reEncryptedEntryEntries
              .map((e) => e.toVaultEntriesCompanion())
              .toList(),
        );

        final recoveryQuestion = newRecoveryQuestion ?? storedRecoveryQuestion;
        final recoveryAnswer = newRecoveryAnswer != null
            ? await cryptoService.hashString(newRecoveryAnswer)
            : storedRecoveryAnswer;

        // Save new salt, derived hash, and recovery Q&A
        await secureStorageService.saveSalt(
          cryptoService.bytesToBase64(newSalt),
        );
        await secureStorageService.saveMasterPasswordEntity(
          masterPasswordEntity: MasterPasswordEntity(
            password: newDerivedKeyBase64,
            recoveryQuestion: recoveryQuestion,
            recoveryAnswer: recoveryAnswer,
          ),
        );

        return newDerivedKey;
      },
      name: 'AuthRepository.setupNewPassword',
      onError: (error, stack) {
        return VaultFailure(message: 'Failed to setup new password: $error');
      },
    );
  }

  @override
  Future<Either<Failure, bool>> resetVault() {
    return guardRepositoryCall(
      () async {
        final masterPassword = await secureStorageService.getMasterPassword();
        if (masterPassword == null) {
          throw const VaultFailure(message: 'Vault not initialized');
        }

        await secureStorageService.clear();
        await vaultLocalDataSource.deleteVaultEntries();

        return true;
      },
      name: 'AuthRepository.resetVault',
      onError: (error, stack) {
        return VaultFailure(message: 'Failed to reset vault: $error');
      },
    );
  }
}
