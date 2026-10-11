import 'package:flutter/material.dart';

enum WaveMemoryCategory {
  health,
  training,
  nutrition,
  schedule,
  preference,
  life;

  String get label => switch (this) {
    WaveMemoryCategory.health => 'Health & Injuries',
    WaveMemoryCategory.training => 'Training',
    WaveMemoryCategory.nutrition => 'Food & Nutrition',
    WaveMemoryCategory.schedule => 'Schedule',
    WaveMemoryCategory.preference => 'Coaching Preferences',
    WaveMemoryCategory.life => 'Life & Context',
  };

  IconData get icon => switch (this) {
    WaveMemoryCategory.health => Icons.healing_outlined,
    WaveMemoryCategory.training => Icons.fitness_center_rounded,
    WaveMemoryCategory.nutrition => Icons.restaurant_outlined,
    WaveMemoryCategory.schedule => Icons.event_outlined,
    WaveMemoryCategory.preference => Icons.tune_rounded,
    WaveMemoryCategory.life => Icons.person_outline_rounded,
  };
}

class WaveMemoryNote {
  const WaveMemoryNote({
    required this.id,
    required this.text,
    required this.category,
    required this.updatedAt,
  });

  factory WaveMemoryNote.fromJson(String id, Map<String, dynamic> json) =>
      WaveMemoryNote(
        id: id,
        text: (json['text'] as String? ?? '').trim(),
        category:
            WaveMemoryCategory.values.asNameMap()[json['category']] ??
            WaveMemoryCategory.life,
        updatedAt: DateTime.tryParse(
          json['updatedAt'] as String? ?? '',
        )?.toLocal(),
      );

  final String id;
  final String text;
  final WaveMemoryCategory category;
  final DateTime? updatedAt;
}
