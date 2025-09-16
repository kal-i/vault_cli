import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/vault_entry_entity.dart';

/// Defines an abstract interface contract for managing vault entries.
abstract interface class VaultRepository {
  Future<Either<Failure, VaultEntryEntity>> addEntry(VaultEntryEntity entry);
  Future<Either<Failure, List<VaultEntryEntity>>> getAllEntries();
  Future<Either<Failure, VaultEntryEntity?>> getEntryById(String id);
  Future<Either<Failure, List<VaultEntryEntity>>> getEntryByTitle(String title);
  Future<Either<Failure, VaultEntryEntity>> updateEntry(VaultEntryEntity entry);
  Future<Either<Failure, bool>> deleteEntry(String id);
}