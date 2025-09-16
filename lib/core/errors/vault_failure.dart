import 'failure.dart';

/// Represents a vault-related failure
class VaultFailure extends Failure {
  const VaultFailure({required super.message});

  @override
  String toString() => 'VaultFailure: $message';
}