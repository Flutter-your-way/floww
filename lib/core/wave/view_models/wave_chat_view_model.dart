import 'dart:async';

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/core/nutrition/models/diet_plan.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/wave/models/wave_action.dart';
import 'package:floww/core/wave/models/wave_action_outcome.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/models/wave_chat_day.dart';
import 'package:floww/core/wave/models/wave_context.dart';
import 'package:floww/core/wave/models/wave_message.dart';
import 'package:floww/core/wave/models/wave_premium_feature.dart';
import 'package:floww/core/wave/models/wave_quota.dart';
import 'package:floww/core/wave/models/wave_rating.dart';
import 'package:floww/core/wave/models/wave_rejected_action.dart';
import 'package:floww/core/wave/models/wave_quick_action.dart';
import 'package:floww/core/wave/models/wave_reply.dart';
import 'package:floww/core/wave/models/wave_reveal.dart';
import 'package:floww/core/wave/models/wave_thinking.dart';
import 'package:floww/core/wave/models/wave_transcript_entry.dart';
import 'package:floww/core/wave/models/wave_undo.dart';
import 'package:floww/core/wave/services/wave_action_service.dart';
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
    WaveActionService? actionService,
    this.onNavigate,
    this.onUpgrade,
  }) : _aiService = aiService ?? WaveAiService(),
       _actionService = actionService ?? WaveActionService(_service),
       _welcomeTimestamp = DateTime.now(),
       _selectedDay = _lastDay ?? AppDateUtils.dateOnly(DateTime.now()) {
    composer.addListener(_onComposerChanged);
    _context = _contextService.cached ?? WaveContext.empty;
    _days.addAll(_transcriptService.cachedDays ?? const []);
    _seedDay();
    _watchContext();
    _watchTranscript();
    _watchDays();
    _transcriptService.backfillDays();
    _loadQuota();
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
  final WaveActionService _actionService;
  final ValueChanged<WaveDestination>? onNavigate;
  final Future<void> Function()? onUpgrade;

  final TextEditingController composer = TextEditingController();
  static DateTime? _lastDay;
  static double _lastOffset = 0;

  final ScrollController scrollController = ScrollController(
    initialScrollOffset: _lastOffset,
  );
  final DateTime _welcomeTimestamp;

  final List<WaveTranscriptEntry> _entries = [];
  final Map<String, WaveMealSlot> _mealSlots = {};
  final Map<String, Set<String>> _selectedFoods = {};
  final Set<String> _entering = {};
  final Map<String, Completer<void>> _reveals = {};

  final List<WaveChatDay> _days = [];

  StreamSubscription<WaveContext>? _contextSubscription;
  StreamSubscription<List<WaveTranscriptEntry>>? _transcriptSubscription;
  StreamSubscription<List<WaveChatDay>>? _daysSubscription;
  WaveContext _context = WaveContext.empty;
  DateTime _selectedDay;
  String? _thinkingQuestion;
  bool _canSend = false;
  bool _isLoaded = false;
  bool _isBusy = false;
  bool _disposed = false;
  WaveQuota? _quota;

  WaveContext get context => _context;

  bool get isReady => _context.isReady;

  bool get isBusy => _isBusy;

  bool get isLoaded => _isLoaded;

  List<WaveQuickAction> get quickActions => WaveQuickAction.values;

  bool get canSend =>
      _canSend &&
      !_isBusy &&
      _reveals.isEmpty &&
      isViewingToday &&
      !isOutOfMessages;

  bool get canUseVoice =>
      !_isBusy && _reveals.isEmpty && isViewingToday && !isOutOfMessages;

  bool get showQuota => isViewingToday && _quota != null && !_quota!.isPremium;

  bool get isOutOfMessages =>
      _quota != null && !_quota!.isPremium && _quota!.isExhausted;

  bool get isQuotaLow => showQuota && _quota!.isLow;

  int get quotaRemaining => _quota?.remaining ?? 0;

  int get quotaLimit => _quota?.limit ?? 0;

  String get quotaMessage => isOutOfMessages
      ? 'You have used all ${_quota?.limit ?? 0} WAVE messages for today.'
      : 'Only ${_quota?.remaining ?? 0} WAVE messages left today.';

  static const String quotaUpsell =
      'Premium gets 60 a day, memory, plan edits and weekly reviews.';
  static const String upgradeLabel = 'Go Premium';

  List<String> get thinkingSteps => WaveThinking.stepsFor(_thinkingQuestion);

  bool shouldEnter(String messageId) => _entering.contains(messageId);

  void markEntered(String messageId) => _entering.remove(messageId);

  bool isRevealing(String messageId) => _reveals.containsKey(messageId);

  void completeReveal(String messageId) {
    final reveal = _reveals.remove(messageId);
    if (reveal == null) return;
    if (!reveal.isCompleted) reveal.complete();
    notifyListeners();
  }

  bool get showQuickActions =>
      !_canSend && isViewingToday && (_quota?.isPremium ?? false);

  List<WaveChatDay> get days => List.unmodifiable(_days);

  DateTime get selectedDay => _selectedDay;

  bool get isViewingToday =>
      AppDateUtils.isSameDay(_selectedDay, DateTime.now());

  String get dayLabel => AppDateUtils.relativeDay(_selectedDay);

  static const String openWorkoutLabel = 'Open Workout';
  static const String manageMemoryLabel = 'Manage';
  static const String memoryUpdatedTitle = 'Memory Updated';
  static const String undoLabel = 'Undo';
  static const String openLabel = 'Open';
  static const String confirmLabel = 'Confirm';
  static const String cancelLabel = 'Cancel';
  static const String actionFailedMessage =
      'I could not save that change. Please try again.';
  static const String undoFailedMessage =
      'I could not undo that change. Please try again.';

  String? confirmationActionLabel(WaveConfirmationMessage message) =>
      switch (message.action) {
        WaveConfirmationAction.openWorkout =>
          isViewingToday && _context.hasActiveWorkout ? openWorkoutLabel : null,
        WaveConfirmationAction.openMemory => manageMemoryLabel,
        WaveConfirmationAction.undo =>
          isViewingToday && !isResolved(message.id) ? undoLabel : null,
        WaveConfirmationAction.navigate => isViewingToday ? openLabel : null,
        WaveConfirmationAction.upgrade => upgradeLabel,
        null => null,
      };

  static const String premiumTitle = 'Part of Premium';
  static const String notFoundTitle = 'Not Found';
  static const String notAvailableTitle = 'Not Available Now';

  bool canRate(String messageId) => _entryOf(messageId)?.isRateable ?? false;

  WaveRating? ratingFor(String messageId) => _entryOf(messageId)?.rating;

  Future<void> rate(String messageId, WaveRating rating) async {
    final entry = _entryOf(messageId);
    if (entry == null || !entry.isRateable || entry.rating == rating) return;
    await _update(entry.copyWith(rating: rating));
  }

  String get statusLabel => isViewingToday
      ? (isReady ? connectedStatus : connectingStatus)
      : dayLabel;

  List<WaveMessage>? _messages;

  List<WaveMessage> get messages => _messages ??= List.unmodifiable([
    if (isViewingToday)
      WaveDailyBriefMessage(
        id: welcomeId,
        timestamp: _welcomeTimestamp,
        brief: _service.briefOf(_context),
      ),
    for (final entry in _entries) ?_messageOf(entry),
  ]);

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
    final quotaBefore = _quota;
    _quota = _quota?.consumed;
    composer.clear();
    final history = List<WaveTranscriptEntry>.of(_entries);
    await _append(_entry(WaveMessageKind.user, text: text));
    await _respondToText(text, history, quotaBefore);
  }

  Future<void> submitVoice(String text) async {
    if (!canUseVoice || text.trim().isEmpty) return;
    composer.text = text.trim();
    await submitComposer();
  }

  Future<void> startDay() => _respondTo(WaveQuickAction.todayPlan);

  Future<void> logWater() async {
    if (_isBusy) return;
    await _perform(
      const WaveAction(
        kind: WaveActionKind.logWater,
        value: WaveChatService.waterQuickAmountMl,
      ),
    );
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
      final outcome = await _actionService.logMeal(
        foods,
        mealSlotFor(message.id),
      );
      _selectedFoods.remove(message.id);
      final entry = _entryOf(message.id);
      if (entry != null) await _update(entry.copyWith(isResolved: true));
      await _confirmOutcome(outcome);
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
    _selectedFoods.clear();
    _mealSlots.clear();
    _seedDay();
    notifyListeners();
    _watchTranscript();
  }

  void goToToday() {
    final today = AppDateUtils.dateOnly(DateTime.now());
    if (AppDateUtils.isSameDay(today, _selectedDay)) return;
    _selectedDay = today;
    _selectedFoods.clear();
    _mealSlots.clear();
    _seedDay();
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
    WaveQuota? quotaBefore,
  ) async {
    WaveReply? reply;
    var failure = _fallbackReply;

    _thinkingQuestion = text;
    _setBusy(true);
    try {
      reply = await _aiService.ask(
        message: text,
        context: _context,
        history: history,
        schedule: await _contextService.upcomingSchedule().catchError((
          Object error,
        ) {
          debugPrint('wave schedule failed: $error');
          return const <WorkoutPlanEntity>[];
        }),
      );
    } on WaveChatException catch (e) {
      debugPrint('wave ai failed: ${e.code}');
      failure = e.message;
      if (e.code == WaveChatErrorCode.quotaExceeded) {
        _quota = quotaBefore?.exhausted;
        if (isOutOfMessages) failure = '$quotaMessage $quotaUpsell';
      } else {
        _quota = quotaBefore;
      }
    } finally {
      _thinkingQuestion = null;
      _setBusy(false);
    }

    if (reply == null) {
      await _respondOffline(text, failure);
      return;
    }

    _quota = reply.quota ?? _quota;
    await _append(
      _entry(
        WaveMessageKind.reply,
        text: reply.text,
        promptVersion: reply.promptVersion,
        aiModel: reply.aiModel,
        route: reply.route,
      ),
    );
    await _confirmMemory(reply);
    final destination = await _runActions(reply);
    await _reportRejected(reply.rejected);
    await _offerPremium(reply.locked);
    await _respondWithCard(reply);
    if (destination != null) _navigate(destination);
  }

  Future<void> upgrade() async {
    await onUpgrade?.call();
    if (_disposed) return;
    await _loadQuota();
  }

  Future<void> _loadQuota() async {
    final quota = await _aiService.quota();
    if (quota == null) return;
    _quota = quota;
    notifyListeners();
  }

  Future<void> _reportRejected(List<WaveRejectedAction> rejected) async {
    for (final item in rejected) {
      final target = item.target.isEmpty ? 'That' : item.target;
      switch (item.reason) {
        case WaveRejectReason.premium:
          continue;
        case WaveRejectReason.notFound:
          await _confirm(
            notFoundTitle,
            '$target is not in your ${_placeOf(item.kind)}',
            tone: WaveConfirmationTone.warning,
          );
        case WaveRejectReason.notAvailable:
          await _confirm(
            notAvailableTitle,
            _unavailableDetailOf(item.kind),
            tone: WaveConfirmationTone.warning,
          );
      }
    }
  }

  static String _placeOf(WaveActionKind kind) => switch (kind) {
    WaveActionKind.logFood => 'foods yet',
    WaveActionKind.unlogFood => 'food log today',
    WaveActionKind.logSet => 'current session',
    WaveActionKind.swapExercise => 'plan today',
    _ => 'habits',
  };

  static String _unavailableDetailOf(WaveActionKind kind) => switch (kind) {
    WaveActionKind.completeAllHabits => 'Every habit is already done today',
    WaveActionKind.startWorkout => 'There is no session to start today',
    WaveActionKind.logSet ||
    WaveActionKind.completeWorkout ||
    WaveActionKind.cancelWorkout => 'No workout is in progress',
    _ => 'Today\'s session is already started, done or not planned',
  };

  Future<void> _offerPremium(List<WavePremiumFeature> locked) async {
    if (locked.isEmpty) return;
    await _confirm(
      premiumTitle,
      locked.map((feature) => feature.label).join(' · '),
      action: WaveConfirmationAction.upgrade,
      tone: WaveConfirmationTone.premium,
    );
  }

  Future<void> _confirmMemory(WaveReply reply) async {
    final details = [
      if (reply.memorySaved.isNotEmpty)
        'Remembered: ${reply.memorySaved.join(' · ')}',
      if (reply.memoryForgotten.isNotEmpty)
        'Forgot: ${reply.memoryForgotten.join(' · ')}',
    ];
    if (details.isEmpty) return;
    await _confirm(
      memoryUpdatedTitle,
      details.join('\n'),
      action: WaveConfirmationAction.openMemory,
      tone: WaveConfirmationTone.memory,
    );
  }

  Future<WaveDestination?> _runActions(WaveReply reply) async {
    WaveDestination? destination;
    for (final action in reply.actions) {
      if (action.needsConfirmation) {
        await _askToConfirm(action);
        continue;
      }
      final outcome = await _perform(action);
      destination = outcome?.destination ?? destination;
    }
    return destination;
  }

  Future<void> _askToConfirm(WaveAction action) {
    final prompt = _actionService.promptFor(action);
    return _append(
      _entry(
        WaveMessageKind.actionPrompt,
        title: prompt.title,
        detail: prompt.detail,
        pendingAction: action,
      ),
    );
  }

  Future<WaveActionOutcome?> _perform(WaveAction action) async {
    _setBusy(true);
    try {
      final outcome = await _actionService.run(action, _context);
      if (outcome != null) await _confirmOutcome(outcome);
      return outcome;
    } catch (e) {
      debugPrint('wave action ${action.kind.name} failed: $e');
      await _append(_entry(WaveMessageKind.reply, text: actionFailedMessage));
      return null;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> confirmPending(String messageId) async {
    final entry = _entryOf(messageId);
    final action = entry?.pendingAction;
    if (entry == null || action == null || entry.isResolved || _isBusy) return;
    await _update(entry.copyWith(isResolved: true));
    final outcome = await _perform(action);
    final destination = outcome?.destination;
    if (destination != null) _navigate(destination);
  }

  Future<void> dismissPending(String messageId) async {
    final entry = _entryOf(messageId);
    final action = entry?.pendingAction;
    if (entry == null || action == null || entry.isResolved) return;
    await _update(entry.copyWith(isResolved: true));
    await _confirmOutcome(_actionService.dismissed(action));
  }

  Future<void> undo(String messageId) async {
    final entry = _entryOf(messageId);
    final undo = entry?.undo;
    if (entry == null || undo == null || entry.isResolved || _isBusy) return;
    if (!isViewingToday) return;

    _setBusy(true);
    try {
      final outcome = await _actionService.undo(undo);
      await _update(entry.copyWith(isResolved: true));
      await _confirm(
        outcome.title,
        '${entry.title ?? ''} · ${outcome.detail}',
        tone: entry.tone,
      );
    } catch (e) {
      debugPrint('wave undo ${undo.kind.name} failed: $e');
      await _append(_entry(WaveMessageKind.reply, text: undoFailedMessage));
    } finally {
      _setBusy(false);
    }
  }

  void openDestination(String messageId) {
    final destination = _entryOf(messageId)?.destination;
    if (destination != null) _navigate(destination);
  }

  void _navigate(WaveDestination destination) {
    if (!isViewingToday) return;
    onNavigate?.call(destination);
  }

  Future<void> _confirmOutcome(WaveActionOutcome outcome) => _append(
    _entry(
      WaveMessageKind.confirmation,
      title: outcome.title,
      detail: outcome.detail,
      action: outcome.action,
      tone: outcome.tone,
      undo: outcome.undo,
      destination: outcome.destination,
    ),
  );

  Future<void> _confirm(
    String title,
    String detail, {
    WaveConfirmationAction? action,
    WaveConfirmationTone? tone,
  }) => _append(
    _entry(
      WaveMessageKind.confirmation,
      title: title,
      detail: detail,
      action: action,
      tone: tone,
    ),
  );

  Future<void> _respondWithCard(WaveReply reply) async {
    switch (reply.card) {
      case WaveCardKind.none:
        return;
      case WaveCardKind.plan:
        await _append(_entry(WaveMessageKind.plan));
      case WaveCardKind.mealLog:
        if (reply.actions.any((action) => action.kind.logsFood)) return;
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
    WaveConfirmationTone? tone,
    WaveAction? pendingAction,
    WaveUndo? undo,
    WaveDestination? destination,
    String? promptVersion,
    String? aiModel,
    String? route,
  }) => WaveTranscriptEntry(
    id: _transcriptService.newId(),
    kind: kind,
    createdAt: DateTime.now(),
    text: text,
    title: title,
    detail: detail,
    swap: swap,
    action: action,
    tone: tone,
    pendingAction: pendingAction,
    undo: undo,
    destination: destination,
    promptVersion: promptVersion,
    aiModel: aiModel,
    route: route,
  );

  Future<void> _append(WaveTranscriptEntry entry) async {
    final text = entry.text ?? '';
    final reveals = entry.kind == WaveMessageKind.reply && text.isNotEmpty;
    _entering.add(entry.id);
    if (reveals) _reveals[entry.id] = Completer<void>();
    _entries.add(entry);
    notifyListeners();
    _scrollToLatest();
    await Future.wait([
      _transcriptService.save(entry),
      if (reveals) _revealOf(entry.id, text),
    ]);
  }

  Future<void> _revealOf(String id, String text) {
    final reveal = _reveals[id];
    if (reveal == null) return Future.value();
    return reveal.future.timeout(
      WaveReveal.durationFor(text) + AppMotion.waveRevealGrace,
      onTimeout: () => completeReveal(id),
    );
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
      tone: entry.tone ?? WaveConfirmationTone.success,
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
    WaveMessageKind.actionPrompt => WaveActionPromptMessage(
      id: entry.id,
      timestamp: entry.createdAt,
      title: entry.title ?? '',
      detail: entry.detail ?? '',
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

  void _seedDay() {
    final cached = _transcriptService.cachedDay(_selectedDay);
    _entries
      ..clear()
      ..addAll(cached ?? const []);
    _isLoaded = cached != null;
  }

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
    _transcriptSubscription = _transcriptService
        .watchDay(_selectedDay)
        .listen(
          (entries) {
            if (_transcriptService.userId == null) {
              if (_isLoaded) return;
              _isLoaded = true;
              notifyListeners();
              return;
            }
            _entries
              ..clear()
              ..addAll(entries);
            _isLoaded = true;
            notifyListeners();
          },
          onError: (Object error) {
            debugPrint('wave transcript failed: $error');
            _isLoaded = true;
            notifyListeners();
          },
        );
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
    _messages = null;
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _lastDay = isViewingToday ? null : _selectedDay;
    if (scrollController.hasClients) _lastOffset = scrollController.offset;
    _contextSubscription?.cancel();
    _transcriptSubscription?.cancel();
    _daysSubscription?.cancel();
    composer.removeListener(_onComposerChanged);
    composer.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
