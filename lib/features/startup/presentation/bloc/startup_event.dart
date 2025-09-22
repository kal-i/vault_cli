part of 'startup_bloc.dart';

sealed class StartupEvent {
  const StartupEvent();
}

final class NavigateToEvent extends StartupEvent {}