import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/no_params.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class RetrieveRecoveryQuestion implements Usecase<String, NoParams> {
  const RetrieveRecoveryQuestion({required this.authRepository});

  final AuthRepository authRepository;

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await authRepository.retrieveRecoveryQuestion();
  }
}
