import 'package:flutter/material.dart';

import 'package:floww/core/guide/models/guide_step.dart';

class GuideContent {
  GuideContent._();

  static const String _sectionFinish = 'Got it';

  static GuideFlow flowFor(GuideSection section) => switch (section) {
    GuideSection.home => home,
    GuideSection.nutrition => nutrition,
    GuideSection.workout => workout,
    GuideSection.habits => habits,
    GuideSection.progress => progress,
  };

  static const GuideFlow home = GuideFlow(
    section: GuideSection.home,
    label: 'HOME GUIDE',
    finishLabel: _sectionFinish,
    steps: [
      GuideStep(
        icon: Icons.bolt_rounded,
        targets: [GuideTargetId.homeFlowScore],
        title: 'Flow Score',
        body:
            'Your day in one number. Training, food, habits and recovery all '
            'feed it. Tap the card for the full breakdown.',
      ),
      GuideStep(
        icon: Icons.contrast_rounded,
        targets: [GuideTargetId.homeMode, GuideTargetId.homeFlowScore],
        title: "Today's mode",
        body:
            'Flow, Steady or Restore. It follows your score and recovery, sets '
            'how hard today should be, and the app colour shifts with it. It '
            'shows here once you have a score.',
      ),
      GuideStep(
        icon: Icons.check_circle_outline_rounded,
        targets: [GuideTargetId.homeHabits],
        title: "Today's habits",
        body: 'Tick them off right here. Every check-in nudges your score.',
      ),
      GuideStep(
        icon: Icons.fitness_center_rounded,
        targets: [GuideTargetId.homeWorkout],
        title: "Today's workout",
        body:
            'The session planned for today. Start it from this card, or open '
            'the summary once it is done.',
      ),
      GuideStep(
        icon: Icons.restaurant_rounded,
        targets: [GuideTargetId.homeNutrition],
        title: 'Food so far',
        body:
            'Calories and macros eaten today. Tap it for your weekly '
            'nutrition report.',
      ),
      GuideStep(
        icon: Icons.favorite_border_rounded,
        targets: [GuideTargetId.homeHealth],
        title: 'Health sync',
        body:
            'Connect your health app so sleep, steps and recovery fill in on '
            'their own.',
      ),
    ],
  );

  static const GuideFlow nutrition = GuideFlow(
    section: GuideSection.nutrition,
    label: 'NUTRITION GUIDE',
    finishLabel: _sectionFinish,
    steps: [
      GuideStep(
        icon: Icons.calendar_month_rounded,
        targets: [GuideTargetId.nutritionDate],
        title: 'Pick a day',
        body: 'Tap the date to look back at what you ate on any day.',
      ),
      GuideStep(
        icon: Icons.local_fire_department_outlined,
        targets: [GuideTargetId.nutritionCalories],
        title: 'Calories',
        body: 'Eaten against your daily target. It updates with every log.',
      ),
      GuideStep(
        icon: Icons.pie_chart_outline_rounded,
        targets: [GuideTargetId.nutritionMacros],
        title: 'Macros',
        body: 'Protein, carbs and fats for the day, split by share.',
      ),
      GuideStep(
        icon: Icons.water_drop_outlined,
        targets: [GuideTargetId.nutritionMicros],
        title: 'Water and more',
        body:
            'Add water in a tap. Tap fibre, sugar or sodium to see which foods '
            'they came from.',
      ),
      GuideStep(
        icon: Icons.add_circle_outline_rounded,
        targets: [GuideTargetId.nutritionMeals],
        title: 'Log a meal',
        body:
            'Add food to breakfast, lunch, dinner or snacks with a photo scan, '
            'a search or your recent foods.',
      ),
    ],
  );

