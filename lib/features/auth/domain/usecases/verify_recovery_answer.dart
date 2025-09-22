import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class VerifyRecoveryAnswer implements Usecase<bool, String> {
  const VerifyRecoveryAnswer({required this.authRepository});

  final AuthRepository authRepository;

  @override
  Future<Either<Failure, bool>> call(String params) async {
    return await authRepository.verifyRecoveryAnswer(recoveryAnswer: params);
  }
}
