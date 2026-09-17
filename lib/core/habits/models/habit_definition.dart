import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/models/habit.dart';

class HabitDefinition {
  const HabitDefinition({
    required this.id,
    required this.title,
    required this.target,
    required this.metric,
    required this.icon,
    required this.createdAt,
    required this.sortOrder,
    this.description,
    this.about,
  });

  factory HabitDefinition.fromJson(Map<String, dynamic> json) =>
      HabitDefinition(
        id: json['id'] as String,
        title: json['title'] as String,
        target: (json['target'] as num).toDouble(),
        metric: metricOf(json['metric'] as String?),
        icon: iconOf(json['icon'] as String?),
        createdAt: AppDateUtils.dateOnly(
          DateTime.parse(json['createdAt'] as String).toLocal(),
        ),
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
        description: json['description'] as String?,
        about: json['about'] as String?,
      );

  static HabitMetric metricOf(String? name) => HabitMetric.values.firstWhere(
    (metric) => metric.name == name,
    orElse: () => HabitMetric.sessions,
  );

  static HabitIconKind iconOf(String? name) => HabitIconKind.values.firstWhere(
    (icon) => icon.name == name,
    orElse: () => HabitIconKind.clipboard,
  );

  final String id;
  final String title;
  final double target;
  final HabitMetric metric;
  final HabitIconKind icon;
  final DateTime createdAt;
  final int sortOrder;
  final String? description;
  final String? about;

  bool existedOn(DateTime date) => !createdAt.isAfter(date);

  Habit toHabit({double value = 0}) => Habit(
    id: id,
    title: title,
    value: value,
    target: target,
    metric: metric,
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
    'description': description,
    'about': about,
  };
}
