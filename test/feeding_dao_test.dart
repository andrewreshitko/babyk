import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;
import 'package:babytrack/database/app_database.dart';
import 'package:babytrack/database/tables.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('dailyTotalAmount sums only bottle events for the given day', () async {
    final dao = db.feedingDao;
    final childId = 'child-1';
    final today = DateTime(2026, 4, 20, 8, 0);

    // Two bottle feeds on the same day
    await dao.insertEvent(FeedingEventsCompanion(
      id: const Value('evt-1'),
      childId: Value(childId),
      type: const Value('bottle'),
      amountMl: const Value(120),
      startTime: Value(today),
      createdAt: Value(today),
    ));

    await dao.insertEvent(FeedingEventsCompanion(
      id: const Value('evt-2'),
      childId: Value(childId),
      type: const Value('bottle'),
      amountMl: const Value(80),
      startTime: Value(today.add(const Duration(hours: 3))),
      createdAt: Value(today),
    ));

    // Breast feed with no amountMl — should contribute 0
    await dao.insertEvent(FeedingEventsCompanion(
      id: const Value('evt-3'),
      childId: Value(childId),
      type: const Value('breast'),
      startTime: Value(today.add(const Duration(hours: 6))),
      createdAt: Value(today),
    ));

    // Different child — must not be included
    await dao.insertEvent(FeedingEventsCompanion(
      id: const Value('evt-4'),
      childId: const Value('child-2'),
      type: const Value('bottle'),
      amountMl: const Value(200),
      startTime: Value(today),
      createdAt: Value(today),
    ));

    final total = await dao.dailyTotalAmount(childId, today);

    expect(total, 200); // 120 + 80 + 0 (breast) — child-2 excluded
  });
}
