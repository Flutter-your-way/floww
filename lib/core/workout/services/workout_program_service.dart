import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';

class WorkoutProgramService extends WorkoutFirestore {
  WorkoutProgramService();

  static const String _stateFailure = 'Could not load your training plan.';
  static const String _startFailure =
      'Could not start this program. Please try again.';

  Stream<WorkoutStateEntity> watchState() {
    final uid = userId;
    if (uid == null) return Stream.value(WorkoutStateEntity.empty);
    return stateDoc(uid).snapshots().map(
      (document) =>
          WorkoutStateEntity.fromJson(document.data() ?? const {}),
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

  Future<ActiveProgramEntry> startProgram(WorkoutProgramEntity program) async {
    final uid = requireUserId;
    final active = ActiveProgramEntry(
      id: program.id,
      name: program.name,
      level: program.level,
      startedAt: DateTime.now(),
      totalWeeks: program.weeks,
      daysPerWeek: program.sessionsPerWeek,
    );
    await guard(
      'startProgram',
      _startFailure,
      () => stateDoc(uid).set({
        'activeProgram': active.toJson(),
      }, SetOptions(merge: true)),
    );
    return active;
  }

  Future<void> stopProgram() async {
    final uid = requireUserId;
    await guard(
      'stopProgram',
      _startFailure,
      () => stateDoc(uid).set({
        'activeProgram': null,
      }, SetOptions(merge: true)),
    );
  }
}
