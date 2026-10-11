import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/models/habit_definition.dart';
import 'package:floww/core/habits/models/habit_draft.dart';
import 'package:floww/core/health/services/health_log_service.dart';
import 'package:floww/core/profile/models/profile_edit_data.dart';
import 'package:floww/core/profile/services/profile_service.dart';
import 'package:floww/core/progress/services/progress_service.dart';
import 'package:floww/core/settings/services/settings_service.dart';
import 'package:floww/core/wave/models/wave_action.dart';
import 'package:floww/core/wave/models/wave_action_outcome.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/models/wave_context.dart';
import 'package:floww/core/wave/models/wave_undo.dart';
import 'package:floww/core/wave/services/wave_chat_service.dart';
import 'package:floww/core/workout/models/workout_section_kind.dart';
import 'package:floww/core/workout/models/workout_shift_offer.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_plan_generator_service.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';
import 'package:floww/core/workout/services/workout_program_service.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';
import 'package:floww/core/workout/services/workout_shift_service.dart';

class WaveActionService {
  WaveActionService(
    this._chatService, {
    WorkoutCatalogService? catalogService,
    WorkoutProgramService? programService,
    WorkoutSessionService? sessionService,
    WorkoutPlanGeneratorService? generatorService,
    ProgressService? progressService,
    HealthLogService? healthLogService,
    SettingsService? settingsService,
    ProfileService? profileService,
  }) : _catalogService = catalogService ?? WorkoutCatalogService(),
       _programService = programService ?? WorkoutProgramService(),
       _sessionService = sessionService ?? WorkoutSessionService(),
       _generatorService = generatorService ?? WorkoutPlanGeneratorService(),
       _progressService = progressService ?? ProgressService(),
       _healthLogService = healthLogService ?? HealthLogService(),
       _settingsService = settingsService ?? SettingsService(),
       _profileService = profileService ?? ProfileService() {
    _planService = WorkoutPlanService(_catalogService);
    _shiftService = WorkoutShiftService(_planService);
  }

  static const int maxRescheduleDays = 14;
  static const double _lighterLoad = 0.9;
  static const double _weightStepKg = 2.5;
  static const int _minSets = 1;
  static const int _minutesPerHour = 60;

  static const String _idsKey = 'ids';
  static const String _idKey = 'id';
  static const String _definitionKey = 'definition';
  static const String _daysKey = 'days';
  static const String _activeKey = 'active';
  static const String _planKey = 'plan';
  static const String _sessionKey = 'sessionId';
  static const String _entryKey = 'entryId';
  static const String _loggedAtKey = 'loggedAt';
  static const String _minutesKey = 'minutes';
  static const String _manualKey = 'manual';
  static const String _modeKey = 'mode';
  static const String _enabledKey = 'enabled';
  static const String _stepsKey = 'steps';
  static const String _sleepKey = 'sleep';
  static const String _waterKey = 'water';

  final WaveChatService _chatService;
  final WorkoutCatalogService _catalogService;
  final WorkoutProgramService _programService;
  final WorkoutSessionService _sessionService;
  final WorkoutPlanGeneratorService _generatorService;
  final ProgressService _progressService;
  final HealthLogService _healthLogService;
  final SettingsService _settingsService;
  final ProfileService _profileService;
  late final WorkoutPlanService _planService;
  late final WorkoutShiftService _shiftService;

  DateTime get _today => AppDateUtils.dateOnly(DateTime.now());

