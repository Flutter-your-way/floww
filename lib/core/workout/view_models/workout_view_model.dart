import 'dart:async';

import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_images.dart';

import 'package:floww/config/entities/exercise_video_entity.dart';
import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/services/exercise_video_service.dart';
import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/dates/date_change_direction.dart';
import 'package:floww/config/utils/dates/day_rollover_timer.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/calisthenics/models/cal_level.dart';
import 'package:floww/core/calisthenics/services/calisthenics_placement.dart';
import 'package:floww/core/calisthenics/models/cal_library_view_data.dart';
import 'package:floww/core/calisthenics/services/calisthenics_library_presenter.dart';
import 'package:floww/core/calisthenics/services/calisthenics_principles_service.dart';
import 'package:floww/core/onboarding/data/onboarding_data.dart';
import 'package:floww/core/recovery/models/muscle_body_side.dart';
import 'package:floww/core/recovery/services/muscle_map_service.dart';
import 'package:floww/core/recovery/services/muscle_targeting.dart';
import 'package:floww/core/settings/services/onboarding_answers_service.dart';
import 'package:floww/core/wave/models/wave_pending_plan.dart';
import 'package:floww/core/wave/services/wave_plan_approval_service.dart';
import 'package:floww/core/workout/models/active_workout_args.dart';
import 'package:floww/core/workout/models/program_artwork.dart';
import 'package:floww/core/workout/models/program_goal.dart';
import 'package:floww/core/workout/models/program_start_config.dart';
import 'package:floww/core/workout/models/todays_workout_args.dart';
import 'package:floww/core/workout/models/workout_course_view_data.dart';
import 'package:floww/core/workout/models/workout_discipline.dart';
import 'package:floww/core/workout/models/workout_history.dart';
import 'package:floww/core/workout/models/workout_shift_offer.dart';
import 'package:floww/core/workout/models/workout_tab.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/services/workout_catalog_data.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_extras_data.dart';
import 'package:floww/core/workout/services/workout_course_presenter.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';
import 'package:floww/core/workout/services/workout_history_analyzer.dart';
import 'package:floww/core/workout/services/workout_metrics.dart';
import 'package:floww/core/workout/services/workout_plan_generator_service.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';
import 'package:floww/core/workout/services/workout_program_service.dart';
import 'package:floww/core/workout/services/workout_plan_banner_service.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';
import 'package:floww/core/workout/services/workout_shift_service.dart';
import 'package:floww/core/yoga/data/yoga_module_data.dart';
import 'package:floww/core/yoga/models/yoga_course_view_data.dart';
import 'package:floww/core/yoga/models/yoga_profile.dart';
import 'package:floww/core/yoga/services/yoga_course_service.dart';
import 'package:floww/core/yoga/services/yoga_library_presenter.dart';
import 'package:floww/core/yoga/services/yoga_plan_mapper.dart';

enum WorkoutDayStatus { past, today, future }

enum WorkoutPrimaryAction { start, resume }

class WorkoutViewModel extends ChangeNotifier {
  WorkoutViewModel(
    this._sessionService,
    this._planService,
    this._programService,
    this._catalogService,
    this._generatorService, {
    OnboardingAnswersService? answersService,
    CalisthenicsPrinciplesService? principlesService,
    MuscleMapService? muscleMapService,
    WavePlanApprovalService? approvalService,
    ExerciseVideoService? videoService,
  }) : _selectedDate = AppDateUtils.dateOnly(DateTime.now()),
       _approvalService = approvalService ?? WavePlanApprovalService(),
       _videoService = videoService ?? ExerciseVideoService(),
       _muscleMapService = muscleMapService ?? MuscleMapService(),
       _answersService = answersService ?? OnboardingAnswersService(),
       _principlesService =
           principlesService ?? CalisthenicsPrinciplesService(),
       _shiftService = WorkoutShiftService(_planService) {
    _dayRollover = DayRolloverTimer(_onNewDay);
    unawaited(_loadCalPrinciplesRead());
    unawaited(_loadPlanBannerDismissed());
    unawaited(_loadMuscleMap());
    _watchPendingPlan();
    _start();
  }

  static const String _pendingPlanTitle = 'New plan waiting for approval';
  static const String _pendingPlanMessage =
      'WAVE has a plan change ready for you. Nothing in Workouts changes '
      'until you approve it in the chat.';
  static const String _pendingPlanAction = 'Review in WAVE';

  final WavePlanApprovalService _approvalService;
  StreamSubscription<WavePendingPlan?>? _pendingPlanSubscription;
  WavePendingPlan? _pendingPlan;

  DateTime? get pendingPlanDay => _pendingPlan?.day;

  WorkoutPlanBuilderItem? get pendingPlanBanner => _pendingPlan == null
      ? null
      : const WorkoutPlanBuilderItem(
          title: _pendingPlanTitle,
          message: _pendingPlanMessage,
          actionLabel: _pendingPlanAction,
        );

  void _watchPendingPlan() {
    _pendingPlanSubscription = _approvalService.watch().listen((pending) {
      _pendingPlan = pending;
      notifyListeners();
    }, onError: (Object error) => debugPrint('pending plan failed: $error'));
  }

  static const int _selectableRangeDays = 365;
  static const int _weekdayReferenceDays = 6;
  static const int _heartRateAxisSteps = 4;
  static const int _secondsPerMinute = 60;
  static const String _loadFailure = 'Could not load your workouts.';
  static const int _historyMinWeeks = 8;
  static const int _historyMaxDays = 182;
  static const int _percent = 100;
  static const double _strongAdherence = 0.8;
  static const int _strongAdherenceMinPlanned = 3;
  static const int _agendaMinEntries = 2;
  static const int _longPlanDays = 90;
  static const int _reportWeeks = 4;
  static const double _readyAdherence = 0.8;
  static const double _steadyAdherence = 0.6;
  static const double _minComfortReserve = 1;
  static const int _challengeEpochYear = 2024;
  static const String _gymExperienceKey = 'gym_experience';
  static const String _yogaExperienceKey = 'yoga_experience';
  static const String _allFilter = 'all';
  static const String _mineFilter = 'mine';
  static const int _calThumbnailBatch = 4;

  final WorkoutSessionService _sessionService;
  final WorkoutPlanService _planService;
  final WorkoutProgramService _programService;
  final WorkoutCatalogService _catalogService;
  final WorkoutPlanGeneratorService _generatorService;
  final WorkoutShiftService _shiftService;
  final OnboardingAnswersService _answersService;
  final CalisthenicsPrinciplesService _principlesService;
  final WorkoutPlanBannerService _planBannerService =
      WorkoutPlanBannerService();
  final MuscleMapService _muscleMapService;
  final ExerciseVideoService _videoService;
  final Map<String, String> _calThumbnails = {};
  final Set<String> _calThumbnailsLoading = {};
  bool _calThumbnailsRequested = false;
  bool? _calPrinciplesRead;

  StreamSubscription<Map<String, dynamic>>? _answersSubscription;
  StreamSubscription<List<WorkoutSessionEntity>>? _sessionSubscription;
  String? _sessionSignature;
  StreamSubscription<WorkoutStateEntity>? _stateSubscription;
  StreamSubscription<List<WorkoutProgramEntity>>? _programSubscription;
  StreamSubscription<WorkoutPlanEntity?>? _planSubscription;
  StreamSubscription<List<WorkoutPlanEntity>>? _catchUpSubscription;

  DateTime _selectedDate;
  DateChangeDirection _dateDirection = DateChangeDirection.forward;
  WorkoutTab _selectedTab = WorkoutTab.overview;
  bool _tabReverse = false;
  late final DayRolloverTimer _dayRollover;

  List<WorkoutSessionEntity> _sessions = const [];
  List<WorkoutProgramEntity> _allPrograms = const [];
  Map<String, dynamic> _answers = const {};
  WorkoutDiscipline _discipline = WorkoutDiscipline.gym;
  WorkoutStateEntity _state = WorkoutStateEntity.empty;
  WorkoutPlanEntity? _plan;
  List<WorkoutPlanEntity> _catchUps = const [];
  String? _focusedSessionId;
  bool _isBuildingPlan = false;
  bool _isPlanBannerDismissed = false;
  bool _isRenamingPlan = false;
  bool _autoBuildTried = false;
  String? _planBuildError;
  WorkoutShiftOffer? _shiftOffer;
  bool _isShifting = false;
  int _shiftRequest = 0;
  String _goalFilter = _allFilter;
  String? _levelFilter;
  WorkoutDiscipline? _catalogDiscipline;
  bool _isStartingExtra = false;
  bool _isBrowsingPrograms = true;
  List<WorkoutPlanEntity> _historyPlans = const [];
  List<Object?>? _historyCacheInputs;
  WorkoutHistoryOverviewItem? _historyCache;
  DateTime? _historyFrom;
  bool _historyLoaded = false;
  bool _showEarlierHistory = false;
  bool _isHealingPlan = false;
  bool _metricsRefreshed = false;
  String? _healedProgramKey;
  int _historyRequest = 0;
  bool _isLoading = true;
  bool _disposed = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  WorkoutDiscipline get discipline => _discipline;

  WorkoutDiscipline get catalogDiscipline => _catalogDiscipline ?? _discipline;

  List<WorkoutProgramEntity> get _programs => [
    for (final program in _allPrograms)
      if (catalogDiscipline.matches(program)) program,
  ];

  WorkoutProgramEntity? get _activeProgramEntity {
    final active = _state.activeProgram;
    return active == null ? null : _programById(active.id);
  }

  CalLevel? get _courseLevel =>
      CalLevel.fromCourse(_activeProgramEntity?.course);

  bool get _isYogaCourseActive =>
      YogaPlanMapper.isCourse(_activeProgramEntity?.course);

  YogaProfile get yogaProfile => YogaCourseService.profileOf(_answers);

  WorkoutCourseItem? get course {
    if (!isOverviewTab || dayStatus == WorkoutDayStatus.past) return null;
    if (showSuggestion) return null;
    final active = _state.activeProgram;
    if (active == null) return null;
    final level = _courseLevel;
    if (_discipline == WorkoutDiscipline.calisthenics && level != null) {
      return WorkoutCoursePresenter.calisthenics(
        level: level,
        active: active,
        date: _selectedDate,
        answers: _answers,
      );
    }
    if (_discipline == WorkoutDiscipline.yoga && _isYogaCourseActive) {
      return WorkoutCoursePresenter.yoga(
        active: active,
        date: _selectedDate,
        answers: _answers,
      );
    }
    return null;
  }

  List<YogaFamilyItem> get yogaLibrary =>
      YogaLibraryPresenter.familiesOf(yogaProfile);

  List<YogaTimelineItem> get yogaSuryaSteps =>
      YogaLibraryPresenter.suryaStepsOf(yogaProfile);

  String get yogaSuryaIntro => YogaModuleData.suryaIntro;

  CalLevel get calLevel => _courseLevel ?? CalLevel.one;

  String get calLevelLabel => calLevel.fullTitle;

  List<CalLadderItem> get calLadders {
    unawaited(_loadCalThumbnails());
    return CalisthenicsLibraryPresenter.laddersOf(
      calLevel,
      thumbnails: _calThumbnails,
      loadingIds: _calThumbnailsLoading,
    );
  }

  Future<void> _loadCalThumbnails() async {
    if (_calThumbnailsRequested) return;
    _calThumbnailsRequested = true;
    final pending = CalisthenicsLibraryPresenter.ladderMoveIds.toSet().toList();
    _calThumbnailsLoading.addAll(pending);
    for (var i = 0; i < pending.length; i += _calThumbnailBatch) {
      final batch = pending.skip(i).take(_calThumbnailBatch);
      final results = await Future.wait([
        for (final id in batch) _calThumbnailOf(id),
      ]);
      if (_disposed) return;
      for (final (id, url) in results) {
        _calThumbnailsLoading.remove(id);
        if (url != null) _calThumbnails[id] = url;
      }
      notifyListeners();
    }
  }

  Future<(String, String?)> _calThumbnailOf(String moveId) async {
    final video = await _videoService.find(
      kind: ExerciseVideoKind.gym,
      queries: CalisthenicsLibraryPresenter.searchQueriesOf(moveId),
    );
    return (moveId, video?.thumbnailUrl);
  }

  List<CalRoutineItem> get calWarmUp => CalisthenicsLibraryPresenter.warmUp;

  List<CalRoutineItem> get calCoolDown => CalisthenicsLibraryPresenter.coolDown;

  List<String> get calPrinciples => CalisthenicsLibraryPresenter.principles;

  List<String> get calSafety => CalisthenicsLibraryPresenter.safety;

  String get calPrinciplesTitle => 'Principles & safety';

  String get calPrinciplesSummary {
    final count = calPrinciples.length + calSafety.length;
    return '$count rules to train strong and safe';
  }

  bool get showCalPrinciplesBadge => _calPrinciplesRead == false;

  void markCalPrinciplesRead() {
    if (_calPrinciplesRead == true) return;
    _calPrinciplesRead = true;
    notifyListeners();
    unawaited(_principlesService.markRead());
  }

  Future<void> _loadCalPrinciplesRead() async {
    final read = await _principlesService.hasRead();
    if (_calPrinciplesRead == true) return;
    _calPrinciplesRead = read;
    notifyListeners();
  }

  String get currentProgramName =>
      _state.activeProgram?.name ?? 'No program yet';

