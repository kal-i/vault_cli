import 'vault_database.dart';

abstract interface class VaultLocalDataSource {
  Future<void> insertVaultEntry({required VaultEntriesCompanion entry});
  Future<List<VaultEntry>> getAllVaultEntries();
  Future<VaultEntry?> getVaultEntryById({required String id});
  Future<List<VaultEntry>> getVaultEntriesByTitle({required String title});
  Future<bool> updateVaultEntry({required VaultEntriesCompanion entry});
  Future<int> deleteVaultEntry({required String id});
}
