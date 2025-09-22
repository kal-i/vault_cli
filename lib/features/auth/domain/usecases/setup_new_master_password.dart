import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class SetupNewMasterPassword
    implements Usecase<dynamic, SetupNewMasterPasswordParams> {
  const SetupNewMasterPassword({required this.authRepository});

  final AuthRepository authRepository;

  @override
  Future<Either<Failure, dynamic>> call(
    SetupNewMasterPasswordParams params,
  ) async {
    return await authRepository.setupNewMasterPassword(
      newMasterPassword: params.newMasterPassword,
      newRecoveryQuestion: params.newRecoveryQuestion,
      newRecoveryAnswer: params.newRecoveryAnswer,
    );
  }
}

class SetupNewMasterPasswordParams {
  const SetupNewMasterPasswordParams({
    required this.newMasterPassword,
    this.newRecoveryQuestion,
    this.newRecoveryAnswer,
  });

  final String newMasterPassword;
  final String? newRecoveryQuestion;
  final String? newRecoveryAnswer;
}
