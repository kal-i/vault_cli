import 'package:fpdart/fpdart.dart';

import '../errors/failure.dart';

Future<Either<Failure, T>> guardRepositoryCall<T>(
  Future<T> Function() call,
) async {
  try {
    final result = await call();
    return right(result);
  } on Failure catch (e) {
    return left(e);
  }
}
