import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/secure_storage_service.dart';

part 'startup_event.dart';
part 'startup_state.dart';

class StartupBloc extends Bloc<StartupEvent, StartupState> {
  StartupBloc({required SecureStorageService secureStorageService})
    : _secureStorageService = secureStorageService,
      super(StartupInitial()) {
    on<NavigateToEvent>(_onNavigateTo);
  }

  final SecureStorageService _secureStorageService;

  void _onNavigateTo(NavigateToEvent event, Emitter<StartupState> emit) async {
    final masterPassword = await _secureStorageService.getMasterPassword();
    if (masterPassword == null) {
      emit(StartupToSetup());
      return;
    }
    emit(StartupToLogin());
  }
}
