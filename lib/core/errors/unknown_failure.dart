import 'failure.dart';

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message});

  @override
  String toString() => 'Unknown error: $message';
}