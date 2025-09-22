import 'dart:developer' as developer;

import 'package:fpdart/fpdart.dart';

import '../errors/failure.dart';
import '../errors/unknown_failure.dart';

Future<Either<Failure, T>> guardRepositoryCall<T>(
  Future<T> Function() call, {
  String name = 'Repository',
  Failure Function(Object error, StackTrace stackTrace)? onError,
}) async {
  try {
    final result = await call();
    return right(result);
  } on Failure catch (e, st) {
    developer.log('[$name] Failure: $e', error: e, stackTrace: st, name: name);
    return left(onError != null ? onError(e, st) : e);
  } catch (e, st) {
    developer.log('[$name] Error: $e', error: e, stackTrace: st, name: name);
    return left(
      onError != null ? onError(e, st) : UnknownFailure(message: e.toString()),
    );
  }
}
