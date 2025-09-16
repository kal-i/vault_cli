part of 'vault_bloc.dart';

sealed class VaultState extends Equatable {
  const VaultState();

  @override
  List<Object?> get props => [];
}

final class InitialVault extends VaultState {}

final class LoadingVault extends VaultState {}

final class LoadedVault extends VaultState {
  const LoadedVault({required this.vaultEntryEntities});

  final List<VaultEntryEntity> vaultEntryEntities;

  @override
  List<Object?> get props => [vaultEntryEntities];
}

final class EntryLoaded extends VaultState {
  const EntryLoaded({required this.vaultEntryEntity});

  final VaultEntryEntity? vaultEntryEntity;

  @override
  List<Object?> get props => [vaultEntryEntity];
}

final class AddedVaultEntry extends VaultState {
  const AddedVaultEntry({required this.vaultEntryEntity});

  final VaultEntryEntity vaultEntryEntity;

  @override
  List<Object?> get props => [vaultEntryEntity];
}

final class UpdatedVaultEntry extends VaultState {
  const UpdatedVaultEntry({required this.updatedVaultEntryEntity});

  final VaultEntryEntity updatedVaultEntryEntity;

  @override
  List<Object?> get props => [updatedVaultEntryEntity];
}

final class DeletedVaultEntry extends VaultState {
  const DeletedVaultEntry({required this.isSuccessful});

  final bool isSuccessful;

  @override
  List<Object?> get props => [isSuccessful];
}

final class ErrorVault extends VaultState {
  const ErrorVault({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
