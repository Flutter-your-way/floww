class AppDateUtils {
  AppDateUtils._();

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String isoKey(DateTime time) => DateTime.fromMillisecondsSinceEpoch(
    time.millisecondsSinceEpoch,
    isUtc: true,
  ).toIso8601String();

  static String dateKey(DateTime date) =>
      '${date.year}-${_padded(date.month)}-${_padded(date.day)}';

  static String _padded(int value) => value.toString().padLeft(2, '0');

  static Duration untilNextDay(DateTime now) =>
      DateTime(now.year, now.month, now.day + 1).difference(now);

  static DateTime atTimeOf(DateTime date, DateTime time) => DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
    time.second,
  );

  static String shortWeekday(DateTime date) =>
      _weekdays[date.weekday - 1].substring(0, 3);

  static String monthDayYear(DateTime date) =>
      '${_shortMonths[date.month - 1]} ${date.day}, ${date.year}';

  static String time(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${date.hour < 12 ? 'AM' : 'PM'}';
  }

  static String relativeDay(DateTime date, {DateTime? now}) {
    final today = dateOnly(now ?? DateTime.now());
    return switch (daysBetween(today, date)) {
      0 => 'Today',
      -1 => 'Yesterday',
      1 => 'Tomorrow',
      _ => '${shortWeekday(date)}, ${dayMonth(date)}',
    };
  }

  static DateTime addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static int daysBetween(DateTime from, DateTime to) =>
      DateTime.utc(to.year, to.month, to.day)
          .difference(DateTime.utc(from.year, from.month, from.day))
          .inDays;

  static DateTime startOfWeek(DateTime date) =>
      addDays(dateOnly(date), 1 - date.weekday);

  static DateTime endOfWeek(DateTime date) => addDays(startOfWeek(date), 6);

  static String weekdayName(DateTime date) => _weekdays[date.weekday - 1];

  static String monthYear(DateTime date) =>
      '${_months[date.month - 1]} ${date.year}';

  static String shortMonthYear(DateTime date) =>
      '${_shortMonths[date.month - 1]} ${date.year}';

  static String monthDay(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}';

  static String dayMonth(DateTime date, {bool withYear = false}) {
    final label = '${date.day} ${_shortMonths[date.month - 1]}';
    return withYear ? '$label ${date.year}' : label;
  }
}
