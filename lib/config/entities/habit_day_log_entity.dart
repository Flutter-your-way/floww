import 'package:floww/config/utils/dates/app_date_utils.dart';

class HabitGoalMath {
  HabitGoalMath._();

  static const String build = 'build';
  static const String limit = 'limit';

  static bool isCompleted(
    double value,
    double target, {
    required bool isLimit,
  }) {
    if (isLimit) return value <= target;
    return target > 0 && value >= target;
  }

  static double progress(double value, double target, {required bool isLimit}) {
    if (isLimit) {
      if (value <= target) return 1;
      if (target <= 0) return 0;
      return (1 - (value - target) / target).clamp(0.0, 1.0);
    }
    return target <= 0 ? 0 : (value / target).clamp(0.0, 1.0);
  }
}

class HabitLogEntry {
  const HabitLogEntry({
    required this.id,
    required this.title,
    required this.value,
    required this.target,
    this.metric = defaultMetric,
    this.goal = HabitGoalMath.build,
    this.due = true,
  });

  factory HabitLogEntry.fromJson(Map<String, dynamic> json) => HabitLogEntry(
    id: json['id'] as String,
    title: json['title'] as String,
    value: (json['value'] as num).toDouble(),
    target: (json['target'] as num).toDouble(),
    metric: json['metric'] as String? ?? defaultMetric,
    goal: json['goal'] as String? ?? HabitGoalMath.build,
    due: json['due'] as bool? ?? true,
  );

  static const String defaultMetric = 'sessions';

  final String id;
  final String title;
  final double value;
  final double target;
  final String metric;
  final String goal;
  final bool due;

  bool get isLimit => goal == HabitGoalMath.limit;

  bool get isCompleted =>
      HabitGoalMath.isCompleted(value, target, isLimit: isLimit);

  double get progress =>
      HabitGoalMath.progress(value, target, isLimit: isLimit);

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'value': value,
    'target': target,
    'metric': metric,
    'goal': goal,
    'due': due,
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

  Iterable<HabitLogEntry> get dueEntries => entries.where((e) => e.due);

  double get completion {
    final due = dueEntries.toList();
    if (due.isEmpty) return 0;
    final total = due.fold<double>(0, (sum, e) => sum + e.progress);
    return total / due.length;
  }

  HabitLogEntry? entryOf(String id) =>
      entries.where((entry) => entry.id == id).firstOrNull;

  Map<String, dynamic> toJson() => {
    'date': AppDateUtils.dateKey(date),
    'entries': [for (final entry in entries) entry.toJson()],
    'completion': completion,
    'updatedAt': AppDateUtils.isoKey(DateTime.now()),
  };
}
