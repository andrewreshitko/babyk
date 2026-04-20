import 'package:drift/drift.dart';

/// Drift table for feeding events.
/// Run `dart run build_runner build` to regenerate app_database.g.dart.
class FeedingEvents extends Table {
  // UUID primary key — no auto-increment
  TextColumn get id => text()();
  TextColumn get childId => text()();

  // Constrained to 'breast' | 'bottle' at the application layer
  TextColumn get type => text()();

  IntColumn get amountMl => integer().nullable()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
