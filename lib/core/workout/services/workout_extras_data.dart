import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/core/calisthenics/data/calisthenics_gates_data.dart';
import 'package:floww/core/workout/models/program_goal.dart';
import 'package:floww/core/workout/models/workout_section_kind.dart';

class SkillRequirement {
  const SkillRequirement({
    required this.testId,
    required this.minimum,
    required this.label,
  });

  final String testId;
  final int minimum;
  final String label;
}

class WorkoutExtrasData {
  WorkoutExtrasData._();

  static const String challengePrefix = 'challenge-';
  static const String firstPullUpId = 'skill-first-pull-up';
  static const String muscleUpId = 'skill-muscle-up';
  static const String frontLeverId = 'skill-front-lever';

  static const Map<String, List<SkillRequirement>> requirements = {
    firstPullUpId: [],
    muscleUpId: [
      SkillRequirement(
        testId: CalisthenicsGatesData.pullUps,
        minimum: 8,
        label: 'strict pull-ups',
      ),
      SkillRequirement(
        testId: CalisthenicsGatesData.dips,
        minimum: 8,
        label: 'parallel-bar dips',
      ),
    ],
    frontLeverId: [
      SkillRequirement(
        testId: CalisthenicsGatesData.pullUps,
        minimum: 5,
        label: 'strict pull-ups',
      ),
      SkillRequirement(
        testId: CalisthenicsGatesData.hollow,
        minimum: 30,
        label: 'seconds of hollow hold',
      ),
    ],
  };

  static const List<int> _stageWeekdays = [
    DateTime.monday,
    DateTime.wednesday,
    DateTime.friday,
  ];

  static ProgramExerciseEntry _prep(String id) =>
      ProgramExerciseEntry(exerciseId: id, section: WorkoutSectionKind.warmUp);

  static ProgramExerciseEntry _cool(String id) => ProgramExerciseEntry(
    exerciseId: id,
    section: WorkoutSectionKind.coolDown,
  );

  static ProgramExerciseEntry _main(
    String id, {
    int? sets,
    int? reps,
    int? rest,
  }) => ProgramExerciseEntry(
    exerciseId: id,
    section: WorkoutSectionKind.main,
    sets: sets,
    reps: reps,
    restSeconds: rest,
  );

  static ProgramDayEntry _stage(
    int index, {
    required String name,
    required String focus,
    required String goal,
    required int minutes,
    required List<ProgramExerciseEntry> exercises,
  }) => ProgramDayEntry(
    weekday: _stageWeekdays[index % _stageWeekdays.length],
    name: name,
    focus: focus,
    goal: goal,
    durationMinutes: minutes,
    exercises: exercises,
  );

  static WorkoutProgramEntity _skill({
    required String id,
    required String name,
    required String description,
    required String level,
    required int weeks,
    required List<ProgramDayEntry> days,
  }) => WorkoutProgramEntity(
    id: id,
    name: name,
    description: description,
    level: level,
    weeks: weeks,
    days: days,
    goal: ProgramGoal.home,
    kind: ProgramKind.skill,
  );

  static WorkoutProgramEntity _challenge({
    required String id,
    required String name,
    required String description,
    required String focus,
    required String goal,
    required int minutes,
    required ProgramGoal programGoal,
    required List<ProgramExerciseEntry> exercises,
  }) => WorkoutProgramEntity(
    id: id,
    name: name,
    description: description,
    level: ProgramLevel.allLevels.label,
    weeks: 1,
    goal: programGoal,
    kind: ProgramKind.challenge,
    days: [
      ProgramDayEntry(
        weekday: DateTime.monday,
        name: name,
        focus: focus,
        goal: goal,
        durationMinutes: minutes,
        exercises: exercises,
      ),
    ],
  );

