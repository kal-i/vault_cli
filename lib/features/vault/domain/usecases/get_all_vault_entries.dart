import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/no_params.dart';
import '../../../../core/usecase/usecase.dart';
import '../entity/vault_entry_entity.dart';
import '../repository/vault_repository.dart';

/// Use case for getting all vault entries.
class GetAllVaultEntries implements Usecase<List<VaultEntryEntity>, NoParams> {
  const GetAllVaultEntries({required this.vaultRepository});

  final VaultRepository vaultRepository;

  @override
  Future<Either<Failure, List<VaultEntryEntity>>> call(NoParams params) {
    return vaultRepository.getAllEntries();
  }
}