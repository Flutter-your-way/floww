import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/entities/onboarding_details_entity.dart';

class OnboardingAnswersException implements Exception {
  OnboardingAnswersException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OnboardingAnswersService {
  OnboardingAnswersService();

  static const String _yes = 'Yes';
  static const String _no = 'No';
  static const String _later = "I'll do it later";

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String get _requireUserId {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw OnboardingAnswersException('Please sign in again.');
    return uid;
  }

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection(AppCollection.onboardingDetails).doc(uid);

  Future<Map<String, dynamic>> loadAnswers() async {
    final uid = _requireUserId;
    try {
      final snapshot = await _doc(uid).get();
      return answersOf(snapshot.data());
    } catch (e, stackTrace) {
      debugPrint('loadAnswers failed: $e\n$stackTrace');
      throw OnboardingAnswersException('Could not load your answers.');
    }
  }

  Future<void> saveAnswers(Map<String, dynamic> answers) async {
    final uid = _requireUserId;
    final now = DateTime.now();
    try {
      final details =
          OnboardingDetailsEntity.fromAnswers(
            uid: uid,
            answers: answers,
            startedAt: now,
            updatedAt: now,
          ).toJson()..removeWhere(
            (key, _) => key == 'startedAt' || key == 'completedAt',
          );
      await _doc(uid).set(details, SetOptions(merge: true));
    } catch (e, stackTrace) {
      debugPrint('saveAnswers failed: $e\n$stackTrace');
      throw OnboardingAnswersException('Could not save your answers.');
    }
  }

  @visibleForTesting
  static Map<String, dynamic> answersOf(Map<String, dynamic>? details) {
    final answers = <String, dynamic>{};

    void put(String key, dynamic value) {
      if (value != null) answers[key] = value;
    }

    final profile = _section(details, 'profile');
    put('name', profile?['name']);
    put('dob', _date(profile?['dateOfBirth']));
    put('biological_sex', profile?['biologicalSex']);
    put('unit_system', profile?['unitSystem']);
    put('height', _number(profile?['heightCm']));
    put('weight', _number(profile?['weightKg']));

    final goals = _section(details, 'goalsActivity');
    put('primary_goal', goals?['primaryGoal']);
    put('target_weight', _number(goals?['targetWeightKg']));
    put('weighing_scale', _yesNo(goals?['hasWeighingScale']));
    put('activity_level', goals?['activityLevel']);
    put('sleep_time', _time(goals?['sleepTime']));
    put('wake_time', _time(goals?['wakeTime']));

    final diet = _section(details, 'healthDiet');
    put('health_conditions', _list(diet?['healthConditions']));
    put('preferred_diet', diet?['preferredDiet']);
    put('food_allergies', _list(diet?['foodAllergies']));
    put('dietary_restrictions', _list(diet?['dietaryRestrictions']));
    put('motivation', diet?['motivation']);

    final training = _section(details, 'trainingSetup');
    final wantsPlan = training?['wantsPersonalizedPlan'];
    put('create_plan', wantsPlan is bool ? (wantsPlan ? _yes : _later) : null);
    put('training_type', training?['trainingType']);

    final gym = _section(details, 'gymDetails');
    put('gym_experience', gym?['experienceLevel']);
    put('gym_goals', _list(gym?['goals']));
    put('gym_days', _list(gym?['trainingDays']));
    put('gym_duration', gym?['workoutDuration']);
    put('gym_equipment', gym?['equipment']);
    put('gym_split', gym?['preferredSplit']);
    put('gym_muscle_groups', _list(gym?['targetMuscleGroups']));

    final cal = _section(details, 'calisthenicsDetails');
    put('cal_experience', cal?['experienceLevel']);
    put('cal_bodyweight', _number(cal?['bodyweightKg']));
    put('cal_max_pushups', _number(cal?['maxPushups']));
    put('cal_max_pullups', _number(cal?['maxPullups']));
    put('cal_max_dips', _number(cal?['maxDips']));
    put('cal_skills', _list(cal?['currentSkills']));
    put('cal_skill_goals', _list(cal?['skillGoals']));
    put('cal_equipment', _list(cal?['equipment']));
    put('cal_days', _list(cal?['trainingDays']));
    put('cal_duration', cal?['workoutDuration']);
    put('cal_workout_time', cal?['preferredWorkoutTime']);
    put('cal_injuries', _list(cal?['injuries']));

    final yoga = _section(details, 'yogaDetails');
    put('yoga_experience', yoga?['experienceLevel']);
    put('yoga_style', yoga?['preferredStyle']);
    put('yoga_goal', yoga?['primaryGoal']);
    put('yoga_meditation', _yesNo(yoga?['wantsMeditation']));
    put('yoga_flexibility', yoga?['flexibilityLevel']);
    put('yoga_duration', yoga?['practiceDuration']);
    put('yoga_days', _list(yoga?['practiceDays']));
    put('yoga_workout_time', yoga?['preferredPracticeTime']);
    put('yoga_equipment', _list(yoga?['equipment']));
    put('yoga_injuries', _list(yoga?['injuries']));

    final targets = _section(details, 'targetsPermissions');
    put('steps_target', _number(targets?['stepsTarget']));
    put('sleep_target', _number(targets?['sleepTargetHours']));
    put('water_target', _number(targets?['waterTargetLiters']));
    put('apple_health', targets?['wearablesConnected']);
    put('referral', targets?['referralSource']);

    final flo = _section(details, 'floState');
    put('morning_energy', flo?['morningEnergy']);
    put('recovery_speed', flo?['recoverySpeed']);
    put('stress_level', flo?['stressLevel']);
    put('sleep_quality', flo?['sleepQuality']);
    put('miss_workouts', _list(flo?['missWorkoutReasons']));
    put('training_behaviour', flo?['badDayBehaviour']);
    put('wave_communication', flo?['communicationStyle']);
    put('push_intensity', flo?['pushIntensity']);

    return answers;
  }

  static Map<String, dynamic>? _section(
    Map<String, dynamic>? data,
    String key,
  ) {
    final value = data?[key];
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  static double? _number(dynamic value) =>
      value is num ? value.toDouble() : null;

  static List<String>? _list(dynamic value) =>
      value is List ? List<String>.from(value) : null;

  static String? _yesNo(dynamic value) =>
      value is bool ? (value ? _yes : _no) : null;

  static DateTime? _date(dynamic value) =>
      value is String ? DateTime.tryParse(value) : null;

  static DateTime? _time(dynamic value) {
    if (value is! String) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}
