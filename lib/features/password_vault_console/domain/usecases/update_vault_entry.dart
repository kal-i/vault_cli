import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/vault_entry_entity.dart';
import '../repository/vault_repository.dart';

/// Use case for updating an entry.
class UpdateVaultEntry implements Usecase<VaultEntryEntity, VaultEntryEntity> {
  const UpdateVaultEntry({required this.vaultRepository});

  final VaultRepository vaultRepository;

  @override
  Future<Either<Failure, VaultEntryEntity>> call(VaultEntryEntity params) {
    return vaultRepository.updateEntry(params);
  }
}