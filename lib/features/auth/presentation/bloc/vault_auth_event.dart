import 'package:equatable/equatable.dart';

import '../../domain/entity/master_password_entity.dart';

sealed class VaultAuthEvent extends Equatable {
  const VaultAuthEvent();

  @override
  List<Object?> get props => [];
}

final class InitializeVaultEvent extends VaultAuthEvent {
  const InitializeVaultEvent({required this.masterPassword});

  final String masterPassword;

  @override
  List<Object?> get props => [masterPassword];
}

final class UnlockVaultEvent extends VaultAuthEvent {
  const UnlockVaultEvent({required this.masterPassword});

  final String masterPassword;

  @override
  List<Object?> get props => [masterPassword];
}