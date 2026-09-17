import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/core/workout/models/exercise.dart';
import 'package:floww/core/workout/services/workout_catalog_data.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';

class WorkoutCatalogService extends WorkoutFirestore {
  WorkoutCatalogService();

  static const String _loadFailure = 'Could not load your exercise library.';
  static const String _saveFailure =
      'Could not save this exercise. Please try again.';

  CollectionReference<Map<String, dynamic>> _exercises(String uid) =>
      collectionOf(uid, AppCollection.workoutExercises);

  CollectionReference<Map<String, dynamic>> _programs(String uid) =>
      collectionOf(uid, AppCollection.workoutPrograms);

  Future<void> ensureSeeded() async {
    final uid = userId;
    if (uid == null) return;

    await guard('ensureSeeded', _loadFailure, () async {
      final state = await stateDoc(uid).get();
      final stored = WorkoutStateEntity.fromJson(state.data() ?? const {});
      if (stored.catalogVersion >= WorkoutCatalogData.version) return;

      final batch = firestore.batch();
      for (final exercise in WorkoutCatalogData.exercises) {
        batch.set(
          _exercises(uid).doc(exercise.id),
          exercise.toCatalogJson(),
          SetOptions(merge: true),
        );
      }
      for (final program in WorkoutCatalogData.programs) {
        batch.set(_programs(uid).doc(program.id), program.toJson());
      }
      batch.set(stateDoc(uid), {
        'catalogVersion': WorkoutCatalogData.version,
      }, SetOptions(merge: true));
      await batch.commit();
    });
  }

  Stream<List<ExerciseCatalogEntry>> watchExercises() {
    final uid = userId;
    if (uid == null) return Stream.value(const []);
    return _exercises(uid)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => parseAll(
            snapshot.docs.map((doc) => doc.data()),
            ExerciseCatalogEntry.fromJson,
          ),
        );
  }

  Future<List<ExerciseCatalogEntry>> loadExercises() async {
    final uid = userId;
    if (uid == null) return const [];
    return guard('loadExercises', _loadFailure, () async {
      final snapshot = await _exercises(uid).orderBy('name').get();
      return parseAll(
        snapshot.docs.map((doc) => doc.data()),
        ExerciseCatalogEntry.fromJson,
      );
    });
  }

  Future<ExerciseCatalogEntry?> exerciseById(String id) async {
    final uid = userId;
    if (uid == null) return null;
    return guard('exerciseById', _loadFailure, () async {
      final document = await _exercises(uid).doc(id).get();
      final data = document.data();
      return data == null ? null : ExerciseCatalogEntry.fromJson(data);
    });
  }

  Future<void> setAdded(String id, bool isAdded) async {
    final uid = requireUserId;
    await guard(
      'setAdded',
      _saveFailure,
      () => _exercises(uid).doc(id).set({
        'isAdded': isAdded,
      }, SetOptions(merge: true)),
    );
  }

  Future<void> createCustomExercise({
    required String name,
    required MuscleGroup group,
    required Equipment equipment,
  }) async {
    final uid = requireUserId;
    final document = _exercises(uid).doc();
    final exercise = ExerciseCatalogEntry(
      id: document.id,
      name: name,
      group: group,
      equipment: equipment,
      met: _metOf(group, equipment),
      muscleShares: {group.label: 1},
      defaultSets: 3,
      defaultReps: 10,
      defaultRestSeconds: 60,
      defaultRepsInReserve: 2,
      defaultWeightKg: equipment == Equipment.bodyweight ? null : 20,
      isCustom: true,
      isAdded: true,
    );
    await guard(
      'createCustomExercise',
      _saveFailure,
      () => document.set(exercise.toJson()),
    );
  }

  Stream<List<WorkoutProgramEntity>> watchPrograms() {
    final uid = userId;
    if (uid == null) return Stream.value(const []);
    return _programs(uid)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => parseAll(
            snapshot.docs.map((doc) => doc.data()),
            WorkoutProgramEntity.fromJson,
          ),
        );
  }

  Future<WorkoutProgramEntity?> programById(String id) async {
    final uid = userId;
    if (uid == null) return null;
    return guard('programById', _loadFailure, () async {
      final document = await _programs(uid).doc(id).get();
      final data = document.data();
      return data == null ? null : WorkoutProgramEntity.fromJson(data);
    });
  }

  static double _metOf(MuscleGroup group, Equipment equipment) {
    if (group == MuscleGroup.cardio) return 7;
    if (equipment == Equipment.bodyweight) return 4;
    return 5;
  }
}
