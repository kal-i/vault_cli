import 'package:equatable/equatable.dart';

import '../../domain/entity/master_password_entity.dart';

sealed class VaultAuthEvent extends Equatable {
  const VaultAuthEvent();

  @override
  List<Object?> get props => [];
}

final class InitializeVaultEvent extends VaultAuthEvent {
  const InitializeVaultEvent({
    required this.masterPassword,
    required this.recoveryQuestion,
    required this.recoveryAnswer,
  });

  final String masterPassword;
  final String recoveryQuestion;
  final String recoveryAnswer;

  @override
  List<Object?> get props => [masterPassword];
}

final class UnlockVaultEvent extends VaultAuthEvent {
  const UnlockVaultEvent({required this.masterPassword});

  final String masterPassword;

  @override
  List<Object?> get props => [masterPassword];
}

final class RetrieveVaultRecoveryQuestionEvent extends VaultAuthEvent {}

final class VerifyVaultRecoveryAnswerEvent extends VaultAuthEvent {
  const VerifyVaultRecoveryAnswerEvent({required this.recoveryAnswer});

  final String recoveryAnswer;

  @override
  List<Object?> get props => [recoveryAnswer];
}

final class SetupNewMasterPasswordEvent extends VaultAuthEvent {
  const SetupNewMasterPasswordEvent({
    required this.newMasterPassword,
    this.newRecoveryQuestion,
    this.newRecoveryAnswer,
  });

  final String newMasterPassword;
  final String? newRecoveryQuestion;
  final String? newRecoveryAnswer;

  @override
  List<Object?> get props => [
    newMasterPassword,
    newRecoveryQuestion,
    newRecoveryAnswer,
  ];
}
