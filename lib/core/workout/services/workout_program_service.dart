import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/streams/combine_latest.dart';
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

  Stream<Set<String>> watchRestDays(DateTime from, DateTime to) {
    final uid = userId;
    if (uid == null) return Stream.value(const {});
    final start = AppDateUtils.dateOnly(from);
    final end = AppDateUtils.dateOnly(to);
    final plans = collectionOf(uid, AppCollection.workoutPlans)
        .orderBy(FieldPath.documentId)
        .startAt([AppDateUtils.dateKey(start)])
        .snapshots();
    return combineLatest([plans, stateDoc(uid).snapshots()]).map((values) {
      final planned = {
        for (final doc
            in (values[0]! as QuerySnapshot<Map<String, dynamic>>).docs)
          doc.id,
      };
      final state = values[1]! as DocumentSnapshot<Map<String, dynamic>>;
      final program = WorkoutStateEntity.fromJson(
        state.data() ?? const {},
      ).activeProgram;
      return restDaysOf(program, planned, start, end);
    });
  }

  static Set<String> restDaysOf(
    ActiveProgramEntry? program,
    Set<String> plannedDays,
    DateTime from,
    DateTime to,
  ) {
    final lastPlanned = plannedDays.isEmpty
        ? null
        : plannedDays.reduce((a, b) => a.compareTo(b) >= 0 ? a : b);
    if (program == null || lastPlanned == null) return const {};
    return {
      for (
        var date = AppDateUtils.dateOnly(from);
        !date.isAfter(to);
        date = AppDateUtils.addDays(date, 1)
      )
        if (!plannedDays.contains(AppDateUtils.dateKey(date)) &&
            AppDateUtils.dateKey(date).compareTo(lastPlanned) < 0 &&
            program.isActiveOn(date))
          AppDateUtils.dateKey(date),
    };
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
