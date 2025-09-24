import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/database_failure.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/vault_failure.dart';
import '../../../../core/utils/vault_entry_crypto_mapper.dart';
import '../../../../core/utils/guard_repository_call.dart';
import '../../../../core/utils/vault_entry_entity_extensions.dart';
import '../../../../core/utils/vault_entry_extensions.dart';
import '../../domain/entity/vault_entry_entity.dart';
import '../../domain/repository/vault_repository.dart';
import '../data_sources/local/vault_database.dart';
import '../data_sources/local/vault_local_data_source.dart';

class VaultRepositoryImpl implements VaultRepository {
  const VaultRepositoryImpl({
    required this.vaultLocalDataSource,
    required this.vaultEntryCryptoMapper,
  });

  final VaultLocalDataSource vaultLocalDataSource;
  final VaultEntryCryptoMapper vaultEntryCryptoMapper;

  @override
  Future<Either<Failure, VaultEntryEntity>> addEntry({
    required VaultEntryEntity entry,
  }) {
    return guardRepositoryCall(
      () async {
        final encryptedEntity = await vaultEntryCryptoMapper.encryptEntity(
          entry,
        );
        final vaultEntriesCompanion = encryptedEntity.toVaultEntriesCompanion();

        await vaultLocalDataSource.insertVaultEntry(
          entry: vaultEntriesCompanion,
        );
        return entry;
      },
      name: 'VaultRepository.addEntry',
      onError: (error, stack) {
        return VaultFailure(message: 'Failed to add a new entry: $error');
      },
    );
  }

  @override
  Future<Either<Failure, bool>> deleteEntry({required String id}) {
    return guardRepositoryCall(
      () async {
        return await vaultLocalDataSource.deleteVaultEntry(id: id) == 1
            ? true
            : false;
      },
      name: 'VaultRepository.deleteEntry',
      onError: (error, stack) {
        return VaultFailure(message: 'Failed to delete an entry: $error');
      },
    );
  }

  @override
  Future<Either<Failure, List<VaultEntryEntity>>> getAllEntries() {
    return guardRepositoryCall(
      () async {
        final vaultEntries = await vaultLocalDataSource.getAllVaultEntries();

        return _decryptVaultEntries(vaultEntries);
      },
      name: 'VaultRepository.getAllEntries',
      onError: (error, stack) {
        return VaultFailure(message: 'Failed to fetch all entries: $error');
      },
    );
  }

  @override
  Future<Either<Failure, VaultEntryEntity?>> getEntryById({
    required String id,
  }) {
    return guardRepositoryCall(
      () async {
        final vaultEntry = await vaultLocalDataSource.getVaultEntryById(id: id);
        if (vaultEntry == null) return null;

        return _decryptVaultEntry(vaultEntry);
      },
      name: 'VaultRepository.getEntryById',
      onError: (error, stack) {
        return VaultFailure(message: 'Failed to fetch an entry by id: $error');
      },
    );
  }

  @override
  Future<Either<Failure, List<VaultEntryEntity>>> getEntryByTitle({
    required String title,
  }) {
    return guardRepositoryCall(
      () async {
        final vaultEntries = await vaultLocalDataSource.getVaultEntriesByTitle(
          title: title,
        );

        return await _decryptVaultEntries(vaultEntries);
      },
      name: 'VaultRepository.getEntryByTitle',
      onError: (error, stack) {
        return VaultFailure(
          message: 'Failed to fetch entries by title: $error',
        );
      },
    );
  }

  @override
  Future<Either<Failure, VaultEntryEntity>> updateEntry({
    required VaultEntryEntity entry,
  }) {
    return guardRepositoryCall(
      () async {
        final encryptedEntity = await vaultEntryCryptoMapper.encryptEntity(
          entry,
        );
        final vaultEntriesCompanion = encryptedEntity.toVaultEntriesCompanion();

        final success = await vaultLocalDataSource.updateVaultEntry(
          entry: vaultEntriesCompanion,
        );

        if (!success) {
          throw const DatabaseFailure(message: 'Failed to update an entry');
        }

        return entry;
      },
      name: 'VaultRepository.updateEntry',
      onError: (error, stack) {
        return VaultFailure(message: 'Failed to update an entry: $error');
      },
    );
  }

  @override
  Future<Either<Failure, void>> deleteAllEntries() async {
    return guardRepositoryCall(
      () async {
        await vaultLocalDataSource.deleteVaultEntries();
      },
      name: 'VaultRepository.deleteAllEntries',
      onError: (error, stack) {
        return VaultFailure(message: 'Failed to delete all entries: $error');
      },
    );
  }

  Future<List<VaultEntryEntity>> _decryptVaultEntries(
    List<VaultEntry> entries,
  ) async {
    final decryptedEntries = entries.map((e) => _decryptVaultEntry(e)).toList();
    return await Future.wait(decryptedEntries);
  }

  Future<VaultEntryEntity> _decryptVaultEntry(VaultEntry e) async {
    return await vaultEntryCryptoMapper.decryptEntity(e.toVaultEntryEntity());
  }
}