  static final List<WorkoutProgramEntity> skills = [
    _skill(
      id: firstPullUpId,
      name: 'Your First Pull-up',
      description:
          'Three stages from a dead hang to one clean strict pull-up. Stay '
          'on a stage until every set feels controlled, then move on.',
      level: ProgramLevel.beginner.label,
      weeks: 6,
      days: [
        _stage(
          0,
          name: 'Stage 1 · Hang & Scap',
          focus: 'Grip and shoulder control',
          goal: 'Hold the bar for 30 seconds without shrugging.',
          minutes: 25,
          exercises: [
            _prep('shoulder-cars'),
            _main('dead-hang', sets: 3, reps: 30, rest: 60),
            _main('scapular-pull-up', sets: 3, reps: 8, rest: 60),
            _main('incline-row', sets: 3, reps: 10, rest: 75),
            _main('hollow-body-hold', sets: 3, reps: 20, rest: 45),
            _cool('doorway-chest-stretch'),
          ],
        ),
        _stage(
          1,
          name: 'Stage 2 · Negatives',
          focus: 'Lowering strength',
          goal: 'Lower for a slow 5 seconds on every negative.',
          minutes: 30,
          exercises: [
            _prep('shoulder-cars'),
            _main('scapular-pull-up', sets: 2, reps: 8, rest: 45),
            _main('negative-pull-up', sets: 4, reps: 4, rest: 90),
            _main('bent-knee-inverted-row', sets: 3, reps: 10, rest: 75),
            _main('dead-hang', sets: 2, reps: 40, rest: 60),
            _cool('doorway-chest-stretch'),
          ],
        ),
        _stage(
          2,
          name: 'Stage 3 · Assisted to Strict',
          focus: 'Full pull-up pattern',
          goal: 'Finish with one strict pull-up attempt while fresh.',
          minutes: 30,
          exercises: [
            _prep('shoulder-cars'),
            _main('pull-up', sets: 3, reps: 1, rest: 120),
            _main('band-assisted-pull-up', sets: 3, reps: 6, rest: 90),
            _main('negative-pull-up', sets: 2, reps: 3, rest: 90),
            _main('inverted-row', sets: 3, reps: 8, rest: 75),
            _cool('doorway-chest-stretch'),
          ],
        ),
      ],
    ),
    _skill(
      id: muscleUpId,
      name: 'Muscle-up',
      description:
          'Build the high pull, the transition and the dip that make up a '
          'strict bar muscle-up. Needs a solid pull-up and dip base first.',
      level: ProgramLevel.advanced.label,
      weeks: 8,
      days: [
        _stage(
          0,
          name: 'Stage 1 · Pull High',
          focus: 'Explosive pulling',
          goal: 'Pull the bar to your chest, not your chin.',
          minutes: 40,
          exercises: [
            _prep('shoulder-cars'),
            _main('scapular-pull-up', sets: 2, reps: 8, rest: 45),
            _main('wide-grip-pull-up', sets: 4, reps: 5, rest: 120),
            _main('pull-up', sets: 3, reps: 6, rest: 120),
            _main('parallel-bar-dip', sets: 3, reps: 8, rest: 90),
            _main('hanging-knee-raise', sets: 3, reps: 10, rest: 60),
            _cool('doorway-chest-stretch'),
          ],
        ),
        _stage(
          1,
          name: 'Stage 2 · Transition',
          focus: 'Turning over the bar',
          goal: 'Own the deepest part of the dip and the top of the pull.',
          minutes: 40,
          exercises: [
            _prep('shoulder-cars'),
            _main('archer-pull-up', sets: 3, reps: 4, rest: 120),
            _main('dip-negative', sets: 4, reps: 4, rest: 90),
            _main('ring-support-hold', sets: 3, reps: 20, rest: 60),
            _main('pull-up', sets: 3, reps: 6, rest: 120),
            _main('toes-to-bar', sets: 3, reps: 6, rest: 75),
            _cool('doorway-chest-stretch'),
          ],
        ),
        _stage(
          2,
          name: 'Stage 3 · Full Attempts',
          focus: 'Muscle-up practice',
          goal: 'Low reps, full rest. Stop when the pull slows down.',
          minutes: 45,
          exercises: [
            _prep('shoulder-cars'),
            _main('muscle-up', sets: 5, reps: 1, rest: 180),
            _main('wide-grip-pull-up', sets: 3, reps: 5, rest: 120),
            _main('parallel-bar-dip', sets: 3, reps: 10, rest: 90),
            _main('hollow-body-hold', sets: 3, reps: 30, rest: 45),
            _cool('doorway-chest-stretch'),
          ],
        ),
      ],
    ),
    _skill(
      id: frontLeverId,
      name: 'Front Lever',
      description:
          'Progress from tuck to advanced tuck to straddle holds, with the '
          'rows and core work that keep the body line straight.',
      level: ProgramLevel.intermediate.label,
      weeks: 8,
      days: [
        _stage(
          0,
          name: 'Stage 1 · Tuck',
          focus: 'Straight-arm pulling',
          goal: 'Hold a tuck lever for 10 seconds with a flat back.',
          minutes: 35,
          exercises: [
            _prep('shoulder-cars'),
            _main('tuck-front-lever', sets: 4, reps: 8, rest: 90),
            _main('feet-elevated-row', sets: 3, reps: 10, rest: 90),
            _main('hollow-body-hold', sets: 3, reps: 30, rest: 45),
            _main('hanging-knee-raise', sets: 3, reps: 10, rest: 60),
            _cool('doorway-chest-stretch'),
          ],
        ),
        _stage(
          1,
          name: 'Stage 2 · Advanced Tuck',
          focus: 'Opening the hips',
          goal: 'Hips level with shoulders on every hold.',
          minutes: 40,
          exercises: [
            _prep('shoulder-cars'),
            _main('adv-tuck-front-lever', sets: 4, reps: 8, rest: 120),
            _main('front-lever-raise', sets: 3, reps: 5, rest: 120),
            _main('pull-up', sets: 3, reps: 6, rest: 120),
            _main('dragon-flag-negative', sets: 3, reps: 4, rest: 90),
            _cool('doorway-chest-stretch'),
          ],
        ),
        _stage(
          2,
          name: 'Stage 3 · Straddle',
          focus: 'Long-lever holds',
          goal: 'Short, clean straddle holds. Quality over time.',
          minutes: 40,
          exercises: [
            _prep('shoulder-cars'),
            _main('straddle-front-lever', sets: 5, reps: 5, rest: 150),
            _main('front-lever-row', sets: 3, reps: 5, rest: 120),
            _main('adv-tuck-front-lever', sets: 2, reps: 10, rest: 90),
            _main('toes-to-bar', sets: 3, reps: 8, rest: 75),
            _cool('doorway-chest-stretch'),
          ],
        ),
      ],
    ),
  ];

