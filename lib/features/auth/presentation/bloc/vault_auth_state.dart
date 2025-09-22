import 'package:equatable/equatable.dart';

sealed class VaultAuthState extends Equatable {
  const VaultAuthState();

  @override
  List<Object?> get props => [];
}

final class VaultAuthInitial extends VaultAuthState {}

final class VaultAuthLoading extends VaultAuthState {}

final class VaultAuthSuccess extends VaultAuthState {
  const VaultAuthSuccess({required this.secretKey});

  final dynamic secretKey;

  @override
  List<Object?> get props => [secretKey];
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
