import 'package:fpdart/fpdart.dart';

import '../errors/failure.dart';

/// Defines a base contract for all use cases.
///
/// Takes [Params] as input and returns a [Future] of either [Failure] or [Type] as output.
abstract interface class Usecase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}