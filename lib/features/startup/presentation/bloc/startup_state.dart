part of 'startup_bloc.dart';

sealed class StartupState {
  const StartupState();
}

final class StartupInitial extends StartupState {}

final class StartupToSetup extends StartupState {}

final class StartupToLogin extends StartupState {}