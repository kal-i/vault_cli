import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entity/vault_entry_entity.dart';
import '../repository/vault_repository.dart';

/// Use case for getting vault entries by [title].
class GetVaultEntriesByTitle implements Usecase<List<VaultEntryEntity>, String> {
  const GetVaultEntriesByTitle({required this.vaultRepository});

  final VaultRepository vaultRepository;

  @override
  Future<Either<Failure, List<VaultEntryEntity>>> call(String params) {
    return vaultRepository.getEntryByTitle(title: params);
  }
}