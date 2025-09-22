import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class UnlockVault implements Usecase<void, String> {
  const UnlockVault({required this.authRepository});

  final AuthRepository authRepository;

  @override
  Future<Either<Failure, dynamic>> call(String params) async {
    return await authRepository.unlockVault(masterPassword: params);
  }
}
