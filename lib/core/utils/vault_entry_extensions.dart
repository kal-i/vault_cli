import '../../features/vault/data/data_sources/local/vault_database.dart';
import '../../features/vault/domain/entity/vault_entry_entity.dart';

/// Extends [VaultEntry] functionality
extension VaultEntryExtensions on VaultEntry {
  /// Extension method to convert [VaultEntry] object to a [VaultEntryEntity] object.
  VaultEntryEntity toVaultEntryEntity() {
    return VaultEntryEntity(
      id: id,
      title: title,
      password: password,
      username: username,
      email: email,
      contactNo: contactNo,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt
    );
  }
}
