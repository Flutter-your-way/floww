import 'package:floww/core/calisthenics/models/cal_ladder.dart';

class CalisthenicsLaddersData {
  CalisthenicsLaddersData._();

  static const String pushHorizontal = 'push-horizontal';
  static const String pushDips = 'push-dips';
  static const String pushVertical = 'push-vertical';
  static const String pullVertical = 'pull-vertical';
  static const String pullHorizontal = 'pull-horizontal';
  static const String legsSquat = 'legs-squat';
  static const String legsPosterior = 'legs-posterior';
  static const String core = 'core';
  static const String lSit = 'skill-l-sit';
  static const String planche = 'skill-planche';
  static const String handstand = 'skill-handstand';
  static const String backLever = 'skill-back-lever';
  static const String humanFlag = 'skill-human-flag';

  static const int consecutiveSessions = 2;

  static final Map<String, CalLadder> _byId = {
    for (final ladder in all) ladder.id: ladder,
  };

  static CalLadder? byId(String? id) => id == null ? null : _byId[id];

  static CalLadder? containing(String moveId) {
    for (final ladder in all) {
      if (ladder.indexOf(moveId) >= 0) return ladder;
    }
    return null;
  }

  static const List<CalLadder> all = [
    CalLadder(
      id: pushHorizontal,
      name: 'Push – horizontal',
      steps: [
        CalLadderStep('wall-push-up', 1, sets: 3, value: 20),
        CalLadderStep('high-incline-push-up', 1, sets: 3, value: 15),
        CalLadderStep('low-incline-push-up', 1, sets: 3, value: 12),
        CalLadderStep('negative-push-up', 1, sets: 3, value: 10),
        CalLadderStep('push-up', 1, sets: 3, value: 15),
        CalLadderStep('decline-push-up', 2, sets: 3, value: 15),
        CalLadderStep(
          'archer-push-up',
          2,
          sets: 3,
          value: 6,
          isPerSide: true,
        ),
        CalLadderStep('pseudo-planche-push-up', 3, sets: 3, value: 10),
        CalLadderStep(
          'one-arm-push-up',
          3,
          sets: 3,
          value: 5,
          isPerSide: true,
        ),
        CalLadderStep('planche-push-up', 4),
      ],
    ),
    CalLadder(
      id: pushDips,
      name: 'Push – dips',
      steps: [
        CalLadderStep('bench-dip', 1, sets: 3, value: 12),
        CalLadderStep('dip-negative', 2, sets: 3, value: 5),
        CalLadderStep('parallel-bar-dip', 2, sets: 3, value: 12),
        CalLadderStep('ring-dip', 3, sets: 3, value: 8),
        CalLadderStep('weighted-dip', 3),
      ],
    ),
    CalLadder(
      id: pushVertical,
      name: 'Push – vertical',
      steps: [
        CalLadderStep('pike-push-up', 2, sets: 3, value: 8),
        CalLadderStep('elevated-pike-push-up', 2, sets: 3, value: 8),
        CalLadderStep('wall-hspu-negative', 2, sets: 3, value: 5),
        CalLadderStep('wall-hspu', 3, sets: 3, value: 5),
        CalLadderStep('deficit-hspu', 3, sets: 3, value: 5),
        CalLadderStep('freestanding-hspu', 4),
      ],
    ),
    CalLadder(
      id: pullVertical,
      name: 'Pull – vertical',
      steps: [
        CalLadderStep('dead-hang', 1, sets: 3, value: 40, isTimed: true),
        CalLadderStep('scapular-pull-up', 1, sets: 3, value: 10),
        CalLadderStep('negative-pull-up', 1, sets: 3, value: 5),
        CalLadderStep('band-assisted-pull-up', 2, sets: 3, value: 8),
        CalLadderStep('pull-up', 2, sets: 3, value: 10),
        CalLadderStep('weighted-pull-up', 3, sets: 3, value: 5),
        CalLadderStep(
          'archer-pull-up',
          3,
          sets: 3,
          value: 6,
          isPerSide: true,
        ),
        CalLadderStep('muscle-up', 3),
        CalLadderStep('one-arm-chin-up', 4),
      ],
    ),
    CalLadder(
      id: pullHorizontal,
      name: 'Pull – horizontal & front lever',
      steps: [
        CalLadderStep('incline-row', 1, sets: 3, value: 12),
        CalLadderStep('bent-knee-inverted-row', 1, sets: 3, value: 10),
        CalLadderStep('inverted-row', 1, sets: 3, value: 12),
        CalLadderStep('feet-elevated-row', 2, sets: 3, value: 12),
        CalLadderStep(
          'tuck-front-lever',
          2,
          sets: 3,
          value: 10,
          isTimed: true,
        ),
        CalLadderStep(
          'adv-tuck-front-lever',
          3,
          sets: 3,
          value: 10,
          isTimed: true,
        ),
        CalLadderStep('straddle-front-lever', 4),
        CalLadderStep('full-front-lever', 4),
      ],
    ),
    CalLadder(
      id: legsSquat,
      name: 'Legs – squat pattern',
      steps: [
        CalLadderStep('box-squat', 1, sets: 3, value: 15),
        CalLadderStep('bodyweight-squat', 1, sets: 3, value: 20),
        CalLadderStep(
          'reverse-lunge',
          1,
          sets: 3,
          value: 10,
          isPerSide: true,
        ),
        CalLadderStep(
          'bulgarian-split-squat',
          2,
          sets: 3,
          value: 12,
          isPerSide: true,
        ),
        CalLadderStep(
          'assisted-pistol-squat',
          2,
          sets: 3,
          value: 6,
          isPerSide: true,
        ),
        CalLadderStep(
          'pistol-squat',
          3,
          sets: 3,
          value: 6,
          isPerSide: true,
        ),
        CalLadderStep(
          'shrimp-squat',
          3,
          sets: 3,
          value: 8,
          isPerSide: true,
        ),
        CalLadderStep(
          'weighted-pistol-squat',
          4,
          sets: 3,
          value: 5,
          isPerSide: true,
        ),
      ],
    ),
    CalLadder(
      id: legsPosterior,
      name: 'Legs – posterior chain',
      steps: [
        CalLadderStep('glute-bridge', 1, sets: 3, value: 15),
        CalLadderStep(
          'single-leg-glute-bridge',
          1,
          sets: 3,
          value: 12,
          isPerSide: true,
        ),
        CalLadderStep(
          'single-leg-rdl',
          2,
          sets: 3,
          value: 10,
          isPerSide: true,
        ),
        CalLadderStep('nordic-curl-negative', 2, sets: 3, value: 5),
        CalLadderStep('nordic-curl', 3, sets: 4, value: 6),
        CalLadderStep('weighted-nordic-curl', 4, sets: 4, value: 8),
      ],
    ),
    CalLadder(
      id: core,
      name: 'Core',
      steps: [
        CalLadderStep('dead-bug', 1, sets: 3, value: 10, isPerSide: true),
        CalLadderStep('plank', 1, sets: 3, value: 40, isTimed: true),
        CalLadderStep('tuck-hollow-hold', 1, sets: 3, value: 20, isTimed: true),
        CalLadderStep('hollow-body-hold', 2, sets: 3, value: 30, isTimed: true),
        CalLadderStep('hanging-knee-raise', 2, sets: 3, value: 12),
        CalLadderStep('hanging-leg-raise', 2, sets: 3, value: 10),
        CalLadderStep('toes-to-bar', 3, sets: 3, value: 10),
        CalLadderStep('dragon-flag-negative', 3, sets: 3, value: 5),
        CalLadderStep('dragon-flag', 4, sets: 3, value: 5),
      ],
    ),
    CalLadder(
      id: lSit,
      name: 'Skill – L-sit',
      steps: [
        CalLadderStep('tuck-l-sit', 2, sets: 4, value: 20, isTimed: true),
        CalLadderStep('l-sit', 3, sets: 3, value: 20, isTimed: true),
        CalLadderStep('v-sit', 4),
      ],
    ),
    CalLadder(
      id: planche,
      name: 'Skill – planche',
      steps: [
        CalLadderStep('planche-lean', 3, sets: 3, value: 30, isTimed: true),
        CalLadderStep('tuck-planche', 3, sets: 3, value: 10, isTimed: true),
        CalLadderStep(
          'adv-tuck-planche',
          3,
          sets: 3,
          value: 8,
          isTimed: true,
        ),
        CalLadderStep('straddle-planche', 4),
        CalLadderStep('full-planche', 4),
      ],
    ),
    CalLadder(
      id: handstand,
      name: 'Skill – handstand',
      steps: [
        CalLadderStep('wall-handstand', 3, sets: 6, value: 40, isTimed: true),
        CalLadderStep('freestanding-handstand', 4),
      ],
    ),
    CalLadder(
      id: backLever,
      name: 'Skill – back lever',
      steps: [
        CalLadderStep('tuck-back-lever', 3, sets: 3, value: 12, isTimed: true),
        CalLadderStep('back-lever', 4),
      ],
    ),
    CalLadder(
      id: humanFlag,
      name: 'Skill – human flag',
      steps: [
        CalLadderStep('tuck-human-flag', 3, sets: 3, value: 8, isTimed: true),
        CalLadderStep(
          'straddle-human-flag',
          4,
          sets: 4,
          value: 6,
          isTimed: true,
          isPerSide: true,
        ),
        CalLadderStep('human-flag', 4),
      ],
    ),
  ];
}
