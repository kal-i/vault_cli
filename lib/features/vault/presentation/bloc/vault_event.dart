part of 'vault_bloc.dart';

sealed class VaultEvent extends Equatable {
  const VaultEvent();

  @override
  List<Object?> get props => [];
}

final class GetAllVaultEntriesEvent extends VaultEvent {}

final class AddVaultEntryEvent extends VaultEvent {
  const AddVaultEntryEvent({
    required this.title,
    required this.password,
    this.username,
    this.email,
    this.contactNo,
    this.notes,
  });

  final String title;
  final String password;
  final String? username;
  final String? email;
  final String? contactNo;
  final String? notes;

  @override
  List<Object?> get props => [
    title,
    password,
    username,
    email,
    contactNo,
    notes,
  ];
}

final class GetVaultEntryByIdEvent extends VaultEvent {
  const GetVaultEntryByIdEvent({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

final class GetVaultEntriesByTitleEvent extends VaultEvent {
  const GetVaultEntriesByTitleEvent({required this.title});

  final String title;

  @override
  List<Object?> get props => [title];
}

final class UpdateVaultEntryEvent extends VaultEvent {
  const UpdateVaultEntryEvent({
    required this.id,
    this.title,
    this.password,
    this.username,
    this.email,
    this.contactNo,
    this.notes,
  });

  final String id;
  final String? title;
  final String? password;
  final String? username;
  final String? email;
  final String? contactNo;
  final String? notes;

  @override
  List<Object?> get props => [
    id,
    title,
    password,
    username,
    email,
    contactNo,
    notes,
  ];
}

final class DeleteVaultEntryEvent extends VaultEvent {
  const DeleteVaultEntryEvent({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

final class DeleteAllEntriesEvent extends VaultEvent {}
