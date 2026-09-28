enum HabitScheduleType { daily, weekdays, weekly }

class HabitSchedule {
  const HabitSchedule._({
    required this.type,
    this.weekdays = const [],
    this.timesPerWeek = DateTime.daysPerWeek,
  });

  const HabitSchedule.daily() : this._(type: HabitScheduleType.daily);

  const HabitSchedule.weekdays(List<int> weekdays)
    : this._(type: HabitScheduleType.weekdays, weekdays: weekdays);

  const HabitSchedule.weekly(int timesPerWeek)
    : this._(type: HabitScheduleType.weekly, timesPerWeek: timesPerWeek);

  factory HabitSchedule.fromJson(Object? json) {
    if (json is! Map) return const HabitSchedule.daily();
    final type = HabitScheduleType.values.firstWhere(
      (type) => type.name == json['type'],
      orElse: () => HabitScheduleType.daily,
    );
    switch (type) {
      case HabitScheduleType.daily:
        return const HabitSchedule.daily();
      case HabitScheduleType.weekdays:
        final days = [
          for (final day in (json['weekdays'] as List? ?? const []))
            if (day is num && day >= DateTime.monday && day <= DateTime.sunday)
              day.toInt(),
        ]..sort();
        return days.isEmpty || days.length == DateTime.daysPerWeek
            ? const HabitSchedule.daily()
            : HabitSchedule.weekdays(days);
      case HabitScheduleType.weekly:
        final times = (json['timesPerWeek'] as num?)?.toInt() ?? 0;
        return times <= 0 || times >= DateTime.daysPerWeek
            ? const HabitSchedule.daily()
            : HabitSchedule.weekly(times);
    }
  }

  static const List<int> allWeekdays = [
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  ];

  final HabitScheduleType type;
  final List<int> weekdays;
  final int timesPerWeek;

  bool get isFlexible => type == HabitScheduleType.weekly;

  bool isScheduledOn(DateTime date) => switch (type) {
    HabitScheduleType.weekdays => weekdays.contains(date.weekday),
    _ => true,
  };

  Map<String, dynamic> toJson() => {
    'type': type.name,
    if (type == HabitScheduleType.weekdays) 'weekdays': weekdays,
    if (type == HabitScheduleType.weekly) 'timesPerWeek': timesPerWeek,
  };

  @override
  bool operator ==(Object other) =>
      other is HabitSchedule &&
      other.type == type &&
      other.timesPerWeek == timesPerWeek &&
      other.weekdays.length == weekdays.length &&
      other.weekdays.every(weekdays.contains);

  @override
  int get hashCode => Object.hash(type, timesPerWeek, Object.hashAll(weekdays));
}
