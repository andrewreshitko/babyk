import 'package:drift/drift.dart';

import 'app_database.dart';
import 'tables.dart';

part 'feeding_dao.g.dart';

@DriftAccessor(tables: [FeedingEvents])
class FeedingDao extends DatabaseAccessor<AppDatabase> with _$FeedingDaoMixin {
  FeedingDao(super.db);

  Future<void> insertEvent(FeedingEventsCompanion event) =>
      into(feedingEvents).insert(event);

  Future<bool> updateEvent(FeedingEvent event) =>
      update(feedingEvents).replace(event);

  Future<int> deleteEvent(String id) =>
      (delete(feedingEvents)..where((t) => t.id.equals(id))).go();

  Future<List<FeedingEvent>> getByChildAndDateRange(
    String childId,
    DateTime start,
    DateTime end,
  ) =>
      (select(feedingEvents)
            ..where(
              (t) =>
                  t.childId.equals(childId) &
                  t.startTime.isBiggerOrEqualValue(start) &
                  t.startTime.isSmallerThanValue(end),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
          .get();

  /// Returns total bottle/breast ml for a child on a given calendar day.
  /// NULL amountMl (e.g. breast-only sessions) is treated as 0.
  Future<int> dailyTotalAmount(String childId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final amountSum = feedingEvents.amountMl.sum();

    final query = selectOnly(feedingEvents)
      ..addColumns([amountSum])
      ..where(
        feedingEvents.childId.equals(childId) &
            feedingEvents.startTime.isBiggerOrEqualValue(start) &
            feedingEvents.startTime.isSmallerThanValue(end),
      );

    final row = await query.getSingleOrNull();
    return row?.read(amountSum) ?? 0;
  }
}