  static final List<WorkoutProgramEntity> challenges = [
    _challenge(
      id: 'challenge-office-20',
      name: 'Quick 20-min Office Workout',
      description:
          'No kit, no changing room. A full-body circuit you can do next to '
          'your desk.',
      focus: 'Full body',
      goal: 'Keep moving; rest only as long as you need.',
      minutes: 20,
      programGoal: ProgramGoal.home,
      exercises: [
        _prep('jumping-jacks'),
        _main('bodyweight-squat', sets: 3, reps: 15, rest: 30),
        _main('push-up', sets: 3, reps: 10, rest: 30),
        _main('glute-bridge', sets: 3, reps: 15, rest: 30),
        _main('plank', sets: 3, reps: 30, rest: 30),
        _cool('hip-flexor-stretch'),
      ],
    ),
    _challenge(
      id: 'challenge-core-10',
      name: '10-min Core Burner',
      description: 'Four core moves, back to back. Short, sharp and done.',
      focus: 'Core',
      goal: 'Brace on every rep and keep your lower back down.',
      minutes: 10,
      programGoal: ProgramGoal.home,
      exercises: [
        _main('dead-bug', sets: 2, reps: 12, rest: 20),
        _main('plank', sets: 2, reps: 40, rest: 20),
        _main('side-plank', sets: 2, reps: 25, rest: 20),
        _main('mountain-climber', sets: 2, reps: 30, rest: 20),
      ],
    ),
    _challenge(
      id: 'challenge-hiit-15',
      name: '15-min HIIT Sprint',
      description:
          'Work hard, rest briefly, repeat. A quick conditioning hit for '
          'busy days.',
      focus: 'Conditioning',
      goal: 'Hold the same pace from the first round to the last.',
      minutes: 15,
      programGoal: ProgramGoal.cardio,
      exercises: [
        _prep('jumping-jacks'),
        _main('burpee', sets: 4, reps: 8, rest: 30),
        _main('mountain-climber', sets: 4, reps: 30, rest: 30),
        _main('bodyweight-squat', sets: 4, reps: 20, rest: 30),
        _cool('hamstring-stretch'),
      ],
    ),
    _challenge(
      id: 'challenge-desk-reset-15',
      name: '15-min Desk Reset',
      description:
          'Undo a day of sitting: hips, hamstrings, shoulders and spine.',
      focus: 'Mobility',
      goal: 'Breathe slowly and ease into each position.',
      minutes: 15,
      programGoal: ProgramGoal.mobility,
      exercises: [
        _main('shoulder-cars', sets: 2, reps: 8, rest: 15),
        _main('worlds-greatest-stretch', sets: 2, reps: 6, rest: 15),
        _main('hip-flexor-stretch', sets: 2, reps: 40, rest: 15),
        _main('hamstring-stretch', sets: 2, reps: 40, rest: 15),
        _main('downward-dog', sets: 2, reps: 45, rest: 15),
      ],
    ),
    _challenge(
      id: 'challenge-push-squat-100',
      name: '100-Rep Push & Squat',
      description:
          '50 push-ups and 50 squats, split into five rounds. Simple to '
          'count, hard to finish.',
      focus: 'Strength endurance',
      goal: 'Finish all five rounds with clean reps.',
      minutes: 15,
      programGoal: ProgramGoal.home,
      exercises: [
        _prep('jumping-jacks'),
        _main('push-up', sets: 5, reps: 10, rest: 45),
        _main('bodyweight-squat', sets: 5, reps: 10, rest: 45),
        _cool('hip-flexor-stretch'),
      ],
    ),
  ];
}
