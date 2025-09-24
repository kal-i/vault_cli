import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/no_params.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class ResetVault implements Usecase<bool, NoParams> {
  const ResetVault({required this.authRepository});

  final AuthRepository authRepository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await authRepository.resetVault();
  }
}
