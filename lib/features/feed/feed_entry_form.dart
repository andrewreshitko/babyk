import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart'; // exposes FeedingEventsCompanion via .g.dart part
import 'feed_providers.dart';

enum FeedType { breast, bottle }

class FeedEntryForm extends ConsumerStatefulWidget {
  const FeedEntryForm({super.key, required this.childId});

  final String childId;

  @override
  ConsumerState<FeedEntryForm> createState() => _FeedEntryFormState();
}

class _FeedEntryFormState extends ConsumerState<FeedEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  FeedType _feedType = FeedType.breast;
  DateTime? _startTime;
  DateTime? _endTime;
  bool _timerRunning = false;
  Duration _elapsed = Duration.zero;
  Timer? _ticker;

  // Accumulated elapsed before the most recent Start press (supports stop/resume)
  Duration _elapsedBase = Duration.zero;

  @override
  void dispose() {
    _ticker?.cancel();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      if (_timerRunning) {
        _ticker?.cancel();
        _timerRunning = false;
        _endTime = DateTime.now();
        _elapsedBase = _elapsed;
      } else {
        final resumeAt = DateTime.now();
        _startTime ??= resumeAt;
        _timerRunning = true;
        _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() {
            _elapsed = _elapsedBase + DateTime.now().difference(resumeAt);
          });
        });
      }
    });
  }

  String get _elapsedLabel {
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();

    if (_timerRunning) {
      _ticker?.cancel();
      _timerRunning = false;
      _endTime = now;
    }

    final companion = FeedingEventsCompanion(
      id: Value(const Uuid().v4()),
      childId: Value(widget.childId),
      type: Value(_feedType.name), // 'breast' | 'bottle'
      amountMl: _feedType == FeedType.bottle
          ? Value(int.parse(_amountController.text))
          : const Value.absent(),
      startTime: Value(_startTime ?? now),
      endTime: _endTime != null ? Value(_endTime!) : const Value.absent(),
      notes: _notesController.text.trim().isNotEmpty
          ? Value(_notesController.text.trim())
          : const Value.absent(),
      createdAt: Value(now),
    );

    await ref.read(feedingDaoProvider).insertEvent(companion);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feeding saved')),
      );
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBottle = _feedType == FeedType.bottle;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Log Feeding')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Type toggle ──────────────────────────────────────────────
            SegmentedButton<FeedType>(
              segments: const [
                ButtonSegment(
                  value: FeedType.breast,
                  icon: Icon(Icons.child_care),
                  label: Text('Breast'),
                ),
                ButtonSegment(
                  value: FeedType.bottle,
                  icon: Icon(Icons.local_drink),
                  label: Text('Bottle'),
                ),
              ],
              selected: {_feedType},
              onSelectionChanged: (selection) => setState(() {
                _feedType = selection.first;
                // Clear stale amount when switching away from bottle
                if (_feedType == FeedType.breast) _amountController.clear();
              }),
            ),
            const SizedBox(height: 20),

            // ── Amount (bottle only) ─────────────────────────────────────
            // AnimatedCrossFade keeps both children mounted so the validator
            // can run; it returns null when breast is selected.
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: isBottle
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  suffixText: 'ml',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (!isBottle) return null;
                  if (v == null || v.isEmpty) return 'Enter amount in ml';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Must be greater than 0';
                  return null;
                },
              ),
              secondChild: const SizedBox(height: 0),
            ),
            if (isBottle) const SizedBox(height: 20),

            // ── Timer ────────────────────────────────────────────────────
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      _elapsedLabel,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: _timerRunning
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      key: const Key('timerButton'),
                      onPressed: _toggleTimer,
                      icon: Icon(_timerRunning ? Icons.stop : Icons.play_arrow),
                      label: Text(_timerRunning ? 'Stop' : 'Start'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _timerRunning
                            ? colorScheme.error
                            : colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Notes ────────────────────────────────────────────────────
            TextFormField(
              key: const Key('notesField'),
              controller: _notesController,
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),

            // ── Actions ──────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('cancelButton'),
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const Key('saveButton'),
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
