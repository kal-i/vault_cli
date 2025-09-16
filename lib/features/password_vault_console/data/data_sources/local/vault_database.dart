import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/vault_entries.dart';

part 'vault_database.g.dart';

@DriftDatabase(tables: [VaultEntries])
class VaultDatabase extends _$VaultDatabase {
  /// Private constructor to enforce factory use
  VaultDatabase._internal(super.e);

  /// Factory constructor that initializes a persistent SQLite file
  static Future<VaultDatabase> create() async {
    // Get platform-specific app data folder
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'vault.sqlite'));

    // Create the database file
    return VaultDatabase._internal(NativeDatabase(file));
  }

  @override
  int get schemaVersion => 1;
}