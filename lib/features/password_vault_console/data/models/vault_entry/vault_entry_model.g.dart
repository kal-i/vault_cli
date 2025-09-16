// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VaultEntryModel _$VaultEntryModelFromJson(Map<String, dynamic> json) =>
    VaultEntryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      contactNo: json['contactNo'] as String?,
      email: json['email'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$VaultEntryModelToJson(VaultEntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'contactNo': instance.contactNo,
      'email': instance.email,
      'username': instance.username,
      'password': instance.password,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
