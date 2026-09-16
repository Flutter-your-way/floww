import 'package:floww/config/utils/dates/app_date_utils.dart';

class DailyFlowEntry {
  const DailyFlowEntry({
    required this.date,
    required this.score,
    required this.workoutScore,
    required this.habitScore,
    required this.nutritionScore,
  });

  const DailyFlowEntry.empty(this.date)
    : score = 0,
      workoutScore = 0,
      habitScore = 0,
      nutritionScore = 0;

  factory DailyFlowEntry.fromJson(Map<String, dynamic> json) => DailyFlowEntry(
    date: DateTime.parse(json['date'] as String),
    score: (json['score'] as num).toInt(),
    workoutScore: (json['workoutScore'] as num? ?? 0).toInt(),
    habitScore: (json['habitScore'] as num? ?? 0).toInt(),
    nutritionScore: (json['nutritionScore'] as num? ?? 0).toInt(),
  );

  final DateTime date;
  final int score;
  final int workoutScore;
  final int habitScore;
  final int nutritionScore;

  bool get hasActivity => score > 0;

  bool sameValuesAs(DailyFlowEntry other) =>
      score == other.score &&
      workoutScore == other.workoutScore &&
      habitScore == other.habitScore &&
      nutritionScore == other.nutritionScore;

  Map<String, dynamic> toJson() => {
    'date': AppDateUtils.dateKey(date),
    'score': score,
    'workoutScore': workoutScore,
    'habitScore': habitScore,
    'nutritionScore': nutritionScore,
    'updatedAt': AppDateUtils.isoKey(DateTime.now()),
  };
}
