import 'package:floww/config/utils/dates/app_date_utils.dart';

class WaveChatDay {
  const WaveChatDay({
    required this.date,
    required this.lastMessageAt,
    required this.preview,
  });

  factory WaveChatDay.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['day'] as String);
    return WaveChatDay(
      date: AppDateUtils.dateOnly(date),
      lastMessageAt: json['lastMessageAt'] == null
          ? date
          : DateTime.parse(json['lastMessageAt'] as String).toLocal(),
      preview: json['preview'] as String? ?? '',
    );
  }

  final DateTime date;
  final DateTime lastMessageAt;
  final String preview;

  String get key => AppDateUtils.dateKey(date);

  String get label => AppDateUtils.relativeDay(date);

  String get timeLabel => AppDateUtils.time(lastMessageAt, padHour: true);

  bool get isToday => AppDateUtils.isSameDay(date, DateTime.now());

  Map<String, dynamic> toJson() => {
    'day': key,
    'lastMessageAt': AppDateUtils.isoKey(lastMessageAt),
    'preview': preview,
  };
}
