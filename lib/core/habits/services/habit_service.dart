import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_day.dart';
import 'package:floww/core/habits/models/habit_detail.dart';
import 'package:floww/core/habits/models/habit_draft.dart';
import 'package:floww/core/habits/models/habit_period.dart';
import 'package:floww/core/habits/models/habit_suggestion.dart';

class HabitService {
  HabitService({bool seedSampleHabits = true})
    : _templates = seedSampleHabits ? [..._sampleTemplates] : [];

  static const _sampleTemplates = [
    _HabitTemplate(
      id: 'workout_training',
      title: 'Workout Training',
      target: 45,
      todayValue: 45,
      metric: HabitMetric.minutes,
      description: 'At least 45 min workout',
      icon: HabitIconKind.dumbbell,
      about:
          'Regular training promotes your strength and a good mental status. '
          'Let\'s aim for at least 45 minutes of intentional movement.',
    ),
    _HabitTemplate(
      id: 'outdoor_walk',
      title: 'Outdoor Walk',
      target: 10000,
      todayValue: 8432,
      metric: HabitMetric.steps,
      description: '10,000 steps a day',
      icon: HabitIconKind.walk,
      about:
          'Walking outdoors keeps your circulation active and your head '
          'clear. Spread the steps across the day so it never feels forced.',
    ),
    _HabitTemplate(
      id: 'water_intake',
      title: 'Water Intake',
      target: 3,
      todayValue: 2.5,
      metric: HabitMetric.liters,
      description: '3L of water daily',
      icon: HabitIconKind.water,
      about:
          'Staying hydrated supports recovery, focus and appetite control. '
          'Keep a bottle within reach and sip through the day.',
    ),
    _HabitTemplate(
      id: 'meditation',
      title: 'Meditation',
      target: 10,
      todayValue: 0,
      metric: HabitMetric.minutes,
      description: '10 min of stillness',
      icon: HabitIconKind.meditation,
      about:
          'A short daily sit lowers stress and sharpens attention. Ten quiet '
          'minutes are enough to feel the difference.',
    ),
    _HabitTemplate(
      id: 'screen_free',
      title: 'Screen Free',
      target: 1,
      todayValue: 0,
      metric: HabitMetric.hours,
      description: '1 hour away from screens',
      icon: HabitIconKind.screenFree,
      about:
          'An hour without screens protects your sleep and your focus. Pick '
          'the same slot each day so it becomes automatic.',
    ),
  ];

  static const _popularHabits = [
    HabitSuggestion(
      id: 'reading',
      title: 'Reading',
      target: 20,
      metric: HabitMetric.minutes,
      icon: HabitIconKind.book,
    ),
    HabitSuggestion(
      id: 'journaling',
      title: 'Journaling',
      target: 10,
      metric: HabitMetric.minutes,
      icon: HabitIconKind.journal,
    ),
    HabitSuggestion(
      id: 'cold_shower',
      title: 'Cold Shower',
      target: 1,
      metric: HabitMetric.sessions,
      icon: HabitIconKind.coldShower,
    ),
    HabitSuggestion(
      id: 'stretching',
      title: 'Stretching',
      target: 15,
      metric: HabitMetric.minutes,
      icon: HabitIconKind.stretching,
    ),
    HabitSuggestion(
      id: 'sleep',
      title: 'Sleep 8h',
      target: 8,
      metric: HabitMetric.hours,
      icon: HabitIconKind.sleep,
    ),
    HabitSuggestion(
      id: 'no_sugar',
      title: 'No Sugar',
      target: 1,
      metric: HabitMetric.sessions,
      icon: HabitIconKind.noSugar,
    ),
  ];

  static const _suggestionGroups = [
    HabitSuggestionGroup(
      id: 'recovery',
      title: 'Improve Recovery',
      suggestionIds: ['sleep', 'stretching'],
    ),
    HabitSuggestionGroup(
      id: 'focus',
      title: 'Sharpen Focus',
      suggestionIds: ['reading', 'journaling'],
    ),
    HabitSuggestionGroup(
      id: 'discipline',
      title: 'Build Discipline',
      suggestionIds: ['cold_shower', 'no_sugar'],
    ),
  ];

  static const _fallbackAbout =
      'Consistency is what turns a habit into an identity. Keep the target '
      'small enough that you can repeat it on your busiest day.';

  static const _weekdayCompletion = [1.0, 1.0, 1.0, 1.0, 0.9, 0.0, 0.0];

  static const _streakDays = {
    'workout_training': 12,
    'outdoor_walk': 8,
    'water_intake': 5,
    'meditation': 12,
    'screen_free': 3,
  };

  static const _stats = HabitStats(
    currentStreakDays: 12,
    longestStreakDays: 28,
    weeklyAverageMinutes: 87,
  );

  final List<_HabitTemplate> _templates;

  int _customCount = 0;

  bool get hasHabits => _templates.isNotEmpty;

  List<HabitSuggestion> popularHabits() => [
    for (final suggestion in _popularHabits)
      if (!_templates.any((template) => template.id == suggestion.id))
        suggestion,
  ];

  List<HabitSuggestionGroup> suggestionGroups() => _suggestionGroups;

  void addCustomHabit(HabitDraft draft) {
    _customCount++;
    _templates.add(
      _HabitTemplate(
        id: 'custom_$_customCount',
        title: draft.title,
        target: draft.target,
        todayValue: 0,
        metric: draft.metric,
        description: draft.description,
      ),
    );
  }

