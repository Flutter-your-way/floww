import 'package:flutter/foundation.dart';

import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/widgets/buttons/select_buttons/weekday_picker.dart';
import 'package:floww/core/workout/models/add_exercise_view_data.dart';
import 'package:floww/core/workout/models/program_editor_view_data.dart';
import 'package:floww/core/workout/models/program_goal.dart';
import 'package:floww/core/workout/models/program_start_config.dart';
import 'package:floww/core/workout/models/set_type.dart';
import 'package:floww/core/workout/models/workout_section_kind.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';
import 'package:floww/core/workout/services/workout_program_service.dart';

class ProgramEditorViewModel extends ChangeNotifier {
  ProgramEditorViewModel(
    this._catalogService,
    this._programService,
    this._planService,
    this._args,
  );

  static const int _minWeeks = 1;
  static const int _maxWeeks = 24;
  static const int _defaultWeeks = 8;
  static const int _minSets = 1;
  static const int _maxSets = 10;
  static const int _minReps = 1;
  static const int _maxReps = 60;
  static const int _secondsPerMinute = 60;
  static const int _secondsPerSet = 40;
  static const int _minDayMinutes = 10;
  static const int _defaultSets = 3;
  static const int _defaultReps = 10;
  static const int _defaultRestSeconds = 60;
  static const String _loadFailure = 'Could not load this program.';