  Future<WaveActionOutcome?> run(WaveAction action, WaveContext context) =>
      switch (action.kind) {
        WaveActionKind.none => Future.value(),
        WaveActionKind.completeAllHabits => _completeHabits(null),
        WaveActionKind.completeHabit => _completeHabits(action.target),
        WaveActionKind.uncompleteHabit => _uncompleteHabit(action.target),
        WaveActionKind.addHabit => _addHabit(action.habitDraft),
        WaveActionKind.editHabit => _editHabit(
          action.target,
          action.habitDraft,
        ),
        WaveActionKind.deleteHabit => _deleteHabit(action.target),
        WaveActionKind.logWater => _logWater(action.value),
        WaveActionKind.unlogWater => _unlogWater(context, action.value),
        WaveActionKind.logFood => _logFood(context, action),
        WaveActionKind.unlogFood => _unlogFood(context, action.target),
        WaveActionKind.createFood => _createFood(action),
        WaveActionKind.startWorkout => _startWorkout(context),
        WaveActionKind.completeWorkout => _completeWorkout(),
        WaveActionKind.cancelWorkout => _cancelWorkout(),
        WaveActionKind.logSet => _logSet(action),
        WaveActionKind.swapExercise => _swapExercise(action),
        WaveActionKind.rescheduleWorkout => _reschedule(action.date),
        WaveActionKind.skipToday => _skipToday(),
        WaveActionKind.shiftPlan => _shiftPlan(),
        WaveActionKind.adjustIntensity => _adjustIntensity(action.intensity),
        WaveActionKind.regeneratePlan => _regeneratePlan(),
        WaveActionKind.logWeight => _logWeight(action.value),
        WaveActionKind.logSleep => _logSleep(action.value),
        WaveActionKind.setFlowMode => _setFlowMode(action.mode),
        WaveActionKind.setReminder => _setReminder(action),
        WaveActionKind.updateTargets => _updateTargets(action.targets),
        WaveActionKind.navigate => _navigate(action.destination),
      };

  Future<WaveActionOutcome> logMeal(
    List<WaveQuickFood> foods,
    WaveMealSlot slot,
  ) async {
    final ids = await _chatService.logFoods(foods, slot);
    return WaveActionOutcome(
      'Meal Logged',
      '${ids.length} added to your nutrition for today',
      undo: WaveUndo(WaveUndoKind.deleteFoodLogs, {_idsKey: ids}),
    );
  }

  WaveActionOutcome promptFor(WaveAction action) => switch (action.kind) {
    WaveActionKind.deleteHabit => WaveActionOutcome(
      'Delete ${action.target}?',
      'The habit leaves your list. Its history stays.',
    ),
    WaveActionKind.cancelWorkout => const WaveActionOutcome(
      'Discard this workout?',
      'Every set logged in today\'s session will be lost.',
    ),
    WaveActionKind.shiftPlan => const WaveActionOutcome(
      'Shift your plan by a day?',
      'Today\'s session moves to tomorrow and every later session slides '
          'back one day.',
    ),
    WaveActionKind.regeneratePlan => const WaveActionOutcome(
      'Build a new plan?',
      'WAVE builds a fresh program from your onboarding answers and '
          'replaces your upcoming sessions. Logged workouts stay.',
    ),
    _ => const WaveActionOutcome('Confirm this change?', ''),
  };

  WaveActionOutcome dismissed(WaveAction action) =>
      const WaveActionOutcome('Left As Is', 'Nothing was changed');

  Future<WaveActionOutcome> _completeHabits(String? title) async {
    final ids = await _chatService.completeHabits(title: title);
    if (ids.isEmpty) {
      return WaveActionOutcome(
        'Nothing To Tick',
        title == null || title.isEmpty
            ? 'Today\'s habits were already complete'
            : '$title was already complete',
      );
    }
    return WaveActionOutcome(
      'Habits Updated',
      ids.length == 1
          ? '1 habit marked complete for today'
          : '${ids.length} habits marked complete for today',
      undo: WaveUndo(WaveUndoKind.reopenHabits, {_idsKey: ids}),
    );
  }

  Future<WaveActionOutcome> _uncompleteHabit(String title) async {
    final ids = await _chatService.uncompleteHabits(title: title);
    if (ids.isEmpty) {
      return WaveActionOutcome('Nothing To Untick', 'I could not find $title');
    }
    return WaveActionOutcome(
      'Habit Unticked',
      '$title is back to not done',
      undo: WaveUndo(WaveUndoKind.completeHabits, {_idsKey: ids}),
    );
  }

  Future<WaveActionOutcome?> _addHabit(HabitDraft? draft) async {
    if (draft == null) return null;
    final id = await _chatService.addHabit(draft);
    return WaveActionOutcome(
      'Habit Added',
      '${draft.title} · ${_targetLabel(draft)} per day',
      undo: WaveUndo(WaveUndoKind.deleteHabit, {_idKey: id}),
    );
  }

  Future<WaveActionOutcome?> _editHabit(String title, HabitDraft? draft) async {
    if (draft == null) return null;
    final previous = await _chatService.editHabit(title, draft);
    if (previous == null) {
      return WaveActionOutcome('Habit Not Found', 'I could not find $title');
    }
    return WaveActionOutcome(
      'Habit Updated',
      '${draft.title} · ${_targetLabel(draft)} per day',
      undo: WaveUndo(WaveUndoKind.restoreHabitEdit, {
        _definitionKey: previous.toJson(),
      }),
    );
  }

