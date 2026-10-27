import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/core/guide/data/guide_content.dart';
import 'package:floww/core/guide/models/guide_step.dart';
import 'package:floww/core/guide/services/guide_service.dart';

class GuideController extends ChangeNotifier {
  GuideController(this._service);

  final GuideService _service;

  Set<GuideSection> _seen = {};
  bool _ready = false;
  int _session = 0;
  GuideSection _current = GuideSection.home;
  GuideFlow? _flow;
  int _index = 0;
  int _direction = 1;
  Timer? _pending;
  final Map<GuideTargetId, GuideTargetEntry> _targets = {};

  void registerTarget(GuideTargetId id, GuideTargetEntry entry) {
    _targets[id] = entry;
  }

  void unregisterTarget(GuideTargetId id, BuildContext context) {
    if (_targets[id]?.context == context) _targets.remove(id);
  }

  GuideTargetEntry? targetEntry(GuideTargetId id) {
    final entry = _targets[id];
    if (entry == null || !entry.context.mounted) return null;
    return entry;
  }

  GuideFlow? get flow => _flow;
  bool get isActive => _flow != null;
  int get stepIndex => _index;
  int get stepCount => _flow?.steps.length ?? 0;
  int get direction => _direction;
  bool get isFirstStep => _index == 0;
  bool get isLastStep => _index >= stepCount - 1;

  GuideStep? get step {
    final flow = _flow;
    if (flow == null) return null;
    return flow.steps[_index];
  }

  String get nextLabel => isLastStep ? (_flow?.finishLabel ?? '') : 'Next';
  String get skipLabel => 'Skip';

  GuideViewState? get view {
    final flow = _flow;
    final step = this.step;
    if (flow == null || step == null) return null;
    return GuideViewState(
      flow: flow,
      step: step,
      index: _index,
      count: stepCount,
      direction: _direction,
      nextLabel: nextLabel,
      skipLabel: skipLabel,
    );
  }

  Future<void> start(GuideSection section) async {
    final session = ++_session;
    _current = section;
    _ready = false;
    _pending?.cancel();
    _closeSilently();
    final seen = await _service.loadSeen();
    if (session != _session) return;
    _seen = seen;
    _ready = true;
    _queue(AppMotion.guideStartDelay);
  }

  void visit(GuideSection section) {
    _current = section;
    if (!_ready || isActive) return;
    _queue(AppMotion.guideSectionDelay);
  }

  Future<void> replay() async {
    _session++;
    _pending?.cancel();
    _seen = {};
    _ready = true;
    if (isActive) {
      _closeSilently();
      notifyListeners();
    }
    await _service.reset();
    _queue(AppMotion.guideStartDelay);
  }

  void stop() {
    _session++;
    _ready = false;
    _pending?.cancel();
    _closeSilently();
  }

  void next() {
    if (!isActive) return;
    if (isLastStep) {
      _complete(chain: true);
      return;
    }
    _index++;
    _direction = 1;
    notifyListeners();
  }

  void back() {
    if (!isActive || isFirstStep) return;
    _index--;
    _direction = -1;
    notifyListeners();
  }

  void passUnavailableStep() {
    if (!isActive) return;
    if (_direction < 0 && !isFirstStep) {
      back();
      return;
    }
    next();
  }

  void skip() {
    if (!isActive) return;
    _complete(chain: false);
  }

  GuideSection? get _due {
    if (!_seen.contains(_current)) return _current;
    return null;
  }

  void _queue(Duration delay) {
    _pending?.cancel();
    if (_due == null) return;
    _pending = Timer(delay, _openDue);
  }

  void _openDue() {
    final section = _due;
    if (!_ready || isActive || section == null) return;
    _flow = GuideContent.flowFor(section);
    _index = 0;
    _direction = 1;
    notifyListeners();
  }

  void _complete({required bool chain}) {
    final section = _flow?.section;
    if (section == null) return;
    _seen = {..._seen, section};
    _closeSilently();
    notifyListeners();
    unawaited(_service.saveSeen(_seen));
    if (chain) _queue(AppMotion.guideSectionDelay);
  }

  void _closeSilently() {
    _flow = null;
    _index = 0;
    _direction = 1;
  }

  @override
  void dispose() {
    _pending?.cancel();
    super.dispose();
  }
}
