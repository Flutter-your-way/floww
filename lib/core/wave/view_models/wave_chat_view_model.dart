import 'dart:async';

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/nutrition/models/diet_plan.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/models/wave_context.dart';
import 'package:floww/core/wave/models/wave_message.dart';
import 'package:floww/core/wave/models/wave_quick_action.dart';
import 'package:floww/core/wave/models/wave_transcript_entry.dart';
import 'package:floww/core/wave/services/wave_chat_service.dart';
import 'package:floww/core/wave/services/wave_context_service.dart';
import 'package:floww/core/wave/services/wave_transcript_service.dart';

class WaveChatViewModel extends ChangeNotifier {
  WaveChatViewModel(this._service, this._contextService, this._transcriptService)
    : _welcomeTimestamp = DateTime.now() {
    composer.addListener(_onComposerChanged);
    _watchContext();
    _watchTranscript();
  }

  static const String title = 'WAVE';
  static const String composerHint = 'Ask WAVE anything...';
  static const String connectedStatus = 'Active · All systems connected';
  static const String connectingStatus = 'Syncing your data...';
  static const String welcomeId = 'wave_welcome';

  final WaveChatService _service;
  final WaveContextService _contextService;
  final WaveTranscriptService _transcriptService;

  final TextEditingController composer = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final DateTime _welcomeTimestamp;

  final List<WaveTranscriptEntry> _entries = [];
  final Map<String, WaveMealSlot> _mealSlots = {};
  final Map<String, Set<String>> _selectedFoods = {};

  StreamSubscription<WaveContext>? _contextSubscription;
  StreamSubscription<List<WaveTranscriptEntry>>? _transcriptSubscription;
  WaveContext _context = WaveContext.empty;
  bool _canSend = false;
  bool _isBusy = false;
  bool _disposed = false;

  WaveContext get context => _context;

  bool get isReady => _context.isReady;

  bool get isBusy => _isBusy;

  String get statusLabel => isReady ? connectedStatus : connectingStatus;

  List<WaveQuickAction> get quickActions => WaveQuickAction.values;

  bool get canSend => _canSend && !_isBusy;

  List<WaveMessage> get messages => [
    WaveDailyBriefMessage(
      id: welcomeId,
      timestamp: _welcomeTimestamp,
      brief: _service.briefOf(_context),
    ),
    for (final entry in _entries)
      ?_messageOf(entry),
  ];

  String timeLabel(WaveMessage message) =>
      AppDateUtils.time(message.timestamp, padHour: true);

  bool isResolved(String messageId) =>
      _entryOf(messageId)?.isResolved ?? false;

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
    await _append(_entry(WaveMessageKind.user, text: text));
    await _respondToText(text);
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

  Future<void> clearHistory() async {
    _entries.clear();
    _selectedFoods.clear();
    _mealSlots.clear();
    notifyListeners();
    await _transcriptService.clear();
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

  Future<void> _respondToText(String text) async {
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

    await _append(_entry(WaveMessageKind.reply, text: _fallbackReply));
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
  }) => WaveTranscriptEntry(
    id: _transcriptService.newId(),
    kind: kind,
    createdAt: DateTime.now(),
    text: text,
    title: title,
    detail: detail,
    swap: swap,
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
    WaveMessageKind.injurySwap => entry.swap == null
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
    _contextSubscription = _contextService.watch().listen(
      (context) {
        _context = context;
        notifyListeners();
      },
      onError: (Object error) => debugPrint('wave context failed: $error'),
    );
  }

  void _watchTranscript() {
    _transcriptSubscription = _transcriptService.watch().listen(
      (entries) {
        if (_transcriptService.userId == null) return;
        _entries
          ..clear()
          ..addAll(entries);
        notifyListeners();
      },
      onError: (Object error) => debugPrint('wave transcript failed: $error'),
    );
  }

  void _setBusy(bool value) {
    if (_isBusy == value) return;
    _isBusy = value;
    notifyListeners();
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
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
    composer.removeListener(_onComposerChanged);
    composer.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