  Future<WaveActionOutcome> _deleteHabit(String title) async {
    final deleted = await _chatService.deleteHabit(title);
    if (deleted == null) {
      return WaveActionOutcome('Habit Not Found', 'I could not find $title');
    }
    return WaveActionOutcome(
      'Habit Deleted',
      '${deleted.title} removed',
      undo: WaveUndo(WaveUndoKind.restoreHabit, {
        _definitionKey: deleted.toJson(),
      }),
    );
  }

  Future<WaveActionOutcome?> _logWater(double amountMl) async {
    if (amountMl <= 0) return null;
    final id = await _chatService.logWater(amountMl);
    return WaveActionOutcome(
      'Water Logged',
      '${amountMl.round()}ml added to today',
      tone: WaveConfirmationTone.water,
      undo: WaveUndo(WaveUndoKind.deleteWaterLogs, {
        _idsKey: [id],
      }),
    );
  }

  Future<WaveActionOutcome> _unlogWater(
    WaveContext context,
    double amountMl,
  ) async {
    final removed = await _chatService.unlogWater(context, amountMl);
    return WaveActionOutcome(
      removed > 0 ? 'Water Removed' : 'Nothing To Remove',
      removed > 0
          ? '${removed.round()}ml taken off today'
          : 'No water logged today',
      tone: WaveConfirmationTone.water,
    );
  }

  Future<WaveActionOutcome> _logFood(
    WaveContext context,
    WaveAction action,
  ) async {
    final food = await _chatService.findFood(context, action.target);
    if (food == null) {
      return WaveActionOutcome(
        'Food Not Found',
        '${action.target} is not in your foods yet',
      );
    }

    final meal = action.meal;
    final slot = meal == null
        ? _chatService.currentMealSlot()
        : WaveChatService.slotOf(meal);
    final servings = action.servings < 1 ? 1 : action.servings;
    final ids = await _chatService.logFood(food, slot, servings: servings);

    return WaveActionOutcome(
      'Food Logged',
      '${ids.length} × ${food.name} added to ${slot.label.toLowerCase()}',
      undo: WaveUndo(WaveUndoKind.deleteFoodLogs, {_idsKey: ids}),
    );
  }

  Future<WaveActionOutcome> _unlogFood(WaveContext context, String name) async {
    final removed = await _chatService.unlogFood(context, name);
    return WaveActionOutcome(
      removed != null ? 'Food Removed' : 'Nothing To Remove',
      removed != null
          ? '$removed taken off today'
          : 'I could not find $name in today\'s log',
    );
  }

  Future<WaveActionOutcome?> _createFood(WaveAction action) async {
    final draft = action.foodDraft;
    if (draft == null) return null;
    final food = await _chatService.createFood(draft);
    return WaveActionOutcome(
      'Food Created',
      '${food.name} · ${food.calories.round()} kcal per '
          '${food.serving.isEmpty ? "serving" : food.serving}',
      undo: WaveUndo(WaveUndoKind.deleteCustomFood, {_idKey: food.id}),
    );
  }

  Future<WaveActionOutcome> _startWorkout(WaveContext context) async {
    final title = await _chatService.startWorkout(context);
    return WaveActionOutcome(
      title != null ? 'Workout Started' : 'No Session Planned',
      title ?? 'There is nothing scheduled for today',
      link: title != null ? WaveConfirmationAction.openWorkout : null,
    );
  }

  Future<WaveActionOutcome> _completeWorkout() async {
    final title = await _chatService.completeWorkout();
    return WaveActionOutcome(
      title != null ? 'Workout Completed' : 'Nothing In Progress',
      title ?? 'Start a session first, then I can finish it',
    );
  }

  Future<WaveActionOutcome> _cancelWorkout() async {
    final title = await _chatService.cancelWorkout();
    return WaveActionOutcome(
      title != null ? 'Workout Cancelled' : 'Nothing In Progress',
      title != null
          ? '$title discarded · start it again anytime today'
          : 'There is no started workout to cancel',
    );
  }

