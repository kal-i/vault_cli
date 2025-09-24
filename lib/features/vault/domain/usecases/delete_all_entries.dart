import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/no_params.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/vault_repository.dart';

class DeleteAllEntries implements Usecase<void, NoParams> {
  const DeleteAllEntries({required this.vaultRepository});

  final VaultRepository vaultRepository;

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await vaultRepository.deleteAllEntries();
  }
}