import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_reminder_setting.dart';
import 'package:floww/core/habits/models/habit_schedule.dart';

class HabitDefinition {
  const HabitDefinition({
    required this.id,
    required this.title,
    required this.target,
    required this.metric,
    required this.icon,
    required this.createdAt,
    required this.sortOrder,
    this.schedule = const HabitSchedule.daily(),
    this.goalType = HabitGoalType.build,
    this.source = HabitSource.manual,
    this.reminder = const HabitReminderSetting.auto(),
    this.archivedAt,
    this.description,
    this.about,
  });

  factory HabitDefinition.fromJson(Map<String, dynamic> json) {
    final archivedAt = json['archivedAt'] as String?;
    return HabitDefinition(
      id: json['id'] as String,
      title: titleOf(json['title'] as String),
      target: (json['target'] as num).toDouble(),
      metric: metricOf(json['metric'] as String?),
      icon: iconOf(json['icon'] as String?),
      createdAt: AppDateUtils.dateOnly(
        DateTime.parse(json['createdAt'] as String).toLocal(),
      ),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      schedule: HabitSchedule.fromJson(json['schedule']),
      goalType: goalTypeOf(json['goalType'] as String?),
      source: sourceOf(
        json['source'] as String?,
        legacyId: json['id'] as String,
      ),
      reminder: HabitReminderSetting.fromJson(json['reminderTime']),
      archivedAt: archivedAt == null
          ? null
          : AppDateUtils.dateOnly(DateTime.parse(archivedAt).toLocal()),
      description: json['description'] as String?,
      about: json['about'] as String?,
    );
  }

  static const Map<String, String> _legacyTitles = {'Sleep 8h': 'Sleep'};

  static const Map<String, HabitSource> _legacySources = {
    'water_intake': HabitSource.water,
    'workout_training': HabitSource.workout,
    'outdoor_walk': HabitSource.steps,
    'sleep': HabitSource.sleep,
  };

  static String titleOf(String title) => _legacyTitles[title] ?? title;

  static HabitMetric metricOf(String? name) => HabitMetric.values.firstWhere(
    (metric) => metric.name == name,
    orElse: () => HabitMetric.sessions,
  );

  static HabitIconKind iconOf(String? name) => HabitIconKind.values.firstWhere(
    (icon) => icon.name == name,
    orElse: () => HabitIconKind.clipboard,
  );

  static HabitGoalType goalTypeOf(String? name) =>
      HabitGoalType.values.firstWhere(
        (goal) => goal.name == name,
        orElse: () => HabitGoalType.build,
      );

  static HabitSource sourceOf(String? name, {String? legacyId}) {
    if (name == null) return _legacySources[legacyId] ?? HabitSource.manual;
    return HabitSource.values.firstWhere(
      (source) => source.name == name,
      orElse: () => HabitSource.manual,
    );
  }

  final String id;
  final String title;
  final double target;
  final HabitMetric metric;
  final HabitIconKind icon;
  final DateTime createdAt;
  final int sortOrder;
  final HabitSchedule schedule;
  final HabitGoalType goalType;
  final HabitSource source;
  final HabitReminderSetting reminder;
  final DateTime? archivedAt;
  final String? description;
  final String? about;

  bool get isArchived => archivedAt != null;

  int? get reminderMinutes => reminder.resolve(icon);

  bool existedOn(DateTime date) => !createdAt.isAfter(date);

  bool activeOn(DateTime date) {
    final archived = archivedAt;
    return existedOn(date) && (archived == null || date.isBefore(archived));
  }

  Habit toHabit({double value = 0, bool isDue = true}) => Habit(
    id: id,
    title: title,
    value: value,
    target: target,
    metric: metric,
    goalType: goalType,
    source: source,
    isDue: isDue,
    description: description,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'target': target,
    'metric': metric.name,
    'icon': icon.name,
    'createdAt': AppDateUtils.isoKey(createdAt),
    'sortOrder': sortOrder,
    'schedule': schedule.toJson(),
    'goalType': goalType.name,
    'source': source.name,
    'reminderTime': reminder.toJson(),
    'archivedAt': archivedAt == null ? null : AppDateUtils.isoKey(archivedAt!),
    'description': description,
    'about': about,
  };
}
