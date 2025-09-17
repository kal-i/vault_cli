import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/vault_entry_entity.dart';
import '../repository/vault_repository.dart';

/// Use case for getting an entry by [id].
class GetVaultEntryById implements Usecase<VaultEntryEntity?, String> {
  const GetVaultEntryById({required this.vaultRepository});

  final VaultRepository vaultRepository;

  @override
  Future<Either<Failure, VaultEntryEntity?>> call(String params) {
    return vaultRepository.getEntryById(id: params);
  }
}