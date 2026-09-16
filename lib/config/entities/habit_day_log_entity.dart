import 'package:floww/config/utils/dates/app_date_utils.dart';

class HabitLogEntry {
  const HabitLogEntry({
    required this.id,
    required this.title,
    required this.value,
    required this.target,
  });

  factory HabitLogEntry.fromJson(Map<String, dynamic> json) => HabitLogEntry(
    id: json['id'] as String,
    title: json['title'] as String,
    value: (json['value'] as num).toDouble(),
    target: (json['target'] as num).toDouble(),
  );

  final String id;
  final String title;
  final double value;
  final double target;

  bool get isCompleted => target > 0 && value >= target;

  double get progress => target <= 0 ? 0 : (value / target).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'value': value,
    'target': target,
  };
}

class HabitDayLog {
  const HabitDayLog({required this.date, required this.entries});

  factory HabitDayLog.fromJson(Map<String, dynamic> json) => HabitDayLog(
    date: DateTime.parse(json['date'] as String),
    entries: [
      for (final entry in (json['entries'] as List? ?? const []))
        HabitLogEntry.fromJson(Map<String, dynamic>.from(entry as Map)),
    ],
  );

  final DateTime date;
  final List<HabitLogEntry> entries;

  double get completion {
    if (entries.isEmpty) return 0;
    final total = entries.fold<double>(0, (sum, e) => sum + e.progress);
    return total / entries.length;
  }

  Map<String, dynamic> toJson() => {
    'date': AppDateUtils.dateKey(date),
    'entries': [for (final entry in entries) entry.toJson()],
    'completion': completion,
    'updatedAt': AppDateUtils.isoKey(DateTime.now()),
  };
}
