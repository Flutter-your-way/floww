import 'dart:async';

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/models/habit_draft.dart';
import 'package:floww/core/nutrition/models/diet_plan.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/models/wave_chat_day.dart';
import 'package:floww/core/wave/models/wave_context.dart';
import 'package:floww/core/wave/models/wave_message.dart';
import 'package:floww/core/wave/models/wave_quick_action.dart';
import 'package:floww/core/wave/models/wave_reply.dart';
import 'package:floww/core/wave/models/wave_transcript_entry.dart';
import 'package:floww/core/wave/services/wave_ai_service.dart';
import 'package:floww/core/wave/services/wave_chat_service.dart';
import 'package:floww/core/wave/services/wave_context_service.dart';
import 'package:floww/core/wave/services/wave_transcript_service.dart';

class WaveChatViewModel extends ChangeNotifier {
  WaveChatViewModel(
    this._service,
    this._contextService,
    this._transcriptService, {
    WaveAiService? aiService,
  }) : _aiService = aiService ?? WaveAiService(),
       _welcomeTimestamp = DateTime.now(),
       _selectedDay = AppDateUtils.dateOnly(DateTime.now()) {
    composer.addListener(_onComposerChanged);
    _watchContext();
    _watchTranscript();
    _watchDays();
    _transcriptService.backfillDays();
  }

  static const String title = 'WAVE';
  static const String composerHint = 'Ask WAVE anything...';
  static const String connectedStatus = 'Active · All systems connected';
  static const String connectingStatus = 'Syncing your data...';
  static const String welcomeId = 'wave_welcome';

  final WaveChatService _service;
  final WaveContextService _contextService;
  final WaveTranscriptService _transcriptService;
  final WaveAiService _aiService;

  final TextEditingController composer = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final DateTime _welcomeTimestamp;

  final List<WaveTranscriptEntry> _entries = [];
  final Map<String, WaveMealSlot> _mealSlots = {};
  final Map<String, Set<String>> _selectedFoods = {};

  final List<WaveChatDay> _days = [];

  StreamSubscription<WaveContext>? _contextSubscription;
  StreamSubscription<List<WaveTranscriptEntry>>? _transcriptSubscription;
  StreamSubscription<List<WaveChatDay>>? _daysSubscription;
  WaveContext _context = WaveContext.empty;
  DateTime _selectedDay;
  bool _canSend = false;
  bool _isBusy = false;
  bool _disposed = false;

  WaveContext get context => _context;

  bool get isReady => _context.isReady;

  bool get isBusy => _isBusy;

  List<WaveQuickAction> get quickActions => WaveQuickAction.values;

  bool get canSend => _canSend && !_isBusy && isViewingToday;

  bool get showQuickActions => !_canSend && isViewingToday;

  List<WaveChatDay> get days => List.unmodifiable(_days);

  DateTime get selectedDay => _selectedDay;

  bool get isViewingToday =>
      AppDateUtils.isSameDay(_selectedDay, DateTime.now());

  String get dayLabel => AppDateUtils.relativeDay(_selectedDay);

  static const String openWorkoutLabel = 'Open Workout';

  String? confirmationActionLabel(WaveConfirmationMessage message) =>
      switch (message.action) {
        WaveConfirmationAction.openWorkout =>
          isViewingToday && _context.hasActiveWorkout ? openWorkoutLabel : null,
        null => null,
      };

  String get statusLabel => isViewingToday
      ? (isReady ? connectedStatus : connectingStatus)
      : dayLabel;

  List<WaveMessage> get messages => [
    if (isViewingToday)
      WaveDailyBriefMessage(
        id: welcomeId,
        timestamp: _welcomeTimestamp,
        brief: _service.briefOf(_context),
      ),
    for (final entry in _entries) ?_messageOf(entry),
  ];

  String timeLabel(WaveMessage message) =>
      AppDateUtils.time(message.timestamp, padHour: true);

  bool isResolved(String messageId) => _entryOf(messageId)?.isResolved ?? false;

  WaveFeeling? feelingFor(String messageId) {
    final feeling = _entryOf(messageId)?.feeling;
    if (feeling == null) return null;
    return WaveFeeling.values.asNameMap()[feeling];
  }