  Future<WaveActionOutcome> _logSet(WaveAction action) async {
    final session = await _sessionService.loadInProgressSession(_today);
    if (session == null) {
      return const WaveActionOutcome(
        'Nothing In Progress',
        'Start today\'s workout first, then I can log your sets',
      );
    }

    final entry = _entryFor(
      session.exercises,
      action.target,
      session.currentEntryId,
    );
    if (entry == null) {
      return WaveActionOutcome(
        'Exercise Not Found',
        '${action.target} is not in this session',
      );
    }

    final amount = action.value.round();
    final set = LoggedSetEntry(
      reps: entry.isTimed ? 0 : amount,
      durationSeconds: entry.isTimed ? amount : null,
      weightKg: action.weightKg > 0 ? action.weightKg : null,
      loggedAt: DateTime.now(),
    );
    final updated = entry.copyWith(sets: [...entry.sets, set]);
    await _sessionService.saveProgress(
      session.copyWith(
        exercises: [
          for (final item in session.exercises)
            item.id == entry.id ? updated : item,
        ],
      ),
    );

    return WaveActionOutcome(
      'Set Logged',
      '${entry.name} · ${_setLabel(set, entry.isTimed)} · set '
          '${updated.workingSetCount}/${entry.targetSets}',
      undo: WaveUndo(WaveUndoKind.removeSet, {
        _sessionKey: session.id,
        _entryKey: entry.id,
        _loggedAtKey: AppDateUtils.isoKey(set.loggedAt),
      }),
    );
  }

  Future<WaveActionOutcome> _swapExercise(WaveAction action) async {
    final plan = await _todayPlan();
    final blocked = _blockedOutcome(plan);
    if (blocked != null || plan == null) return blocked!;

    final entry = _entryFor(plan.exercises, action.target, null);
    if (entry == null || action.target.isEmpty) {
      return WaveActionOutcome(
        'Exercise Not Found',
        '${action.target} is not in today\'s plan',
      );
    }

    final catalog = await _catalogService.loadExercises();
    final alternatives = WorkoutPlanService.alternativesOf(entry, catalog);
    final replacement =
        _exerciseNamed(alternatives, action.replacement) ??
        _exerciseNamed(catalog, action.replacement) ??
        alternatives.firstOrNull;
    if (replacement == null) {
      return WaveActionOutcome(
        'No Alternative Found',
        'Open today\'s workout to swap ${entry.name} by hand',
      );
    }

    final days = await _planService.planDaysOf([plan.date]);
    final history = await _sessionService.loadRecentSessions();
    final swapped = _planService.swapEntry(
      entry,
      replacement,
      history: history,
    );
    await _planService.savePlan(
      plan.copyWithExercises([
        for (final item in plan.exercises) item.id == entry.id ? swapped : item,
      ]),
    );

    return WaveActionOutcome(
      'Exercise Swapped',
      '${entry.name} → ${replacement.name}',
      undo: WaveUndo(WaveUndoKind.restorePlanDays, {_daysKey: days}),
    );
  }

  Future<WaveActionOutcome> _adjustIntensity(WaveIntensity intensity) async {
    final plan = await _todayPlan();
    final blocked = _blockedOutcome(plan);
    if (blocked != null || plan == null) return blocked!;

    final lighter = intensity == WaveIntensity.lighter;
    final days = await _planService.planDaysOf([plan.date]);
    var changed = 0;
    final exercises = [
      for (final entry in plan.exercises)
        if (entry.section == WorkoutSectionKind.main)
          () {
            changed++;
            return lighter ? _lighter(entry) : _harder(entry);
          }()
        else
          entry,
    ];
    if (changed == 0) {
      return const WaveActionOutcome(
        'Nothing To Adjust',
        'Today\'s session has no main lifts',
      );
    }

    await _planService.savePlan(
      plan.copyWith(
        exercises: exercises,
        insight:
            '${plan.insight}\n\n'
            '${lighter ? 'WAVE lightened today on request: one set fewer and about 10% less weight on each main lift.' : 'WAVE added one set to each main lift on request.'}',
      ),
    );

    return WaveActionOutcome(
      lighter ? 'Session Lightened' : 'Session Pushed',
      lighter
          ? 'One set fewer and ~10% less weight on $changed main lifts'
          : 'One extra set on $changed main lifts',
      undo: WaveUndo(WaveUndoKind.restorePlanDays, {_daysKey: days}),
    );
  }

