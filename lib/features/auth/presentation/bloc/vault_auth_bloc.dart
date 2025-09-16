import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/emit_result.dart';
import '../../../../init_dependencies.dart';
import '../../domain/entity/master_password_entity.dart';
import '../../domain/usecases/initialize_vault.dart';
import '../../domain/usecases/unlock_vault.dart';
import 'vault_auth_event.dart';
import 'vault_auth_state.dart';

class VaultAuthBloc extends Bloc<VaultAuthEvent, VaultAuthState> {
  VaultAuthBloc({
    required InitializeVault initializeVault,
    required UnlockVault unlockVault,
  }) : _initializeVault = initializeVault,
       _unlockVault = unlockVault,
       super(VaultAuthInitial()) {
    on<InitializeVaultEvent>(_onInitializeVault);
    on<UnlockVaultEvent>(_onUnlockVault);
  }

  final InitializeVault _initializeVault;
  final UnlockVault _unlockVault;

  void _onInitializeVault(
    InitializeVaultEvent event,
    Emitter<VaultAuthState> emit,
  ) async {
    emit(VaultAuthLoading());

    await emitResult(
      emit,
      _initializeVault(MasterPasswordEntity(password: event.masterPassword)),
      onError: (l) => VaultAuthError(message: l),
      onSuccess: (r) {
        setupVaultRepositoryAndBloc(r);
        return VaultAuthSuccess(secretKey: r);
      },
    );
  }

  void _onUnlockVault(
    UnlockVaultEvent event,
    Emitter<VaultAuthState> emit,
  ) async {
    emit(VaultAuthLoading());

    await emitResult(
      emit,
      _unlockVault(MasterPasswordEntity(password: event.masterPassword)),
      onError: (l) => VaultAuthError(message: l),
      onSuccess: (r) {
        setupVaultRepositoryAndBloc(r);
        return VaultAuthSuccess(secretKey: r);
      },
    );
  }
}
