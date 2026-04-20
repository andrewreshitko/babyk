import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/baby.dart';
import '../models/log_entry.dart';

class BabyStore extends ChangeNotifier {
  List<Baby> _babies = [];
  List<LogEntry> _entries = [];

  List<Baby> get babies => List.unmodifiable(_babies);
  List<LogEntry> get entries => List.unmodifiable(_entries);

  List<LogEntry> entriesForBaby(String babyId) =>
      _entries.where((e) => e.babyId == babyId).toList();

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final babiesJson = prefs.getString('babies');
      final entriesJson = prefs.getString('entries');

      if (babiesJson != null) {
        final list = jsonDecode(babiesJson) as List<dynamic>;
        _babies = list.map((e) => Baby.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (entriesJson != null) {
        final list = jsonDecode(entriesJson) as List<dynamic>;
        _entries = list.map((e) => LogEntry.fromJson(e as Map<String, dynamic>)).toList();
      }
      notifyListeners();
    } catch (_) {
      // Storage errors are non-fatal; app starts with empty state
    }
  }

  Future<void> addBaby(Baby baby) async {
    _babies = [..._babies, baby];
    notifyListeners();
    await _persist();
  }

  Future<void> addEntry(LogEntry entry) async {
    _entries = [entry, ..._entries];
    notifyListeners();
    await _persist();
  }

  Future<void> deleteEntry(String id) async {
    _entries = _entries.where((e) => e.id != id).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('babies', jsonEncode(_babies.map((b) => b.toJson()).toList()));
      await prefs.setString('entries', jsonEncode(_entries.map((e) => e.toJson()).toList()));
    } catch (_) {
      // Persist failures are silent; data will be saved on next successful write
    }
  }
}
