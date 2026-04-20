import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/baby.dart';
import '../models/log_entry.dart';
import '../store/baby_store.dart';
import '../widgets/segmented_control.dart';

class FeedingEntryScreen extends StatefulWidget {
  final Baby baby;

  const FeedingEntryScreen({super.key, required this.baby});

  @override
  State<FeedingEntryScreen> createState() => _FeedingEntryScreenState();
}

class _FeedingEntryScreenState extends State<FeedingEntryScreen> {
  FeedingMethod _method = FeedingMethod.breast;
  FeedingSide _side = FeedingSide.left;
  final _amountController = TextEditingController();
  final _durationController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _durationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    context.read<BabyStore>().addEntry(LogEntry(
          id: const Uuid().v4(),
          babyId: widget.baby.id,
          timestamp: DateTime.now(),
          entryType: EntryType.feeding,
          feedingMethod: _method,
          feedingSide: _method == FeedingMethod.breast ? _side : null,
          feedingAmount: _method == FeedingMethod.bottle
              ? double.tryParse(_amountController.text)
              : null,
          feedingDurationSeconds: _method == FeedingMethod.breast
              ? ((double.tryParse(_durationController.text) ?? 0) * 60).round()
              : null,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        ));
    Navigator.pop(context);
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
              _header('New Feeding'),
              const SizedBox(height: 16),

              _label('Method'),
              const SizedBox(height: 6),
              SegmentedControl<FeedingMethod>(
                values: FeedingMethod.values,
                selected: _method,
                onChanged: (v) => setState(() => _method = v),
                label: (v) => v.name[0].toUpperCase() + v.name.substring(1),
              ),

              if (_method == FeedingMethod.breast) ...[
                const SizedBox(height: 16),
                _label('Side'),
                const SizedBox(height: 6),
                SegmentedControl<FeedingSide>(
                  values: FeedingSide.values,
                  selected: _side,
                  onChanged: (v) => setState(() => _side = v),
                  label: (v) => v.name[0].toUpperCase() + v.name.substring(1),
                ),
                const SizedBox(height: 16),
                _label('Duration (mins)'),
                const SizedBox(height: 6),
                _textField(_durationController, '0', isNumber: true),
              ],

              if (_method == FeedingMethod.bottle) ...[
                const SizedBox(height: 16),
                _label('Amount (ml)'),
                const SizedBox(height: 6),
                _textField(_amountController, '0', isNumber: true),
              ],

              const SizedBox(height: 16),
              _label('Notes'),
              const SizedBox(height: 6),
              _textField(_noteController, 'Extra details...', multiline: true),

              const SizedBox(height: 28),
              _saveButton('Save Feeding', _save),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(String title) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
          ),
        ],
      );

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
      );

  Widget _textField(TextEditingController ctrl, String hint,
      {bool isNumber = false, bool multiline = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      maxLines: multiline ? 4 : 1,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _saveButton(String label, VoidCallback onPressed) => SizedBox(
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
