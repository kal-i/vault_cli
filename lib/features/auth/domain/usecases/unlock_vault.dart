import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entity/master_password_entity.dart';
import '../repository/auth_repository.dart';

class UnlockVault implements Usecase<void, MasterPasswordEntity> {
  const UnlockVault({required this.authRepository});

  final AuthRepository authRepository;

  @override
  Future<Either<Failure, dynamic>> call(MasterPasswordEntity params) async {
    return await authRepository.unlockVault(masterPassword: params);
  }
}
