class WaveThinking {
  const WaveThinking._();

  static const String thinking = 'Thinking';
  static const String writing = 'Writing your answer';
  static const String working = 'Working on it';
  static const String fallbackTopic = 'Reading your day';
  static const int maxTopics = 2;

  static const List<(String, List<String>)> _topics = [
    ('Checking your Flow Score', ['score', 'flow', 'points']),
    (
      'Reading your last 7 days',
      ['week', 'improv', 'progress', 'trend', 'lately', 'behind'],
    ),
    (
      'Reviewing your recovery',
      ['sleep', 'recover', 'tired', 'hrv', 'sore', 'rest', 'energy'],
    ),
    (
      'Looking at your nutrition',
      ['eat', 'food', 'protein', 'calorie', 'meal', 'diet', 'carb', 'water'],
    ),
    (
      'Reviewing your training',
      ['workout', 'lift', 'weight', 'bench', 'squat', 'train', 'session'],
    ),
    ('Checking your habits', ['habit', 'streak', 'steps']),
  ];

  static List<String> stepsFor(String? question) {
    if (question == null) return const [working];

    final text = question.toLowerCase();
    final topics = [
      for (final (label, keywords) in _topics)
        if (keywords.any(text.contains)) label,
    ].take(maxTopics).toList();

    return [
      thinking,
      if (topics.isEmpty) fallbackTopic else ...topics,
      writing,
    ];
  }
}
