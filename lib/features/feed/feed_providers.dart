import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/app_database.dart';
import '../../database/feeding_dao.dart';

/// Must be overridden in the root ProviderScope before first use.
///
/// Example in main.dart:
///   runApp(ProviderScope(
///     overrides: [appDatabaseProvider.overrideWithValue(AppDatabase())],
///     child: const MyApp(),
///   ));
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden in ProviderScope');
});

final feedingDaoProvider = Provider<FeedingDao>((ref) {
  return ref.watch(appDatabaseProvider).feedingDao;
});
