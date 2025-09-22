import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entity/vault_entry_entity.dart';

/// Defines an abstract interface contract for managing vault entries.
abstract interface class VaultRepository {
  Future<Either<Failure, VaultEntryEntity>> addEntry({
    required VaultEntryEntity entry,
  });
  Future<Either<Failure, List<VaultEntryEntity>>> getAllEntries();
  Future<Either<Failure, VaultEntryEntity?>> getEntryById({required String id});
  Future<Either<Failure, List<VaultEntryEntity>>> getEntryByTitle({
    required String title,
  });
  Future<Either<Failure, VaultEntryEntity>> updateEntry({
    required VaultEntryEntity entry,
  });
  Future<Either<Failure, bool>> deleteEntry({required String id});
}