  Future<WaveActionOutcome> _skipToday() async {
    final plan = await _todayPlan();
    if (plan == null) {
      return const WaveActionOutcome(
        'Already A Rest Day',
        'There is no session planned for today',
      );
    }
    final blocked = _blockedOutcome(plan);
    if (blocked != null) return blocked;

    final days = await _planService.planDaysOf([plan.date]);
    await _planService.skipDay(plan.date);
    return WaveActionOutcome(
      'Rest Day Set',
      '${plan.name} skipped · the rest of your plan stays put',
      undo: WaveUndo(WaveUndoKind.restorePlanDays, {_daysKey: days}),
    );
  }

  Future<WaveActionOutcome> _reschedule(DateTime? date) async {
    final today = _today;
    if (date == null ||
        !date.isAfter(today) ||
        date.isAfter(AppDateUtils.addDays(today, maxRescheduleDays))) {
      return const WaveActionOutcome(
        'Pick Another Day',
        'I can move today\'s session to any day in the next two weeks',
      );
    }

    final days = await _planService.planDaysOf([today, date]);
    final active = (await _programService.loadState()).activeProgram;
    final plan = await _planService.ensurePlanFor(today, activeProgram: active);
    final blocked = _blockedOutcome(plan);
    if (blocked != null || plan == null) return blocked!;

    final other = await _planService.ensurePlanFor(date, activeProgram: active);
    await _planService.movePlan(plan, date, swapWith: other);

    final when = AppDateUtils.relativeDay(date);
    return WaveActionOutcome(
      'Workout Moved',
      other == null
          ? '${plan.name} moved to $when'
          : '${plan.name} moved to $when · ${other.name} moved to today',
      undo: WaveUndo(WaveUndoKind.restorePlanDays, {_daysKey: days}),
    );
  }

  Future<WaveActionOutcome> _shiftPlan() async {
    final active = (await _programService.loadState()).activeProgram;
    if (active == null) {
      return const WaveActionOutcome(
        'No Active Program',
        'Shifting needs a program. Ask me to skip today instead',
      );
    }
    final plan = await _planService.ensurePlanFor(
      _today,
      activeProgram: active,
    );
    final blocked = _blockedOutcome(plan);
    if (blocked != null || plan == null) return blocked!;

    await _shiftService.apply(
      WorkoutShiftOffer(kind: WorkoutShiftKind.postpone, plan: plan),
      active,
    );
    return WaveActionOutcome(
      'Plan Shifted',
      '${plan.name} moved to tomorrow · later sessions slid back a day',
      undo: WaveUndo(WaveUndoKind.unshiftPlan, {
        _activeKey: active.toJson(),
        _planKey: plan.toJson(),
      }),
    );
  }

  Future<WaveActionOutcome> _regeneratePlan() async {
    final previous = (await _programService.loadState()).activeProgram;
    final program = await _generatorService.generate();
    final active = _programService.activeEntryFor(program, startDate: _today);
    await _planService.scheduleProgram(
      program,
      active,
      from: _today,
      saveActive: true,
    );
    return WaveActionOutcome(
      'New Plan Ready',
      '${program.name} starts today',
      undo: WaveUndo(WaveUndoKind.restoreProgram, {
        _activeKey: previous?.toJson(),
      }),
    );
  }

  Future<WaveActionOutcome?> _logWeight(double weightKg) async {
    if (weightKg <= 0) return null;
    final id = await _progressService.addWeightLog(weightKg, DateTime.now());
    return WaveActionOutcome(
      'Weight Logged',
      '${_decimal(weightKg)} kg recorded for today',
      undo: WaveUndo(WaveUndoKind.deleteWeightLog, {_idKey: id}),
    );
  }

  Future<WaveActionOutcome?> _logSleep(double hours) async {
    if (hours <= 0) return null;
    final today = _today;
    final previous = await _healthLogService.loadSleep(today);
    final minutes = (hours * _minutesPerHour).round();
    await _healthLogService.saveSleep(
      today,
      HealthSleepRecord(minutes: minutes, manualMinutes: minutes),
    );
    return WaveActionOutcome(
      'Sleep Logged',
      '${_sleepLabel(minutes)} for last night',
      undo: WaveUndo(WaveUndoKind.restoreSleep, {
        _minutesKey: previous.minutes,
        _manualKey: previous.manualMinutes,
      }),
    );
  }

