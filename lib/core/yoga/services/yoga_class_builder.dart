import 'dart:math' as math;

import 'package:floww/core/yoga/data/yoga_module_data.dart';
import 'package:floww/core/yoga/data/yoga_postures_data.dart';
import 'package:floww/core/yoga/models/yoga_caution.dart';
import 'package:floww/core/yoga/models/yoga_class_block.dart';
import 'package:floww/core/yoga/models/yoga_class_section.dart';
import 'package:floww/core/yoga/models/yoga_posture.dart';
import 'package:floww/core/yoga/models/yoga_profile.dart';

class YogaClassBuilder {
  const YogaClassBuilder();

  static const int _secondsPerMinute = 60;
  static const int _holdStep = 5;
  static const int _minHold = 15;
  static const int _maxHold = 90;
  static const int _maxRepeatMultiplier = 3;
  static const int _maxRestingHold = 900;
  static const int _transitionSeconds = 10;
  static const int _roundRestSeconds = 30;
  static const int _minSuryaRound = 60;
  static const int _maxSuryaRound = 150;
  static const int _shortSuryaRounds = 2;
  static const double _relaxationShare = 0.5;
  static const double _arrivalShare = 0.25;
  static const int _minArrivalMinutes = 1;
  static const int _minRelaxationMinutes = 2;

  YogaClassPlan build({
    required int week,
    required int minutes,
    required YogaProfile profile,
    bool isGentle = false,
  }) {
    final courseWeek = YogaModuleData.weekAt(week);
    final target = isGentle
        ? math.min(minutes, YogaModuleData.shortClassMinutes)
        : minutes;
    final sections = <YogaClassSection, List<YogaPosture>>{};
    for (final section in YogaClassSection.values) {
      final postures = <YogaPosture>[];
      for (final id in courseWeek.sections[section] ?? const <String>[]) {
        final posture = resolve(id, profile.cautions);
        if (posture != null && !postures.contains(posture)) {
          postures.add(posture);
        }
      }
      if (postures.isNotEmpty) sections[section] = postures;
    }

    final rounds = target < YogaModuleData.classMinutes
        ? math.min(_shortSuryaRounds, courseWeek.suryaRounds)
        : courseWeek.suryaRounds;
    final budgets = _budgetsOf(sections.keys.toList(), target);
    final bySection = <YogaClassSection, List<YogaClassBlock>>{};
    var activeSeconds = 0;
    for (final entry in sections.entries) {
      if (_isResting(entry.key)) continue;
      final budget = budgets[entry.key] ?? 0;
      final built = entry.key == YogaClassSection.suryaNamaskar
          ? _suryaBlocks(entry.value.first, budget, rounds)
          : _blocksOf(entry.key, entry.value, budget);
      bySection[entry.key] = built;
      activeSeconds += built.fold(
        0,
        (total, block) => total + block.totalSeconds,
      );
    }
    final resting = [
      for (final section in sections.keys)
        if (_isResting(section)) section,
    ];
    final restingBase = resting.fold<double>(
      0,
      (total, section) => total + (budgets[section] ?? 0),
    );
    final restingAvailable = math.max(
      restingBase,
      (target * _secondsPerMinute - activeSeconds).toDouble(),
    );
    for (final section in resting) {
      final share = restingBase == 0
          ? 0.0
          : restingAvailable * (budgets[section] ?? 0) / restingBase;
      bySection[section] = _blocksOf(section, sections[section]!, share);
    }
    final blocks = [
      for (final section in YogaClassSection.values) ...?bySection[section],
    ];
    return YogaClassPlan(
      week: courseWeek.number,
      minutes: target,
      blocks: blocks,
      isGentle: isGentle,
    );
  }

  static YogaPosture? resolve(String id, Set<YogaCaution> cautions) {
    final visited = <String>{};
    var posture = YogaPosturesData.byId(id);
    while (posture != null && posture.isCautionedFor(cautions)) {
      if (!visited.add(posture.id)) return null;
      final alternative = posture.alternativeId;
      posture = alternative == null ? null : YogaPosturesData.byId(alternative);
    }
    return posture;
  }