  WaveMealSlot mealSlotFor(String messageId) =>
      _mealSlots[messageId] ?? _service.currentMealSlot();

  bool isFoodSelected(String messageId, WaveQuickFood food) =>
      _selectedFoods[messageId]?.contains(food.name) ?? false;

  WaveMealTotals mealTotals(WaveMealLogMessage message) {
    final selected = _selectedFoods[message.id];
    if (selected == null || selected.isEmpty) return WaveMealTotals.empty;

    var calories = 0;
    var protein = 0;
    var carbs = 0;
    var fat = 0;
    for (final food in message.foods) {
      if (!selected.contains(food.name)) continue;
      calories += food.calories;
      protein += food.protein;
      carbs += food.carbs;
      fat += food.fat;
    }

    return WaveMealTotals(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      itemCount: selected.length,
    );
  }

  Future<void> sendQuickAction(WaveQuickAction action) async {
    await _append(_entry(WaveMessageKind.user, text: action.label));
    await _respondTo(action);
  }

  Future<void> submitComposer() async {
    final text = composer.text.trim();
    if (text.isEmpty) return;
    composer.clear();
    final history = List<WaveTranscriptEntry>.of(_entries);
    await _append(_entry(WaveMessageKind.user, text: text));
    await _respondToText(text, history);
  }

  Future<void> startDay() => _respondTo(WaveQuickAction.todayPlan);

