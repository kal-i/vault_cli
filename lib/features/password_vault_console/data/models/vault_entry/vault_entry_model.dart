import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/vault_entry_entity.dart';

part 'vault_entry_model.g.dart';

@JsonSerializable()
class VaultEntryModel extends VaultEntryEntity {
  const VaultEntryModel({
    required super.id,
    required super.title,
    super.contactNo,
    super.email,
    super.username,
    required super.password,
    super.notes,
    required super.createdAt,
    super.updatedAt,
  });

  factory VaultEntryModel.fromJson(Map<String, dynamic> json) =>
      _$VaultEntryModelFromJson(json);

  Map<String, dynamic> toJson() => _$VaultEntryModelToJson(this);

  factory VaultEntryModel.fromEntity(VaultEntryEntity entity) =>
      VaultEntryModel(
        id: entity.id,
        title: entity.title,
        contactNo: entity.contactNo,
        email: entity.email,
        username: entity.username,
        password: entity.password,
        notes: entity.notes,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  VaultEntryEntity toEntity() => VaultEntryEntity(
    id: id,
    title: title,
    contactNo: contactNo,
    email: email,
    username: username,
    password: password,
    notes: notes,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
