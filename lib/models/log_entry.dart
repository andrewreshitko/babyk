enum EntryType { feeding, diaper, sleep, health, growth }

enum FeedingMethod { breast, bottle, solid }

enum FeedingSide { left, right, both }

enum DiaperType { wet, dirty, both, dry }

enum MedicalType { question, symptom, vaccination }

class LogEntry {
  final String id;
  final String babyId;
  final DateTime timestamp;
  final EntryType entryType;
  final String? note;

  // Feeding
  final FeedingMethod? feedingMethod;
  final FeedingSide? feedingSide;
  final double? feedingAmount;
  final int? feedingDurationSeconds;

  // Diaper
  final DiaperType? diaperType;

  // Sleep
  final DateTime? sleepStartTime;
  final DateTime? sleepEndTime;

  // Growth
  final double? weightGrams;
  final double? heightCm;

  // Health
  final MedicalType? medicalType;
  final bool? isResolved;

  const LogEntry({
    required this.id,
    required this.babyId,
    required this.timestamp,
    required this.entryType,
    this.note,
    this.feedingMethod,
    this.feedingSide,
    this.feedingAmount,
    this.feedingDurationSeconds,
    this.diaperType,
    this.sleepStartTime,
    this.sleepEndTime,
    this.weightGrams,
    this.heightCm,
    this.medicalType,
    this.isResolved,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'babyId': babyId,
        'timestamp': timestamp.toIso8601String(),
        'entryType': entryType.name,
        if (note != null) 'note': note,
        if (feedingMethod != null) 'feedingMethod': feedingMethod!.name,
        if (feedingSide != null) 'feedingSide': feedingSide!.name,
        if (feedingAmount != null) 'feedingAmount': feedingAmount,
        if (feedingDurationSeconds != null) 'feedingDurationSeconds': feedingDurationSeconds,
        if (diaperType != null) 'diaperType': diaperType!.name,
        if (sleepStartTime != null) 'sleepStartTime': sleepStartTime!.toIso8601String(),
        if (sleepEndTime != null) 'sleepEndTime': sleepEndTime!.toIso8601String(),
        if (weightGrams != null) 'weightGrams': weightGrams,
        if (heightCm != null) 'heightCm': heightCm,
        if (medicalType != null) 'medicalType': medicalType!.name,
        if (isResolved != null) 'isResolved': isResolved,
      };

  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
        id: json['id'] as String,
        babyId: json['babyId'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        entryType: EntryType.values.byName(json['entryType'] as String),
        note: json['note'] as String?,
        feedingMethod: json['feedingMethod'] != null
            ? FeedingMethod.values.byName(json['feedingMethod'] as String)
            : null,
        feedingSide: json['feedingSide'] != null
            ? FeedingSide.values.byName(json['feedingSide'] as String)
            : null,
        feedingAmount: (json['feedingAmount'] as num?)?.toDouble(),
        feedingDurationSeconds: json['feedingDurationSeconds'] as int?,
        diaperType: json['diaperType'] != null
            ? DiaperType.values.byName(json['diaperType'] as String)
            : null,
        sleepStartTime: json['sleepStartTime'] != null
            ? DateTime.parse(json['sleepStartTime'] as String)
            : null,
        sleepEndTime: json['sleepEndTime'] != null
            ? DateTime.parse(json['sleepEndTime'] as String)
            : null,
        weightGrams: (json['weightGrams'] as num?)?.toDouble(),
        heightCm: (json['heightCm'] as num?)?.toDouble(),
        medicalType: json['medicalType'] != null
            ? MedicalType.values.byName(json['medicalType'] as String)
            : null,
        isResolved: json['isResolved'] as bool?,
      );

  String get subtitle {
    switch (entryType) {
      case EntryType.feeding:
        final method = feedingMethod?.name ?? '';
        if (feedingMethod == FeedingMethod.breast) {
          final side = feedingSide?.name ?? '';
          final mins = feedingDurationSeconds != null ? ' · ${feedingDurationSeconds! ~/ 60}m' : '';
          return 'Breast · ${_capitalize(side)}$mins';
        }
        if (feedingMethod == FeedingMethod.bottle) {
          return 'Bottle · ${feedingAmount?.toStringAsFixed(0) ?? '?'} ml';
        }
        return _capitalize(method);
      case EntryType.diaper:
        return _capitalize(diaperType?.name ?? '');
      case EntryType.sleep:
        if (sleepStartTime != null && sleepEndTime != null) {
          final dur = sleepEndTime!.difference(sleepStartTime!);
          return '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';
        }
        return '';
      case EntryType.health:
        return _capitalize(medicalType?.name ?? '');
      case EntryType.growth:
        final parts = <String>[];
        if (weightGrams != null) parts.add('${weightGrams!.toStringAsFixed(0)} g');
        if (heightCm != null) parts.add('${heightCm!.toStringAsFixed(1)} cm');
        return parts.join(' · ');
    }
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
