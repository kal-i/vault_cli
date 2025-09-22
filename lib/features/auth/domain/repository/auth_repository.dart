import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entity/master_password_entity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, dynamic>> initializeVault({
    required MasterPasswordEntity masterPassword,
  });

  Future<Either<Failure, dynamic>> unlockVault({
    required String masterPassword,
  });

  Future<Either<Failure, String>> retrieveRecoveryQuestion();

  Future<Either<Failure, bool>> verifyRecoveryAnswer({
    required String recoveryAnswer,
  });

  Future<Either<Failure, dynamic>> setupNewMasterPassword({
    required String newMasterPassword,
    String? newRecoveryQuestion,
    String? newRecoveryAnswer,
  });
}
