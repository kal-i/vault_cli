import 'package:drift/drift.dart';

@TableIndex(name: 'title', columns: {#title})
class VaultEntries extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get contactNo => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get username => text().nullable()();
  TextColumn get password => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}