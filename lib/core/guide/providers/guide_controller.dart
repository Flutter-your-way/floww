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
  List<GuideStep> _steps = const [];
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
  int get stepCount => _steps.length;
  int get direction => _direction;
  bool get isFirstStep => _index == 0;
  bool get isLastStep => _index >= stepCount - 1;

  GuideStep? get step {
    if (_flow == null || _steps.isEmpty) return null;
    return _steps[_index];
  }

  String get nextLabel {
    final action = step?.action;
    if (action != null) return action;
    if (!isLastStep) return 'Next';
    return _flow?.finishLabel ?? '';
  }

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
    _refreshSteps();
    if (isLastStep) {
      _complete(chain: true);
      return;
    }
    _index++;
    _direction = 1;
    notifyListeners();
  }

  void skip() {
    final flow = _flow;
    if (flow == null) return;
    _seen = {..._seen, flow.hostSection};
    _complete(chain: false);
  }

  GuideSection? get _due {
    final welcome = GuideContent.intro;
    if (!_seen.contains(welcome.section) && _current == welcome.hostSection) {
      return welcome.section;
    }
    if (!_seen.contains(_current)) return _current;
    return null;
  }

  void _queue(Duration delay) {
    _pending?.cancel();
    final section = _due;
    if (section == null) return;
    if (GuideContent.flowFor(section).hostSection != _current) return;
    _pending = Timer(delay, _openDue);
  }

  void _openDue() {
    final section = _due;
    if (!_ready || isActive || section == null) return;
    if (GuideContent.flowFor(section).hostSection != _current) return;
    _flow = GuideContent.flowFor(section);
    _steps = const [];
    _index = 0;
    _refreshSteps();
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

  void _refreshSteps() {
    final flow = _flow;
    if (flow == null) return;
    final current = step;
    final start = current == null ? 0 : flow.steps.indexOf(current) + 1;
    _steps = [
      ..._steps.take(current == null ? 0 : _index + 1),
      for (final next in flow.steps.skip(start))
        if (!next.optional || next.targets.any(_isAvailable)) next,
    ];
  }

  bool _isAvailable(GuideTargetId id) {
    final entry = targetEntry(id);
    if (entry == null) return false;
    final box = entry.context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return true;
    return !box.size.isEmpty;
  }

  void _closeSilently() {
    _flow = null;
    _steps = const [];
    _index = 0;
    _direction = 1;
  }

  @override
  void dispose() {
    _pending?.cancel();
    super.dispose();
  }
}
