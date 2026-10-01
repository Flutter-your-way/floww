import 'package:flutter/material.dart';

enum ProgramGoal {
  strength('strength', 'Strength', Icons.fitness_center),
  muscle('muscle', 'Muscle', Icons.sports_gymnastics),
  fatLoss('fat-loss', 'Fat Loss', Icons.local_fire_department, isPremium: true),
  cardio('cardio', 'Cardio', Icons.directions_run, isPremium: true),
  home('home', 'Home', Icons.home_rounded, isPremium: true),
  mobility('mobility', 'Mobility', Icons.self_improvement, isPremium: true);

  const ProgramGoal(this.id, this.label, this.icon, {this.isPremium = false});

  final String id;
  final String label;
  final IconData icon;
  final bool isPremium;

  static ProgramGoal fromId(String? id) => values.firstWhere(
    (goal) => goal.id == id,
    orElse: () => ProgramGoal.strength,
  );
}

enum ProgramLevel {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced'),
  allLevels('All Levels');

  const ProgramLevel(this.label);

  final String label;

  static ProgramLevel fromLabel(String? label) => values.firstWhere(
    (level) => level.label == label,
    orElse: () => ProgramLevel.allLevels,
  );
}
