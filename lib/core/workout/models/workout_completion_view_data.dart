import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import 'package:floww/core/workout/models/workout_completion.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';

class WorkoutCompleteItem {
  const WorkoutCompleteItem({
    required this.glyph,
    required this.title,
    required this.message,
    required this.scoreLabel,
    required this.previousScoreLabel,
    required this.newScoreLabel,
    required this.gainLabel,
    required this.gainCaption,
    required this.stats,
    required this.shareLabel,
    required this.doneLabel,
  });

  final String glyph;
  final String title;
  final String message;
  final String scoreLabel;
  final String previousScoreLabel;
  final String newScoreLabel;
  final String gainLabel;
  final String gainCaption;
  final List<WorkoutStatItem> stats;
  final String shareLabel;
  final String doneLabel;
}

class ShareStatItem {
  const ShareStatItem({
    required this.label,
    required this.value,
    required this.unit,
    this.glyph,
  });

  final String label;
  final String value;
  final String unit;
  final String? glyph;
}

class ShareTargetItem {
  const ShareTargetItem({
    required this.target,
    required this.label,
    this.icon,
    this.assetPath,
  });

  final ShareTarget target;
  final String label;
  final IconData? icon;
  final String? assetPath;
}

class WorkoutShareCardItem {
  const WorkoutShareCardItem({
    required this.brandLabel,
    required this.sessionLabel,
    required this.modeLabel,
    required this.caption,
    required this.headline,
    required this.stats,
    required this.tags,
    required this.siteLabel,
    required this.handleLabel,
    required this.hasPhotoSlot,
    required this.photoHint,
    required this.photoHintSuffix,
    this.photoBytes,
  });

  final String brandLabel;
  final String sessionLabel;
  final String? modeLabel;
  final String? caption;
  final String? headline;
  final List<ShareStatItem> stats;
  final List<String> tags;
  final String siteLabel;
  final String handleLabel;
  final bool hasPhotoSlot;
  final String photoHint;
  final String photoHintSuffix;
  final Uint8List? photoBytes;
}

class WorkoutShareItem {
  const WorkoutShareItem({
    required this.cards,
    required this.targets,
    required this.promptLabel,
  });

  final List<WorkoutShareCardItem> cards;
  final List<ShareTargetItem> targets;
  final String promptLabel;
}

class RecoveryMoodItem {
  const RecoveryMoodItem({
    required this.mood,
    required this.glyph,
    required this.label,
  });

  final RecoveryMood mood;
  final String glyph;
  final String label;
}

class RecoveryCheckInItem {
  const RecoveryCheckInItem({
    required this.title,
    required this.subtitle,
    required this.moods,
    required this.skipLabel,
    required this.saveLabel,
  });

  final String title;
  final String subtitle;
  final List<RecoveryMoodItem> moods;
  final String skipLabel;
  final String saveLabel;
}
