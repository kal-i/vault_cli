import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entity/master_password_entity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, dynamic>> initializeVault({
    required MasterPasswordEntity masterPassword,
  });

  Future<Either<Failure, dynamic>> unlockVault({
    required MasterPasswordEntity masterPassword,
  });

  // TODO: implement recovery
}
