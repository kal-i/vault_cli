import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/database_failure.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/vault_entry_crypto_mapper.dart';
import '../../../../core/utils/guard_repository_call.dart';
import '../../domain/entities/vault_entry_entity.dart';
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
  Future<Either<Failure, VaultEntryEntity>> addEntry(VaultEntryEntity entry) {
    return guardRepositoryCall(() async {
      final encryptedEntity = await vaultEntryCryptoMapper.encryptEntity(entry);
      final driftEntry = _toDrift(encryptedEntity);

      await vaultLocalDataSource.insertVaultEntry(driftEntry);
      return entry;
    });
  }

  @override
  Future<Either<Failure, bool>> deleteEntry(String id) {
    return guardRepositoryCall(() async {
      return await vaultLocalDataSource.deleteVaultEntry(id) == 1
          ? true
          : false;
    });
  }

  @override
  Future<Either<Failure, List<VaultEntryEntity>>> getAllEntries() {
    return guardRepositoryCall(() async {
      final driftEntities = await vaultLocalDataSource.getAllVaultEntries();

      return _decryptVaultEntries(driftEntities);
    });
  }

  @override
  Future<Either<Failure, VaultEntryEntity?>> getEntryById(String id) {
    return guardRepositoryCall(() async {
      final driftEntry = await vaultLocalDataSource.getVaultEntryById(id);
      if (driftEntry == null) return null;

      return _decryptVaultEntry(driftEntry);
    });
  }

  @override
  Future<Either<Failure, List<VaultEntryEntity>>> getEntryByTitle(
    String title,
  ) {
    return guardRepositoryCall(() async {
      final driftEntries = await vaultLocalDataSource.getVaultEntriesByTitle(
        title,
      );

      return await _decryptVaultEntries(driftEntries);
    });
  }

  @override
  Future<Either<Failure, VaultEntryEntity>> updateEntry(
    VaultEntryEntity entry,
  ) {
    return guardRepositoryCall(() async {
      final encryptedEntity = await vaultEntryCryptoMapper.encryptEntity(entry);
      final driftEntry = _toDrift(encryptedEntity);

      final success = await vaultLocalDataSource.updateVaultEntry(driftEntry);
      if (!success) {
        throw const DatabaseFailure(message: 'Failed to update an entry');
      }

      return entry;
    });
  }

  Future<List<VaultEntryEntity>> _decryptVaultEntries(
    List<VaultEntry> entries,
  ) async {
    final decryptedEntries = entries.map((e) => _decryptVaultEntry(e)).toList();
    return await Future.wait(decryptedEntries);
  }

  Future<VaultEntryEntity> _decryptVaultEntry(VaultEntry e) async {
    return await vaultEntryCryptoMapper.decryptEntity(_fromDrift(e));
  }

  VaultEntryEntity _fromDrift(VaultEntry e) => VaultEntryEntity(
    id: e.id,
    title: e.title,
    contactNo: e.contactNo,
    email: e.email,
    username: e.username,
    password: e.password,
    notes: e.notes,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );

  VaultEntriesCompanion _toDrift(VaultEntryEntity e) => VaultEntriesCompanion(
    id: Value(e.id),
    title: Value(e.title),
    contactNo: Value(e.contactNo),
    email: Value(e.email),
    password: Value(e.password),
    notes: Value(e.notes),
    createdAt: Value(e.createdAt),
    updatedAt: Value(e.updatedAt),
  );
}
