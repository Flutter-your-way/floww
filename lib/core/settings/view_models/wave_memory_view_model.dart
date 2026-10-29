import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:floww/core/settings/services/settings_service.dart';
import 'package:floww/core/wave/models/wave_memory_note.dart';
import 'package:floww/core/wave/models/wave_summary_item.dart';
import 'package:floww/core/wave/services/wave_memory_service.dart';

class WaveMemoryGroup {
  const WaveMemoryGroup({required this.category, required this.notes});

  final WaveMemoryCategory category;
  final List<WaveMemoryNote> notes;
}

class WaveSummaryGroup {
  const WaveSummaryGroup({required this.section, required this.items});

  final WaveSummarySection section;
  final List<WaveSummaryItem> items;
}

class WaveMemoryViewModel extends ChangeNotifier {
  WaveMemoryViewModel(this._memoryService, this._settingsService) {
    _notesSubscription = _memoryService.watchNotes().listen((notes) {
      _notes = notes;
      _isLoading = false;
      notifyListeners();
    }, onError: _onStreamError);
    _summarySubscription = _memoryService.watchSummary().listen((items) {
      _summaryItems = items;
      notifyListeners();
    }, onError: _onStreamError);
    _enabledSubscription = _settingsService.watchWaveMemoryEnabled().listen((
      enabled,
    ) {
      _isEnabled = enabled;
      notifyListeners();
    }, onError: _onStreamError);
  }

  static const String title = 'WAVE Memory';
  static const String toggleTitle = 'Let WAVE remember';
  static const String toggleOnSubtitle =
      'WAVE saves lasting facts from your chats to coach you better';
  static const String toggleOffSubtitle =
      'WAVE will not save or use anything from past chats';
  static const String explainer =
      'WAVE notes things that matter for your coaching, like injuries, foods '
      'you avoid or your schedule. It never saves today\'s numbers. Delete '
      'anything here and WAVE forgets it straight away.';
  static const String emptyTitle = 'Nothing remembered yet';
  static const String emptyMessage =
      'Tell WAVE about an injury, a food you avoid or your schedule and it '
      'will show up here.';
  static const String summaryTitle = 'Conversation Summary';
  static const String summarySubtitle =
      'What WAVE is still keeping track of from your older chats';
  static const String showLessLabel = 'Show less';
  static const int collapsedSummaryCount = 3;
  static const String dangerTitle = 'Reset Memory';
  static const String forgetTitle = 'Forget Everything';
  static const String forgetSubtitle = 'Delete every note and the summary';
  static const String forgettingSubtitle = 'Forgetting…';
  static const String forgetPromptTitle = 'Forget everything?';
  static const String forgetPromptMessage =
      'WAVE will lose every note and the summary of your past chats. Your '
      'chat history and logs stay as they are.';
  static const String forgetConfirmLabel = 'Yes, forget everything';
  static const String failedMessage =
      'Could not update WAVE\'s memory. Check your connection and try again.';

  final WaveMemoryService _memoryService;
  final SettingsService _settingsService;

  StreamSubscription<List<WaveMemoryNote>>? _notesSubscription;
  StreamSubscription<List<WaveSummaryItem>>? _summarySubscription;
  StreamSubscription<bool>? _enabledSubscription;

  List<WaveMemoryNote> _notes = const [];
  final Set<String> _deleting = {};
  List<WaveSummaryItem> _summaryItems = const [];
  final Set<WaveSummaryItem> _deletingSummary = {};
  bool _isSummaryExpanded = false;
  bool _isEnabled = true;
  bool _isLoading = true;
  bool _isForgetting = false;
  bool _disposed = false;
  String? _errorMessage;

  bool get isEnabled => _isEnabled;

  bool get isLoading => _isLoading;

  bool get isForgetting => _isForgetting;

  String? get errorMessage => _errorMessage;

  bool get hasSummary => _visibleSummary.isNotEmpty;

  bool get isSummaryExpanded => _isSummaryExpanded;

  bool get canToggleSummary => _visibleSummary.length > collapsedSummaryCount;

  String get summaryToggleLabel => _isSummaryExpanded
      ? showLessLabel
      : 'Show all (${_visibleSummary.length})';

  List<WaveSummaryGroup> get summaryGroups {
    final ordered = [
      for (final section in WaveSummarySection.values)
        ..._visibleSummary.where((item) => item.section == section),
    ];
    final shown = _isSummaryExpanded
        ? ordered
        : ordered.take(collapsedSummaryCount).toList();
    return [
      for (final section in WaveSummarySection.values)
        if (shown.where((item) => item.section == section).toList()
            case final items when items.isNotEmpty)
          WaveSummaryGroup(section: section, items: items),
    ];
  }

  List<WaveSummaryItem> get _visibleSummary => _summaryItems
      .where(
        (item) => !_deletingSummary.any(
          (pending) =>
              pending.section == item.section && pending.text == item.text,
        ),
      )
      .toList();

  bool get isEmpty => _notes.isEmpty && !hasSummary;

  bool get canForget => !isEmpty && !_isForgetting;

  String get toggleSubtitle =>
      _isEnabled ? toggleOnSubtitle : toggleOffSubtitle;

  String get forgetActionSubtitle =>
      _isForgetting ? forgettingSubtitle : forgetSubtitle;

  List<WaveMemoryGroup> get groups => [
    for (final category in WaveMemoryCategory.values)
      if (_visibleNotes.where((note) => note.category == category).toList()
          case final notes when notes.isNotEmpty)
        WaveMemoryGroup(category: category, notes: notes),
  ];

  Iterable<WaveMemoryNote> get _visibleNotes =>
      _notes.where((note) => !_deleting.contains(note.id));

  Future<void> setEnabled(bool value) async {
    _isEnabled = value;
    notifyListeners();
    if (!await _settingsService.setWaveMemoryEnabled(value)) {
      _isEnabled = !value;
      _errorMessage = failedMessage;
      notifyListeners();
    }
  }

  Future<void> deleteNote(WaveMemoryNote note) => _run(() async {
    _deleting.add(note.id);
    notifyListeners();
    try {
      await _memoryService.deleteNote(note.id);
    } finally {
      _deleting.remove(note.id);
    }
  });

  void toggleSummaryExpanded() {
    _isSummaryExpanded = !_isSummaryExpanded;
    notifyListeners();
  }

  Future<void> deleteSummaryItem(WaveSummaryItem item) => _run(() async {
    _deletingSummary.add(item);
    notifyListeners();
    try {
      await _memoryService.deleteSummaryItem(item);
    } finally {
      _deletingSummary.remove(item);
    }
  });

  Future<void> clearSummary() => _run(_memoryService.clearSummary);

  Future<void> forgetEverything() async {
    if (_isForgetting) return;
    _isForgetting = true;
    notifyListeners();
    await _run(_memoryService.forgetEverything);
    _isForgetting = false;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    _errorMessage = null;
    try {
      await action();
    } catch (e, stackTrace) {
      debugPrint('wave memory update failed: $e\n$stackTrace');
      _errorMessage = failedMessage;
    }
    notifyListeners();
  }

  void _onStreamError(Object error) {
    debugPrint('wave memory stream failed: $error');
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
    _notesSubscription?.cancel();
    _summarySubscription?.cancel();
    _enabledSubscription?.cancel();
    super.dispose();
  }
}
