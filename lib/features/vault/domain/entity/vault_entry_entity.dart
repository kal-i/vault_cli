/// Represents an entry stored in the secure vault.
class VaultEntryEntity {
  const VaultEntryEntity({
    required this.id,
    required this.title,
    this.contactNo,
    this.email,
    this.username,
    required this.password,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String? contactNo;
  final String? email;
  final String? username;
  final String password;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
}
