import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/baby.dart';
import '../models/log_entry.dart';
import '../store/baby_store.dart';
import '../widgets/segmented_control.dart';

class DiaperEntryScreen extends StatefulWidget {
  final Baby baby;

  const DiaperEntryScreen({super.key, required this.baby});

  @override
  State<DiaperEntryScreen> createState() => _DiaperEntryScreenState();
}

class _DiaperEntryScreenState extends State<DiaperEntryScreen> {
  DiaperType _type = DiaperType.wet;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    context.read<BabyStore>().addEntry(LogEntry(
          id: const Uuid().v4(),
          babyId: widget.baby.id,
          timestamp: DateTime.now(),
          entryType: EntryType.diaper,
          diaperType: _type,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('New Diaper', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text('Type', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              SegmentedControl<DiaperType>(
                values: DiaperType.values,
                selected: _type,
                onChanged: (v) => setState(() => _type = v),
                label: (v) => v.name[0].toUpperCase() + v.name.substring(1),
              ),

              const SizedBox(height: 16),
              const Text('Notes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              TextField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Extra details (color, consistency...)',
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
                  child: const Text('Save Diaper Change', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