  Future<WaveActionOutcome?> _setFlowMode(WaveFlowModeChoice choice) async {
    final mode = switch (choice) {
      WaveFlowModeChoice.flow => AppThemeMode.flow,
      WaveFlowModeChoice.steady => AppThemeMode.steady,
      WaveFlowModeChoice.restore => AppThemeMode.restore,
      WaveFlowModeChoice.auto || WaveFlowModeChoice.none => null,
    };
    if (choice == WaveFlowModeChoice.none) return null;

    final today = _today;
    final previous = await _settingsService.loadFlowModeOverride(today);
    await _settingsService.setFlowModeOverride(today, mode);
    return WaveActionOutcome(
      mode == null ? 'Mode On Auto' : 'Mode Set',
      mode == null
          ? 'Your Flow Score picks today\'s mode again'
          : '${mode.name.toUpperCase()} for the rest of today',
      undo: WaveUndo(WaveUndoKind.restoreFlowMode, {_modeKey: previous?.name}),
    );
  }

  Future<WaveActionOutcome> _setReminder(WaveAction action) async {
    final id = action.reminder;
    if (!_settingsService.isNotificationId(id)) {
      return const WaveActionOutcome(
        'Reminder Not Found',
        'Open Notifications in Settings to manage reminders',
      );
    }
    final previous = await _settingsService.notificationEnabled(id);
    await _saveReminder(id, action.enabled);
    final title = _settingsService.notificationTitleOf(id);
    return WaveActionOutcome(
      action.enabled ? 'Reminder On' : 'Reminder Off',
      '$title turned ${action.enabled ? 'on' : 'off'}',
      undo: WaveUndo(WaveUndoKind.restoreReminder, {
        _idKey: id,
        _enabledKey: previous,
      }),
    );
  }

  Future<WaveActionOutcome?> _updateTargets(WaveTargetsDraft targets) async {
    final account = await _profileService.loadAccount();
    final specs = ProfileService.dailyTargetSpecsOf(account);
    final previous = DailyTargetsDraft(specs: specs);

    double next(DailyTarget target, double requested) {
      final spec = specs.firstWhere((spec) => spec.target == target);
      if (requested <= 0) return spec.value;
      final snapped =
          ((requested - spec.min) / spec.step).round() * spec.step + spec.min;
      return ProfileService.clampTarget(snapped, spec.min, spec.max);
    }

    final updated = [
      for (final spec in specs)
        spec.copyWith(
          value: next(spec.target, switch (spec.target) {
            DailyTarget.steps => targets.steps,
            DailyTarget.sleep => targets.sleepHours,
            DailyTarget.water => targets.waterLiters,
          }),
        ),
    ];
    await _profileService.saveDailyTargets(DailyTargetsDraft(specs: updated));

    final changes = [
      for (var index = 0; index < specs.length; index++)
        if (specs[index].value != updated[index].value)
          '${updated[index].title} ${_decimal(updated[index].value)} '
              '${updated[index].unit}',
    ];
    return WaveActionOutcome(
      changes.isEmpty ? 'Targets Unchanged' : 'Targets Updated',
      changes.isEmpty ? 'Those targets were already set' : changes.join(' · '),
      undo: changes.isEmpty
          ? null
          : WaveUndo(WaveUndoKind.restoreTargets, {
              _stepsKey: previous.valueOf(DailyTarget.steps),
              _sleepKey: previous.valueOf(DailyTarget.sleep),
              _waterKey: previous.valueOf(DailyTarget.water),
            }),
    );
  }

  Future<WaveActionOutcome?> _navigate(WaveDestination destination) async {
    if (destination == WaveDestination.none) return null;
    return WaveActionOutcome(
      'Opening ${destinationLabelOf(destination)}',
      'Tap Open to go back there anytime',
      destination: destination,
    );
  }

