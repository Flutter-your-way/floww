import 'package:flutter/foundation.dart';

import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_program_service.dart';
import 'package:floww/core/yoga/data/yoga_module_data.dart';
import 'package:floww/core/yoga/models/yoga_class_section.dart';
import 'package:floww/core/yoga/models/yoga_course_view_data.dart';
import 'package:floww/core/yoga/models/yoga_profile.dart';
import 'package:floww/core/yoga/services/yoga_course_service.dart';
import 'package:floww/core/yoga/services/yoga_library_presenter.dart';
import 'package:floww/core/yoga/services/yoga_plan_mapper.dart';

class YogaCourseViewModel extends ChangeNotifier {
  YogaCourseViewModel(
    this._programService,
    this._catalogService,
    this._courseService,
  );

  final WorkoutProgramService _programService;
  final WorkoutCatalogService _catalogService;
  final YogaCourseService _courseService;

  YogaProfile _profile = YogaProfile.standard;
  int? _currentWeek;
  bool _isLoading = true;
  bool _disposed = false;

  bool get isLoading => _isLoading;

  YogaProfile get profile => _profile;

  bool get hasActiveCourse => _currentWeek != null;

  String get title => 'Hatha Yoga';

  String get brand => YogaModuleData.brand;

  String get heading => YogaModuleData.title;

  String get subtitle => YogaModuleData.subtitle;

  String get motto => YogaModuleData.motto;

  String get brandLong => YogaModuleData.brandLong;

  List<YogaPillarItem> get pillars => [
    for (final pillar in YogaModuleData.pillars)
      YogaPillarItem(name: pillar.name, meaning: pillar.meaning),
  ];

  List<String> get learningGoals => YogaModuleData.learningGoals;

  List<String> get safetyEssentials => YogaModuleData.safetyEssentials;

  String get disclaimer => YogaModuleData.disclaimer;

  String get publicationNote => YogaModuleData.publicationNote;

  List<String> get cautionNotes => [
    for (final caution in _profile.cautions)
      ?YogaModuleData.cautionNotes[caution],
  ];

  String get startLabel => "Start Today's Class";

  String get inactiveMessage =>
      'Start NYASP Hatha Foundations from Programs, or ask WAVE to build your '
      'yoga plan, and your classes will follow this course week by week.';

  List<YogaWeekItem> get weeks => [
    for (final week in YogaModuleData.weeks)
      YogaWeekItem(
        label: week.label,
        title: week.title,
        summary: week.summary,
        isCurrent: week.number == _currentWeek,
        isDone: _currentWeek != null && week.number < _currentWeek!,
      ),
  ];

  String get classTitle => 'The ${YogaModuleData.classMinutes}-minute class';

  List<YogaTimelineItem> get classTimeline => [
    for (final section in YogaClassSection.values)
      YogaTimelineItem(
        range: section.rangeLabel,
        title: section.title,
        detail: section.sequence,
      ),
  ];

  String get teachingNote => YogaModuleData.teachingNote;

  String get suryaIntro => YogaModuleData.suryaIntro;

  List<YogaTimelineItem> get suryaSteps =>
      YogaLibraryPresenter.suryaStepsOf(_profile);

  List<String> get suryaPacing => YogaModuleData.suryaPacing;

  List<YogaFamilyItem> get library => YogaLibraryPresenter.familiesOf(_profile);

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _courseService.loadProfile();
      final state = await _programService.loadState();
      final active = state.activeProgram;
      if (active != null) {
        final program = await _catalogService.programById(active.id);
        if (YogaPlanMapper.isCourse(program?.course)) {
          _currentWeek = YogaCourseService.weekOf(
            active,
            DateTime.now(),
            _profile,
          );
        }
      }
    } catch (_) {
      _currentWeek = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
