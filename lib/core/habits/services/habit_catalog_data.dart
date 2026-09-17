import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_suggestion.dart';

class HabitCatalogData {
  HabitCatalogData._();

  static const String fallbackAbout =
      'Consistency is what turns a habit into an identity. Keep the target '
      'small enough that you can repeat it on your busiest day.';

  static const List<HabitSuggestion> suggestions = [
    HabitSuggestion(
      id: 'workout_training',
      title: 'Workout Training',
      target: 45,
      metric: HabitMetric.minutes,
      icon: HabitIconKind.dumbbell,
      description: 'At least 45 min workout',
      about:
          'Regular training promotes your strength and a good mental status. '
          'Let\'s aim for at least 45 minutes of intentional movement.',
    ),
    HabitSuggestion(
      id: 'outdoor_walk',
      title: 'Outdoor Walk',
      target: 10000,
      metric: HabitMetric.steps,
      icon: HabitIconKind.walk,
      description: '10,000 steps a day',
      about:
          'Walking outdoors keeps your circulation active and your head '
          'clear. Spread the steps across the day so it never feels forced.',
    ),
    HabitSuggestion(
      id: 'water_intake',
      title: 'Water Intake',
      target: 3,
      metric: HabitMetric.liters,
      icon: HabitIconKind.water,
      description: '3L of water daily',
      about:
          'Staying hydrated supports recovery, focus and appetite control. '
          'Keep a bottle within reach and sip through the day.',
    ),
    HabitSuggestion(
      id: 'meditation',
      title: 'Meditation',
      target: 10,
      metric: HabitMetric.minutes,
      icon: HabitIconKind.meditation,
      description: '10 min of stillness',
      about:
          'A short daily sit lowers stress and sharpens attention. Ten quiet '
          'minutes are enough to feel the difference.',
    ),
    HabitSuggestion(
      id: 'screen_free',
      title: 'Screen Free',
      target: 1,
      metric: HabitMetric.hours,
      icon: HabitIconKind.screenFree,
      description: '1 hour away from screens',
      about:
          'An hour without screens protects your sleep and your focus. Pick '
          'the same slot each day so it becomes automatic.',
    ),
    HabitSuggestion(
      id: 'reading',
      title: 'Reading',
      target: 20,
      metric: HabitMetric.minutes,
      icon: HabitIconKind.book,
      description: '20 min of reading',
      about:
          'Reading every day compounds quietly. Twenty focused minutes are '
          'enough to finish a book a month.',
    ),
    HabitSuggestion(
      id: 'journaling',
      title: 'Journaling',
      target: 10,
      metric: HabitMetric.minutes,
      icon: HabitIconKind.journal,
      description: '10 min of writing',
      about:
          'Writing down what happened clears your head and shows patterns '
          'you would otherwise miss.',
    ),
    HabitSuggestion(
      id: 'cold_shower',
      title: 'Cold Shower',
      target: 1,
      metric: HabitMetric.sessions,
      icon: HabitIconKind.coldShower,
      description: 'One cold finish a day',
      about:
          'Ending your shower cold is a short, repeatable act of discipline '
          'that carries into the rest of the day.',
    ),
    HabitSuggestion(
      id: 'stretching',
      title: 'Stretching',
      target: 15,
      metric: HabitMetric.minutes,
      icon: HabitIconKind.stretching,
      description: '15 min of mobility',
      about:
          'Mobility work keeps your joints healthy and shortens the time it '
          'takes to recover between sessions.',
    ),
    HabitSuggestion(
      id: 'sleep',
      title: 'Sleep 8h',
      target: 8,
      metric: HabitMetric.hours,
      icon: HabitIconKind.sleep,
      description: '8 hours of sleep',
      about:
          'Sleep is the single biggest lever on recovery, appetite and mood. '
          'Protect the same window every night.',
    ),
    HabitSuggestion(
      id: 'no_sugar',
      title: 'No Sugar',
      target: 1,
      metric: HabitMetric.sessions,
      icon: HabitIconKind.noSugar,
      description: 'A day without added sugar',
      about:
          'Cutting added sugar steadies your energy across the day and makes '
          'hunger far easier to read.',
    ),
  ];

  static const List<HabitSuggestionGroup> groups = [
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
    HabitSuggestionGroup(
      id: 'movement',
      title: 'Move Every Day',
      suggestionIds: ['workout_training', 'outdoor_walk'],
    ),
  ];
}
