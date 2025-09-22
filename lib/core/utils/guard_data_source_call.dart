import 'dart:developer' as developer;

import '../errors/failure.dart';

/// A generic async function wrapper that handles and logs errors
Future<T> guardDataSourceCall<T>(
  Future<T> Function() call, {
  String name = 'DataSource',
  Failure Function(Object error)? mapError,
}) async {
  try {
    return await call();
  } catch (e, st) {
    developer.log('[$name] Error: $e', error: e, stackTrace: st, name: name);

    if (mapError != null) throw mapError(e);

    rethrow;
  }
}