  Map<YogaClassSection, double> _budgetsOf(
    List<YogaClassSection> present,
    int target,
  ) {
    if (present.isEmpty) return const {};
    final baseTotal = present.fold<int>(
      0,
      (total, section) => total + section.minutes,
    );
    final core = math.min(target, YogaModuleData.classMinutes);
    final scale = core / baseTotal;
    final minutes = {
      for (final section in present) section: section.minutes * scale,
    };
    final extra = target - core;
    if (extra > 0) {
      final hasRelaxation = minutes.containsKey(YogaClassSection.relaxation);
      final hasArrival = minutes.containsKey(YogaClassSection.arrival);
      final relaxation = hasRelaxation ? extra * _relaxationShare : 0.0;
      final arrival = hasArrival ? extra * _arrivalShare : 0.0;
      final rest = extra - relaxation - arrival;
      if (hasRelaxation) {
        minutes[YogaClassSection.relaxation] =
            minutes[YogaClassSection.relaxation]! + relaxation;
      }
      if (hasArrival) {
        minutes[YogaClassSection.arrival] =
            minutes[YogaClassSection.arrival]! + arrival;
      }
      for (final section in present) {
        minutes[section] =
            minutes[section]! + rest * section.minutes / baseTotal;
      }
    }
    if (minutes.containsKey(YogaClassSection.arrival)) {
      minutes[YogaClassSection.arrival] = math.max(
        minutes[YogaClassSection.arrival]!,
        _minArrivalMinutes.toDouble(),
      );
    }
    if (minutes.containsKey(YogaClassSection.relaxation)) {
      minutes[YogaClassSection.relaxation] = math.max(
        minutes[YogaClassSection.relaxation]!,
        _minRelaxationMinutes.toDouble(),
      );
    }
    return {
      for (final entry in minutes.entries)
        entry.key: entry.value * _secondsPerMinute,
    };
  }

  List<YogaClassBlock> _suryaBlocks(
    YogaPosture posture,
    double budget,
    int rounds,
  ) {
    if (posture.id != YogaPosturesData.suryaNamaskarId || rounds <= 0) {
      return _blocksOf(YogaClassSection.suryaNamaskar, [posture], budget);
    }
    final perRound = budget / rounds - _roundRestSeconds;
    return [
      YogaClassBlock(
        section: YogaClassSection.suryaNamaskar,
        postureId: posture.id,
        holdSeconds: _rounded(perRound, _minSuryaRound, _maxSuryaRound),
        repeats: rounds,
        transitionSeconds: _roundRestSeconds,
      ),
    ];
  }

  List<YogaClassBlock> _blocksOf(
    YogaClassSection section,
    List<YogaPosture> postures,
    double budget,
  ) {
    var weight = 0;
    var slots = 0;
    for (final posture in postures) {
      final repeats = _repeatsOf(posture);
      weight += posture.holdSeconds * repeats;
      slots += repeats;
    }
    final available = budget - slots * _transitionSeconds;
    final factor = weight == 0 ? 1.0 : available / weight;
    final isResting = _isResting(section);
    final cap = isResting ? _maxRestingHold : _maxHold;
    return [
      for (final posture in postures)
        _blockOf(
          section,
          posture,
          posture.holdSeconds * factor,
          cap,
          isResting,
        ),
    ];
  }

  YogaClassBlock _blockOf(
    YogaClassSection section,
    YogaPosture posture,
    double hold,
    int cap,
    bool isResting,
  ) {
    final multiplier = isResting || hold <= cap
        ? 1
        : math.min(_maxRepeatMultiplier, (hold / cap).ceil());
    return YogaClassBlock(
      section: section,
      postureId: posture.id,
      holdSeconds: _rounded(hold / multiplier, _minHold, cap),
      repeats: _repeatsOf(posture) * multiplier,
      transitionSeconds: _transitionSeconds,
    );
  }

  bool _isResting(YogaClassSection section) =>
      section == YogaClassSection.arrival ||
      section == YogaClassSection.relaxation;

  int _repeatsOf(YogaPosture posture) => posture.isPerSide ? 2 : 1;

  int _rounded(double seconds, int min, int max) {
    final stepped = (seconds / _holdStep).round() * _holdStep;
    return stepped.clamp(min, max);
  }
}
