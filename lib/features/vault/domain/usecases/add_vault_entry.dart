import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/vault_entry_entity.dart';
import '../repository/vault_repository.dart';

/// Use case for adding a new vault entry.
class AddVaultEntry implements Usecase<VaultEntryEntity, VaultEntryEntity> {
  const AddVaultEntry({required this.vaultRepository});

  final VaultRepository vaultRepository;

  @override
  Future<Either<Failure, VaultEntryEntity>> call(
    VaultEntryEntity params,
  ) {
    return vaultRepository.addEntry(entry:  params);
  }
}
