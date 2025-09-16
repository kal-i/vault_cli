import 'vault_database.dart';

abstract interface class VaultLocalDataSource {
  Future<void> insertVaultEntry(VaultEntriesCompanion entry);
  Future<List<VaultEntry>> getAllVaultEntries();
  Future<VaultEntry?> getVaultEntryById(String id);
  Future<List<VaultEntry>> getVaultEntriesByTitle(String title);
  Future<bool> updateVaultEntry(VaultEntriesCompanion entry);
  Future<int> deleteVaultEntry(String id);
}