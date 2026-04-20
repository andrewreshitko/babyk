import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:babytrack/database/app_database.dart';
import 'package:babytrack/features/feed/feed_entry_form.dart';
import 'package:babytrack/features/feed/feed_providers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  // Push FeedEntryForm on top of a base route so Navigator.maybePop() works.
  Widget buildSubject() {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: Builder(
          builder: (ctx) => TextButton(
            onPressed: () => Navigator.of(ctx).push(
              MaterialPageRoute<void>(
                builder: (_) => const FeedEntryForm(childId: 'child-1'),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
  }

  Future<void> openForm(WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('Save inserts a bottle FeedingEvent into the DAO', (tester) async {
    await openForm(tester);

    // Switch to Bottle
    await tester.tap(find.text('Bottle'));
    await tester.pumpAndSettle();

    // Enter amount
    await tester.enterText(find.byType(TextFormField).first, '120');

    // Tap Save (no timer started — startTime defaults to now)
    await tester.tap(find.byKey(const Key('saveButton')));
    await tester.pumpAndSettle();

    // Snackbar should be visible
    expect(find.text('Feeding saved'), findsOneWidget);

    // Record must be in the DB
    final events = await db.feedingDao.getByChildAndDateRange(
      'child-1',
      DateTime(2000),
      DateTime(2100),
    );

    expect(events, hasLength(1));
    expect(events.first.type, 'bottle');
    expect(events.first.amountMl, 120);
    expect(events.first.childId, 'child-1');
  });

  testWidgets('Save is blocked when bottle amount is empty', (tester) async {
    await openForm(tester);

    await tester.tap(find.text('Bottle'));
    await tester.pumpAndSettle();

    // Do NOT enter amount — tap Save
    await tester.tap(find.byKey(const Key('saveButton')));
    await tester.pumpAndSettle();

    // Validation error shown, nothing saved
    expect(find.text('Enter amount in ml'), findsOneWidget);

    final events = await db.feedingDao.getByChildAndDateRange(
      'child-1',
      DateTime(2000),
      DateTime(2100),
    );
    expect(events, isEmpty);
  });

  testWidgets('Save breast feed without amount succeeds', (tester) async {
    await openForm(tester);

    // Breast is the default — go straight to Save
    await tester.tap(find.byKey(const Key('saveButton')));
    await tester.pumpAndSettle();

    expect(find.text('Feeding saved'), findsOneWidget);

    final events = await db.feedingDao.getByChildAndDateRange(
      'child-1',
      DateTime(2000),
      DateTime(2100),
    );

    expect(events, hasLength(1));
    expect(events.first.type, 'breast');
    expect(events.first.amountMl, isNull);
  });
}
