import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'store/baby_store.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = BabyStore();
  await store.load();

  runApp(
    ChangeNotifierProvider.value(
      value: store,
      child: const BabyTrackApp(),
    ),
  );
}

class BabyTrackApp extends StatelessWidget {
  const BabyTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BabyTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6)),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: const DashboardScreen(),
    );
  }
}
