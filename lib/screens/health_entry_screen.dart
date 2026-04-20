import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/baby.dart';
import '../models/log_entry.dart';
import '../store/baby_store.dart';
import '../widgets/segmented_control.dart';

enum _HealthMode { medical, growth }

class HealthEntryScreen extends StatefulWidget {
  final Baby baby;

  const HealthEntryScreen({super.key, required this.baby});

  @override
  State<HealthEntryScreen> createState() => _HealthEntryScreenState();
}

class _HealthEntryScreenState extends State<HealthEntryScreen> {
  _HealthMode _mode = _HealthMode.medical;
  MedicalType _medicalType = MedicalType.question;
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final isGrowth = _mode == _HealthMode.growth;
    context.read<BabyStore>().addEntry(LogEntry(
          id: const Uuid().v4(),
          babyId: widget.baby.id,
          timestamp: DateTime.now(),
          entryType: isGrowth ? EntryType.growth : EntryType.health,
          weightGrams: isGrowth ? double.tryParse(_weightController.text) : null,
          heightCm: isGrowth ? double.tryParse(_heightController.text) : null,
          medicalType: !isGrowth ? _medicalType : null,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isGrowth = _mode == _HealthMode.growth;

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
                  Text(
                    isGrowth ? 'Growth Log' : 'Health Log',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SegmentedControl<_HealthMode>(
                values: _HealthMode.values,
                selected: _mode,
                onChanged: (v) => setState(() => _mode = v),
                label: (v) => v == _HealthMode.medical ? 'Medical' : 'Growth',
              ),
              const SizedBox(height: 20),

              if (isGrowth) ...[
                _label('Weight (g)'),
                const SizedBox(height: 6),
                _numberField(_weightController, '0'),
                const SizedBox(height: 16),
                _label('Height (cm)'),
                const SizedBox(height: 6),
                _numberField(_heightController, '0'),
              ] else ...[
                _label('Category'),
                const SizedBox(height: 6),
                SegmentedControl<MedicalType>(
                  values: MedicalType.values,
                  selected: _medicalType,
                  onChanged: (v) => setState(() => _medicalType = v),
                  label: (v) => v.name[0].toUpperCase() + v.name.substring(1),
                ),
              ],

              const SizedBox(height: 16),
              _label(isGrowth ? 'Notes' : 'Details'),
              const SizedBox(height: 6),
              TextField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: isGrowth ? 'Extra details...' : 'Describe the symptom, question, or vaccination...',
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
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Save ${isGrowth ? 'Growth' : 'Health'} Entry',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
      );

  Widget _numberField(TextEditingController ctrl, String hint) => TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      );
}
