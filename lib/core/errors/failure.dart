/// Base class for all failures.
abstract class Failure {
  const Failure({required this.message});

  final String message;

  @override
  String toString() => 'Failure: $message';
}
