import 'package:flutter/material.dart';

enum ProgramGoal {
  strength(
    'strength',
    'Strength',
    Icons.fitness_center,
    headline: 'Raw strength',
    tagline: 'Get stronger on the big lifts, week after week',
  ),
  muscle(
    'muscle',
    'Muscle',
    Icons.sports_gymnastics,
    headline: 'Muscle and size',
    tagline: 'Hypertrophy training built around the basics',
  ),
  fatLoss(
    'fat-loss',
    'Fat Loss',
    Icons.local_fire_department,
    headline: 'Lean and fit',
    tagline: 'Burn fat while keeping the muscle you have',
    isPremium: true,
  ),
  cardio(
    'cardio',
    'Cardio',
    Icons.directions_run,
    headline: 'Engine and endurance',
    tagline: 'Build the stamina to go longer and harder',
    isPremium: true,
  ),
  home(
    'home',
    'Home',
    Icons.home_rounded,
    headline: 'Train at home',
    tagline: 'No gym needed, just you and some floor space',
    isPremium: true,
  ),
  mobility(
    'mobility',
    'Mobility',
    Icons.self_improvement,
    headline: 'Move better',
    tagline: 'Loosen up, recover faster and stay pain-free',
    isPremium: true,
  );

  const ProgramGoal(
    this.id,
    this.label,
    this.icon, {
    required this.headline,
    required this.tagline,
    this.isPremium = false,
  });

  final String id;
  final String label;
  final IconData icon;
  final String headline;
  final String tagline;
  final bool isPremium;

  static ProgramGoal fromId(String? id) => values.firstWhere(
    (goal) => goal.id == id,
    orElse: () => ProgramGoal.strength,
  );
}

enum ProgramKind {
  standard('standard'),
  skill('skill'),
  challenge('challenge');

  const ProgramKind(this.id);

  final String id;

  static ProgramKind fromId(String? id) => values.firstWhere(
    (kind) => kind.id == id,
    orElse: () => ProgramKind.standard,
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
