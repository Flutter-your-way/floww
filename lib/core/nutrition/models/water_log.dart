import 'package:floww/config/utils/dates/app_date_utils.dart';

class WaterLog {
  const WaterLog({
    required this.id,
    required this.amountMl,
    required this.loggedAt,
  });

  factory WaterLog.fromJson(Map<String, dynamic> json) => WaterLog(
    id: json['id'] as String,
    amountMl: (json['amountMl'] as num).toDouble(),
    loggedAt: DateTime.parse(json['loggedAt'] as String).toLocal(),
  );

  final String id;
  final double amountMl;
  final DateTime loggedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'amountMl': amountMl,
    'loggedAt': AppDateUtils.isoKey(loggedAt),
  };
}
