import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/vault_repository.dart';

/// Use case for deleting an entry by [id].
class DeleteVaultEntry implements Usecase<bool, String> {
  const DeleteVaultEntry({required this.vaultRepository});

  final VaultRepository vaultRepository;

  @override
  Future<Either<Failure, bool>> call(String params) {
    return vaultRepository.deleteEntry(params);
  }
}
