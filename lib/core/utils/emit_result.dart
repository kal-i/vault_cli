import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../errors/failure.dart';

/// A lightweight helper for BLoC event handlers that emit state
/// based on a single async operation.
///
/// Unlike [emitAndRefresh], this does not trigger a follow-up "refresh"
/// operation — it just resolves the result and emits the corresponding state.
///
/// ## Type Parameters:
/// - [TState] — The BLoC state type (e.g. `VaultState`).
/// - [TResult] — The result type returned by the async operation
///   (e.g. `VaultEntryEntity`, `List<VaultEntryEntity>`, `bool`, etc.).
///
/// ## Parameters:
/// - [emit] — The `Emitter<TState>` provided by BLoC.
/// - [future] — The main operation returning `Either<Failure, TResult>`.
/// - [onError] — Maps a failure message to an error state.
/// - [onSuccess] — Maps a successful result to a success state.
///
/// ## Example:
/// ```dart
/// await emitResult<MyState, List<MyEntity>>(
///   emit,
///   repository.getAllItems(),
///   onError: (message) => MyErrorState(message),
///   onSuccess: (items) => MyLoadedState(items: items),
/// );
/// ```
///
/// This will:
/// - Attempt to fetch items.
/// - If it fails → emit `MyErrorState`.
/// - If it succeeds → emit `MyLoadedState` with the result.
Future<void> emitResult<TState, TResult>(
  Emitter<TState> emit,
  Future<Either<Failure, TResult>> future, {
  required TState Function(String message) onError,
  required TState Function(TResult result) onSuccess,
}) async {
  final result = await future;
  result.fold((l) => emit(onError(l.message)), (r) => emit(onSuccess(r)));
}
