import 'vault_database.dart';

Future<void> clearVaultTable(VaultDatabase db) async {
  await db.delete(db.vaultEntries).go();
  print('Vault table cleared');
}