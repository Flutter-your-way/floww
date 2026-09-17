import 'package:flutter/material.dart';

enum ExerciseInfoTone { positive, negative, neutral }

class ExerciseInfoItem {
  const ExerciseInfoItem({required this.text, this.label});

  final String text;
  final String? label;
}

class ExerciseInfoSection {
  const ExerciseInfoSection({
    required this.id,
    required this.icon,
    required this.title,
    required this.tone,
    required this.items,
    this.emptyMessage,
  });

  final String id;
  final IconData icon;
  final String title;
  final ExerciseInfoTone tone;
  final List<ExerciseInfoItem> items;
  final String? emptyMessage;
}
