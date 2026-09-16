import 'package:floww/config/utils/dates/app_date_utils.dart';

class WeightLog {
  const WeightLog({
    required this.id,
    required this.weightKg,
    required this.loggedAt,
  });

  factory WeightLog.fromJson(Map<String, dynamic> json) => WeightLog(
    id: json['id'] as String,
    weightKg: (json['weightKg'] as num).toDouble(),
    loggedAt: DateTime.parse(json['loggedAt'] as String).toLocal(),
  );

  final String id;
  final double weightKg;
  final DateTime loggedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'weightKg': weightKg,
    'loggedAt': AppDateUtils.isoKey(loggedAt),
  };
}
