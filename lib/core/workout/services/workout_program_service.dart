import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';

class WorkoutProgramService extends WorkoutFirestore {
  WorkoutProgramService();

  static const String _stateFailure = 'Could not load your training plan.';

  Stream<WorkoutStateEntity> watchState() {
    final uid = userId;
    if (uid == null) return Stream.value(WorkoutStateEntity.empty);
    return stateDoc(uid).snapshots().map(
      (document) => WorkoutStateEntity.fromJson(document.data() ?? const {}),
    );
  }

  Future<WorkoutStateEntity> loadState() async {
    final uid = userId;
    if (uid == null) return WorkoutStateEntity.empty;
    return guard('loadState', _stateFailure, () async {
      final document = await stateDoc(uid).get();
      return WorkoutStateEntity.fromJson(document.data() ?? const {});
    });
  }

  ActiveProgramEntry activeEntryFor(
    WorkoutProgramEntity program, {
    DateTime? startDate,
    int? weeks,
    List<int> weekdays = const [],
  }) {
    final isFixed = program.hasFixedLength;
    return ActiveProgramEntry(
      id: program.id,
      name: program.name,
      level: program.level,
      startedAt: startDate ?? DateTime.now(),
      totalWeeks: isFixed
          ? (program.lengthDays / DateTime.daysPerWeek).ceil()
          : weeks ?? program.weeks,
      daysPerWeek: program.sessionsPerWeek,
      weekdays: weekdays,
      totalDays: isFixed ? program.lengthDays : 0,
    );
  }
}
