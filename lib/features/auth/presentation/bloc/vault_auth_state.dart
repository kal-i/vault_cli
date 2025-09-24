import 'package:equatable/equatable.dart';

sealed class VaultAuthState extends Equatable {
  const VaultAuthState();

  @override
  List<Object?> get props => [];
}

final class VaultAuthInitial extends VaultAuthState {}

final class VaultAuthLoading extends VaultAuthState {}

abstract class VaultAuthSuccess extends VaultAuthState {
  const VaultAuthSuccess({required this.secretKey});

  final dynamic secretKey;

  @override
  List<Object?> get props => [secretKey];
}

final class VaultAuthInitialized extends VaultAuthSuccess {
  const VaultAuthInitialized({required super.secretKey});
}

final class VaultAuthUnlocked extends VaultAuthSuccess {
  const VaultAuthUnlocked({required super.secretKey});
}

final class VaultAuthMasterPasswordUpdated extends VaultAuthSuccess {
  const VaultAuthMasterPasswordUpdated({required super.secretKey});
}

final class VaultAuthError extends VaultAuthState {
  const VaultAuthError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class VaultRetrievedRecoveryQuestion extends VaultAuthState {
  const VaultRetrievedRecoveryQuestion({required this.recoveryQuestion});

  final String recoveryQuestion;

  @override
  List<Object?> get props => [recoveryQuestion];
}

final class VaultVerifiedRecoveryAnswer extends VaultAuthState {
  const VaultVerifiedRecoveryAnswer({required this.isSuccessful});

  final bool isSuccessful;

  @override
  List<Object?> get props => [isSuccessful];
}
