enum RecoveryMood { great, okay, tired, sore }

enum ShareTarget { stories, strava, addImage, downloadImage, share }

class WorkoutCompletion {
  const WorkoutCompletion({
    required this.workoutId,
    required this.name,
    required this.modeLabel,
    required this.durationSeconds,
    required this.calories,
    required this.volumeKg,
    required this.personalRecords,
    required this.flowScoreBefore,
    required this.flowScoreAfter,
    required this.headline,
    required this.caption,
    required this.muscleTags,
    required this.siteLabel,
    required this.handleLabel,
  });

  final String workoutId;
  final String name;
  final String modeLabel;
  final int durationSeconds;
  final int calories;
  final int volumeKg;
  final int personalRecords;
  final int flowScoreBefore;
  final int flowScoreAfter;
  final String headline;
  final String caption;
  final List<String> muscleTags;
  final String siteLabel;
  final String handleLabel;

  int get flowScoreGain => flowScoreAfter - flowScoreBefore;
}
