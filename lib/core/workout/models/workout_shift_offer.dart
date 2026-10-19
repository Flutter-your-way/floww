import 'package:floww/config/entities/workout_plan_entity.dart';

enum WorkoutShiftKind { restore, catchUp, postpone }

class WorkoutShiftOffer {
  const WorkoutShiftOffer({required this.kind, required this.plan});

  final WorkoutShiftKind kind;
  final WorkoutPlanEntity plan;

  String get title => switch (kind) {
    WorkoutShiftKind.restore => '${plan.name} moved to tomorrow',
    WorkoutShiftKind.catchUp => 'Missed ${plan.name} yesterday',
    WorkoutShiftKind.postpone => 'Not feeling today?',
  };

  String get message => switch (kind) {
    WorkoutShiftKind.restore =>
      'Changed your mind? Bring ${plan.name} back to today and the rest of '
          'your program moves back with it.',
    WorkoutShiftKind.catchUp =>
      'Do ${plan.name} today instead. Anything already planned for today '
          'stays put, and both show up in your history.',
    WorkoutShiftKind.postpone =>
      'Move today\'s session to tomorrow. Every later session shifts by a day '
          'so your program stays in order.',
  };

  String get actionLabel => switch (kind) {
    WorkoutShiftKind.restore => 'Bring it back to today',
    WorkoutShiftKind.catchUp => 'Add to today',
    WorkoutShiftKind.postpone => 'Move to tomorrow',
  };
}