  static const GuideFlow workout = GuideFlow(
    section: GuideSection.workout,
    label: 'WORKOUTS GUIDE',
    finishLabel: _sectionFinish,
    steps: [
      GuideStep(
        icon: Icons.calendar_month_rounded,
        targets: [GuideTargetId.workoutDate],
        title: 'Your week',
        body: 'Tap the date to see what is planned, or was done, on any day.',
      ),
      GuideStep(
        icon: Icons.view_week_outlined,
        targets: [GuideTargetId.workoutTabs],
        title: 'Four views',
        body:
            'Overview for today, History for past sessions, Programs to switch '
            'plans, Exercises for the full library.',
      ),
      GuideStep(
        icon: Icons.event_note_rounded,
        targets: [GuideTargetId.workoutAgenda, GuideTargetId.workoutOverview],
        title: "Today's plan",
        body:
            'What is scheduled today. Missed yesterday? You can add it to today '
            'as a catch-up.',
      ),
      GuideStep(
        icon: Icons.insights_rounded,
        targets: [GuideTargetId.workoutOverview],
        title: 'Your training',
        body: 'Summary and training effect from your recent sessions.',
      ),
      GuideStep(
        icon: Icons.play_arrow_rounded,
        targets: [GuideTargetId.workoutStart],
        title: 'Start',
        body:
            'Runs today\'s session one exercise at a time, with a rest timer '
            'between sets.',
      ),
    ],
  );

  static const GuideFlow habits = GuideFlow(
    section: GuideSection.habits,
    label: 'HABITS GUIDE',
    finishLabel: _sectionFinish,
    steps: [
      GuideStep(
        icon: Icons.calendar_month_rounded,
        targets: [GuideTargetId.habitsDate],
        title: 'Any day',
        body: 'Tap the date to see how a past day went.',
      ),
      GuideStep(
        icon: Icons.speed_rounded,
        targets: [GuideTargetId.habitsScore],
        title: 'Daily score',
        body: "How much of today's habits are done. It feeds your Flow Score.",
      ),
      GuideStep(
        icon: Icons.touch_app_outlined,
        targets: [GuideTargetId.habitsToday, GuideTargetId.habitsEmpty],
        title: 'Check in',
        body:
            'Tap a habit to log it. Steps and sleep can sync from your health '
            'app.',
      ),
      GuideStep(
        icon: Icons.date_range_rounded,
        targets: [GuideTargetId.habitsWeekly],
        title: 'Your week',
        body: 'Which days you hit your habits, at a glance.',
      ),
      GuideStep(
        icon: Icons.add_task_rounded,
        targets: [GuideTargetId.habitsAdd],
        title: 'Add a habit',
        body: 'Track anything. Set the amount, unit and days it repeats.',
      ),
    ],
  );

  static const GuideFlow progress = GuideFlow(
    section: GuideSection.progress,
    label: 'PROGRESS GUIDE',
    finishLabel: _sectionFinish,
    steps: [
      GuideStep(
        icon: Icons.dashboard_outlined,
        targets: [GuideTargetId.progressOverview],
        title: 'At a glance',
        body: 'Your key numbers, up top.',
      ),
      GuideStep(
        icon: Icons.show_chart_rounded,
        targets: [GuideTargetId.progressFlowScore],
        title: 'Flow Score trend',
        body:
            'The quickest answer to "am I improving?". Your week, and how it '
            'compares to the last.',
      ),
      GuideStep(
        icon: Icons.monitor_weight_outlined,
        targets: [GuideTargetId.progressWeight],
        title: 'Weight',
        body: 'Log a weigh-in and follow the trend.',
      ),
      GuideStep(
        icon: Icons.emoji_events_outlined,
        targets: [GuideTargetId.progressAnalytics],
        title: 'Volume, habits, records',
        body:
            'Training volume, habit consistency and personal records. Part of '
            'Premium.',
      ),
      GuideStep(
        icon: Icons.lightbulb_outline_rounded,
        targets: [GuideTargetId.progressInsights],
        title: 'WAVE Insights',
        body:
            'Where you are improving, where you are slipping and what to focus '
            'on next.',
      ),
    ],
  );
}
