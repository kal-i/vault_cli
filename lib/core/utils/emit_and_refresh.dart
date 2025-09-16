import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../errors/failure.dart';

/// A helper function for BLoC event handlers that:
/// 1. Executes a main async operation (e.g. add, update, delete).
/// 2. If the main operation succeeds, triggers a "refresh" operation to fetch
///    an updated list of data.
/// 3. Emits the appropriate state for either failure or success.
///
/// ## Use Case
/// Perfect for scenarios like:
/// - Adding an item then reloading the list.
/// - Updating an item then reloading the list.
/// - Deleting an item then reloading the list.
///
/// ## Type Parameters:
/// - [TState] — The BLoC state type (e.g. `VaultState`).
/// - [TMainResult] — The result type of the main async operation
///   (e.g. `bool` for delete, `VaultEntryEntity` for add/update).
/// - [TRefreshResult] — The result type of each item returned by the refresh call
///   (usually your entity type, e.g. `VaultEntryEntity`).
///
/// ## Parameters:
/// - [emit] — The `Emitter<TState>` provided by BLoC.
/// - [future] — The main operation returning `Either<Failure, TMainResult>`.
/// - [refresh] — A callback that re-fetches data, returning
///   `Either<Failure, List<TRefreshResult>>`.
/// - [onError] — A function that maps a failure message to an error state.
/// - [onSuccess] — A function that maps the refreshed list to a success state.
///
/// ## Example:
/// ```dart
/// await emitAndRefresh<MyState, bool, MyEntity>(
///   emit,
///   repository.deleteItem(itemId),
///   () => repository.getAllItems(),
///   (message) => MyErrorState(message),
///   (items) => MyLoadedState(items: items),
/// );
/// ```
///
/// This will:
/// - Attempt to delete the item.
/// - If delete fails → emit `MyErrorState`.
/// - If delete succeeds → call `getAllItems()`, then emit `MyLoadedState`
///   with the refreshed list.
Future<void> emitAndRefresh<TState, TMainResult, TRefreshResult>(
    Emitter<TState> emit,
    Future<Either<Failure, TMainResult>> future,
    Future<Either<Failure, List<TRefreshResult>>> Function() refresh,
    TState Function(String) onError,
    TState Function(List<TRefreshResult>) onSuccess,
    ) async {
  final result = await future;
  await result.fold(
        (l) async => emit(onError(l.message)),
        (_) async {
      final refreshed = await refresh();
      refreshed.fold(
            (l) => emit(onError(l.message)),
            (r) => emit(onSuccess(r)),
      );
    },
  );
}
