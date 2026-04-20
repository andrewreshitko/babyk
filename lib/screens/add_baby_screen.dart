import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/baby.dart';
import '../store/baby_store.dart';

class AddBabyScreen extends StatefulWidget {
  final void Function(Baby baby)? onAdded;

  const AddBabyScreen({super.key, this.onAdded});

  @override
  State<AddBabyScreen> createState() => _AddBabyScreenState();
}

class _AddBabyScreenState extends State<AddBabyScreen> {
  final _nameController = TextEditingController();
  DateTime _birthDate = DateTime.now();
  String _gender = 'Unknown';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final baby = Baby(
      id: const Uuid().v4(),
      name: name,
      birthDate: _birthDate,
      gender: _gender,
    );
    context.read<BabyStore>().addBaby(baby);
    widget.onAdded?.call(baby);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _nameController.text.trim().isNotEmpty;

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
                  const Text('Add Baby', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              _label('Name'),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration("Baby's name"),
                onChanged: (_) => setState(() {}),
                autofocus: true,
              ),

              const SizedBox(height: 16),
              _label('Birth Date'),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('MMMM d, yyyy').format(_birthDate),
                        style: const TextStyle(fontSize: 16, color: Color(0xFF1E293B)),
                      ),
                      const Spacer(),
                      const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              _label('Gender'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: ['Boy', 'Girl', 'Other', 'Unknown'].map((g) {
                  final isSelected = _gender == g;
                  return ChoiceChip(
                    label: Text(g),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _gender = g),
                    selectedColor: const Color(0xFF3B82F6),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canSave ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    disabledBackgroundColor: const Color(0xFF94A3B8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add Baby', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      );
}
