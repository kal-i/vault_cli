import 'package:cryptography/cryptography.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/vault_failure.dart';
import '../../../../core/services/crypto_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/entity/master_password_entity.dart';
import '../../domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.secureStorageService,
    required this.cryptoService,
  });

  final SecureStorageService secureStorageService;
  final CryptoService cryptoService;

  @override
  Future<Either<Failure, SecretKey>> initializeVault({
    required MasterPasswordEntity masterPassword,
  }) async {
    try {
      final existingHash = await secureStorageService.getMasterPassword();
      if (existingHash != null) {
        return left(const VaultFailure(message: 'Vault already initialized'));
      }

      final salt = cryptoService.generateSalt();
      final derivedKey = await cryptoService.deriveKey(
        masterPassword.password,
        salt,
      );

      final derivedKeyBytes = await derivedKey.extractBytes();

      await secureStorageService.saveSalt(cryptoService.bytesToBase64(salt));
      await secureStorageService.saveMasterPassword(
        cryptoService.bytesToBase64(derivedKeyBytes),
      );

      return right(derivedKey);
    } catch (e) {
      return left(VaultFailure(message: 'Failed to initialize vault: $e'));
    }
  }

  @override
  Future<Either<Failure, dynamic>> unlockVault({
    required MasterPasswordEntity masterPassword,
  }) async {
    try {
      final storedSalt = await secureStorageService.getSalt();
      final storedHash = await secureStorageService.getMasterPassword();

      if (storedSalt == null || storedHash == null) {
        return left(const VaultFailure(message: 'Vault not initialized'));
      }

      final derivedKey = await cryptoService.deriveKey(
        masterPassword.password,
        cryptoService.base64ToBytes(storedSalt),
      );

      final derivedKeyBytes = await derivedKey.extractBytes();
      final derivedHash = cryptoService.bytesToBase64(derivedKeyBytes);

      if (derivedHash != storedHash) {
        return left(const VaultFailure(message: 'Invalid master password'));
      }

      return right(derivedKey);
    } catch (e) {
      return left(VaultFailure(message: 'Failed to unlock vault: $e'));
    }
  }
}