  bool get isCurrentProgramWave {
    final active = _state.activeProgram;
    return active != null && active.id == _state.generatedProgramId;
  }

  String get changeProgramLabel =>
      _state.activeProgram == null ? 'Choose program' : 'Change program';

  void openProgramSwitcher() => selectTab(WorkoutTab.programs);

  bool get canCreateProgram =>
      _discipline == WorkoutDiscipline.gym &&
      catalogDiscipline == WorkoutDiscipline.gym;

  bool get _activeMatchesDiscipline {
    final program = _activeProgramEntity;
    if (program == null || program.id != _state.generatedProgramId) {
      return true;
    }
    return _discipline.matches(program);
  }

  String? get errorMessage => _errorMessage;

  List<WorkoutTab> get tabs => WorkoutTab.values;

  WorkoutTab get selectedTab => _selectedTab;

  bool get tabReverse => _tabReverse;

  DateTime get selectedDate => _selectedDate;

  DateChangeDirection get dateDirection => _dateDirection;

  DateTime get _today => AppDateUtils.dateOnly(DateTime.now());

  DateTime get firstSelectableDate =>
      AppDateUtils.addDays(_today, -_selectableRangeDays);

  DateTime get lastSelectableDate =>
      AppDateUtils.addDays(_today, _selectableRangeDays);

  bool get canGoPrevious => _selectedDate.isAfter(firstSelectableDate);

  bool get canGoNext => _selectedDate.isBefore(lastSelectableDate);

  WorkoutDayStatus get dayStatus {
    final today = _today;
    if (AppDateUtils.isSameDay(_selectedDate, today)) {
      return WorkoutDayStatus.today;
    }
    return _selectedDate.isAfter(today)
        ? WorkoutDayStatus.future
        : WorkoutDayStatus.past;
  }

  bool get isOverviewTab => _selectedTab == WorkoutTab.overview;

  bool get showDateSelector => isOverviewTab;

  String get titlePrefix => !showDateSelector
      ? 'Your'
      : dayStatus == WorkoutDayStatus.today
      ? 'Today\'s'
      : '${AppDateUtils.weekdayName(_selectedDate)}\'s';

  String get dateLabel => AppDateUtils.dayMonth(
    _selectedDate,
    withYear: _selectedDate.year != _today.year,
  );

  Future<void> _start() async {
    try {
      await _catalogService.ensureSeeded();
    } on WorkoutException catch (error) {
      _onError(error);
      return;
    }

    _answersSubscription = _answersService.watchAnswers().listen((answers) {
      _answers = answers;
      final discipline = WorkoutDiscipline.fromAnswers(answers);
      if (discipline != _discipline) {
        _discipline = discipline;
        _catalogDiscipline = null;
        _goalFilter = _allFilter;
        _levelFilter = null;
        _isBrowsingPrograms = true;
        _shiftOffer = null;
        unawaited(_refreshShiftOffer());
      }
      notifyListeners();
    }, onError: (_) {});

    _sessionSubscription = _sessionService.watchRecentSessions().listen((
      sessions,
    ) {
      _sessions = sessions;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      final signature = [
        for (final session in sessions) '${session.id}:${session.status.name}',
      ].join(',');
      if (signature != _sessionSignature) {
        _sessionSignature = signature;
        unawaited(_refreshShiftOffer());
      }
      unawaited(_refreshStaleMetrics());
      final loadedFrom = _historyFrom;
      if (loadedFrom == null || _historyStart.isBefore(loadedFrom)) {
        _reloadHistoryIfVisible();
      }
    }, onError: _onError);

    _stateSubscription = _programService.watchState().listen((state) {
      _state = state;
      notifyListeners();
      if (!_autoBuildTried && !state.hasGeneratedPlan) {
        _autoBuildTried = true;
        unawaited(buildPlan(showResult: false));
      }
      unawaited(_ensurePlan());
      unawaited(_refreshShiftOffer());
      _reloadHistoryIfVisible();
    }, onError: _onError);

    _programSubscription = _catalogService.watchPrograms().listen((programs) {
      _allPrograms = programs;
      notifyListeners();
      unawaited(_healStalePlan());
      unawaited(_renameGeneratedPlan());
    }, onError: _onError);

    _watchPlan();
  }

  void _watchPlan() {
    _planSubscription?.cancel();
    _planSubscription = _planService.watchPlan(_selectedDate).listen((plan) {
      _plan = plan;
      notifyListeners();
      unawaited(_refreshShiftOffer());
      unawaited(_healStalePlan());
    }, onError: _onError);
    _catchUpSubscription?.cancel();
    _catchUpSubscription = _planService.watchCatchUps(_selectedDate).listen((
      plans,
    ) {
      _catchUps = plans;
      notifyListeners();
    }, onError: _onError);
  }

  Future<void> _refreshStaleMetrics() async {
    if (_metricsRefreshed) return;
    _metricsRefreshed = true;
    try {
      await _sessionService.refreshMetrics(_sessions);
    } on WorkoutException catch (_) {
      _metricsRefreshed = false;
    }
  }

  Future<void> _healStalePlan() async {
    final plan = _plan;
    final active = _state.activeProgram;
    final program = _activeProgramEntity;
    if (plan == null || active == null || program == null || _isHealingPlan) {
      return;
    }
    if (plan.sessionId != null || plan.programId != program.id) return;
    if (WorkoutDiscipline.ofPlan(plan) ==
        WorkoutDiscipline.ofProgram(program)) {
      return;
    }
    final key = '${program.id}:${program.course}';
    if (_healedProgramKey == key) return;
    _healedProgramKey = key;
    _isHealingPlan = true;
    try {
      await _planService.scheduleProgram(program, active, from: _today);
    } on WorkoutException catch (_) {
      _healedProgramKey = null;
    } finally {
      _isHealingPlan = false;
    }
  }

  Future<void> _ensurePlan() async {
    final active = _state.activeProgram;
    if (active == null || dayStatus == WorkoutDayStatus.past) return;
    try {
      await _planService.ensurePlanFor(_selectedDate, activeProgram: active);
    } on WorkoutException catch (error) {
      _onError(error);
    }
  }

  void _onError(Object error) {
    _isLoading = false;
    _errorMessage = error is WorkoutException ? error.message : _loadFailure;
    notifyListeners();
  }

