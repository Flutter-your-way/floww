enum CalLevel {
  one(
    1,
    'Ultra Beginner',
    'Base Strength',
    weeks: 8,
    sessions: 3,
    minutes: 50,
    minuteRange: '45–55 min',
    experience: 'Beginner',
    goal:
        'Learn patterns, build tendon tolerance, earn your first strict '
        'pull-up and 10 push-ups.',
    restGuidance: 'Easy walks 20–30 min; aim for 8–9 h sleep.',
  ),
  two(
    2,
    'Beginner → Intermediate',
    'Strength Foundation',
    weeks: 12,
    sessions: 4,
    minutes: 65,
    minuteRange: '60–70 min',
    experience: 'Intermediate',
    goal:
        '8+ strict pull-ups, 25 push-ups, 15 dips, an assisted pistol, '
        'tuck lever and L-sit.',
    restGuidance: 'Keep rest days active but easy.',
  ),
  three(
    3,
    'Intermediate → Advanced',
    'Strength + Skill',
    weeks: 12,
    sessions: 5,
    minutes: 80,
    minuteRange: '70–85 min',
    experience: 'Advanced',
    goal:
        'Weighted strength, the muscle-up, handstand push-ups, advanced-tuck '
        'lever and planche.',
    restGuidance:
        'Take one full rest day mid-week; skill days are about '
        'quality, not fatigue.',
  ),
  four(
    4,
    'Advanced Athlete',
    'Peak Strength & Elite Skills',
    weeks: 12,
    sessions: 6,
    minutes: 90,
    minuteRange: '75–100 min',
    experience: 'Advanced',
    goal:
        'Straddle and full lever and planche, the human flag, one-arm work '
        'and heavy weighted pulls and dips.',
    restGuidance:
        'Rest day: mobility and walking, sauna or contrast if you '
        'like.',
  );

  const CalLevel(
    this.number,
    this.title,
    this.focus, {
    required this.weeks,
    required this.sessions,
    required this.minutes,
    required this.minuteRange,
    required this.experience,
    required this.goal,
    required this.restGuidance,
  });

  static const String coursePrefix = 'calisthenics-l';

  final int number;
  final String title;
  final String focus;
  final int weeks;
  final int sessions;
  final int minutes;
  final String minuteRange;
  final String experience;
  final String goal;
  final String restGuidance;

  String get label => 'Level $number';

  String get fullTitle => '$label · $focus';

  String get courseId => '$coursePrefix$number';

  int get lengthDays => weeks * DateTime.daysPerWeek;

  CalLevel? get next => number < values.length ? values[number] : null;

  static CalLevel of(int number) =>
      values[(number - 1).clamp(0, values.length - 1)];

  static CalLevel? fromCourse(String? course) {
    if (course == null || !course.startsWith(coursePrefix)) return null;
    final number = int.tryParse(course.substring(coursePrefix.length));
    return number == null ? null : of(number);
  }

  static CalLevel fittingDays(CalLevel placed, int days) {
    var level = placed;
    while (level.number > 1 && level.sessions > days) {
      level = values[level.number - 2];
    }
    return level;
  }
}