  Future<void> logWater() async {
    if (_isBusy) return;
    _setBusy(true);
    try {
      await _service.logWater(WaveChatService.waterQuickAmountMl);
      await _append(
        _entry(
          WaveMessageKind.confirmation,
          title: 'Water Logged',
          detail:
              '${WaveChatService.waterQuickAmountMl.round()}ml added to today',
        ),
      );
    } catch (e) {
      debugPrint('wave log water failed: $e');
      await _append(
        _entry(
          WaveMessageKind.reply,
          text: 'I could not log that water. Please try again.',
        ),
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<void> selectFeeling(String messageId, WaveFeeling feeling) async {
    final entry = _entryOf(messageId);
    if (entry == null) return;
    await _update(entry.copyWith(feeling: feeling.name, isResolved: true));
    await _append(_entry(WaveMessageKind.reply, text: feeling.response));
  }

  void selectMealSlot(String messageId, WaveMealSlot slot) {
    _mealSlots[messageId] = slot;
    notifyListeners();
  }

  void toggleFood(String messageId, WaveQuickFood food) {
    final selected = _selectedFoods.putIfAbsent(messageId, () => <String>{});
    if (!selected.remove(food.name)) selected.add(food.name);
    notifyListeners();
  }

  Future<void> logMeal(WaveMealLogMessage message) async {
    if (_isBusy) return;
    final selected = _selectedFoods[message.id] ?? const <String>{};
    final foods = [
      for (final food in message.foods)
        if (selected.contains(food.name)) food,
    ];
    if (foods.isEmpty) return;

    _setBusy(true);
    try {
      final count = await _service.logFoods(foods, mealSlotFor(message.id));
      _selectedFoods.remove(message.id);
      final entry = _entryOf(message.id);
      if (entry != null) await _update(entry.copyWith(isResolved: true));
      await _append(
        _entry(
          WaveMessageKind.confirmation,
          title: 'Meal Logged',
          detail: '$count added to your nutrition for today',
        ),
      );
    } catch (e) {
      debugPrint('wave log meal failed: $e');
      await _append(
        _entry(
          WaveMessageKind.reply,
          text: 'I could not save that meal. Please try again.',
        ),
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<void> applySwap(WaveInjurySwapMessage message) async {
    if (isResolved(message.id) || _isBusy) return;
    _setBusy(true);
    try {
      final applied = await _service.applySwap(_context, message.swap);
      final entry = _entryOf(message.id);
      if (entry != null) await _update(entry.copyWith(isResolved: true));
      await _append(
        _entry(
          WaveMessageKind.confirmation,
          title: applied ? 'Workout Updated' : 'Could Not Update',
          detail: applied
              ? '${message.swap.removing} → ${message.swap.adding} applied'
              : 'Your plan changed. Open the workout to swap it manually.',
        ),
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<void> keepOriginal(WaveInjurySwapMessage message) async {
    if (isResolved(message.id)) return;
    final entry = _entryOf(message.id);
    if (entry != null) await _update(entry.copyWith(isResolved: true));
    await _append(
      _entry(
        WaveMessageKind.confirmation,
        title: 'Workout Unchanged',
        detail: '${message.swap.removing} kept in your session',
      ),
    );
  }

  void selectDay(WaveChatDay day) {
    if (AppDateUtils.isSameDay(day.date, _selectedDay)) return;
    _selectedDay = day.date;
    _entries.clear();
    _selectedFoods.clear();
    _mealSlots.clear();
    notifyListeners();
    _watchTranscript();
  }

  void goToToday() {
    final today = AppDateUtils.dateOnly(DateTime.now());
    if (AppDateUtils.isSameDay(today, _selectedDay)) return;
    _selectedDay = today;
    _entries.clear();
    _selectedFoods.clear();
    _mealSlots.clear();
    notifyListeners();
    _watchTranscript();
  }

  Future<void> _respondTo(WaveQuickAction action) async {
    switch (action) {
      case WaveQuickAction.todayPlan:
        await _append(_entry(WaveMessageKind.plan));
      case WaveQuickAction.shoulderPain:
        await _respondToPain(MuscleGroup.shoulders);
      case WaveQuickAction.finishedWorkout:
        await _append(_entry(WaveMessageKind.checkIn));
      case WaveQuickAction.logMeal:
        await _append(_entry(WaveMessageKind.mealLog));
      case WaveQuickAction.scoreBreakdown:
        await _append(_entry(WaveMessageKind.scoreReport));
    }
  }

  Future<void> _respondToText(
    String text,
    List<WaveTranscriptEntry> history,
  ) async {
    WaveReply? reply;
    var failure = _fallbackReply;

    _setBusy(true);
    try {
      reply = await _aiService.ask(
        message: text,
        context: _context,
        history: history,
      );
    } on WaveChatException catch (e) {
      debugPrint('wave ai failed: ${e.code}');
      failure = e.message;
    } finally {
      _setBusy(false);
    }

    if (reply == null) {
      await _respondOffline(text, failure);
      return;
    }

    await _append(_entry(WaveMessageKind.reply, text: reply.text));
    await _runAction(reply);
    await _respondWithCard(reply);
  }

  Future<void> _runAction(WaveReply reply) async {
    if (reply.action == WaveActionKind.none) return;

    _setBusy(true);
    try {
      switch (reply.action) {
        case WaveActionKind.none:
          return;
        case WaveActionKind.completeAllHabits:
          await _confirmHabits(await _service.completeHabits());
        case WaveActionKind.completeHabit:
          await _confirmHabits(
            await _service.completeHabits(title: reply.actionTarget),
            title: reply.actionTarget,
          );
        case WaveActionKind.uncompleteHabit:
          await _confirmUnticked(reply.actionTarget);
        case WaveActionKind.addHabit:
          await _confirmAddHabit(reply);
        case WaveActionKind.editHabit:
          await _confirmEditHabit(reply);
        case WaveActionKind.deleteHabit:
          await _confirmDeleteHabit(reply.actionTarget);
        case WaveActionKind.logWater:
          await _confirmWater(reply.actionAmountMl);
        case WaveActionKind.unlogWater:
          await _confirmUnlogWater(reply.actionAmountMl);
        case WaveActionKind.logFood:
          await _confirmLogFood(reply);
        case WaveActionKind.unlogFood:
          await _confirmUnlogFood(reply.actionTarget);
        case WaveActionKind.createFood:
          await _confirmCreateFood(reply);
        case WaveActionKind.startWorkout:
          await _confirmStartWorkout();
        case WaveActionKind.completeWorkout:
          await _confirmCompleteWorkout();
        case WaveActionKind.cancelWorkout:
          await _confirmCancelWorkout();
      }
    } catch (e) {
      debugPrint('wave action failed: $e');
      await _append(
        _entry(
          WaveMessageKind.reply,
          text: 'I could not save that change. Please try again.',
        ),
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _confirmHabits(int count, {String? title}) async {
    if (count == 0) {
      await _append(
        _entry(
          WaveMessageKind.confirmation,
          title: 'Nothing To Tick',
          detail: title == null || title.isEmpty
              ? 'Today\'s habits were already complete'
              : '$title was already complete',
        ),
      );
      return;
    }

    await _append(
      _entry(
        WaveMessageKind.confirmation,
        title: 'Habits Updated',
        detail: count == 1
            ? '1 habit marked complete for today'
            : '$count habits marked complete for today',
      ),
    );
  }

  Future<void> _confirmUnticked(String title) async {
    final count = await _service.uncompleteHabits(title: title);
    await _confirm(
      count > 0 ? 'Habit Unticked' : 'Nothing To Untick',
      count > 0 ? '$title is back to not done' : 'I could not find $title',
    );
  }

  Future<void> _confirmAddHabit(WaveReply reply) async {
    final draft = reply.habitDraft;
    if (draft == null) return;
    await _service.addHabit(draft);
    await _confirm(
      'Habit Added',
      '${draft.title} · ${_targetLabel(draft)} per day',
    );
  }

  Future<void> _confirmEditHabit(WaveReply reply) async {
    final draft = reply.habitDraft;
    if (draft == null) return;
    final updated = await _service.editHabit(reply.actionTarget, draft);
    await _confirm(
      updated ? 'Habit Updated' : 'Habit Not Found',
      updated
          ? '${draft.title} · ${_targetLabel(draft)} per day'
          : 'I could not find ${reply.actionTarget}',
    );
  }

  Future<void> _confirmDeleteHabit(String title) async {
    final deleted = await _service.deleteHabit(title);
    await _confirm(
      deleted ? 'Habit Deleted' : 'Habit Not Found',
      deleted ? '$title removed' : 'I could not find $title',
    );
  }

  Future<void> _confirmUnlogWater(double amountMl) async {
    final removed = await _service.unlogWater(_context, amountMl);
    await _confirm(
      removed > 0 ? 'Water Removed' : 'Nothing To Remove',
      removed > 0
          ? '${removed.round()}ml taken off today'
          : 'No water logged today',
    );
  }

  Future<void> _confirmLogFood(WaveReply reply) async {
    final food = await _service.findFood(_context, reply.actionTarget);
    if (food == null) {
      await _confirm(
        'Food Not Found',
        '${reply.actionTarget} is not in your foods yet',
      );
      return;
    }

    final slot = reply.meal == null
        ? _service.currentMealSlot()
        : WaveChatService.slotOf(reply.meal!);
    final servings = reply.servings < 1 ? 1 : reply.servings;
    final logged = await _service.logFood(food, slot, servings: servings);

    await _confirm(
      'Food Logged',
      '$logged × ${food.name} added to ${slot.label.toLowerCase()}',
    );
  }

  Future<void> _confirmUnlogFood(String name) async {
    final removed = await _service.unlogFood(_context, name);
    await _confirm(
      removed != null ? 'Food Removed' : 'Nothing To Remove',
      removed != null
          ? '$removed taken off today'
          : 'I could not find $name in today\'s log',
    );
  }

  Future<void> _confirmCreateFood(WaveReply reply) async {
    final draft = reply.foodDraft;
    if (draft == null) return;
    final food = await _service.createFood(draft);
    await _confirm(
      'Food Created',
      '${food.name} · ${food.calories.round()} kcal per '
          '${food.serving.isEmpty ? "serving" : food.serving}',
    );
  }

  Future<void> _confirmStartWorkout() async {
    final title = await _service.startWorkout(_context);
    await _confirm(
      title != null ? 'Workout Started' : 'No Session Planned',
      title ?? 'There is nothing scheduled for today',
      action: title != null ? WaveConfirmationAction.openWorkout : null,
    );
  }

  Future<void> _confirmCompleteWorkout() async {
    final title = await _service.completeWorkout();
    await _confirm(
      title != null ? 'Workout Completed' : 'Nothing In Progress',
      title ?? 'Start a session first, then I can finish it',
    );
  }

  Future<void> _confirmCancelWorkout() async {
    final title = await _service.cancelWorkout();
    await _confirm(
      title != null ? 'Workout Cancelled' : 'Nothing In Progress',
      title != null
          ? '$title discarded · start it again anytime today'
          : 'There is no started workout to cancel',
    );
  }

  Future<void> _confirm(
    String title,
    String detail, {
    WaveConfirmationAction? action,
  }) => _append(
    _entry(
      WaveMessageKind.confirmation,
      title: title,
      detail: detail,
      action: action,
    ),
  );

  static String _targetLabel(HabitDraft draft) {
    final target = draft.target;
    final value = target == target.roundToDouble()
        ? target.round().toString()
        : target.toStringAsFixed(1);
    return '$value ${draft.metric.name}';
  }

  Future<void> _confirmWater(double amountMl) async {
    if (amountMl <= 0) return;
    await _service.logWater(amountMl);
    await _append(
      _entry(
        WaveMessageKind.confirmation,
        title: 'Water Logged',
        detail: '${amountMl.round()}ml added to today',
      ),
    );
  }

  Future<void> _respondWithCard(WaveReply reply) async {
    switch (reply.card) {
      case WaveCardKind.none:
        return;
      case WaveCardKind.plan:
        await _append(_entry(WaveMessageKind.plan));
      case WaveCardKind.mealLog:
        await _append(_entry(WaveMessageKind.mealLog));
      case WaveCardKind.scoreReport:
        await _append(_entry(WaveMessageKind.scoreReport));
      case WaveCardKind.checkIn:
        await _append(_entry(WaveMessageKind.checkIn));
      case WaveCardKind.dietPlan:
        await _respondWithDietPlan();
      case WaveCardKind.injurySwap:
        await _respondToInjury(reply.injuryArea);
    }
  }

  Future<void> _respondOffline(String text, String failure) async {
    if (_service.asksForDietPlan(text)) {
      await _respondWithDietPlan();
      return;
    }

    final area = _service.painAreaOf(text);
    if (area != null) {
      await _respondToPain(area);
      return;
    }

    final action = _service.actionOf(text);
    if (action != null) {
      await _respondTo(action);
      return;
    }

    await _append(_entry(WaveMessageKind.reply, text: failure));
  }

  Future<void> _respondToInjury(MuscleGroup? area) async {
    if (area == null) return;
    _setBusy(true);
    try {
      final swap = await _service.swapFor(_context, area: area);
      if (swap == null) return;
      await _append(_entry(WaveMessageKind.injurySwap, swap: swap));
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _respondToPain(MuscleGroup area) async {
    _setBusy(true);
    try {
      final swap = await _service.swapFor(_context, area: area);
      if (swap == null) {
        await _append(
          _entry(
            WaveMessageKind.reply,
            text:
                'Nothing in today\'s plan loads your ${area.label.toLowerCase()} '
                'directly, so there is nothing to swap. Rest it and tell me if '
                'the pain continues.',
          ),
        );
        return;
      }
      await _append(_entry(WaveMessageKind.injurySwap, swap: swap));
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _respondWithDietPlan() async {
    _setBusy(true);
    try {
      final plan = await _service.ensureDietPlan(_context);
      if (plan == null) {
        await _append(
          _entry(
            WaveMessageKind.reply,
            text: 'Sign in again and I will build your diet plan.',
          ),
        );
        return;
      }
      _cachedDietPlan = plan;
      await _append(_entry(WaveMessageKind.dietPlan));
    } catch (e) {
      debugPrint('wave diet plan failed: $e');
      await _append(
        _entry(
          WaveMessageKind.reply,
          text: 'I could not build your diet plan right now.',
        ),
      );
    } finally {
      _setBusy(false);
    }
  }

  String get _fallbackReply =>
      "I'm on it. Ask me about today's plan, an injury swap, your meals or "
      'your Flow Score and I will adjust everything for you.';

  WaveTranscriptEntry _entry(
    WaveMessageKind kind, {
    String? text,
    String? title,
    String? detail,
    WaveInjurySwap? swap,
    WaveConfirmationAction? action,
  }) => WaveTranscriptEntry(
    id: _transcriptService.newId(),
    kind: kind,
    createdAt: DateTime.now(),
    text: text,
    title: title,
    detail: detail,
    swap: swap,
    action: action,
  );

  Future<void> _append(WaveTranscriptEntry entry) async {
    _entries.add(entry);
    notifyListeners();
    _scrollToLatest();
    await _transcriptService.save(entry);
  }

  Future<void> _update(WaveTranscriptEntry entry) async {
    final index = _entries.indexWhere((item) => item.id == entry.id);
    if (index < 0) return;
    _entries[index] = entry;
    notifyListeners();
    await _transcriptService.save(entry);
  }

  WaveTranscriptEntry? _entryOf(String id) =>
      _entries.where((entry) => entry.id == id).firstOrNull;

  WaveMessage? _messageOf(WaveTranscriptEntry entry) => switch (entry.kind) {
    WaveMessageKind.user => WaveUserMessage(
      id: entry.id,
      timestamp: entry.createdAt,
      text: entry.text ?? '',
    ),
    WaveMessageKind.reply => WaveReplyMessage(
      id: entry.id,
      timestamp: entry.createdAt,
      text: entry.text ?? '',
    ),
    WaveMessageKind.dailyBrief => WaveDailyBriefMessage(
      id: entry.id,
      timestamp: entry.createdAt,
      brief: _service.briefOf(_context),
    ),
    WaveMessageKind.plan => WavePlanMessage(
      id: entry.id,
      timestamp: entry.createdAt,
      title: "Today's Plan",
      items: _service.planItemsOf(_context),
    ),
    WaveMessageKind.injurySwap =>
      entry.swap == null
          ? null
          : WaveInjurySwapMessage(
              id: entry.id,
              timestamp: entry.createdAt,
              swap: entry.swap!,
            ),
    WaveMessageKind.confirmation => WaveConfirmationMessage(
      id: entry.id,
      timestamp: entry.createdAt,
      title: entry.title ?? '',
      detail: entry.detail ?? '',
      action: entry.action,
    ),
    WaveMessageKind.checkIn => WaveCheckInMessage(
      id: entry.id,
      timestamp: entry.createdAt,
      title: 'How are you feeling? 💪',
      subtitle: 'This helps WAVE plan your recovery',
    ),
    WaveMessageKind.scoreReport => WaveScoreReportMessage(
      id: entry.id,
      timestamp: entry.createdAt,
      report: _service.scoreReportOf(_context),
    ),
    WaveMessageKind.mealLog => WaveMealLogMessage(
      id: entry.id,
      timestamp: entry.createdAt,
      title: 'Log a Meal 🍽️',
      subtitle: 'Tap to add items · WAVE will calculate macros',
      foods: _service.quickFoodsOf(_context),
    ),
    WaveMessageKind.dietPlan => WaveDietPlanMessage(
      id: entry.id,
      timestamp: entry.createdAt,
      plan: _dietPlanCard,
    ),
  };

  WaveDietPlan get _dietPlanCard =>
      _cachedDietPlan ??
      WaveDietPlan(
        title: '${DietPlan.lengthDays}-Day Diet Plan',
        description: 'Open your Nutrition screen to follow the plan.',
        meals: const [],
      );

  WaveDietPlan? _cachedDietPlan;

  void _watchContext() {
    _contextSubscription = _contextService.watch().listen((context) {
      _context = context;
      notifyListeners();
    }, onError: (Object error) => debugPrint('wave context failed: $error'));
  }

  void _watchDays() {
    _daysSubscription = _transcriptService.watchDays().listen((days) {
      _days
        ..clear()
        ..addAll(days);
      notifyListeners();
    }, onError: (Object error) => debugPrint('wave days failed: $error'));
  }

  void _watchTranscript() {
    _transcriptSubscription?.cancel();
    _transcriptSubscription = _transcriptService.watchDay(_selectedDay).listen((
      entries,
    ) {
      if (_transcriptService.userId == null) return;
      _entries
        ..clear()
        ..addAll(entries);
      notifyListeners();
    }, onError: (Object error) => debugPrint('wave transcript failed: $error'));
  }

  void _setBusy(bool value) {
    if (_isBusy == value) return;
    _isBusy = value;
    notifyListeners();
    if (value) _scrollToLatest();
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: AppMotion.expand,
        curve: AppMotion.expandCurve,
      );
    });
  }

  void _onComposerChanged() {
    final canSend = composer.text.trim().isNotEmpty;
    if (canSend == _canSend) return;
    _canSend = canSend;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _contextSubscription?.cancel();
    _transcriptSubscription?.cancel();
    _daysSubscription?.cancel();
    composer.removeListener(_onComposerChanged);
    composer.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