  void addHabit(HabitSuggestion suggestion) {
    if (_templates.any((template) => template.id == suggestion.id)) return;
    _templates.add(
      _HabitTemplate(
        id: suggestion.id,
        title: suggestion.title,
        target: suggestion.target,
        todayValue: 0,
        metric: suggestion.metric,
        icon: suggestion.icon,
      ),
    );
  }

  List<Habit> habitsFor(DateTime date) {
    final today = AppDateUtils.dateOnly(DateTime.now());
    if (AppDateUtils.isSameDay(date, today)) {
      return [for (final template in _templates) template.today()];
    }
    if (date.isAfter(today)) {
      return [for (final template in _templates) template.at(0)];
    }
    return [
      for (final template in _templates) template.at(_completionOf(date)),
    ];
  }

  List<HabitDay> weekFor(DateTime date, {required double todayCompletion}) {
    final today = AppDateUtils.dateOnly(DateTime.now());
    final start = AppDateUtils.startOfWeek(date);
    return [
      for (var index = 0; index < DateTime.daysPerWeek; index++)
        _dayFor(AppDateUtils.addDays(start, index), today, todayCompletion),
    ];
  }

  HabitStats statsFor(DateTime date) => _stats;

  HabitDetail? detailFor(String id) {
    for (final template in _templates) {
      if (template.id != id) continue;
      final today = AppDateUtils.dateOnly(DateTime.now());
      final tracked = [
        for (final day in monthFor(DateTime(today.year, today.month)))
          if (day.status != HabitDayStatus.upcoming) day,
      ];
      final recent = tracked.length <= DateTime.daysPerWeek
          ? tracked
          : tracked.sublist(tracked.length - DateTime.daysPerWeek);
      final average = recent.isEmpty
          ? 0.0
          : recent.fold<double>(0, (sum, day) => sum + day.completion) /
                recent.length;
      return HabitDetail(
        id: template.id,
        title: template.title,
        description: template.description ?? '',
        about: template.about ?? _fallbackAbout,
        target: template.target,
        metric: template.metric,
        icon: template.icon,
        currentStreakDays: _streakDays[template.id] ?? 0,
        longestStreakDays: _stats.longestStreakDays,
        weeklyAveragePercent: (average * 100).round(),
        totalCompletions: tracked
            .where((day) => day.status == HabitDayStatus.completed)
            .length,
      );
    }
    return null;
  }

  void updateHabit(String id, HabitDraft draft) {
    final index = _templates.indexWhere((template) => template.id == id);
    if (index < 0) return;
    final template = _templates[index];
    _templates[index] = _HabitTemplate(
      id: template.id,
      title: draft.title,
      target: draft.target,
      todayValue: template.todayValue,
      metric: draft.metric,
      description: draft.description,
      about: template.about,
      icon: template.icon,
    );
  }

  List<HabitDay> daysFor(HabitPeriod period) {
    final today = AppDateUtils.dateOnly(DateTime.now());
    return switch (period) {
      HabitPeriod.thisWeek => weekFor(
        today,
        todayCompletion: _completionOf(today),
      ),
      HabitPeriod.thisMonth => monthFor(DateTime(today.year, today.month)),
      HabitPeriod.lastMonth => monthFor(DateTime(today.year, today.month - 1)),
    };
  }

  List<HabitStreak> habitStreaks() => [
    for (final template in _templates)
      HabitStreak(title: template.title, days: _streakDays[template.id] ?? 0),
  ];

  List<HabitDay> monthFor(DateTime month) {
    final today = AppDateUtils.dateOnly(DateTime.now());
    final first = DateTime(month.year, month.month);
    final dayCount = DateTime(month.year, month.month + 1, 0).day;
    return [
      for (var day = 0; day < dayCount; day++)
        _dayFor(AppDateUtils.addDays(first, day), today, _completionOf(today)),
    ];
  }

  HabitDay _dayFor(DateTime date, DateTime today, double todayCompletion) {
    if (date.isAfter(today)) {
      return HabitDay(
        date: date,
        completion: 0,
        status: HabitDayStatus.upcoming,
      );
    }
    final completion = AppDateUtils.isSameDay(date, today)
        ? todayCompletion
        : _completionOf(date);
    return HabitDay(
      date: date,
      completion: completion,
      status: _statusOf(completion),
    );
  }

  HabitDayStatus _statusOf(double completion) {
    if (completion >= 1) return HabitDayStatus.completed;
    return completion > 0 ? HabitDayStatus.partial : HabitDayStatus.missed;
  }

  double _completionOf(DateTime date) => _weekdayCompletion[date.weekday - 1];
}

class _HabitTemplate {
  const _HabitTemplate({
    required this.id,
    required this.title,
    required this.target,
    required this.todayValue,
    required this.metric,
    this.description,
    this.about,
    this.icon = HabitIconKind.clipboard,
  });

  final String id;
  final String title;
  final double target;
  final double todayValue;
  final HabitMetric metric;
  final String? description;
  final String? about;
  final HabitIconKind icon;

  Habit today() => Habit(
    id: id,
    title: title,
    value: todayValue,
    target: target,
    metric: metric,
    description: description,
  );

  Habit at(double completion) => Habit(
    id: id,
    title: title,
    value: target * completion,
    target: target,
    metric: metric,
    description: description,
  );
}