  Future<WaveActionOutcome> undo(WaveUndo undo) async {
    switch (undo.kind) {
      case WaveUndoKind.deleteWaterLogs:
        await _chatService.deleteWaterLogs(undo.stringsOf(_idsKey));
      case WaveUndoKind.deleteFoodLogs:
        await _chatService.deleteFoodLogs(undo.stringsOf(_idsKey));
      case WaveUndoKind.deleteCustomFood:
        await _chatService.deleteCustomFood(undo.stringOf(_idKey) ?? '');
      case WaveUndoKind.reopenHabits:
        await _chatService.setHabitsCompleted(
          undo.stringsOf(_idsKey),
          completed: false,
        );
      case WaveUndoKind.completeHabits:
        await _chatService.setHabitsCompleted(
          undo.stringsOf(_idsKey),
          completed: true,
        );
      case WaveUndoKind.deleteHabit:
        await _chatService.deleteHabitById(undo.stringOf(_idKey) ?? '');
      case WaveUndoKind.restoreHabit || WaveUndoKind.restoreHabitEdit:
        final definition = undo.mapOf(_definitionKey);
        if (definition != null) {
          await _chatService.restoreHabit(HabitDefinition.fromJson(definition));
        }
      case WaveUndoKind.deleteWeightLog:
        await _progressService.deleteWeightLog(undo.stringOf(_idKey) ?? '');
      case WaveUndoKind.restoreSleep:
        await _healthLogService.saveSleep(
          _today,
          HealthSleepRecord(
            minutes: (undo.numberOf(_minutesKey) ?? 0).round(),
            manualMinutes: undo.numberOf(_manualKey)?.round(),
          ),
        );
      case WaveUndoKind.restorePlanDays:
        await _planService.restorePlanDays(_planDaysOf(undo.mapOf(_daysKey)));
      case WaveUndoKind.restoreProgram:
        await _restoreProgram(undo.mapOf(_activeKey));
      case WaveUndoKind.unshiftPlan:
        final active = undo.mapOf(_activeKey);
        final plan = undo.mapOf(_planKey);
        if (active != null && plan != null) {
          await _planService.restoreToToday(
            today: _today,
            restored: ActiveProgramEntry.fromJson(active),
            postponed: WorkoutPlanEntity.fromJson(plan),
          );
        }
      case WaveUndoKind.removeSet:
        await _removeSet(undo);
      case WaveUndoKind.restoreFlowMode:
        await _settingsService.setFlowModeOverride(
          _today,
          AppThemeMode.values.asNameMap()[undo.stringOf(_modeKey)],
        );
      case WaveUndoKind.restoreReminder:
        await _saveReminder(
          undo.stringOf(_idKey) ?? '',
          undo.data[_enabledKey] == true,
        );
      case WaveUndoKind.restoreTargets:
        await _restoreTargets(undo);
    }
    return const WaveActionOutcome('Undone', 'That change was reversed');
  }

  static String destinationLabelOf(WaveDestination destination) =>
      switch (destination) {
        WaveDestination.none || WaveDestination.home => 'Home',
        WaveDestination.nutrition => 'Nutrition',
        WaveDestination.workout => 'Workouts',
        WaveDestination.habits => 'Habits',
        WaveDestination.progress => 'Progress',
        WaveDestination.todaysWorkout => 'Today\'s Workout',
        WaveDestination.activeWorkout => 'Active Workout',
        WaveDestination.dietPlan => 'Diet Plan',
        WaveDestination.weeklyNutritionReport => 'Weekly Nutrition Report',
        WaveDestination.habitCalendar => 'Habit Calendar',
        WaveDestination.foodScan => 'Food Scan',
        WaveDestination.muscleRecovery => 'Muscle Recovery',
        WaveDestination.achievements => 'Achievements',
        WaveDestination.profile => 'Profile',
        WaveDestination.editPersonalInfo => 'Personal Info',
        WaveDestination.editDailyTargets => 'Daily Targets',
        WaveDestination.connectedApps => 'Connected Apps',
        WaveDestination.notificationSettings => 'Notifications',
        WaveDestination.units => 'Units',
        WaveDestination.privacyData => 'Privacy & Data',
        WaveDestination.waveMemory => 'WAVE Memory',
        WaveDestination.premium => 'Premium',
      };

  Future<WorkoutPlanEntity?> _todayPlan() async {
    final active = (await _programService.loadState()).activeProgram;
    return _planService.ensurePlanFor(_today, activeProgram: active);
  }

  WaveActionOutcome? _blockedOutcome(WorkoutPlanEntity? plan) {
    if (plan == null) {
      return const WaveActionOutcome(
        'No Session Planned',
        'There is no workout scheduled for today',
      );
    }
    if (plan.sessionId != null) {
      return const WaveActionOutcome(
        'Session Already Started',
        'Plan changes only work before today\'s workout starts',
      );
    }
    return null;
  }

  Future<void> _saveReminder(String id, bool enabled) async {
    final saved = await _settingsService.setNotificationEnabled(id, enabled);
    if (!saved) throw StateError('Could not save the reminder.');
  }

