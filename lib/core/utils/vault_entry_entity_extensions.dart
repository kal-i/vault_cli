import 'package:drift/drift.dart';

import '../../features/vault/data/data_sources/local/vault_database.dart';
import '../../features/vault/domain/entity/vault_entry_entity.dart';

/// Adds/ extends [VaultEntryEntity] functionality w/ the ff. methods.
extension VaultEntryEntityExtensions on VaultEntryEntity {
  /// Extension method to convert [VaultEntryEntity] object to a [VaultEntriesCompanion] object.
  VaultEntriesCompanion toVaultEntriesCompanion() {
    return VaultEntriesCompanion(
      id: Value(id),
      title: Value(title),
      password: Value(password),
      username: Value(username),
      email: Value(email),
      contactNo: Value(contactNo),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