  Future<void> retry() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await _sessionSubscription?.cancel();
    await _stateSubscription?.cancel();
    await _programSubscription?.cancel();
    await _planSubscription?.cancel();
    await _catchUpSubscription?.cancel();
    await _start();
    _reloadHistoryIfVisible();
  }

  DateTime get _historyStart {
    final today = _today;
    var start = AppDateUtils.addDays(
      AppDateUtils.startOfWeek(today),
      -DateTime.daysPerWeek * (_historyMinWeeks - 1),
    );
    for (final session in _sessions) {
      if (session.date.isBefore(start)) {
        start = AppDateUtils.startOfWeek(session.date);
      }
    }
    final floor = AppDateUtils.startOfWeek(
      AppDateUtils.addDays(today, -_historyMaxDays),
    );
    return start.isBefore(floor) ? floor : start;
  }

  void _reloadHistoryIfVisible() {
    if (_selectedTab == WorkoutTab.history) unawaited(_loadHistory());
  }

  Future<void> _loadHistory() async {
    final request = ++_historyRequest;
    final from = _historyStart;
    final end = AppDateUtils.addDays(AppDateUtils.endOfWeek(_today), 1);
    try {
      final plans = await _planService.loadScheduleBetween(
        from,
        end,
        activeProgram: _state.activeProgram,
      );
      if (request != _historyRequest) return;
      _historyPlans = plans;
    } on WorkoutException catch (error) {
      if (request != _historyRequest) return;
      _historyPlans = const [];
      _onError(error);
    }
    _historyFrom = from;
    _historyLoaded = true;
    notifyListeners();
  }

  List<WorkoutSessionEntity> get _daySessions => [
    for (final session in _sessions)
      if (AppDateUtils.isSameDay(session.date, _selectedDate)) session,
  ];

  WorkoutSessionEntity? get _selectedSession {
    final sessions = _daySessions;
    if (sessions.isEmpty) return null;
    for (final session in sessions) {
      if (session.id == _focusedSessionId) return session;
    }
    for (final session in sessions) {
      if (session.isInProgress) return session;
    }
    return sessions.first;
  }

  WorkoutSessionEntity? _sessionFor(DateTime planDate) {
    WorkoutSessionEntity? completed;
    for (final session in _daySessions) {
      if (!session.fulfillsPlanOn(planDate)) continue;
      if (session.isInProgress) return session;
      if (session.isCompleted) completed ??= session;
    }
    return completed;
  }

  WorkoutPlanEntity? _planFor(DateTime planDate) {
    if (AppDateUtils.isSameDay(planDate, _selectedDate)) return _plan;
    for (final plan in _catchUps) {
      if (AppDateUtils.isSameDay(plan.date, planDate)) return plan;
    }
    return null;
  }

  List<_DayWorkout> get _dayWorkouts {
    final workouts = <_DayWorkout>[];
    final matched = <String>{};
    final plan = _plan;
    if (plan != null) {
      final session = _sessionFor(_selectedDate);
      if (session != null) matched.add(session.id);
      workouts.add(
        _DayWorkout(planDate: _selectedDate, plan: plan, session: session),
      );
    }
    final activeId = _state.activeProgram?.id;
    final catchUpDay = AppDateUtils.addDays(_selectedDate, -1);
    for (final catchUp in _catchUps) {
      final session = _sessionFor(catchUp.date);
      if (session == null &&
          (catchUp.programId != activeId ||
              !AppDateUtils.isSameDay(catchUp.date, catchUpDay))) {
        continue;
      }
      if (session != null) matched.add(session.id);
      workouts.add(
        _DayWorkout(
          planDate: catchUp.date,
          plan: catchUp,
          session: session,
          isCatchUp: true,
        ),
      );
    }
    for (final session in _daySessions.reversed) {
      if (matched.contains(session.id)) continue;
      if (!session.isCompleted && !session.isInProgress) continue;
      workouts.add(
        _DayWorkout(
          planDate: session.scheduledDate,
          session: session,
          isCatchUp: session.isCatchUp,
        ),
      );
    }
    return workouts;
  }

  _DayWorkout? get _nextPending {
    for (final workout in _dayWorkouts) {
      if (workout.session == null && workout.plan != null) return workout;
    }
    return null;
  }

  _DayWorkout? _workoutById(String id) {
    for (final workout in _dayWorkouts) {
      if (workout.id == id) return workout;
    }
    return null;
  }

  String? get overviewWorkoutId => _selectedSession?.id;

  bool get isOverviewActive {
    final active = _activeSession;
    return active != null && _selectedSession?.id == active.id;
  }

  WorkoutPrimaryAction? get primaryAction {
    if (dayStatus != WorkoutDayStatus.today) return null;
    if (_activeSession != null) return WorkoutPrimaryAction.resume;
    if (_nextPending != null) return WorkoutPrimaryAction.start;
    return _daySessions.isEmpty ? WorkoutPrimaryAction.start : null;
  }

  bool get canLogWorkout =>
      dayStatus == WorkoutDayStatus.today && _activeSession == null;

  bool get isLogWorkoutPrimary =>
      canLogWorkout && primaryAction != WorkoutPrimaryAction.start;

  String get logWorkoutLabel => 'Log Workout';

  void focusSession(String id) {
    _focusedSessionId = id;
    if (_selectedTab != WorkoutTab.overview) {
      selectTab(WorkoutTab.overview);
      return;
    }
    notifyListeners();
  }

  String get primaryActionLabel => _nextPending?.isCatchUp ?? false
      ? 'Start Catch-up'
      : _discipline.startLabel;

  TodaysWorkoutArgs get startArgs {
    final next = _nextPending;
    return TodaysWorkoutArgs(
      date: _selectedDate,
      catchUpFrom: next != null && next.isCatchUp ? next.planDate : null,
    );
  }

  WorkoutSessionEntity? get _activeSession {
    if (dayStatus != WorkoutDayStatus.today) return null;
    for (final session in _daySessions) {
      if (session.isInProgress) return session;
    }
    return null;
  }

  bool get isTimerPaused => _activeSession?.isTimerPaused ?? false;

  String get activeStatusLabel => isTimerPaused ? 'Paused' : 'In Progress';

  String get activeProgressLabel {
    final session = _activeSession;
    if (session == null) return '';
    var logged = 0;
    for (final exercise in session.exercises) {
      logged += exercise.workingSetCount;
    }
    return '$logged/${session.plannedSets} sets';
  }

  Future<void> toggleTimer() async {
    final session = _activeSession;
    if (session == null) return;
    final now = DateTime.now();
    final updated = session.isTimerPaused
        ? session.resumedAt(now)
        : session.pausedAt(now);
    _sessions = [
      for (final entry in _sessions)
        if (entry.id == updated.id) updated else entry,
    ];
    notifyListeners();
    try {
      await _sessionService.saveTimer(updated);
    } on WorkoutException catch (error) {
      _onError(error);
    }
  }

  bool get hasPlan => _plan != null;

  ActiveWorkoutArgs get activeWorkoutArgs {
    final session = _activeSession;
    final plan = session == null
        ? _plan
        : session.isManual
        ? null
        : _planFor(session.scheduledDate);
    return ActiveWorkoutArgs(
      date: _selectedDate,
      plan: plan,
      history: plan == null ? null : _sessions,
      session: session,
    );
  }

  List<String?> get planImageUrls => [
    for (final plan in [?_plan, ..._catchUps])
      for (final exercise in plan.exercises)
        exercise.imageUrl ?? WorkoutCatalogData.imageFor(exercise.exerciseId),
  ];

  WorkoutAgendaItem? get agenda {
    if (!isOverviewTab) return null;
    final workouts = _dayWorkouts;
    if (workouts.length < _agendaMinEntries) return null;
    final focusedId = _selectedSession?.id;
    final hasActive = _activeSession != null;
    var done = 0;
    for (final workout in workouts) {
      if (workout.session?.isCompleted ?? false) done++;
    }
    final active = _state.activeProgram;
    return WorkoutAgendaItem(
      title: '$titlePrefix Plan',
      progressLabel: '$done of ${workouts.length} done',
      planLabel: active == null
          ? null
          : _programProgressLabel(active, _selectedDate),
      planProgress: active == null
          ? null
          : _programProgressOf(active, _selectedDate),
      entries: [
        for (final workout in workouts)
          _agendaEntryOf(workout, focusedId: focusedId, hasActive: hasActive),
      ],
    );
  }

  WorkoutAgendaEntryItem _agendaEntryOf(
    _DayWorkout workout, {
    required String? focusedId,
    required bool hasActive,
  }) {
    final session = workout.session;
    final plan = workout.plan;
    final isToday = dayStatus == WorkoutDayStatus.today;
    final status = session == null
        ? WorkoutAgendaStatus.pending
        : session.isCompleted
        ? WorkoutAgendaStatus.completed
        : WorkoutAgendaStatus.inProgress;
    final isFocused = session != null && session.id == focusedId;
    final action = switch (status) {
      WorkoutAgendaStatus.pending =>
        isToday && !hasActive ? WorkoutAgendaAction.start : null,
      WorkoutAgendaStatus.inProgress =>
        isToday ? WorkoutAgendaAction.resume : WorkoutAgendaAction.focus,
      WorkoutAgendaStatus.completed => WorkoutAgendaAction.focus,
    };
    return WorkoutAgendaEntryItem(
      id: workout.id,
      name: session?.name ?? plan?.name ?? '',
      tagLabel: workout.isCatchUp
          ? 'Catch-up · ${AppDateUtils.relativeDay(workout.planDate)}'
          : plan == null
          ? 'Logged'
          : 'Scheduled',
      metaLabel: _agendaMetaOf(workout),
      status: status,
      statusLabel: switch (status) {
        WorkoutAgendaStatus.pending =>
          isToday
              ? hasActive
                    ? 'Up next'
                    : 'Ready'
              : dayStatus == WorkoutDayStatus.future
              ? 'Planned'
              : 'Missed',
        WorkoutAgendaStatus.inProgress =>
          isToday ? activeStatusLabel : 'Unfinished',
        WorkoutAgendaStatus.completed => 'Completed',
      },
      action: action,
      actionLabel: switch (action) {
        WorkoutAgendaAction.start => 'Start',
        WorkoutAgendaAction.resume => 'Resume',
        WorkoutAgendaAction.focus => 'View',
        null => null,
      },
      isCatchUp: workout.isCatchUp,
      isFocused: isFocused,
      canRemove: workout.isCatchUp && session == null && isToday,
      imageUrl: plan == null
          ? ProgramArtwork.ofSession(session!)
          : ProgramArtwork.ofPlan(plan),
    );
  }

  String _agendaMetaOf(_DayWorkout workout) {
    final session = workout.session;
    final plan = workout.plan;
    if (session != null && session.isCompleted) {
      return '${_durationLabel(session.trackedSeconds)} min · '
          '${_discipline.countLabel(session.exerciseCount)} · '
          '${NumberFormatter.grouped(session.caloriesKcal)} kcal';
    }
    if (session != null) {
      var logged = 0;
      for (final exercise in session.exercises) {
        logged += exercise.workingSetCount;
      }
      return '$logged/${session.plannedSets} sets logged';
    }
    if (plan == null) return '';
    return '${plan.durationMinutes} min · '
        '${_discipline.countLabel(plan.exercises.length)}'
        '${_discipline == WorkoutDiscipline.yoga ? '' : ' · ${plan.totalSets} sets'}';
  }

  TodaysWorkoutArgs? startArgsFor(String id) {
    final workout = _workoutById(id);
    if (workout == null || workout.plan == null) return null;
    return TodaysWorkoutArgs(
      date: _selectedDate,
      catchUpFrom: workout.isCatchUp ? workout.planDate : null,
    );
  }

  ActiveWorkoutArgs? resumeArgsFor(String id) {
    final workout = _workoutById(id);
    final session = workout?.session;
    if (workout == null || session == null || !session.isInProgress) {
      return null;
    }
    final plan = workout.plan;
    return ActiveWorkoutArgs(
      date: _selectedDate,
      plan: plan,
      history: plan == null ? null : _sessions,
      session: session,
    );
  }

  String? sessionIdOf(String entryId) => _workoutById(entryId)?.session?.id;

  bool isSessionActive(String id) => _activeSession?.id == id;

  void focusEntry(String id) {
    final session = _workoutById(id)?.session;
    if (session == null || session.id == _focusedSessionId) return;
    _focusedSessionId = session.id;
    notifyListeners();
  }

  String removeCatchUpTitle(WorkoutAgendaEntryItem entry) =>
      'Skip ${entry.name}?';

  String removeCatchUpMessage(WorkoutAgendaEntryItem entry) {
    final planDate = _workoutById(entry.id)?.planDate;
    final day = planDate == null
        ? 'its original day'
        : AppDateUtils.relativeDay(planDate).toLowerCase();
    return 'This takes it off today\'s plan. It stays marked as missed for '
        '$day, and you can add it back from the missed workout card.';
  }

  String get removeCatchUpConfirmLabel => 'Remove';

  String get removeCatchUpCancelLabel => 'Keep it';

  Future<void> removeCatchUp(String id) async {
    final workout = _workoutById(id);
    final plan = workout?.plan;
    if (workout == null ||
        plan == null ||
        !workout.isCatchUp ||
        workout.session != null) {
      return;
    }
    try {
      await _planService.unscheduleCatchUp(plan);
    } on WorkoutException catch (error) {
      _onError(error);
    }
  }

  String _programProgressLabel(ActiveProgramEntry active, DateTime date) =>
      active.hasFixedLength
      ? '${active.name} · day ${active.dayNumberAt(date)} of '
            '${active.totalDays}'
      : '${active.name} · week ${active.weekAt(date)} of '
            '${active.totalWeeks}';

  double? _programProgressOf(ActiveProgramEntry active, DateTime date) {
    if (active.hasFixedLength) {
      return active.dayNumberAt(date) / active.totalDays;
    }
    if (active.totalWeeks <= 0) return null;
    return active.weekAt(date) / active.totalWeeks;
  }

  Future<void> _renameGeneratedPlan() async {
    if (_isRenamingPlan || _isBuildingPlan) return;
    WorkoutProgramEntity? stale;
    for (final program in _allPrograms) {
      if (program.needsGeneratedName) stale = program;
    }
    if (stale == null) return;
    _isRenamingPlan = true;
    try {
      final renamed = stale.copyWith(name: WorkoutProgramEntity.generatedName);
      await _catalogService.saveProgram(renamed);
      final active = (await _programService.loadState()).activeProgram;
      if (active != null && active.id == renamed.id) {
        await _planService.scheduleProgram(
          renamed,
          active.withProgram(renamed),
          from: _today,
          saveActive: true,
        );
      }
    } on WorkoutException catch (_) {
      return;
    } finally {
      _isRenamingPlan = false;
    }
  }

  bool get isBuildingPlan => _isBuildingPlan;

  bool get needsRebuildWarning => _state.activeProgram != null;

  String get rebuildWarningTitle => 'Replace your current plan?';

  String get rebuildWarningMessage {
    final name = _state.activeProgram?.name;
    return 'WAVE builds a new plan from today and replaces '
        '${name == null || name.isEmpty ? 'your current plan' : name}. '
        'Every upcoming session is overwritten, including exercise swaps, '
        'moved sessions and edits you made, and the program restarts from '
        'week 1. Workouts you already logged stay in your history.';
  }

  String get rebuildWarningConfirm => 'Rebuild Plan';

  String get rebuildWarningCancel => 'Keep Current Plan';

  bool get _isPlanBannerHidden =>
      _isPlanBannerDismissed && !_isBuildingPlan && _planBuildError == null;

  bool get canDismissPlanBanner => !_isBuildingPlan;

  String? get planRebuildLabel {
    if (_isLoading || !_isPlanBannerHidden) return null;
    return _state.generatedProgramId == null
        ? 'Build my plan'
        : 'Rebuild my plan';
  }

  void dismissPlanBanner() {
    if (_isPlanBannerDismissed) return;
    _isPlanBannerDismissed = true;
    _planBuildError = null;
    notifyListeners();
    unawaited(_planBannerService.markDismissed());
  }

  Future<void> _loadPlanBannerDismissed() async {
    final dismissed = await _planBannerService.isDismissed();
    if (_isPlanBannerDismissed || !dismissed) return;
    _isPlanBannerDismissed = true;
    notifyListeners();
  }

  WorkoutPlanBuilderItem? get planBuilder {
    if (_isLoading) return null;
    final active = _state.activeProgram;
    final generatedId = _state.generatedProgramId;
    final isGeneratedActive = active != null && active.id == generatedId;
    final isVisible = switch (_selectedTab) {
      WorkoutTab.overview =>
        _isBuildingPlan ||
            ((active == null || !_activeMatchesDiscipline) &&
                dayStatus != WorkoutDayStatus.past),
      WorkoutTab.programs =>
        _isBuildingPlan ||
            _planBuildError != null ||
            !isGeneratedActive ||
            !_activeMatchesDiscipline,
      _ => false,
    };
    if (!isVisible || _isPlanBannerHidden) return null;
    if (_isBuildingPlan) {
      return WorkoutPlanBuilderItem(
        title: 'WAVE is building your $_planLengthLabel plan',
        message:
            'Reading your onboarding answers and picking exercises from your '
            'library. This takes a few seconds.',
        actionLabel: 'Building…',
      );
    }
    final generated = generatedId == null ? null : _programById(generatedId);
    final calLevel = CalLevel.fromCourse(generated?.course);
    if (isGeneratedActive && calLevel != null) {
      return WorkoutPlanBuilderItem(
        title: 'Calisthenics ${calLevel.fullTitle}',
        message:
            'Finished your retest week? Update your strength test in '
            'Settings → Onboarding answers, then rebuild. Clearing 80% of the '
            'next level\'s gates moves you up; logged workouts stay in your '
            'history.',
        actionLabel: 'Rebuild my plan',
        errorMessage: _planBuildError,
      );
    }
    final courseCopy = _courseBuilderCopy(
      isGeneratedActive: isGeneratedActive,
      hasGenerated: generatedId != null,
    );
    if (courseCopy != null) return courseCopy;
    return WorkoutPlanBuilderItem(
      title: isGeneratedActive
          ? 'Your WAVE $_planLengthLabel plan'
          : 'Get your personal $_planLengthLabel plan',
      message: isGeneratedActive
          ? 'Changed your schedule, equipment or goal? Rebuild the plan from '
                'your latest onboarding answers. Logged workouts stay in your '
                'history.'
          : active != null
          ? 'WAVE builds a standard $_planLengthLabel program from your '
                'onboarding answers. It replaces ${active.name} and reschedules your '
                'upcoming sessions.'
          : 'WAVE builds a standard $_planLengthLabel program from your '
                'onboarding answers: your training days, session length, equipment and '
                'goal.',
      actionLabel: generatedId == null ? 'Build my plan' : 'Rebuild my plan',
      errorMessage: _planBuildError,
    );
  }

  WorkoutPlanBuilderItem? _courseBuilderCopy({
    required bool isGeneratedActive,
    required bool hasGenerated,
  }) {
    final actionLabel = hasGenerated ? 'Rebuild my plan' : 'Build my plan';
    return switch (_discipline) {
      WorkoutDiscipline.yoga => WorkoutPlanBuilderItem(
        title: isGeneratedActive && _isYogaCourseActive
            ? 'Your NYASP Hatha course'
            : 'Start your NYASP Hatha course',
        message: isGeneratedActive && _isYogaCourseActive
            ? 'Changed your practice days, class length or limitations? '
                  'Rebuild from your latest answers. Logged classes stay in '
                  'your history.'
            : 'WAVE builds the 4-week beginner Hatha course from your '
                  'answers: practice days, class length, experience and any '
                  'limitations, with safe alternatives for each.',
        actionLabel: actionLabel,
        errorMessage: _planBuildError,
      ),
      WorkoutDiscipline.calisthenics when _courseLevel == null =>
        WorkoutPlanBuilderItem(
          title: 'Find your calisthenics level',
          message:
              'WAVE places you in Level 1–4 from your strength tests and '
              'builds that level\'s weekly sessions, progressions and '
              'periodization.',
          actionLabel: actionLabel,
          errorMessage: _planBuildError,
        ),
      _ => null,
    };
  }

  Future<void> buildPlan({bool showResult = true}) async {
    if (_isBuildingPlan) return;
    _isBuildingPlan = true;
    _planBuildError = null;
    notifyListeners();
    try {
      final program = await _sizedPlanOf(await _generatorService.generate());
      final active = _programService.activeEntryFor(program, startDate: _today);
      await _planService.scheduleProgram(
        program,
        active,
        from: _today,
        saveActive: true,
      );
      _isBuildingPlan = false;
      if (showResult) {
        _setDate(_today);
        selectTab(WorkoutTab.overview);
      }
    } on WorkoutException catch (error) {
      _planBuildError = showResult ? error.message : null;
    }
    _isBuildingPlan = false;
    notifyListeners();
  }

  bool get _wantsLongPlan =>
      _discipline == WorkoutDiscipline.gym &&
      _answers[OnboardingData.gymPlanLengthId] == OnboardingData.threeMonthPlan;

  String get _planLengthLabel => _wantsLongPlan ? '90-day' : '30-day';

  Future<WorkoutProgramEntity> _sizedPlanOf(
    WorkoutProgramEntity program,
  ) async {
    if (_answers.isEmpty) {
      try {
        _answers = await _answersService.loadAnswers();
        _discipline = WorkoutDiscipline.fromAnswers(_answers);
      } on OnboardingAnswersException catch (_) {
        return program;
      }
    }
    if (!_wantsLongPlan || program.course != null) return program;
    if (program.lengthDays == _longPlanDays) return program;
    final sized = program.copyWith(
      lengthDays: _longPlanDays,
      weeks: (_longPlanDays / DateTime.daysPerWeek).ceil(),
    );
    await _catalogService.saveProgram(sized);
    return sized;
  }

  Future<void> _refreshShiftOffer() async {
    final request = ++_shiftRequest;
    try {
      final offer = await _shiftService.offerFor(
        date: _selectedDate,
        activeProgram: _state.activeProgram,
        sessions: _sessions,
        todayPlan: _plan,
        includePostpone: false,
      );
      if (request != _shiftRequest) return;
      _shiftOffer = offer;
      notifyListeners();
    } on WorkoutException catch (_) {
      return;
    }
  }

  WorkoutShiftOffer? get shiftOffer {
    final offer = _shiftOffer;
    if (_selectedTab != WorkoutTab.overview || offer == null) return null;
    return offer;
  }

  bool get isShifting => _isShifting;

  Future<void> applyShift() async {
    final offer = _shiftOffer;
    final active = _state.activeProgram;
    if (offer == null || active == null || _isShifting) return;
    _isShifting = true;
    notifyListeners();
    try {
      await _shiftService.apply(offer, active);
      _shiftOffer = null;
    } on WorkoutException catch (error) {
      _onError(error);
    }
    _isShifting = false;
    notifyListeners();
    unawaited(_refreshShiftOffer());
  }

  bool get _isRestDay =>
      _state.activeProgram != null &&
      _activeMatchesDiscipline &&
      _plan == null &&
      _catchUps.isEmpty &&
      dayStatus != WorkoutDayStatus.past;

  String get _restDayMessage => switch (_discipline) {
    WorkoutDiscipline.calisthenics => calLevel.restGuidance,
    WorkoutDiscipline.yoga =>
      'No class scheduled. Gentle walking and easy breathing are enough; '
          'your next class follows your practice days.',
    WorkoutDiscipline.gym =>
      'No workout scheduled. Recover well: walk, stretch and sleep so your '
          'next session counts.',
  };

  WorkoutEmptyState get emptyState => switch (_selectedTab) {
    WorkoutTab.overview when _isRestDay => WorkoutEmptyState(
      icon: Icons.bedtime_outlined,
      title: 'Rest day',
      message: _restDayMessage,
    ),
    WorkoutTab.overview =>
      dayStatus == WorkoutDayStatus.future
          ? WorkoutEmptyState(
              icon: Icons.calendar_today,
              title: 'Nothing logged for this day',
              message:
                  'This is a future date. Come back on '
                  '${AppDateUtils.weekdayName(_selectedDate)} to log your '
                  'workout, or start a program to schedule one.',
            )
          : WorkoutEmptyState(
              icon: Icons.directions_run,
              iconAsset: AppImages.runIcon,
              title: 'No ${_discipline.sessionNoun} logged yet',
              message: _discipline == WorkoutDiscipline.yoga
                  ? 'Start your first class to track practice minutes, your '
                        'self-check and your progress through the course.'
                  : 'Start your first session to unlock training stats, '
                        'muscle tracking, and progress insights.',
            ),
    WorkoutTab.history => WorkoutEmptyState(
      icon: Icons.pending_actions,
      title: 'No ${_discipline.sessionNoun} history',
      message:
          'Complete your first ${_discipline.sessionNoun} and it\'ll appear '
          'here with your stats.',
    ),
    WorkoutTab.programs => const WorkoutEmptyState(
      icon: Icons.pending_actions,
      title: 'No programs available',
      message:
          'Your program library is still syncing. Pull back in a moment to '
          'pick a weekly training plan.',
    ),
    WorkoutTab.exercises => const WorkoutEmptyState(
      icon: Icons.fitness_center,
      title: 'No exercises tracked',
      message:
          'Log a workout and every exercise you perform will show up here '
          'with your best sets.',
    ),
  };

  bool get showOverview =>
      _selectedTab == WorkoutTab.overview && overview != null;

  bool get showOverviewInsights => _selectedSession?.isCompleted ?? false;

  bool get isHistoryLoading =>
      _selectedTab == WorkoutTab.history && !_historyLoaded && !_isLoading;

  bool get showHistory => _selectedTab == WorkoutTab.history && history != null;

  bool get showEmptyState =>
      !_isLoading &&
      !isHistoryLoading &&
      _errorMessage == null &&
      agenda == null &&
      (planBuilder == null || !isOverviewTab) &&
      !showOverview &&
      !showHistory &&
      !showPrograms &&
      !showExercises &&
      !showSuggestion;

  DateTime? get _planStart => _state.activeProgram?.startDate;

  bool get _hasEarlierHistory {
    final start = _planStart;
    if (start == null) return false;
    return _sessions.any((session) => session.scheduledDate.isBefore(start)) ||
        _historyPlans.any((plan) => plan.date.isBefore(start));
  }

  DateTime? get _historyCutoff =>
      _showEarlierHistory || !_hasEarlierHistory ? null : _planStart;

  String? get historyResetLabel {
    final start = _planStart;
    if (_selectedTab != WorkoutTab.history ||
        start == null ||
        !_hasEarlierHistory) {
      return null;
    }
    final name = _state.activeProgram?.name ?? 'current plan';
    return _showEarlierHistory
        ? 'Showing everything, including sessions from before $name started '
              'on ${AppDateUtils.dayMonth(start)}.'
        : 'History restarted on ${AppDateUtils.dayMonth(start)} when $name '
              'began. Earlier sessions are saved, not deleted.';
  }

  String get historyToggleLabel =>
      _showEarlierHistory ? 'Show current plan only' : 'Show earlier history';

  void toggleEarlierHistory() {
    _showEarlierHistory = !_showEarlierHistory;
    notifyListeners();
  }

  WorkoutHistoryAnalysis? get _historyAnalysis {
    final from = _historyFrom;
    if (!_historyLoaded || from == null) return null;
    final cutoff = _historyCutoff;
    if (cutoff == null) {
      return WorkoutHistoryAnalyzer.analyze(
        today: _today,
        from: from,
        plans: _historyPlans,
        sessions: _sessions,
        activeProgram: _state.activeProgram,
      );
    }
    final cutoffWeek = AppDateUtils.startOfWeek(cutoff);
    return WorkoutHistoryAnalyzer.analyze(
      today: _today,
      from: from.isAfter(cutoffWeek) ? from : cutoffWeek,
      plans: [
        for (final plan in _historyPlans)
          if (!plan.date.isBefore(cutoff)) plan,
      ],
      sessions: [
        for (final session in _sessions)
          if (!session.scheduledDate.isBefore(cutoff)) session,
      ],
      activeProgram: _state.activeProgram,
    );
  }

  WorkoutHistoryOverviewItem? get history {
    final inputs = [
      _historyLoaded,
      _historyFrom,
      _today,
      _historyPlans,
      _sessions,
      _state.activeProgram,
      _showEarlierHistory,
    ];
    final cachedInputs = _historyCacheInputs;
    if (cachedInputs != null && _sameInputs(cachedInputs, inputs)) {
      return _historyCache;
    }
    _historyCacheInputs = inputs;
    return _historyCache = _buildHistory();
  }

  static bool _sameInputs(List<Object?> a, List<Object?> b) {
    for (var i = 0; i < a.length; i++) {
      if (!identical(a[i], b[i]) && a[i] != b[i]) return false;
    }
    return true;
  }

  WorkoutHistoryOverviewItem? _buildHistory() {
    final analysis = _historyAnalysis;
    if (analysis == null) return null;
    final weeks = _historyWeeksOf(analysis.days);
    final consistency = _consistencyOf(analysis);
    if (weeks.isEmpty && consistency == null) return null;
    return WorkoutHistoryOverviewItem(consistency: consistency, weeks: weeks);
  }

  List<WorkoutHistoryWeekItem> _historyWeeksOf(List<WorkoutHistoryDay> days) {
    final today = _today;
    final weeks = <WorkoutHistoryWeekItem>[];
    DateTime? weekStart;
    var entries = <WorkoutHistoryEntryItem>[];
    var planned = 0;
    var done = 0;
    var workouts = 0;

    void closeWeek() {
      final start = weekStart;
      if (start == null || entries.isEmpty) return;
      weeks.add(
        WorkoutHistoryWeekItem(
          title: _weekTitleOf(start),
          summaryLabel: planned > 0
              ? '$done of $planned done'
              : workouts > 0
              ? '$workouts ${workouts == 1 ? 'workout' : 'workouts'}'
              : null,
          entries: entries,
        ),
      );
    }

    for (final day in days.reversed) {
      if (day.date.isAfter(today)) continue;
      final start = AppDateUtils.startOfWeek(day.date);
      if (weekStart == null || !AppDateUtils.isSameDay(start, weekStart)) {
        closeWeek();
        weekStart = start;
        entries = [];
        planned = 0;
        done = 0;
        workouts = 0;
      }
      final isCompleted = day.outcome == WorkoutDayOutcome.completed;
      if (isCompleted) workouts++;
      if (day.isPlanned && day.outcome != WorkoutDayOutcome.pending) {
        planned++;
        if (isCompleted) done++;
      }
      for (final session in day.sessions) {
        entries.add(WorkoutHistoryEntryItem.session(_historyItemOf(session)));
      }
      final missed = _missedItemOf(day);
      if (missed != null) entries.add(WorkoutHistoryEntryItem.missed(missed));
    }
    closeWeek();
    return weeks;
  }

  String _weekTitleOf(DateTime start) {
    final thisWeek = AppDateUtils.startOfWeek(_today);
    if (AppDateUtils.isSameDay(start, thisWeek)) return 'This week';
    if (AppDateUtils.isSameDay(
      start,
      AppDateUtils.addDays(thisWeek, -DateTime.daysPerWeek),
    )) {
      return 'Last week';
    }
    final end = AppDateUtils.endOfWeek(start);
    final withYear = end.year != _today.year;
    return start.month == end.month
        ? '${start.day} – ${AppDateUtils.dayMonth(end, withYear: withYear)}'
        : '${AppDateUtils.dayMonth(start)} – '
              '${AppDateUtils.dayMonth(end, withYear: withYear)}';
  }

  String _historyDayLabel(DateTime date) {
    final today = _today;
    if (AppDateUtils.isSameDay(date, today)) return 'Today';
    if (AppDateUtils.isSameDay(date, AppDateUtils.addDays(today, -1))) {
      return 'Yesterday';
    }
    return '${AppDateUtils.weekdayName(date)}, ${AppDateUtils.monthDay(date)}';
  }

  WorkoutHistoryItem _historyItemOf(WorkoutSessionEntity session) {
    final isToday = AppDateUtils.isSameDay(session.date, _today);
    final dateLabel = isToday
        ? 'Today · ${AppDateUtils.time(session.startedAt)}'
        : _historyDayLabel(session.date);
    return WorkoutHistoryItem(
      id: session.id,
      name: session.name,
      dateLabel: session.isCatchUp
          ? '$dateLabel · Catch-up for '
                '${AppDateUtils.shortWeekday(session.scheduledDate)}'
          : dateLabel,
      effectLabel: _discipline == WorkoutDiscipline.yoga
          ? session.selfCheckAverage?.toStringAsFixed(1) ?? '—'
          : session.trainingEffect.toStringAsFixed(1),
      effectCaption: _discipline == WorkoutDiscipline.yoga
          ? 'comfort'
          : 'effect',
      metrics: [
        WorkoutMetricItem(
          icon: Icons.schedule,
          label: _durationLabel(session.trackedSeconds),
        ),
        WorkoutMetricItem(
          icon: Icons.local_fire_department,
          label: '${NumberFormatter.grouped(session.caloriesKcal)} kcal',
        ),
        WorkoutMetricItem(
          icon: Icons.bar_chart,
          label: _discipline.countLabel(session.exerciseCount),
        ),
      ],
      statusLabel: session.isCompleted
          ? 'Completed'
          : isToday && session.isInProgress
          ? 'In Progress'
          : 'Unfinished',
      isHighlighted: isToday,
    );
  }

  MissedWorkoutItem? _missedItemOf(WorkoutHistoryDay day) {
    final plan = day.plan;
    final insight = day.insight;
    if (day.outcome != WorkoutDayOutcome.missed ||
        plan == null ||
        insight == null) {
      return null;
    }
    final advice = _missedAdviceOf(plan, insight);
    return MissedWorkoutItem(
      date: day.date,
      name: plan.name,
      dateLabel: _historyDayLabel(day.date),
      detailLabel: plan.programLabel.isNotEmpty
          ? plan.programLabel
          : plan.focus,
      metrics: [
        WorkoutMetricItem(
          icon: Icons.schedule,
          label: '${plan.durationMinutes} min',
        ),
        WorkoutMetricItem(
          icon: Icons.bar_chart,
          label: _discipline.countLabel(plan.exercises.length),
        ),
        WorkoutMetricItem(
          icon: Icons.layers_outlined,
          label: '${plan.totalSets} sets',
        ),
      ],
      adviceTitle: advice.title,
      advice: advice.message,
      adviceTone: advice.tone,
      musclesLabel: insight.muscles.join(' · '),
      exercises: [
        for (final entry in plan.exercises)
          MissedExerciseItem(
            name: entry.name,
            targetLabel: entry.isTimed
                ? '${entry.targetSets} × ${entry.targetReps}s'
                : '${entry.targetSets} × ${entry.targetReps}',
          ),
      ],
      goal: plan.goal.isNotEmpty ? plan.goal : plan.focus,
      actionLabel: insight.canSchedule ? 'Do it today' : null,
    );
  }

  ({String title, String message, WorkoutStatTone tone}) _missedAdviceOf(
    WorkoutPlanEntity plan,
    MissedWorkoutInsight insight,
  ) {
    final muscles = insight.muscles;
    final musclesLabel = muscles.join(' & ');
    final keyExercise = insight.keyExercise;
    final coveredOn = insight.coveredOn;
    if (_discipline == WorkoutDiscipline.yoga) {
      return switch (insight.recovery) {
        MissedRecovery.scheduled => (
          title: 'Scheduled for today',
          message:
              '${plan.name} is on today\'s practice. Move at an easy pace and '
              'rest whenever you need; it counts toward yesterday.',
          tone: WorkoutStatTone.accent,
        ),
        MissedRecovery.catchUp => (
          title: 'Practise it today',
          message:
              'Missed yesterday\'s class? Add ${plan.name} to today. Today\'s '
              'own class stays on your plan, so keep both gentle.',
          tone: WorkoutStatTone.accent,
        ),
        _ => (
          title: 'Continue with the course',
          message:
              'Only yesterday\'s class can be made up. Pick up with your next '
              'class at a comfortable pace; the course progresses only when '
              'breathing and movement stay comfortable.',
          tone: WorkoutStatTone.neutral,
        ),
      };
    }
    switch (insight.recovery) {
      case MissedRecovery.scheduled:
        return (
          title: 'Scheduled for today',
          message:
              '${plan.name} is on today\'s plan. Today\'s own '
              '${_discipline.sessionNoun} stays too, so do both and nothing '
              'gets lost.',
          tone: WorkoutStatTone.accent,
        );
      case MissedRecovery.catchUp:
        return (
          title: 'Catch up today',
          message:
              'Add ${plan.name} to today. Today\'s own '
              '${_discipline.sessionNoun} stays on your plan, and both show up '
              'in your history.',
          tone: WorkoutStatTone.accent,
        );
      case MissedRecovery.covered:
        return (
          title: 'Already covered',
          message:
              'You trained ${muscles.first} '
              '${_relativeLabel(coveredOn ?? plan.date)}, so the main work '
              'of this session is done. No need to make it up.',
          tone: WorkoutStatTone.accent,
        );
      case MissedRecovery.prioritize:
        final focus = muscles.isEmpty
            ? 'This session'
            : '$musclesLabel ${muscles.length == 1 ? 'hasn\'t' : 'haven\'t'} '
                  'been trained since';
        final addition = keyExercise == null
            ? 'Only yesterday\'s session can be made up, so add a few extra '
                  'sets to your next session'
            : 'Only yesterday\'s session can be made up, so add 2–3 sets of '
                  '$keyExercise to your next session';
        return (
          title: 'Make it up this week',
          message: '$focus. $addition to keep progressing.',
          tone: WorkoutStatTone.warning,
        );
      case MissedRecovery.letGo:
        return (
          title: 'Let it go',
          message:
              'Too far back to make up — your program has already moved on. '
              'Focus on hitting this week\'s sessions.',
          tone: WorkoutStatTone.neutral,
        );
    }
  }

  String _relativeLabel(DateTime date) {
    final today = _today;
    if (AppDateUtils.isSameDay(date, today)) return 'today';
    if (AppDateUtils.isSameDay(date, AppDateUtils.addDays(today, -1))) {
      return 'yesterday';
    }
    return 'on ${AppDateUtils.weekdayName(date)}, ${AppDateUtils.monthDay(date)}';
  }

  WorkoutConsistencyItem? _consistencyOf(WorkoutHistoryAnalysis analysis) {
    final days = analysis.consistencyDays;
    final hasActivity = days.any(
      (day) => day.isPlanned || day.outcome == WorkoutDayOutcome.completed,
    );
    if (!hasActivity) return null;
    final consistency = analysis.consistency;
    final adherence = consistency.adherence;
    final today = _today;
    final marks = [for (final day in days) _markOf(day)];

    return WorkoutConsistencyItem(
      periodLabel: 'Last ${WorkoutHistoryAnalyzer.consistencyWeeks} weeks',
      headline: adherence == null
          ? '${consistency.workouts}'
          : '${(adherence * _percent).round()}%',
      caption: adherence == null
          ? consistency.workouts == 1
                ? 'workout logged'
                : 'workouts logged'
          : '${consistency.completed} of ${consistency.planned} planned '
                'sessions done',
      progress: adherence,
      stats: [
        WorkoutConsistencyStat(
          value: '${consistency.workouts}',
          label: 'Done',
          tone: WorkoutStatTone.accent,
        ),
        WorkoutConsistencyStat(
          value: '${consistency.missed}',
          label: 'Missed',
          tone: consistency.missed > 0
              ? WorkoutStatTone.alert
              : WorkoutStatTone.neutral,
        ),
        WorkoutConsistencyStat(
          value: '${consistency.streak}',
          label: 'Streak',
          tone: WorkoutStatTone.neutral,
        ),
      ],
      weekdayLabels: [
        for (final day in days.take(DateTime.daysPerWeek))
          AppDateUtils.shortWeekday(day.date).substring(0, 1),
      ],
      days: [
        for (var i = 0; i < days.length; i++)
          WorkoutDayMarkItem(
            label: '${days[i].date.day}',
            mark: marks[i],
            isToday: AppDateUtils.isSameDay(days[i].date, today),
          ),
      ],
      legend: [
        WorkoutDayMark.completed,
        WorkoutDayMark.missed,
        if (marks.contains(WorkoutDayMark.partial)) WorkoutDayMark.partial,
        if (marks.contains(WorkoutDayMark.planned)) WorkoutDayMark.planned,
      ],
      insight: _consistencyInsightOf(consistency),
    );
  }

  WorkoutDayMark _markOf(WorkoutHistoryDay day) => switch (day.outcome) {
    WorkoutDayOutcome.completed => WorkoutDayMark.completed,
    WorkoutDayOutcome.partial => WorkoutDayMark.partial,
    WorkoutDayOutcome.missed => WorkoutDayMark.missed,
    WorkoutDayOutcome.rest => WorkoutDayMark.rest,
    WorkoutDayOutcome.pending =>
      day.isPlanned ? WorkoutDayMark.planned : WorkoutDayMark.rest,
  };

  String? _consistencyInsightOf(WorkoutConsistency consistency) {
    final adherence = consistency.adherence;
    final weekday = consistency.mostMissedWeekday;
    if (consistency.missedInRow >= WorkoutHistoryAnalyzer.patternThreshold) {
      return '${consistency.missedInRow} sessions missed in a row. A shorter '
          'version of your next workout keeps the habit alive — momentum '
          'beats perfection.';
    }
    if (weekday != null) {
      final name = AppDateUtils.weekdayName(
        AppDateUtils.addDays(
          AppDateUtils.startOfWeek(_today),
          weekday - DateTime.monday,
        ),
      );
      return 'You\'ve missed ${consistency.mostMissedCount} ${name}s recently. '
          'If that day is usually busy, plan a lighter session or a rest day '
          'there instead.';
    }
    if (adherence != null &&
        adherence >= _strongAdherence &&
        consistency.planned >= _strongAdherenceMinPlanned) {
      return 'Strong consistency — ${(adherence * _percent).round()}% of '
          'planned sessions done. Keep this rhythm going.';
    }
    if (consistency.missed > 0) {
      return 'Tap a missed session to see what WAVE recommends doing about it.';
    }
    return null;
  }

  Future<void> catchUp(MissedWorkoutItem item) async {
    if (_isShifting ||
        !AppDateUtils.isSameDay(item.date, AppDateUtils.addDays(_today, -1))) {
      return;
    }
    WorkoutPlanEntity? missed;
    for (final plan in _historyPlans) {
      if (AppDateUtils.isSameDay(plan.date, item.date)) missed = plan;
    }
    if (missed == null) return;
    _isShifting = true;
    notifyListeners();
    var scheduled = false;
    try {
      await _planService.scheduleCatchUp(missed, _today);
      _historyPlans = [
        for (final plan in _historyPlans)
          if (identical(plan, missed))
            plan.copyWith(rescheduledTo: _today)
          else
            plan,
      ];
      scheduled = true;
    } on WorkoutException catch (error) {
      _onError(error);
    }
    _isShifting = false;
    notifyListeners();
    if (!scheduled) return;
    _setDate(_today);
    selectTab(WorkoutTab.overview);
    unawaited(_refreshShiftOffer());
  }

  bool get showSuggestion =>
      _selectedTab == WorkoutTab.overview &&
      overview == null &&
      agenda == null &&
      suggestion != null;

  bool get showPrograms =>
      _selectedTab == WorkoutTab.programs && _programs.isNotEmpty;

  bool get showExercises => _selectedTab == WorkoutTab.exercises;

  WorkoutOverviewItem? get overview {
    final session = _selectedSession;
    if (session == null) return null;
    final isYoga = _discipline == WorkoutDiscipline.yoga;
    final daySessions = [
      for (final item in _daySessions)
        if (item.isCompleted || item.isInProgress) item,
    ];
    return WorkoutOverviewItem(
      summary: _summaryOf(session),
      summaries: [for (final item in daySessions) _summaryOf(item)],
      summaryIndex: daySessions
          .indexWhere((item) => item.id == session.id)
          .clamp(0, daySessions.isEmpty ? 0 : daySessions.length - 1),
      trainingEffect: isYoga ? null : _trainingEffectOf(session),
      muscles: isYoga ? const [] : _musclesOf(session),
      targets: isYoga ? MuscleTargets.empty : _targetsOf(session),
      heartRate: _heartRateOf(session),
      performance: isYoga
          ? _yogaPerformanceOf(session)
          : _performanceOf(session),
    );
  }

  WorkoutSummaryItem _summaryOf(WorkoutSessionEntity session) {
    return WorkoutSummaryItem(
      name: session.name,
      exercisesLabel: _exercisesLabelOf(session),
      flowPointsLabel: '+ ${session.flowPoints} FLOWW points',
      statusLabel: session.isCompleted
          ? 'Completed'
          : session.isTimerPaused
          ? 'Paused'
          : 'In Progress',
      isCompleted: session.isCompleted,
      imageUrl: ProgramArtwork.ofSession(session),
      sessionId: session.id,
      stats: [
        WorkoutStatItem(
          icon: Icons.schedule,
          title: 'DURATION',
          value: _durationLabel(session.trackedSeconds),
          unit: 'min',
        ),
        _loadStatOf(session),
        WorkoutStatItem(
          icon: Icons.local_fire_department,
          title: 'CALORIES',
          value: NumberFormatter.grouped(session.caloriesKcal),
          unit: 'kcal',
        ),
        WorkoutStatItem(
          icon: Icons.monitor_heart,
          title: 'AVG HEART RATE',
          value: session.averageHeartRate == null
              ? '—'
              : '${session.averageHeartRate}',
          unit: session.averageHeartRate == null ? '' : 'bpm',
        ),
      ],
    );
  }

  WorkoutStatItem _loadStatOf(WorkoutSessionEntity session) =>
      switch (_discipline) {
        WorkoutDiscipline.gym => WorkoutStatItem(
          icon: Icons.bar_chart,
          title: 'VOLUME',
          value: NumberFormatter.grouped(session.volumeKg.round()),
          unit: 'kg',
        ),
        WorkoutDiscipline.calisthenics => WorkoutStatItem(
          icon: Icons.bar_chart,
          title: 'TOTAL REPS',
          value: NumberFormatter.grouped(session.totalReps),
          unit: _holdLabelOf(session),
        ),
        WorkoutDiscipline.yoga => WorkoutStatItem(
          icon: Icons.self_improvement,
          title: 'COMFORT',
          value: session.selfCheckAverage?.toStringAsFixed(1) ?? '—',
          unit: session.selfCheckAverage == null ? '' : '/ 5',
        ),
      };

  int _holdSecondsOf(WorkoutSessionEntity session) {
    var total = 0;
    for (final exercise in session.exercises) {
      if (exercise.isTimed) total += exercise.completedSeconds;
    }
    return total;
  }

  String _holdLabelOf(WorkoutSessionEntity session) {
    final seconds = _holdSecondsOf(session);
    return seconds == 0 ? '' : '+ ${_durationLabel(seconds)} hold';
  }

  PerformanceItem _yogaPerformanceOf(WorkoutSessionEntity session) {
    var sides = 0;
    for (final exercise in session.exercises) {
      sides += exercise.workingSetCount;
    }
    return PerformanceItem(
      stats: [
        PerformanceStatItem(
          label: 'Poses Practised',
          value: '${session.exerciseCount}',
          tone: WorkoutStatTone.accent,
        ),
        PerformanceStatItem(
          label: 'Holds & Rounds',
          value: '$sides',
          tone: WorkoutStatTone.neutral,
        ),
        PerformanceStatItem(
          label: 'Time in Poses',
          value: '${_durationLabel(_holdSecondsOf(session))} min',
          tone: WorkoutStatTone.neutral,
        ),
        PerformanceStatItem(
          label: 'Self-check',
          value: session.selfCheckAverage == null
              ? 'Not saved'
              : '${session.selfCheckAverage!.toStringAsFixed(1)} / 5',
          tone: WorkoutStatTone.neutral,
        ),
      ],
      records: const [],
    );
  }

  String _exercisesLabelOf(WorkoutSessionEntity session) {
    if (session.isInProgress) {
      final done = session.exercises.where((entry) => entry.isComplete).length;
      return '$done / ${session.exercises.length} '
          '${_capitalized(_discipline.itemsNoun)} done';
    }
    final count = session.exerciseCount;
    final noun = count == 1 ? _discipline.itemNoun : _discipline.itemsNoun;
    return '$count ${_capitalized(noun)}';
  }

  static String _capitalized(String text) =>
      text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';

  TrainingEffectItem _trainingEffectOf(WorkoutSessionEntity session) {
    const total = WorkoutMetrics.effectSegments;
    final filled =
        (session.trainingEffect / WorkoutMetrics.maxTrainingEffect * total)
            .round()
            .clamp(0, total);
    return TrainingEffectItem(
      score: session.trainingEffect.toStringAsFixed(1),
      rating: WorkoutMetrics.effectRatingOf(session.trainingEffect),
      summary: WorkoutMetrics.effectSummaryOf(
        session.trainingEffect,
        session.muscleActivation,
      ),
      filledSegments: filled,
      totalSegments: total,
      recoveryLabel: 'Recovery Recommended',
      recoveryValue:
          '${WorkoutMetrics.recoveryHoursOf(session.trainingEffect)}h',
    );
  }

  MuscleTargets _targetsOf(WorkoutSessionEntity session) =>
      MuscleTargeting.ofShares({
        for (final muscle in session.muscleActivation)
          muscle.name: muscle.share,
      });

  MuscleMapTemplate? muscleMapOf(MuscleBodySide side) =>
      _muscleMapService.templateOf(side);

  Future<void> _loadMuscleMap() async {
    try {
      await _muscleMapService.load();
      notifyListeners();
    } catch (_) {}
  }

  List<MuscleFocusEntry> _musclesOf(WorkoutSessionEntity session) => [
    for (final muscle in session.muscleActivation)
      MuscleFocusEntry(
        name: muscle.name,
        shareLabel: '${(muscle.share * 100).round()}%',
        share: muscle.share,
      ),
  ];

  String get summaryInfoMessage => switch (_discipline) {
    WorkoutDiscipline.yoga =>
      '$titlePrefix overview: class length, calories, your self-check comfort '
          'score and heart rate. Comfort is the average of the five 1–5 '
          'statements you rate after class: steady breath, knowing when to '
          'modify, slow transitions, using support and finishing settled.',
    WorkoutDiscipline.calisthenics =>
      '$titlePrefix overview: session length, total reps and time under '
          'hold, calories and heart rate. Bodyweight work is tracked in reps '
          'and seconds rather than kilograms, so progress shows as harder '
          'progressions and more clean reps.',
    WorkoutDiscipline.gym =>
      '$titlePrefix overview: total volume, calories burned, and average '
          'heart rate from your logged session. Volume is the weight you '
          'lifted multiplied by the reps you completed across every set. '
          'Calories use your logged body weight and the intensity of each '
          'movement. Heart rate is read from Apple Health or Health Connect '
          'when connected.',
  };

  String get trainingEffectInfoMessage =>
      'Training Effect (1–5) measures how much this session moved your '
      'fitness. It combines the sets you completed, how long you trained, '
      'and the intensity of the movements you chose. 1–2 = recovery, '
      '3 = maintaining, 4 = improving, 5 = highly impactful.';

  MuscleAnatomyItem? get anatomy {
    final session = _selectedSession;
    if (session == null || session.muscleActivation.isEmpty) return null;
    final activation = session.muscleActivation;
    return MuscleAnatomyItem(
      subtitle: '$titlePrefix activation map',
      targets: _targetsOf(session),
      muscles: [
        for (var i = 0; i < activation.length; i++)
          MuscleFocusEntry(
            name: activation[i].name,
            shareLabel: '${(activation[i].share * 100).round()}%',
            share: activation[i].share,
            highlight: i == 0 ? _highestActivationLabel : null,
          ),
      ],
      recoveryTip:
          'Primary muscles (${activation.first.name}) need '
          '${WorkoutMetrics.recoveryHoursOf(session.trainingEffect)}h to '
          'fully recover. Avoid targeting them again tomorrow.',
    );
  }

  String get _highestActivationLabel => dayStatus == WorkoutDayStatus.today
      ? 'Highest activation today'
      : 'Highest activation';

  HeartRateItem? _heartRateOf(WorkoutSessionEntity session) {
    final average = session.averageHeartRate;
    final peak = session.peakHeartRate;
    if (average == null || peak == null || session.heartRateSamples.isEmpty) {
      return null;
    }
    final totalMinutes = session.durationSeconds ~/ _secondsPerMinute;
    final step = totalMinutes / _heartRateAxisSteps;
    return HeartRateItem(
      stats: [
        HeartRateStatItem(
          value: '$average',
          unit: 'bpm',
          label: 'Average',
          tone: WorkoutStatTone.alert,
        ),
        HeartRateStatItem(
          value: '$peak',
          unit: 'bpm',
          label: 'Peak',
          tone: WorkoutStatTone.accent,
        ),
        HeartRateStatItem(
          value: '${_zoneOf(average, peak)}',
          unit: '/ 5',
          label: 'Zone',
          tone: WorkoutStatTone.ember,
        ),
      ],
      samples: [
        for (final sample in session.heartRateSamples) sample.toDouble(),
      ],
      axisLabels: [
        for (var i = 0; i < _heartRateAxisSteps; i++) '${(step * i).round()}m',
        '${totalMinutes}m',
      ],
    );
  }

  int _zoneOf(int average, int peak) {
    if (peak == 0) return 1;
    final ratio = average / peak;
    if (ratio < 0.6) return 1;
    if (ratio < 0.7) return 2;
    if (ratio < 0.8) return 3;
    if (ratio < 0.9) return 4;
    return 5;
  }

  PerformanceItem _performanceOf(WorkoutSessionEntity session) {
    return PerformanceItem(
      stats: [
        PerformanceStatItem(
          label: 'New PRs',
          value: '${session.personalRecords.length}',
          tone: WorkoutStatTone.accent,
        ),
        PerformanceStatItem(
          label: 'Exercises Completed',
          value: '${session.exerciseCount}',
          tone: WorkoutStatTone.neutral,
        ),
        PerformanceStatItem(
          label: 'Total Sets',
          value: '${session.totalSets}',
          tone: WorkoutStatTone.neutral,
        ),
        PerformanceStatItem(
          label: 'Total Reps',
          value: '${session.totalReps}',
          tone: WorkoutStatTone.neutral,
        ),
      ],
      records: [
        for (final record in session.personalRecords)
          PersonalRecordItem(
            label: '${record.glyph} ${record.exercise}',
            improvement: record.improvement,
          ),
      ],
    );
  }

  String _durationLabel(int seconds) {
    final minutes = seconds ~/ _secondsPerMinute;
    final remainder = seconds % _secondsPerMinute;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }

  bool get isReadOnly => dayStatus == WorkoutDayStatus.past;

  bool get showReadOnlyBanner =>
      isReadOnly && _selectedTab == WorkoutTab.overview && overview != null;

  String get readOnlyLabel {
    final isYesterday = AppDateUtils.isSameDay(
      _selectedDate,
      AppDateUtils.addDays(_today, -1),
    );
    final distance = AppDateUtils.daysBetween(_today, _selectedDate).abs();
    final reference = isYesterday
        ? 'Yesterday'
        : distance <= _weekdayReferenceDays
        ? AppDateUtils.weekdayName(_selectedDate)
        : AppDateUtils.dayMonth(_selectedDate);
    return '$reference\'s session — historical data (read-only)';
  }

  String get suggestionTitle => _nextPending?.isCatchUp ?? false
      ? 'Catch-up For Today'
      : dayStatus == WorkoutDayStatus.today
      ? 'Scheduled For Today'
      : 'Scheduled For ${AppDateUtils.weekdayName(_selectedDate)}';

  WorkoutSuggestionItem? get suggestion {
    if (dayStatus == WorkoutDayStatus.past) return null;
    final next = _nextPending;
    final plan = next?.plan;
    if (next == null || plan == null) return null;
    final active = _state.activeProgram;
    final kind = WorkoutDiscipline.ofPlan(plan);
    return WorkoutSuggestionItem(
      eyebrow: suggestionTitle.toUpperCase(),
      title: plan.name,
      metaLabels: [
        '${plan.durationMinutes} min',
        kind.countLabel(plan.exercises.length),
        if (plan.focus.isNotEmpty) plan.focus,
      ],
      contextLabel: next.isCatchUp
          ? 'Missed on ${AppDateUtils.weekdayName(plan.date)}, '
                '${AppDateUtils.dayMonth(plan.date)}'
          : kind != WorkoutDiscipline.gym && plan.programLabel.isNotEmpty
          ? plan.programLabel
          : active == null
          ? null
          : _programProgressLabel(active, plan.date),
      imageUrl: _suggestionImageOf(plan),
      actionLabel: dayStatus == WorkoutDayStatus.future
          ? 'PREVIEW ${kind.sessionNoun.toUpperCase()}'
          : null,
    );
  }

  String? _suggestionImageOf(WorkoutPlanEntity plan) {
    final image = ProgramArtwork.ofPlan(plan);
    if (image != null) return image;
    final active = _state.activeProgram;
    final program = active == null ? null : _programById(active.id);
    return program == null ? null : ProgramArtwork.of(program);
  }

  ActiveProgramItem? get activeProgram {
    final program = _state.activeProgram;
    if (program == null) return null;
    if (program.hasFixedLength) {
      final day = program.dayNumberAt(_today);
      final progress = day / program.totalDays;
      return ActiveProgramItem(
        name: program.name,
        scheduleLabel:
            'Day $day of ${program.totalDays} · '
            '${program.daysPerWeek} days/week',
        statusLabel: 'ACTIVE',
        levelLabel:
            '${program.level} · ${program.totalDays - day} days remaining',
        progressLabel: '${(progress * 100).round()}% complete',
        progress: progress,
        isWave: program.id == _state.generatedProgramId,
      );
    }
    if (program.totalWeeks == 0) return null;
    final week = program.weekAt(_today);
    final remaining = program.totalWeeks - week + 1;
    final progress = week / program.totalWeeks;
    return ActiveProgramItem(
      name: program.name,
      scheduleLabel:
          'Week $week of ${program.totalWeeks} · '
          '${program.daysPerWeek} days/week',
      statusLabel: 'ACTIVE',
      levelLabel: '${program.level} · $remaining weeks remaining',
      progressLabel: '${(progress * 100).round()}% complete',
      progress: progress,
    );
  }

  String? get activeProgramId => _state.activeProgram?.id;

  static const int _exploreMinGoals = 2;

  static const List<ProgramLevel> _exploreLevels = [
    ProgramLevel.allLevels,
    ProgramLevel.beginner,
    ProgramLevel.intermediate,
    ProgramLevel.advanced,
  ];

  bool get _hasCustomPrograms => _programs.any((program) => program.isCustom);

  List<ProgramFilterItem<WorkoutDiscipline>> get catalogDisciplines => [
    for (final discipline in WorkoutDiscipline.values)
      ProgramFilterItem(
        value: discipline,
        label: discipline.label,
        isSelected: discipline == catalogDiscipline,
      ),
  ];

  void selectCatalogDiscipline(WorkoutDiscipline discipline) {
    if (discipline == catalogDiscipline) return;
    _catalogDiscipline = discipline;
    _goalFilter = _allFilter;
    _levelFilter = null;
    _isBrowsingPrograms = true;
    notifyListeners();
  }

  String get catalogHeading => 'Browse ${catalogDiscipline.label}';

  CalLevel? get _userCalLevel {
    final course = _courseLevel;
    if (course != null) return course;
    final results = CalisthenicsPlacement.resultsOf(_answers);
    if (_discipline != WorkoutDiscipline.calisthenics && results.isEmpty) {
      return null;
    }
    return CalisthenicsPlacement.levelFor(results);
  }

  ProgramLevel? get _userProgramLevel {
    final key = switch (catalogDiscipline) {
      WorkoutDiscipline.gym => _gymExperienceKey,
      WorkoutDiscipline.yoga => _yogaExperienceKey,
      WorkoutDiscipline.calisthenics => null,
    };
    final answer = key == null ? null : _answers[key];
    if (answer is! String) return null;
    final label = answer.trim().toLowerCase();
    for (final level in ProgramLevel.values) {
      if (level.label.toLowerCase() == label) return level;
    }
    return null;
  }

  List<ProgramGoalCardItem> programGoalCards({required bool isUnlocked}) {
    final cards = [
      for (final goal in ProgramGoal.values)
        if (_programs.any(
          (program) => program.goal == goal && !program.isCustom,
        ))
          ProgramGoalCardItem(
            id: goal.id,
            title: goal.headline,
            subtitle: goal.tagline,
            imageUrl: ProgramArtwork.ofGoal(goal),
            isLocked: goal.isPremium && !isUnlocked,
          ),
    ];
    return cards.length < _exploreMinGoals ? const [] : cards;
  }

  List<ProgramLevelCardItem> get programLevelCards {
    if (catalogDiscipline == WorkoutDiscipline.calisthenics) {
      final current = _userCalLevel;
      return [
        for (final level in CalLevel.values)
          if (_programs.any((program) => program.id == level.courseId))
            ProgramLevelCardItem(
              id: level.courseId,
              title: level.label,
              imageUrl: ProgramArtwork.ofCalLevel(level),
              programId: level.courseId,
              isCurrent: level == current,
            ),
      ];
    }
    final current = _userProgramLevel;
    return [
      for (final level in _exploreLevels)
        if (level == ProgramLevel.allLevels ||
            _programs.any(
              (program) => ProgramLevel.fromLabel(program.level) == level,
            ))
          ProgramLevelCardItem(
            id: level.name,
            title: level.label,
            imageUrl: ProgramArtwork.ofLevel(level),
            isCurrent: level == current,
          ),
    ];
  }

  ProgramCollectionItem? get programCollection {
    if (!_hasCustomPrograms) return null;
    final count = _programs.where((program) => program.isCustom).length;
    return ProgramCollectionItem(
      title: 'My programs',
      subtitle:
          '$count ${count == 1 ? 'program' : 'programs'} you built, ready to '
          'run or tweak.',
    );
  }

  bool get showProgramExplore => _isBrowsingPrograms;

  String get programListTitle {
    if (_isBrowsingPrograms) return 'All programs';
    if (_goalFilter == _mineFilter) return 'My programs';
    if (_goalFilter != _allFilter) return ProgramGoal.fromId(_goalFilter).label;
    final level = _levelFilter;
    for (final item in ProgramLevel.values) {
      if (item.name == level) return '${item.label} programs';
    }
    return 'All programs';
  }

  void exploreGoal(String goalId) {
    _goalFilter = goalId;
    _levelFilter = null;
    _isBrowsingPrograms = false;
    notifyListeners();
  }

  void exploreLevel(String levelId) {
    _goalFilter = _allFilter;
    _levelFilter = levelId == ProgramLevel.allLevels.name ? null : levelId;
    _isBrowsingPrograms = false;
    notifyListeners();
  }

  void backToExplore() {
    _goalFilter = _allFilter;
    _levelFilter = null;
    _isBrowsingPrograms = true;
    notifyListeners();
  }

  void showMyPrograms() {
    _goalFilter = _mineFilter;
    _levelFilter = null;
    _isBrowsingPrograms = false;
    notifyListeners();
  }

  bool _matchesFilters(WorkoutProgramEntity program) {
    final goalMatches = switch (_goalFilter) {
      _allFilter => true,
      _mineFilter => program.isCustom,
      _ => program.goal.id == _goalFilter,
    };
    if (!program.isStandard) return false;
    final level = ProgramLevel.fromLabel(program.level);
    final levelMatches =
        _levelFilter == null ||
        level == ProgramLevel.allLevels ||
        level.name == _levelFilter;
    return goalMatches && levelMatches;
  }

  String get programsCountLabel {
    final count = programs.length;
    return '$count ${count == 1 ? 'program' : 'programs'}';
  }

  String get programsEmptyMessage => switch (catalogDiscipline) {
    WorkoutDiscipline.yoga =>
      'Your yoga programs are still syncing. Pull back in a moment to see '
          'the NYASP Hatha course.',
    WorkoutDiscipline.calisthenics =>
      'No calisthenics levels match this filter. Try another level.',
    WorkoutDiscipline.gym =>
      'No programs match these filters. Try another goal or level, or build '
          'your own.',
  };

  ProgramStartSetup? programStartSetupFor(String id) {
    final program = _programById(id);
    if (program == null) return null;
    return ProgramStartSetup(
      programId: program.id,
      name: program.name,
      dayWeekdays: [for (final day in program.days) day.weekday],
      weeks: program.weeks,
      lengthDays: program.lengthDays,
    );
  }

  List<int> _weekdaysOf(WorkoutProgramEntity program) {
    final active = _state.activeProgram;
    if (active != null &&
        active.id == program.id &&
        active.weekdays.length == program.days.length) {
      return active.weekdays;
    }
    return [for (final day in program.days) day.weekday];
  }

  ProgramDetailItem? programDetailFor(String id) {
    final program = _programById(id);
    if (program == null) return null;
    final active = _state.activeProgram;
    final isActive = active?.id == program.id;
    final canStart = !program.isChallenge;
    final isOwnType = _discipline.matches(program);
    final requirement = _requirementOf(program);
    final canAddToday =
        !isActive && program.days.isNotEmpty && !_hasSessionInProgress;
    final weekdays = _weekdaysOf(program);
    final order = [for (var i = 0; i < program.days.length; i++) i]
      ..sort((a, b) => weekdays[a].compareTo(weekdays[b]));
    final anchor = AppDateUtils.startOfWeek(_today);
    return ProgramDetailItem(
      id: program.id,
      name: program.name,
      description: program.description,
      logo: ProgramArtwork.of(program),
      isActive: isActive,
      isCustom: program.isCustom,
      isPremium: _isPremium(program),
      isWave: program.isGenerated,
      isCourse: canStart && YogaPlanMapper.isCourse(program.course),
      canStart: canStart,
      canCustomize: program.isStandard && program.course == null,
      canAddToday: canAddToday,
      scheduleLabel: canAddToday ? 'Sessions' : 'Weekly schedule',
      addTodayNote: isActive
          ? null
          : !canAddToday
          ? 'Finish the session you have in progress to add another one '
                'today.'
          : program.isChallenge
          ? 'Tap the session to do it today. Finishing it earns Flow Score, '
                'keeps your streak going and counts toward your challenge '
                'badges.'
          : requirement != null && requirement.isMet
          ? '${requirement.message} Tap a stage to do it today.'
          : program.isSkill
          ? 'Tap a stage to do it today. Move to the next stage once every '
                'set feels controlled.'
          : isOwnType
          ? 'Tap a session to do it today, or start the program to make it '
                'your plan.'
          : 'This sits outside your ${_discipline.label} plan. Tap a session '
                'to do it today and your plan stays as it is, or start the '
                'program to make it your plan instead.',
      schedule: [
        for (final index in order)
          ProgramScheduleItem(
            dayIndex: index,
            weekdayLabel: AppDateUtils.shortWeekday(
              AppDateUtils.addDays(anchor, weekdays[index] - DateTime.monday),
            ).toUpperCase(),
            name: program.days[index].name,
            detail:
                '${program.days[index].focus} · '
                '${program.days[index].exercises.length} exercises · '
                '${program.days[index].durationMinutes} min',
          ),
      ],
      stats: [
        if (program.isChallenge)
          WorkoutStatItem(
            icon: Icons.schedule,
            title: 'Time',
            value: '${program.averageMinutes}',
            unit: 'min',
          )
        else
          WorkoutStatItem(
            icon: Icons.schedule,
            title: 'Duration',
            value: program.hasFixedLength
                ? '${program.lengthDays}'
                : '${program.weeks}',
            unit: program.hasFixedLength ? 'days' : 'weeks',
          ),
        if (program.isStandard)
          WorkoutStatItem(
            icon: Icons.track_changes,
            title: 'Frequency',
            value: '${program.sessionsPerWeek}x',
            unit: '/ week',
          )
        else
          WorkoutStatItem(
            icon: Icons.track_changes,
            title: program.isSkill ? 'Stages' : 'Moves',
            value: program.isSkill
                ? '${program.days.length}'
                : '${program.days.first.exercises.length}',
            unit: '',
          ),
        WorkoutStatItem(
          icon: Icons.bar_chart,
          title: 'Level',
          value: program.level,
          unit: '',
        ),
      ],
      warning: requirement != null && !requirement.isMet
          ? requirement.message
          : active == null || isActive || !canStart
          ? null
          : 'Starting this program replaces ${active.name} and '
                'reschedules your upcoming sessions.',
    );
  }

  List<ProgramItem> get programs {
    final activeId = _state.activeProgram?.id;
    final filtered =
        [
          for (final program in _programs)
            if (_matchesFilters(program)) program,
        ]..sort((a, b) {
          final activeOrder = (b.id == activeId ? 1 : 0).compareTo(
            a.id == activeId ? 1 : 0,
          );
          if (activeOrder != 0) return activeOrder;
          final generatedOrder = (b.isGenerated ? 1 : 0).compareTo(
            a.isGenerated ? 1 : 0,
          );
          if (generatedOrder != 0) return generatedOrder;
          final customOrder = (b.isCustom ? 1 : 0).compareTo(
            a.isCustom ? 1 : 0,
          );
          if (customOrder != 0) return customOrder;
          return a.name.compareTo(b.name);
        });
    return [for (final program in filtered) _itemOf(program)];
  }

  bool _isPremium(WorkoutProgramEntity program) =>
      program.goal.isPremium && !program.isCustom && !program.isChallenge;

  ProgramItem _itemOf(WorkoutProgramEntity program, {String? badgeLabel}) {
    final activeId = _state.activeProgram?.id;
    final anchor = AppDateUtils.startOfWeek(_today);
    final stages = program.days.length;
    return ProgramItem(
      id: program.id,
      name: program.name,
      description: program.description,
      logo: ProgramArtwork.of(program),
      metaLabel: program.isChallenge
          ? '${program.averageMinutes} min · ${program.days.first.focus}'
          : program.hasFixedLength
          ? '${program.level} · ${program.lengthDays} days'
          : '${program.level} · ${program.weeks} '
                '${program.weeks == 1 ? 'week' : 'weeks'}',
      scheduleLabel: program.isChallenge
          ? '${program.days.first.exercises.length} moves · no kit plan needed'
          : program.isSkill
          ? '$stages ${stages == 1 ? 'stage' : 'stages'} · '
                '~${program.averageMinutes} min'
          : '${program.sessionsPerWeek}x / week · '
                '~${program.averageMinutes} min',
      weekdays: [
        if (program.isStandard)
          for (var i = 0; i < DateTime.daysPerWeek; i++)
            ProgramWeekdayItem(
              label: AppDateUtils.shortWeekday(
                AppDateUtils.addDays(anchor, i),
              ).substring(0, 1),
              isTraining: _weekdaysOf(program).contains(DateTime.monday + i),
            ),
      ],
      badgeLabel:
          badgeLabel ??
          (program.id == activeId
              ? 'Active'
              : program.isGenerated
              ? 'WAVE'
              : program.isCustom
              ? 'Custom'
              : null),
      isActive: program.id == activeId,
      isPremium: _isPremium(program),
      isWave: program.isGenerated,
    );
  }

  List<ProgramItem> get skillPrograms => [
    if (catalogDiscipline == WorkoutDiscipline.calisthenics)
      for (final program in _allPrograms)
        if (program.isSkill)
          _itemOf(
            program,
            badgeLabel: (_requirementOf(program)?.isMet ?? false)
                ? 'Ready'
                : null,
          ),
  ];

  ({bool isMet, String message})? _requirementOf(WorkoutProgramEntity program) {
    final requirements = WorkoutExtrasData.requirements[program.id];
    if (!program.isSkill || requirements == null || requirements.isEmpty) {
      return null;
    }
    final results = CalisthenicsPlacement.resultsOf(_answers);
    final needs = [
      for (final item in requirements) '${item.minimum} ${item.label}',
    ].join(' and ');
    final missing = [
      for (final item in requirements)
        if (results[item.testId] case final value? when value < item.minimum)
          '${NumberFormatter.trimmed(value)} of ${item.minimum} ${item.label}',
    ];
    final isTested = requirements.every(
      (item) => results.containsKey(item.testId),
    );
    if (missing.isNotEmpty) {
      return (
        isMet: false,
        message:
            'Build up first: your strength test shows ${missing.join(' and ')}'
            '. Work on the earlier stages or your level plan until you reach '
            '$needs.',
      );
    }
    if (!isTested) {
      return (
        isMet: false,
        message:
            'Before you start you should manage $needs. Test yourself first, '
            'or add your results in Settings → Onboarding answers so WAVE '
            'can check for you.',
      );
    }
    return (
      isMet: true,
      message: 'Your strength test clears the requirement ($needs).',
    );
  }

  List<WorkoutProgramEntity> get _challenges => [
    for (final program in _allPrograms)
      if (program.isChallenge) program,
  ]..sort((a, b) => a.id.compareTo(b.id));

  Set<String> get _challengesDoneThisWeek {
    final weekStart = AppDateUtils.startOfWeek(_today);
    return {
      for (final session in _sessions)
        if (session.isCompleted && !session.date.isBefore(weekStart))
          ?session.programId,
    };
  }

  ChallengeBoardItem? get challengeBoard {
    final challenges = _challenges;
    if (challenges.isEmpty) return null;
    final done = _challengesDoneThisWeek;
    final week =
        AppDateUtils.daysBetween(
          DateTime(_challengeEpochYear),
          AppDateUtils.startOfWeek(_today),
        ) ~/
        DateTime.daysPerWeek;
    final weekly = challenges[week % challenges.length];
    final doneCount = challenges
        .where((program) => done.contains(program.id))
        .length;
    return ChallengeBoardItem(
      weekly: ChallengeItem(
        id: weekly.id,
        title: weekly.name,
        subtitle: weekly.description,
        metaLabel: '${weekly.averageMinutes} min · ${weekly.days.first.focus}',
        imageUrl: ProgramArtwork.of(weekly),
        isDone: done.contains(weekly.id),
      ),
      others: [
        for (final program in challenges)
          if (program.id != weekly.id)
            _itemOf(
              program,
              badgeLabel: done.contains(program.id) ? 'Done' : null,
            ),
      ],
      progressLabel: '$doneCount of ${challenges.length} done this week',
      rewardLabel:
          'Open to everyone. Each one adds to your Flow Score, streak and '
          'challenge badges.',
    );
  }

  WorkoutLevelReportItem? get levelReport {
    final active = _state.activeProgram;
    if (active == null || !_activeMatchesDiscipline) return null;
    final today = _today;
    final daysOnPlan = AppDateUtils.daysBetween(active.startDate, today) + 1;
    if (daysOnPlan < 1) return null;
    final week = _periodOf(
      label: 'This week',
      from: AppDateUtils.startOfWeek(today),
      planned: active.daysPerWeek,
    );
    final weeksOnPlan = (daysOnPlan / DateTime.daysPerWeek).ceil().clamp(
      1,
      _reportWeeks,
    );
    final month = _periodOf(
      label: 'Last $_reportWeeks weeks',
      from: AppDateUtils.addDays(
        today,
        -(_reportWeeks * DateTime.daysPerWeek - 1),
      ),
      planned: active.daysPerWeek * weeksOnPlan,
    );
    final adherence = month.item.progress ?? 0;
    final reserve = month.reserve;
    final weeksLeft = _reportWeeks - daysOnPlan ~/ DateTime.daysPerWeek;
    final next = _nextLevelLabel;
    final levelLabel = _currentLevelLabel;
    final periods = [week.item, month.item];
    if (weeksLeft > 0) {
      return WorkoutLevelReportItem(
        levelLabel: levelLabel,
        verdictTitle:
            'Level check in $weeksLeft '
            '${weeksLeft == 1 ? 'week' : 'weeks'}',
        verdictMessage:
            'WAVE reviews your consistency, sets, reps and reps in reserve '
            'after $_reportWeeks weeks on the plan before deciding on a '
            'level-up.',
        isReady: false,
        periods: periods,
      );
    }
    if (adherence >= _readyAdherence &&
        reserve != null &&
        reserve < _minComfortReserve) {
      return WorkoutLevelReportItem(
        levelLabel: levelLabel,
        verdictTitle: 'Hold this level',
        verdictMessage:
            'Your consistency is there, but sets are ending with almost '
            'nothing left (${reserve.toStringAsFixed(1)} reps in reserve on '
            'average). Stay here until they feel more comfortable.',
        isReady: false,
        periods: periods,
      );
    }
    if (adherence >= _readyAdherence) {
      return WorkoutLevelReportItem(
        levelLabel: levelLabel,
        verdictTitle: next == null
            ? 'Top level, still progressing'
            : 'Ready for $next',
        verdictMessage: next == null
            ? 'You completed ${(adherence * _percent).round()}% of your '
                  'planned sessions. WAVE keeps raising sets, reps and load '
                  'inside your plan.'
            : 'You completed ${(adherence * _percent).round()}% of your '
                  'planned sessions over the last $_reportWeeks weeks with '
                  'reps to spare. You can move up.',
        isReady: next != null,
        periods: periods,
        actionLabel: next == null ? null : 'Level up to $next',
      );
    }
    return WorkoutLevelReportItem(
      levelLabel: levelLabel,
      verdictTitle: adherence >= _steadyAdherence
          ? 'On track'
          : 'Build consistency first',
      verdictMessage:
          'You completed ${(adherence * _percent).round()}% of your planned '
          'sessions over the last $_reportWeeks weeks. Reach '
          '${(_readyAdherence * _percent).round()}% to level up.',
      isReady: false,
      periods: periods,
    );
  }

  ({WorkoutLevelPeriodItem item, double? reserve}) _periodOf({
    required String label,
    required DateTime from,
    required int planned,
  }) {
    var done = 0;
    var sets = 0;
    var reps = 0;
    var reserveTotal = 0;
    var reserveCount = 0;
    for (final session in _sessions) {
      if (!session.isCompleted || session.date.isBefore(from)) continue;
      if (!session.isManual) done++;
      sets += session.totalSets;
      reps += session.totalReps;
      for (final entry in session.exercises) {
        for (final set in entry.workingSets) {
          final reserve = set.repsInReserve;
          if (reserve == null) continue;
          reserveTotal += reserve;
          reserveCount++;
        }
      }
    }
    final reserve = reserveCount == 0 ? null : reserveTotal / reserveCount;
    return (
      item: WorkoutLevelPeriodItem(
        label: label,
        sessionsLabel: planned > 0
            ? '$done of $planned sessions'
            : '$done ${done == 1 ? 'session' : 'sessions'}',
        volumeLabel: '$sets sets · $reps reps',
        effortLabel: reserve == null
            ? 'No RIR logged'
            : '${reserve.toStringAsFixed(1)} avg RIR',
        progress: planned > 0 ? (done / planned).clamp(0, 1).toDouble() : null,
      ),
      reserve: reserve,
    );
  }

  String get _currentLevelLabel => switch (_discipline) {
    WorkoutDiscipline.calisthenics => calLevel.label,
    _ => _primaryLevel?.label ?? 'Your level',
  };

  ProgramLevel? get _primaryLevel {
    final key = _discipline == WorkoutDiscipline.yoga
        ? _yogaExperienceKey
        : _gymExperienceKey;
    final answer = _answers[key];
    if (answer is! String) return null;
    for (final level in ProgramLevel.values) {
      if (level.label.toLowerCase() == answer.trim().toLowerCase()) {
        return level;
      }
    }
    return null;
  }

  ProgramLevel? get _nextProgramLevel => switch (_primaryLevel) {
    ProgramLevel.beginner => ProgramLevel.intermediate,
    ProgramLevel.intermediate => ProgramLevel.advanced,
    _ => null,
  };

  String? get _nextLevelLabel => switch (_discipline) {
    WorkoutDiscipline.calisthenics => calLevel.next?.label,
    _ => _nextProgramLevel?.label,
  };

  String? get levelUpProgramId => _discipline == WorkoutDiscipline.calisthenics
      ? calLevel.next?.courseId
      : null;

  String get levelUpTitle => 'Level up to ${_nextLevelLabel ?? ''}?';

  String get levelUpMessage =>
      'WAVE updates your experience level and rebuilds your plan at the new '
      'level. Upcoming sessions are replaced; workouts you already logged '
      'stay in your history.';

  String get levelUpConfirmLabel => 'Level up';

  String get levelUpCancelLabel => 'Not yet';

  Future<void> levelUp() async {
    final next = _nextProgramLevel;
    if (next == null || _isBuildingPlan) return;
    final key = _discipline == WorkoutDiscipline.yoga
        ? _yogaExperienceKey
        : _gymExperienceKey;
    try {
      await _answersService.saveAnswers({..._answers, key: next.label});
    } on OnboardingAnswersException catch (error) {
      _planBuildError = error.message;
      notifyListeners();
      return;
    }
    await buildPlan();
  }

  WorkoutProgramEntity? _programById(String id) {
    for (final program in _allPrograms) {
      if (program.id == id) return program;
    }
    return null;
  }

  Future<void> startProgram(String id, ProgramStartConfig config) async {
    final program = _programById(id);
    if (program == null) return;
    try {
      final active = _programService.activeEntryFor(
        program,
        startDate: config.startDate,
        weeks: config.weeks,
        weekdays: config.weekdays,
      );
      await _planService.scheduleProgram(
        program,
        active,
        from: _today,
        saveActive: true,
      );
      _goalFilter = _allFilter;
      _levelFilter = null;
      _isBrowsingPrograms = true;
      _setDate(_today);
      selectTab(WorkoutTab.overview);
    } on WorkoutException catch (error) {
      _onError(error);
    }
  }

  bool get _hasSessionInProgress {
    final today = _today;
    return _sessions.any(
      (session) =>
          session.isInProgress && AppDateUtils.isSameDay(session.date, today),
    );
  }

  Future<ActiveWorkoutArgs?> startExtraSession(
    String programId,
    int dayIndex,
  ) async {
    final program = _programById(programId);
    if (program == null || _isStartingExtra || _hasSessionInProgress) {
      return null;
    }
    if (dayIndex < 0 || dayIndex >= program.days.length) return null;
    _isStartingExtra = true;
    try {
      final today = _today;
      final active = _programService.activeEntryFor(
        program,
        startDate: today,
        weekdays: [
          for (var i = 0; i < program.days.length; i++)
            (today.weekday - 1 + i - dayIndex) % DateTime.daysPerWeek + 1,
        ],
      );
      final plan = await _planService.buildPlan(
        date: today,
        program: program,
        activeProgram: active,
      );
      if (plan == null) return null;
      final session = await _sessionService.startExtraSession(plan);
      _setDate(today);
      selectTab(WorkoutTab.overview);
      return ActiveWorkoutArgs(
        date: today,
        plan: plan,
        history: _sessions,
        session: session,
      );
    } on WorkoutException catch (error) {
      _onError(error);
      return null;
    } finally {
      _isStartingExtra = false;
    }
  }

  String deleteProgramTitle(ProgramDetailItem detail) =>
      'Delete ${detail.name}?';

  String deleteProgramMessage(ProgramDetailItem detail) => detail.isActive
      ? 'This also stops the program and clears your upcoming sessions. '
            'Workouts you already logged stay in your history.'
      : 'This removes the program. Workouts you already logged stay in your '
            'history.';

  String stopProgramTitle(ProgramDetailItem detail) => 'Stop ${detail.name}?';

  String get stopProgramMessage =>
      'Your upcoming planned sessions will be cleared. Workouts you already '
      'logged stay in your history, and you can start any program again.';

  Future<void> stopProgram() async {
    try {
      await _planService.clearUpcoming(_today, stopProgram: true);
      _plan = null;
      notifyListeners();
    } on WorkoutException catch (error) {
      _onError(error);
    }
  }

  Future<void> deleteProgram(String id) async {
    final program = _programById(id);
    if (program == null || !program.isCustom) return;
    try {
      if (_state.activeProgram?.id == id) await stopProgram();
      await _catalogService.deleteProgram(id);
    } on WorkoutException catch (error) {
      _onError(error);
    }
  }

  void selectTab(WorkoutTab tab) {
    if (tab == _selectedTab) return;
    _tabReverse = tab.index < _selectedTab.index;
    _selectedTab = tab;
    notifyListeners();
    _reloadHistoryIfVisible();
  }

  void previousDay() {
    if (canGoPrevious) _setDate(AppDateUtils.addDays(_selectedDate, -1));
  }

  void nextDay() {
    if (canGoNext) _setDate(AppDateUtils.addDays(_selectedDate, 1));
  }

  void selectDate(DateTime date) => _setDate(AppDateUtils.dateOnly(date));

  void _onNewDay() {
    final previousDay = AppDateUtils.addDays(_today, -1);
    if (AppDateUtils.isSameDay(_selectedDate, previousDay)) {
      _setDate(_today);
    } else {
      notifyListeners();
    }
    _reloadHistoryIfVisible();
  }

  void _setDate(DateTime date) {
    if (AppDateUtils.isSameDay(date, _selectedDate)) return;
    _dateDirection = date.isAfter(_selectedDate)
        ? DateChangeDirection.forward
        : DateChangeDirection.backward;
    _selectedDate = date;
    _plan = null;
    _catchUps = const [];
    _focusedSessionId = null;
    _shiftOffer = null;
    notifyListeners();
    _watchPlan();
    unawaited(_ensurePlan());
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _dayRollover.cancel();
    _answersSubscription?.cancel();
    _sessionSubscription?.cancel();
    _stateSubscription?.cancel();
    _programSubscription?.cancel();
    _planSubscription?.cancel();
    _catchUpSubscription?.cancel();
    _pendingPlanSubscription?.cancel();
    super.dispose();
  }
}

class _DayWorkout {
  const _DayWorkout({
    required this.planDate,
    this.plan,
    this.session,
    this.isCatchUp = false,
  });

  final DateTime planDate;
  final WorkoutPlanEntity? plan;
  final WorkoutSessionEntity? session;
  final bool isCatchUp;

  String get id =>
      plan != null ? AppDateUtils.dateKey(planDate) : session?.id ?? '';
}
