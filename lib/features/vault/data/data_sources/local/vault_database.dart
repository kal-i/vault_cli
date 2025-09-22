import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/vault_entries.dart';

part 'vault_database.g.dart';

@DriftDatabase(tables: [VaultEntries])
class VaultDatabase extends _$VaultDatabase {
  VaultDatabase._internal(super.e);

  static Future<VaultDatabase> create() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'vault.sqlite'));

    return VaultDatabase._internal(NativeDatabase(file));
  }

  @override
  int get schemaVersion => 1;
}