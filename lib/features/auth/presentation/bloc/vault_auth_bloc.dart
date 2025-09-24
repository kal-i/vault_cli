import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/no_params.dart';
import '../../../../core/utils/emit_result.dart';
import '../../../../init_dependencies.dart';
import '../../domain/entity/master_password_entity.dart';
import '../../domain/usecases/initialize_vault.dart';
import '../../domain/usecases/reset_vault.dart';
import '../../domain/usecases/retrieve_recovery_question.dart';
import '../../domain/usecases/setup_new_master_password.dart';
import '../../domain/usecases/unlock_vault.dart';
import '../../domain/usecases/verify_recovery_answer.dart';
import 'vault_auth_event.dart';
import 'vault_auth_state.dart';

class VaultAuthBloc extends Bloc<VaultAuthEvent, VaultAuthState> {
  VaultAuthBloc({
    required InitializeVault initializeVault,
    required UnlockVault unlockVault,
    required RetrieveRecoveryQuestion retrieveRecoveryQuestion,
    required VerifyRecoveryAnswer verifyRecoveryAnswer,
    required SetupNewMasterPassword setupNewMasterPassword,
    required ResetVault resetVault,
  }) : _initializeVault = initializeVault,
       _unlockVault = unlockVault,
       _retrieveRecoveryQuestion = retrieveRecoveryQuestion,
       _verifyRecoveryAnswer = verifyRecoveryAnswer,
       _setupNewMasterPassword = setupNewMasterPassword,
       _resetVault = resetVault,
       super(VaultAuthInitial()) {
    on<InitializeVaultEvent>(_onInitializeVault);
    on<UnlockVaultEvent>(_onUnlockVault);
    on<RetrieveVaultRecoveryQuestionEvent>(_onRetrieveVaultRecoveryQuestion);
    on<VerifyVaultRecoveryAnswerEvent>(_onVerifyVaultRecoveryAnswer);
    on<SetupNewMasterPasswordEvent>(_onSetupNewMasterPassword);
    on<ResetVaultEvent>(_onResetVault);
  }

  final InitializeVault _initializeVault;
  final UnlockVault _unlockVault;
  final RetrieveRecoveryQuestion _retrieveRecoveryQuestion;
  final VerifyRecoveryAnswer _verifyRecoveryAnswer;
  final SetupNewMasterPassword _setupNewMasterPassword;
  final ResetVault _resetVault;

  void _onInitializeVault(
    InitializeVaultEvent event,
    Emitter<VaultAuthState> emit,
  ) async {
    emit(VaultAuthLoading());

    await emitResult<VaultAuthState, dynamic>(
      emit,
      _initializeVault(
        MasterPasswordEntity(
          password: event.masterPassword,
          recoveryQuestion: event.recoveryQuestion,
          recoveryAnswer: event.recoveryAnswer,
        ),
      ),
      onError: (l) => VaultAuthError(message: l),
      onSuccess: (r) {
        setupVaultRepositoryAndBloc(r);
        return VaultAuthInitialized(secretKey: r);
      },
    );
  }

  void _onUnlockVault(
    UnlockVaultEvent event,
    Emitter<VaultAuthState> emit,
  ) async {
    emit(VaultAuthLoading());

    await emitResult<VaultAuthState, dynamic>(
      emit,
      _unlockVault(event.masterPassword),
      onError: (l) => VaultAuthError(message: l),
      onSuccess: (r) {
        setupVaultRepositoryAndBloc(r);
        return VaultAuthUnlocked(secretKey: r);
      },
    );
  }

  void _onRetrieveVaultRecoveryQuestion(
    RetrieveVaultRecoveryQuestionEvent event,
    Emitter<VaultAuthState> emit,
  ) async {
    emit(VaultAuthLoading());

    await emitResult(
      emit,
      _retrieveRecoveryQuestion(NoParams()),
      onError: (l) => VaultAuthError(message: l),
      onSuccess: (r) => VaultRetrievedRecoveryQuestion(recoveryQuestion: r),
    );
  }

  void _onVerifyVaultRecoveryAnswer(
    VerifyVaultRecoveryAnswerEvent event,
    Emitter<VaultAuthState> emit,
  ) async {
    emit(VaultAuthLoading());

    await emitResult<VaultAuthState, bool>(
      emit,
      _verifyRecoveryAnswer(event.recoveryAnswer),
      onError: (l) => VaultAuthError(message: l),
      onSuccess: (r) => VaultVerifiedRecoveryAnswer(isSuccessful: r),
    );
  }

  void _onSetupNewMasterPassword(
    SetupNewMasterPasswordEvent event,
    Emitter<VaultAuthState> emit,
  ) async {
    emit(VaultAuthLoading());

    await emitResult(
      emit,
      _setupNewMasterPassword(
        SetupNewMasterPasswordParams(
          newMasterPassword: event.newMasterPassword,
          newRecoveryQuestion: event.newRecoveryQuestion,
          newRecoveryAnswer: event.newRecoveryAnswer,
        ),
      ),
      onError: (l) => VaultAuthError(message: l),
      onSuccess: (r) {
        setupVaultRepositoryAndBloc(r);
        return VaultAuthMasterPasswordUpdated(secretKey: r);
      },
    );
  }

  void _onResetVault(
    ResetVaultEvent event,
    Emitter<VaultAuthState> emit,
  ) async {
    emit(VaultAuthLoading());

    await emitResult(
      emit,
      _resetVault(NoParams()),
      onError: (l) => VaultAuthError(message: l),
      onSuccess: (r) => VaultReset(isSuccessful: r),
    );
  }
}
