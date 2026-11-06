import 'package:floww/config/utils/dates/app_date_utils.dart';

class WavePendingPlan {
  const WavePendingPlan({
    required this.messageId,
    required this.day,
    required this.title,
  });

  static WavePendingPlan? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final messageId = json['messageId'] as String? ?? '';
    final day = DateTime.tryParse(json['day'] as String? ?? '');
    if (messageId.isEmpty || day == null) return null;
    return WavePendingPlan(
      messageId: messageId,
      day: AppDateUtils.dateOnly(day),
      title: json['title'] as String? ?? '',
    );
  }

  final String messageId;
  final DateTime day;
  final String title;

  Map<String, dynamic> toJson() => {
    'messageId': messageId,
    'day': AppDateUtils.dateKey(day),
    'title': title,
  };
}
