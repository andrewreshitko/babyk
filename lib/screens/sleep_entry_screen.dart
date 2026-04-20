import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/baby.dart';
import '../models/log_entry.dart';
import '../store/baby_store.dart';
import '../widgets/segmented_control.dart';

enum _SleepMode { manual, timer }

class SleepEntryScreen extends StatefulWidget {
  final Baby baby;

  const SleepEntryScreen({super.key, required this.baby});

  @override
  State<SleepEntryScreen> createState() => _SleepEntryScreenState();
}

class _SleepEntryScreenState extends State<SleepEntryScreen> {
  _SleepMode _mode = _SleepMode.manual;
  DateTime _startTime = DateTime.now().subtract(const Duration(hours: 1));
  DateTime _endTime = DateTime.now();
  final _noteController = TextEditingController();

  // Timer mode
  late DateTime _timerStart;
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void dispose() {
    _ticker?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  void _onModeChanged(_SleepMode mode) {
    setState(() => _mode = mode);
    if (mode == _SleepMode.timer) {
      _timerStart = DateTime.now();
      _elapsed = Duration.zero;
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed = DateTime.now().difference(_timerStart));
      });
    } else {
      _ticker?.cancel();
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (picked == null) return;

    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    setState(() {
      if (isStart) {
        _startTime = dt;
        if (_endTime.isBefore(_startTime)) _endTime = _startTime.add(const Duration(hours: 1));
      } else {
        _endTime = dt;
      }
    });
  }

  void _saveManual() {
    context.read<BabyStore>().addEntry(LogEntry(
          id: const Uuid().v4(),
          babyId: widget.baby.id,
          timestamp: _startTime,
          entryType: EntryType.sleep,
          sleepStartTime: _startTime,
          sleepEndTime: _endTime,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        ));
    Navigator.pop(context);
  }

  void _stopTimer() {
    _ticker?.cancel();
    final end = DateTime.now();
    context.read<BabyStore>().addEntry(LogEntry(
          id: const Uuid().v4(),
          babyId: widget.baby.id,
          timestamp: _timerStart,
          entryType: EntryType.sleep,
          sleepStartTime: _timerStart,
          sleepEndTime: end,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        ));
    Navigator.pop(context);
  }

  String get _elapsedLabel {
    final h = _elapsed.inHours;
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sleep Log', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SegmentedControl<_SleepMode>(
                values: _SleepMode.values,
                selected: _mode,
                onChanged: _onModeChanged,
                label: (v) => v == _SleepMode.manual ? 'Manual' : 'Timer',
              ),
              const SizedBox(height: 20),

              if (_mode == _SleepMode.manual) ...[
                const Text('Start Time', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                const SizedBox(height: 6),
                _timeTile(DateFormat('h:mm a').format(_startTime), () => _pickTime(true)),

                const SizedBox(height: 16),
                const Text('End Time', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                const SizedBox(height: 6),
                _timeTile(DateFormat('h:mm a').format(_endTime), () => _pickTime(false)),

                const SizedBox(height: 16),
                const Text('Notes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                const SizedBox(height: 6),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Extra details...',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 28),
                _primaryButton('Save Sleep Log', _saveManual),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('Active Sleep Timer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                      const SizedBox(height: 12),
                      Text(
                        _elapsedLabel,
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontFeatures: [FontFeature.tabularFigures()]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Started at ${DateFormat('h:mm a').format(_timerStart)}',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Notes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                const SizedBox(height: 6),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Extra details...',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _stopTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Stop & Save', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeTile(String value, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(value, style: const TextStyle(fontSize: 18, color: Color(0xFF1E293B))),
              const Spacer(),
              const Icon(Icons.access_time, size: 18, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      );

  Widget _primaryButton(String label, VoidCallback onPressed) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ),
      );
}
