import 'package:floww/core/habits/models/habit.dart';

class HabitReminderSetting {
  const HabitReminderSetting.auto() : minutes = null, isOff = false;

  const HabitReminderSetting.at(int this.minutes) : isOff = false;

  const HabitReminderSetting.off() : minutes = null, isOff = true;

  factory HabitReminderSetting.fromJson(Object? json) {
    if (json == _offValue) return const HabitReminderSetting.off();
    final parts = json is String ? json.split(':') : null;
    if (parts == null || parts.length != 2) {
      return const HabitReminderSetting.auto();
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return const HabitReminderSetting.auto();
    }
    return HabitReminderSetting.at(hour * Duration.minutesPerHour + minute);
  }

  factory HabitReminderSetting.of(int? minutes) => minutes == null
      ? const HabitReminderSetting.off()
      : HabitReminderSetting.at(minutes);

  static const String _offValue = 'off';
  static const int fallbackMinutes = 9 * Duration.minutesPerHour;

  static const Map<HabitIconKind, int> _defaultMinutes = {
    HabitIconKind.coldShower: 7 * Duration.minutesPerHour,
    HabitIconKind.meditation: 7 * Duration.minutesPerHour + 30,
    HabitIconKind.stretching: 7 * Duration.minutesPerHour + 30,
    HabitIconKind.water: 10 * Duration.minutesPerHour,
    HabitIconKind.noSugar: 15 * Duration.minutesPerHour,
    HabitIconKind.walk: 17 * Duration.minutesPerHour + 30,
    HabitIconKind.dumbbell: 18 * Duration.minutesPerHour,
    HabitIconKind.screenFree: 20 * Duration.minutesPerHour + 30,
    HabitIconKind.book: 21 * Duration.minutesPerHour,
    HabitIconKind.journal: 21 * Duration.minutesPerHour,
    HabitIconKind.sleep: 21 * Duration.minutesPerHour + 30,
  };

  static int defaultMinutesFor(HabitIconKind icon) =>
      _defaultMinutes[icon] ?? fallbackMinutes;

  final int? minutes;
  final bool isOff;

  int? resolve(HabitIconKind icon) =>
      isOff ? null : minutes ?? defaultMinutesFor(icon);

  String? toJson() {
    if (isOff) return _offValue;
    final value = minutes;
    if (value == null) return null;
    final hour = (value ~/ Duration.minutesPerHour).toString().padLeft(2, '0');
    final minute = (value % Duration.minutesPerHour).toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
