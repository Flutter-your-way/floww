import 'package:flutter/material.dart';

import 'package:floww/core/workout/models/active_workout_view_data.dart';
import 'package:floww/core/workout/models/exercise_info.dart';
import 'package:floww/core/yoga/data/yoga_module_data.dart';
import 'package:floww/core/yoga/models/yoga_posture.dart';
import 'package:floww/core/yoga/models/yoga_profile.dart';

class YogaLessonViewModel extends ChangeNotifier {
  YogaLessonViewModel(this.posture, this._profile);

  static const String _goalId = 'goal';
  static const String _safetyId = 'safety';
  static const String _entryId = 'entry';
  static const String _exitId = 'exit';
  static const String _breathId = 'breath';
  static const String _modificationsId = 'modifications';
  static const String _holdId = 'hold';
  static const String _propsId = 'props';

  final YogaPosture posture;
  final YogaProfile _profile;

  String? _expandedId = _entryId;

  String get title => posture.name;

  String get subtitle => posture.sanskritName ?? posture.family.title;

  String get imageUrl => posture.imageUrl;

  String get summary => posture.summary;

  String get disclaimer => YogaModuleData.disclaimer;

  bool get isCautioned => posture.isCautionedFor(_profile.cautions);

  String get cautionTitle => 'Consider skipping this pose';

  String get cautionMessage =>
      'You told WAVE about ${_cautionLabels.join(', ').toLowerCase()} '
      'limitations. Use the modifications below or choose the alternative.';

  Iterable<String> get _cautionLabels => [
    for (final caution in posture.cautions)
      if (_profile.cautions.contains(caution)) caution.label,
  ];

  void toggle(String id) {
    _expandedId = _expandedId == id ? null : id;
    notifyListeners();
  }

  List<ExerciseInfoSectionItem> get sections => [
    _section(_goalId, Icons.flag_outlined, 'Lesson goal', ExerciseInfoTone.neutral, [
      ExerciseInfoItem(text: posture.goal),
    ]),
    _section(
      _safetyId,
      Icons.health_and_safety_outlined,
      'Safety reminder',
      ExerciseInfoTone.negative,
      [for (final text in posture.avoid) ExerciseInfoItem(text: text)],
    ),
    _section(
      _entryId,
      Icons.login_rounded,
      'Step-by-step entry',
      ExerciseInfoTone.positive,
      _numbered(posture.entrySteps),
    ),
    _section(
      _exitId,
      Icons.logout_rounded,
      'Exit',
      ExerciseInfoTone.neutral,
      _numbered(posture.exitSteps),
    ),
    _section(
      _breathId,
      Icons.air_rounded,
      'Breath and alignment cues',
      ExerciseInfoTone.positive,
      [
        for (final text in posture.breathCues)
          ExerciseInfoItem(label: 'Breath', text: text),
        for (final text in posture.alignmentCues)
          ExerciseInfoItem(label: 'Align', text: text),
      ],
    ),
    _section(
      _modificationsId,
      Icons.tune_rounded,
      'Modifications',
      ExerciseInfoTone.neutral,
      _modifications,
    ),
    _section(_holdId, Icons.timer_outlined, 'Hold or repetitions', ExerciseInfoTone.neutral, [
      ExerciseInfoItem(text: posture.holdGuidance),
      if (posture.isPerSide)
        const ExerciseInfoItem(text: 'Practise both sides evenly.'),
    ]),
    _section(
      _propsId,
      Icons.inventory_2_outlined,
      'Props',
      ExerciseInfoTone.neutral,
      [
        for (final prop in posture.props)
          ExerciseInfoItem(
            label: prop.label,
            text: _profile.owns(prop)
                ? prop.text
                : '${prop.text} — or ${prop.substitute.toLowerCase()}',
          ),
      ],
    ),
  ];

  List<ExerciseInfoItem> get _modifications {
    final personal = <ExerciseInfoItem>[];
    final general = <ExerciseInfoItem>[];
    for (final modification in posture.modifications) {
      final caution = modification.caution;
      if (caution == null) {
        general.add(ExerciseInfoItem(text: modification.text));
      } else if (_profile.cautions.contains(caution)) {
        personal.add(
          ExerciseInfoItem(label: 'Your ${caution.label}', text: modification.text),
        );
      }
    }
    final remaining = [
      for (final modification in posture.modifications)
        if (modification.caution case final caution?)
          if (!_profile.cautions.contains(caution))
            ExerciseInfoItem(label: caution.label, text: modification.text),
    ];
    return [...personal, ...general, ...remaining];
  }

  List<ExerciseInfoItem> _numbered(List<String> steps) => [
    for (var i = 0; i < steps.length; i++)
      ExerciseInfoItem(label: '${i + 1}', text: steps[i]),
  ];

  ExerciseInfoSectionItem _section(
    String id,
    IconData icon,
    String title,
    ExerciseInfoTone tone,
    List<ExerciseInfoItem> items,
  ) => ExerciseInfoSectionItem(
    id: id,
    icon: icon,
    title: title,
    tone: tone,
    items: items,
    isExpanded: _expandedId == id,
  );
}
