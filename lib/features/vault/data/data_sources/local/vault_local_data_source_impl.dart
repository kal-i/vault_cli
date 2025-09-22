import 'package:drift/drift.dart';

import '../../../../../core/errors/database_failure.dart';
import '../../../../../core/utils/guard_data_source_call.dart';

import 'vault_database.dart';
import 'vault_local_data_source.dart';

class VaultLocalDataSourceImpl implements VaultLocalDataSource {
  const VaultLocalDataSourceImpl({required this.db});

  final VaultDatabase db;

  @override
  Future<int> deleteVaultEntry({required String id}) {
    return guardDataSourceCall(
      () async {
        return await (db.delete(
          db.vaultEntries,
        )..where((tbl) => tbl.id.equals(id))).go();
      },
      name: 'VaultLocalDataSource.deleteVaultEntry',
      mapError: (error) =>
          DatabaseFailure(message: 'Failed to delete entry: $error'),
    );
  }

  @override
  Future<List<VaultEntry>> getAllVaultEntries() {
    return guardDataSourceCall(
      () async {
        return await db.select(db.vaultEntries).get();
      },
      name: 'VaultLocalDataSource.getAllVaultEntries',
      mapError: (error) =>
          DatabaseFailure(message: 'Failed to fetch entries: $error'),
    );
  }

  @override
  Future<List<VaultEntry>> getVaultEntriesByTitle({required String title}) {
    return guardDataSourceCall(
      () async {
        return await (db.select(
          db.vaultEntries,
        )..where((tbl) => tbl.title.like('%$title%'))).get();
      },
      name: 'VaultLocalDataSource.getVaultEntriesByTitle',
      mapError: (error) =>
          DatabaseFailure(message: 'Failed to fetch entries by title: $error'),
    );
  }

  @override
  Future<VaultEntry?> getVaultEntryById({required String id}) {
    return guardDataSourceCall(
      () async {
        return await (db.select(
          db.vaultEntries,
        )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      },
      name: 'VaultLocalDataSource.getVaultEntryById',
      mapError: (error) =>
          DatabaseFailure(message: 'Failed to fetch an entry by id: $error'),
    );
  }

  @override
  Future<void> insertVaultEntry({required VaultEntriesCompanion entry}) {
    return guardDataSourceCall(
      () async {
        await db.into(db.vaultEntries).insert(entry);
      },
      name: 'VaultLocalDataSource.insertVaultEntry',
      mapError: (error) =>
          DatabaseFailure(message: 'Failed to insert an entry: $error'),
    );
  }

  @override
  Future<bool> updateVaultEntry({required VaultEntriesCompanion entry}) {
    return guardDataSourceCall(
      () async {
        return await db.update(db.vaultEntries).replace(entry);
      },
      name: 'VaultLocalDataSource.updateVaultEntry',
      mapError: (error) =>
          DatabaseFailure(message: 'Failed to update an entry: $error'),
    );
  }

  @override
  Future<void> insertAllVaultEntries({
    required List<VaultEntriesCompanion> entries,
  }) {
    return guardDataSourceCall(
      () async {
        await db.batch((batch) {
          batch.insertAll(db.vaultEntries, entries);
        });
      },
      name: 'VaultLocalDataSource.insertAllVaultEntries',
      mapError: (error) =>
          DatabaseFailure(message: 'Failed to insert all entries: $error'),
    );
  }

  @override
  Future<void> deleteVaultEntries() {
    return guardDataSourceCall(
      () async {
        await db.batch((batch) {
          batch.deleteAll(db.vaultEntries);
        });
      },
      name: 'VaultLocalDataSource.deleteVaultEntries',
      mapError: (error) =>
          DatabaseFailure(message: 'Failed to delete entries: $error'),
    );
  }

  @override
  Future<void> updateVaultEntries({
    required List<VaultEntriesCompanion> entries,
  }) {
    return guardDataSourceCall(
      () async {
        await db.batch((batch) {
          batch.replaceAll(db.vaultEntries, entries.map((e) => e).toList());
        });
      },
      name: 'VaultLocalDataSource.updateAllEntries',
      mapError: (error) =>
          DatabaseFailure(message: 'Failed to update entries: $error'),
    );
  }
}