  final WorkoutCatalogService _catalogService;
  final WorkoutProgramService _programService;
  final WorkoutPlanService _planService;
  final ProgramEditorArgs _args;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _disposed = false;
  String? _errorMessage;
  Map<String, ExerciseCatalogEntry> _catalog = const {};
  WorkoutProgramEntity? _source;
  String _programId = '';
  String _name = '';
  String _description = '';
  ProgramGoal _goal = ProgramGoal.strength;
  ProgramLevel _level = ProgramLevel.beginner;
  int _weeks = _defaultWeeks;
  List<ProgramDayEntry> _days = [];

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final exercises = await _catalogService.loadExercises();
      _catalog = {for (final exercise in exercises) exercise.id: exercise};
      final sourceId = _args.programId;
      final source = sourceId == null
          ? null
          : await _catalogService.programById(sourceId);
      _source = source;
      if (source == null) {
        _programId = _catalogService.newProgramId();
      } else {
        _programId = _args.editExisting
            ? source.id
            : _catalogService.newProgramId();
        _name = _args.editExisting ? source.name : 'My ${source.name}';
        _description = source.description;
        _goal = source.goal;
        _level = ProgramLevel.fromLabel(source.level);
        _weeks = source.weeks;
        _days = [...source.days]
          ..sort((a, b) => a.weekday.compareTo(b.weekday));
      }
    } on WorkoutException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = _loadFailure;
    }
    _isLoading = false;
    notifyListeners();
  }

  String get title => _args.editExisting
      ? 'Edit Program'
      : _source == null
      ? 'New Program'
      : 'Customize Program';

  String get name => _name;

  String get nameLabel => 'Program name';

  String get nameHint => 'e.g. Summer Strength';

  String get goalLabel => 'Goal';

  String get levelLabel => 'Level';

  String get lengthLabel => 'Length';

  String get daysLabel => 'Training days';

  String get daysHint => _days.isEmpty
      ? 'Tap the days you want to train'
      : '${_days.length} ${_days.length == 1 ? 'day' : 'days'} a week';

  String get addExerciseLabel => 'Add exercise';

  String get saveLabel => 'Save program';

  String get dayNameHint => 'Session name';

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  List<ProgramFilterItem<ProgramGoal>> get goalOptions => [
    for (final goal in ProgramGoal.values)
      ProgramFilterItem(
        value: goal,
        label: goal.label,
        isSelected: goal == _goal,
      ),
  ];

  void selectGoal(ProgramGoal goal) {
    if (goal == _goal) return;
    _goal = goal;
    notifyListeners();
  }

  List<ProgramFilterItem<ProgramLevel>> get levelOptions => [
    for (final level in ProgramLevel.values)
      ProgramFilterItem(
        value: level,
        label: level.label,
        isSelected: level == _level,
      ),
  ];

  void selectLevel(ProgramLevel level) {
    if (level == _level) return;
    _level = level;
    notifyListeners();
  }

  AddExerciseTargetItem get weeksTarget => AddExerciseTargetItem(
    label: 'Weeks',
    value: '$_weeks',
    unit: _weeks == 1 ? 'week' : 'weeks',
    canDecrease: _weeks > _minWeeks,
    canIncrease: _weeks < _maxWeeks,
  );

  void adjustWeeks(int delta) {
    final next = (_weeks + delta).clamp(_minWeeks, _maxWeeks);
    if (next == _weeks) return;
    _weeks = next;
    notifyListeners();
  }

  DateTime _dateOfWeekday(int weekday) => AppDateUtils.addDays(
    AppDateUtils.startOfWeek(DateTime.now()),
    weekday - DateTime.monday,
  );

  List<WeekdayPickerItem> get weekdayItems => [
    for (var i = 0; i < DateTime.daysPerWeek; i++)
      WeekdayPickerItem(
        weekday: DateTime.monday + i,
        label: AppDateUtils.shortWeekday(
          _dateOfWeekday(DateTime.monday + i),
        ).substring(0, 1),
        isSelected: _days.any((day) => day.weekday == DateTime.monday + i),
      ),
  ];

  void toggleWeekday(int weekday) {
    final existing = _days.indexWhere((day) => day.weekday == weekday);
    if (existing >= 0) {
      _days = [..._days]..removeAt(existing);
    } else {
      _days = [
        ..._days,
        ProgramDayEntry(
          weekday: weekday,
          name: '${AppDateUtils.weekdayName(_dateOfWeekday(weekday))} Session',
          focus: _goal.label,
          goal: '',
          durationMinutes: _minDayMinutes,
          exercises: const [],
        ),
      ]..sort((a, b) => a.weekday.compareTo(b.weekday));
    }
    notifyListeners();
  }

  int _dayIndexOf(int weekday) =>
      _days.indexWhere((day) => day.weekday == weekday);

  void _updateDay(int weekday, ProgramDayEntry Function(ProgramDayEntry) map) {
    final index = _dayIndexOf(weekday);
    if (index < 0) return;
    _days = [..._days]..[index] = map(_days[index]);
    notifyListeners();
  }

  void renameDay(int weekday, String name) =>
      _updateDay(weekday, (day) => day.copyWith(name: name));

  int _setsOf(ProgramExerciseEntry entry) =>
      entry.sets ?? _catalog[entry.exerciseId]?.defaultSets ?? _defaultSets;

  int _repsOf(ProgramExerciseEntry entry) =>
      entry.reps ?? _catalog[entry.exerciseId]?.defaultReps ?? _defaultReps;

  int _restOf(ProgramExerciseEntry entry) =>
      entry.restSeconds ??
      _catalog[entry.exerciseId]?.defaultRestSeconds ??
      _defaultRestSeconds;

  bool _isTimed(ProgramExerciseEntry entry) =>
      _catalog[entry.exerciseId]?.trackingMode == TrackingMode.duration;

  String _nameOf(ProgramExerciseEntry entry) =>
      _catalog[entry.exerciseId]?.name ?? entry.exerciseId;

  String _targetLabelOf(ProgramExerciseEntry entry) =>
      '${_setsOf(entry)} × ${_repsOf(entry)}${_isTimed(entry) ? 's' : ''}';

  int _minutesOf(ProgramDayEntry day) {
    var seconds = 0;
    for (final entry in day.exercises) {
      seconds += _setsOf(entry) * (_restOf(entry) + _secondsPerSet);
    }
    final minutes = (seconds / _secondsPerMinute).round();
    return minutes < _minDayMinutes ? _minDayMinutes : minutes;
  }

  List<ProgramEditorDayItem> get days => [
    for (final day in _days)
      ProgramEditorDayItem(
        weekday: day.weekday,
        weekdayLabel: AppDateUtils.weekdayName(
          _dateOfWeekday(day.weekday),
        ).toUpperCase(),
        name: day.name,
        summaryLabel:
            '${day.exercises.length} '
            '${day.exercises.length == 1 ? 'exercise' : 'exercises'} · '
            '~${_minutesOf(day)} min',
        exercises: [
          for (var i = 0; i < day.exercises.length; i++)
            ProgramEditorExerciseItem(
              index: i,
              glyph: day.exercises[i].section.glyph,
              name: _nameOf(day.exercises[i]),
              targetLabel: _targetLabelOf(day.exercises[i]),
            ),
        ],
      ),
  ];

  List<AddExerciseSectionOption> get sections => [
    for (final kind in WorkoutSectionKind.values)
      AddExerciseSectionOption(
        id: kind.id,
        glyph: kind.glyph,
        title: kind.title,
      ),
  ];

  String get defaultSectionId => WorkoutSectionKind.main.id;

  void addExercise(int weekday, String sectionId, WorkoutEntryEntity entry) {
    final section = WorkoutSectionKind.fromId(sectionId);
    _updateDay(weekday, (day) {
      final exercises = [
        ...day.exercises,
        ProgramExerciseEntry(
          exerciseId: entry.exerciseId,
          section: section,
          sets: entry.targetSets,
          reps: entry.targetReps,
          restSeconds: entry.restSeconds,
          repsInReserve: entry.repsInReserve,
          weightKg: entry.targetWeightKg,
        ),
      ];
      final ordered = <ProgramExerciseEntry>[
        for (final kind in WorkoutSectionKind.values)
          for (final exercise in exercises)
            if (exercise.section == kind) exercise,
      ];
      return day.copyWith(exercises: ordered);
    });
  }

  void removeExercise(int weekday, int index) => _updateDay(
    weekday,
    (day) => day.copyWith(exercises: [...day.exercises]..removeAt(index)),
  );

  ProgramExerciseEntry? _exerciseAt(int weekday, int index) {
    final dayIndex = _dayIndexOf(weekday);
    if (dayIndex < 0) return null;
    final exercises = _days[dayIndex].exercises;
    return index < exercises.length ? exercises[index] : null;
  }

  ProgramExerciseEditItem? exerciseEditFor(int weekday, int index) {
    final entry = _exerciseAt(weekday, index);
    if (entry == null) return null;
    final sets = _setsOf(entry);
    final reps = _repsOf(entry);
    return ProgramExerciseEditItem(
      name: _nameOf(entry),
      sectionLabel: '${entry.section.glyph} ${entry.section.title}',
      setsTarget: AddExerciseTargetItem(
        label: 'Sets',
        value: '$sets',
        unit: '',
        canDecrease: sets > _minSets,
        canIncrease: sets < _maxSets,
      ),
      repsTarget: AddExerciseTargetItem(
        label: _isTimed(entry) ? 'Seconds' : 'Reps',
        value: '$reps',
        unit: '',
        canDecrease: reps > _minReps,
        canIncrease: reps < _maxReps,
      ),
    );
  }

  void _updateExercise(
    int weekday,
    int index,
    ProgramExerciseEntry Function(ProgramExerciseEntry) map,
  ) => _updateDay(weekday, (day) {
    if (index >= day.exercises.length) return day;
    return day.copyWith(
      exercises: [...day.exercises]..[index] = map(day.exercises[index]),
    );
  });

  void adjustSets(int weekday, int index, int delta) => _updateExercise(
    weekday,
    index,
    (entry) => entry.copyWith(
      sets: (_setsOf(entry) + delta).clamp(_minSets, _maxSets),
    ),
  );

  void adjustReps(int weekday, int index, int delta) => _updateExercise(
    weekday,
    index,
    (entry) => entry.copyWith(
      reps: (_repsOf(entry) + delta).clamp(_minReps, _maxReps),
    ),
  );

  String? get validationMessage {
    if (_name.trim().isEmpty) return 'Give your program a name.';
    if (_days.isEmpty) return 'Pick at least one training day.';
    for (final day in _days) {
      if (day.exercises.isEmpty) {
        return 'Add at least one exercise to '
            '${AppDateUtils.weekdayName(_dateOfWeekday(day.weekday))}.';
      }
      if (day.name.trim().isEmpty) {
        return 'Name the '
            '${AppDateUtils.weekdayName(_dateOfWeekday(day.weekday))} session.';
      }
    }
    return null;
  }

  bool get canSave => !_isLoading && !_isSaving && validationMessage == null;

  Future<String?> save() async {
    if (!canSave) return null;
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    final source = _source;
    final program = WorkoutProgramEntity(
      id: _programId,
      name: _name.trim(),
      description: _description.isNotEmpty
          ? _description
          : '${_days.length} custom sessions a week',
      level: _level.label,
      weeks: _weeks,
      deloadEvery: source?.deloadEvery ?? 0,
      goal: _goal,
      isCustom: true,
      basedOn: _args.editExisting ? source?.basedOn : source?.id,
      lengthDays: _args.editExisting ? source?.lengthDays ?? 0 : 0,
      isGenerated: _args.editExisting && (source?.isGenerated ?? false),
      days: [
        for (final day in _days)
          day.copyWith(name: day.name.trim(), durationMinutes: _minutesOf(day)),
      ],
    );
    try {
      await _catalogService.saveProgram(program);
      await _syncActive(program);
      _isSaving = false;
      notifyListeners();
      return program.id;
    } on WorkoutException catch (error) {
      _errorMessage = error.message;
      _isSaving = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> _syncActive(WorkoutProgramEntity program) async {
    final state = await _programService.loadState();
    final active = state.activeProgram;
    if (active == null || active.id != program.id) return;
    final updated = active.withProgram(program);
    await _planService.scheduleProgram(
      program,
      updated,
      from: AppDateUtils.dateOnly(DateTime.now()),
      saveActive: true,
    );
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