  Future<void> _restoreProgram(Map<String, dynamic>? json) async {
    if (json == null) {
      await _planService.clearUpcoming(_today, stopProgram: true);
      return;
    }
    final active = ActiveProgramEntry.fromJson(json);
    final program = await _catalogService.programById(active.id);
    if (program == null) throw StateError('Previous program is gone.');
    await _planService.scheduleProgram(
      program,
      active,
      from: _today,
      saveActive: true,
    );
  }

  Future<void> _removeSet(WaveUndo undo) async {
    final session = await _sessionService.loadSession(
      undo.stringOf(_sessionKey) ?? '',
    );
    final entryId = undo.stringOf(_entryKey);
    final loggedAt = undo.stringOf(_loggedAtKey);
    if (session == null || entryId == null || loggedAt == null) return;
    await _sessionService.saveProgress(
      session.copyWith(
        exercises: [
          for (final entry in session.exercises)
            entry.id == entryId
                ? entry.copyWith(
                    sets: [
                      for (final set in entry.sets)
                        if (AppDateUtils.isoKey(set.loggedAt) != loggedAt) set,
                    ],
                  )
                : entry,
        ],
      ),
    );
  }

  Future<void> _restoreTargets(WaveUndo undo) async {
    final account = await _profileService.loadAccount();
    final specs = ProfileService.dailyTargetSpecsOf(account);
    await _profileService.saveDailyTargets(
      DailyTargetsDraft(
        specs: [
          for (final spec in specs)
            spec.copyWith(
              value:
                  undo.numberOf(switch (spec.target) {
                    DailyTarget.steps => _stepsKey,
                    DailyTarget.sleep => _sleepKey,
                    DailyTarget.water => _waterKey,
                  }) ??
                  spec.value,
            ),
        ],
      ),
    );
  }

  static Map<String, Map<String, dynamic>?> _planDaysOf(
    Map<String, dynamic>? days,
  ) => {
    for (final day in (days ?? const <String, dynamic>{}).entries)
      day.key: day.value is Map
          ? Map<String, dynamic>.from(day.value as Map)
          : null,
  };

  static WorkoutEntryEntity? _entryFor(
    List<WorkoutEntryEntity> entries,
    String name,
    String? currentId,
  ) {
    final wanted = name.trim().toLowerCase();
    if (wanted.isNotEmpty) {
      return entries
          .where(
            (entry) =>
                entry.name.toLowerCase().contains(wanted) ||
                wanted.contains(entry.name.toLowerCase()),
          )
          .firstOrNull;
    }
    return entries.where((entry) => entry.id == currentId).firstOrNull ??
        entries.where((entry) => !entry.isDone).firstOrNull ??
        entries.lastOrNull;
  }

  static ExerciseCatalogEntry? _exerciseNamed(
    List<ExerciseCatalogEntry> exercises,
    String name,
  ) {
    final wanted = name.trim().toLowerCase();
    if (wanted.isEmpty) return null;
    return exercises
            .where((exercise) => exercise.name.toLowerCase() == wanted)
            .firstOrNull ??
        exercises
            .where(
              (exercise) =>
                  exercise.name.toLowerCase().contains(wanted) ||
                  wanted.contains(exercise.name.toLowerCase()),
            )
            .firstOrNull;
  }

  static WorkoutEntryEntity _lighter(WorkoutEntryEntity entry) {
    final weight = entry.targetWeightKg;
    return entry.copyWith(
      targetSets: entry.targetSets > _minSets
          ? entry.targetSets - 1
          : entry.targetSets,
      targetWeightKg: weight == null
          ? null
          : ((weight * _lighterLoad) / _weightStepKg).round() * _weightStepKg,
    );
  }

  static WorkoutEntryEntity _harder(WorkoutEntryEntity entry) =>
      entry.copyWith(targetSets: entry.targetSets + 1);

  static String _setLabel(LoggedSetEntry set, bool isTimed) {
    final effort = isTimed
        ? '${set.durationSeconds ?? 0}s'
        : '${set.reps} reps';
    final weight = set.weightKg;
    return weight == null ? effort : '$effort × ${_decimal(weight)}kg';
  }

  static String _targetLabel(HabitDraft draft) =>
      '${_decimal(draft.target)} ${draft.metric.name}';

  static String _sleepLabel(int minutes) {
    final hours = minutes ~/ _minutesPerHour;
    final rest = minutes % _minutesPerHour;
    return rest == 0 ? '${hours}h' : '${hours}h ${rest}m';
  }

  static String _decimal(double value) => value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);
}
