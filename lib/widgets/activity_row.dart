import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/log_entry.dart';

class ActivityRow extends StatelessWidget {
  final LogEntry entry;
  final VoidCallback? onDelete;

  const ActivityRow({super.key, required this.entry, this.onDelete});

  IconData get _icon {
    switch (entry.entryType) {
      case EntryType.feeding:
        return Icons.water_drop_outlined;
      case EntryType.diaper:
        return Icons.change_circle_outlined;
      case EntryType.sleep:
        return Icons.bedtime_outlined;
      case EntryType.health:
        return Icons.favorite_outline;
      case EntryType.growth:
        return Icons.show_chart;
    }
  }

  String get _title {
    switch (entry.entryType) {
      case EntryType.feeding:
        return 'Feeding';
      case EntryType.diaper:
        return 'Diaper Change';
      case EntryType.sleep:
        return 'Sleep';
      case EntryType.health:
        return 'Health';
      case EntryType.growth:
        return 'Growth';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade100,
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(_icon, size: 20, color: const Color(0xFF666666)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (entry.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.subtitle,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                  if (entry.note != null && entry.note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.note!,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              DateFormat('h:mm a').format(entry.timestamp),
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}
