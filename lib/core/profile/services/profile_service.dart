import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/entities/measurement_system.dart';
import 'package:floww/config/entities/subscription_entity.dart';
import 'package:floww/config/utils/formatters/measurement_converter.dart';
import 'package:floww/core/profile/models/profile_account.dart';
import 'package:floww/core/profile/models/profile_edit_data.dart';

class ProfileException implements Exception {
  ProfileException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProfileService {
  ProfileService();

  static const List<ProfileChoice> _goals = [
    ProfileChoice(
      id: 'Lose Fat',
      label: 'Lose Fat',
      icon: Icons.local_fire_department_rounded,
    ),
    ProfileChoice(
      id: 'Gain Muscle',
      label: 'Gain Muscle',
      icon: Icons.fitness_center_rounded,
    ),
    ProfileChoice(
      id: 'Recomposition',
      label: 'Recomposition',
      icon: Icons.donut_small_rounded,
    ),
    ProfileChoice(
      id: 'Lifestyle',
      label: 'Lifestyle',
      icon: Icons.favorite_rounded,
    ),
    ProfileChoice(
      id: 'Maintain',
      label: 'Maintain',
      icon: Icons.check_circle_rounded,
    ),
  ];

  static const List<ProfileChoice> _diets = [
    ProfileChoice(id: 'Flexible', label: 'Flexible'),
    ProfileChoice(id: 'Vegetarian', label: 'Vegetarian'),
    ProfileChoice(id: 'Vegan', label: 'Vegan'),
    ProfileChoice(id: 'Eggetarian', label: 'Eggetarian'),
    ProfileChoice(id: 'Non-Vegetarian', label: 'Non-Vegetarian'),
  ];

  static const List<ProfileChoice> _experiences = [
    ProfileChoice(id: 'Beginner', label: 'Beginner'),
    ProfileChoice(id: 'Intermediate', label: 'Intermediate'),
    ProfileChoice(id: 'Advanced', label: 'Advanced'),
  ];

  static const double stepsMin = 2000;
  static const double stepsMax = 25000;
  static const double stepsStep = 500;
  static const double sleepMin = 4;
  static const double sleepMax = 12;
  static const double sleepStep = 0.5;
  static const double waterMin = 1;
  static const double waterMax = 8;
  static const double waterStep = 0.5;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String? get userId {
    try {
      return _auth.currentUser?.uid;
    } catch (e) {
      debugPrint('Firebase unavailable, skipping profile: $e');
      return null;
    }
  }

  String get _requireUserId {
    final uid = userId;
    if (uid == null) throw ProfileException('Please sign in again.');
    return uid;
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(AppCollection.users).doc(uid);

  DocumentReference<Map<String, dynamic>> _onboardingDoc(String uid) =>
      _firestore.collection(AppCollection.onboardingDetails).doc(uid);

  List<ProfileChoice> goals() => _goals;

  List<ProfileChoice> diets() => _diets;

  List<ProfileChoice> experiences() => _experiences;

  Stream<ProfileAccount> watchAccount() {
    final uid = userId;
    if (uid == null) return Stream.value(ProfileAccount.empty);

    return combineAccount(
      user: _userDoc(uid).snapshots().map((doc) => doc.data()),
      onboarding: _onboardingDoc(uid).snapshots().map((doc) => doc.data()),
    );
  }

  Future<ProfileAccount> loadAccount() async {
    final uid = userId;
    if (uid == null) return ProfileAccount.empty;

    try {
      final documents = await Future.wait([
        _userDoc(uid).get(),
        _onboardingDoc(uid).get(),
      ]);

      return accountOf(documents[0].data(), documents[1].data());
    } catch (e, stackTrace) {
      debugPrint('loadAccount failed: $e\n$stackTrace');
      throw ProfileException('Could not load your profile.');
    }
  }

  Future<void> savePersonalInformation(PersonalInformationDraft draft) async {
    final uid = _requireUserId;
    final now = DateTime.now();
    final heightCm = draft.heightUnit == HeightUnit.cm
        ? draft.heightValue
        : MeasurementConverter.inchesToCm(draft.heightValue);
    final weightKg = draft.weightUnit == WeightUnit.kg
        ? draft.weightValue
        : MeasurementConverter.lbsToKg(draft.weightValue);

    await _write('savePersonalInformation', 'Could not save your profile.', () {
      final batch = _firestore.batch();

      batch.set(_onboardingDoc(uid), {
        'uid': uid,
        'profile': {
          'name': draft.name,
          'heightCm': heightCm,
          'weightKg': weightKg,
          'unitSystem': draft.unitSystem.label,
        },
        'goalsActivity': {'primaryGoal': draft.goalId},
        'healthDiet': {'preferredDiet': draft.dietId},
        'trainingSetup': {'experienceLevel': draft.experienceId},
        'updatedAt': now.toIso8601String(),
      }, SetOptions(merge: true));

      batch.set(_userDoc(uid), {
        'displayName': draft.name,
        'updatedAt': now.toIso8601String(),
      }, SetOptions(merge: true));

      return batch.commit();
    });
  }

  Future<void> saveDailyTargets(DailyTargetsDraft draft) async {
    final uid = _requireUserId;
    final now = DateTime.now();

    await _write('saveDailyTargets', 'Could not save your targets.', () {
      return _onboardingDoc(uid).set({
        'uid': uid,
        'targetsPermissions': {
          'stepsTarget': draft.valueOf(DailyTarget.steps),
          'sleepTargetHours': draft.valueOf(DailyTarget.sleep),
          'waterTargetLiters': draft.valueOf(DailyTarget.water),
        },
        'updatedAt': now.toIso8601String(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> saveMeasurementSystem(MeasurementSystem system) async {
    final uid = _requireUserId;
    final now = DateTime.now();

    await _write('saveMeasurementSystem', 'Could not save your units.', () {
      return _onboardingDoc(uid).set({
        'uid': uid,
        'profile': {'unitSystem': system.label},
        'updatedAt': now.toIso8601String(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> _write(
    String operation,
    String failureMessage,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on ProfileException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('$operation failed: $e\n$stackTrace');
      throw ProfileException(failureMessage);
    }
  }

  @visibleForTesting
  static ProfileAccount accountOf(
    Map<String, dynamic>? user,
    Map<String, dynamic>? onboarding,
  ) {
    final profile = _section(onboarding, 'profile');
    final goalsActivity = _section(onboarding, 'goalsActivity');
    final healthDiet = _section(onboarding, 'healthDiet');
    final trainingSetup = _section(onboarding, 'trainingSetup');
    final targets = _section(onboarding, 'targetsPermissions');
    final trainingType = _string(trainingSetup, 'trainingType');

    return ProfileAccount(
      name: _string(profile, 'name') ?? _string(user, 'displayName'),
      email: _string(user, 'email'),
      avatarUrl: _string(user, 'avatarUrl'),
      heightCm: _number(profile, 'heightCm'),
      weightKg: _number(profile, 'weightKg'),
      dateOfBirth: _dateTime(profile, 'dateOfBirth'),
      biologicalSex: _string(profile, 'biologicalSex'),
      activityLevel: _string(goalsActivity, 'activityLevel'),
      targetWeightKg: _number(goalsActivity, 'targetWeightKg'),
      unitSystem: MeasurementSystem.fromLabel(_string(profile, 'unitSystem')),
      goal: _string(goalsActivity, 'primaryGoal'),
      diet: _string(healthDiet, 'preferredDiet'),
      experience:
          _string(trainingSetup, 'experienceLevel') ??
          _specialisedExperience(onboarding, trainingType),
      trainingType: trainingType,
      trainingDaysPerWeek: _trainingDaysOf(onboarding, trainingType),
      stepsTarget: _number(targets, 'stepsTarget'),
      sleepTargetHours: _number(targets, 'sleepTargetHours'),
      waterTargetLiters: _number(targets, 'waterTargetLiters'),
      memberSince: _dateTime(user, 'createdAt'),
      subscription: _subscriptionOf(user),
    );
  }

  @visibleForTesting
  static Stream<ProfileAccount> combineAccount({
    required Stream<Map<String, dynamic>?> user,
    required Stream<Map<String, dynamic>?> onboarding,
  }) {
    late final StreamController<ProfileAccount> controller;
    final subscriptions = <StreamSubscription<Map<String, dynamic>?>>[];
    final pending = [true, true];
    final latest = <Map<String, dynamic>?>[null, null];

    void emit() {
      if (pending.contains(true)) return;
      controller.add(accountOf(latest[0], latest[1]));
    }

    void attach(Stream<Map<String, dynamic>?> stream, int index) {
      subscriptions.add(
        stream.listen((data) {
          latest[index] = data;
          pending[index] = false;
          emit();
        }, onError: controller.addError),
      );
    }

    controller = StreamController<ProfileAccount>(
      onListen: () {
        attach(user, 0);
        attach(onboarding, 1);
      },
      onCancel: () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
        subscriptions.clear();
      },
    );

    return controller.stream;
  }

  static String? _specialisedExperience(
    Map<String, dynamic>? onboarding,
    String? trainingType,
  ) {
    final section = switch (trainingType) {
      'Gym' => 'gymDetails',
      'Calisthenics' => 'calisthenicsDetails',
      'Yoga' => 'yogaDetails',
      _ => null,
    };
    if (section == null) return null;
    return _string(_section(onboarding, section), 'experienceLevel');
  }

  static int? _trainingDaysOf(
    Map<String, dynamic>? onboarding,
    String? trainingType,
  ) {
    final section = switch (trainingType) {
      'Gym' => _section(onboarding, 'gymDetails'),
      'Calisthenics' => _section(onboarding, 'calisthenicsDetails'),
      'Yoga' => _section(onboarding, 'yogaDetails'),
      _ => null,
    };
    if (section == null) return null;
    final days = section['trainingDays'] ?? section['practiceDays'];
    return days is List && days.isNotEmpty ? days.length : null;
  }

  static SubscriptionEntity? _subscriptionOf(Map<String, dynamic>? user) {
    if (!SubscriptionEntity.isStoredOn(user)) return null;
    try {
      return SubscriptionEntity.fromUser(_string(user, 'uid') ?? '', user!);
    } catch (e) {
      debugPrint('Skipped unreadable subscription: $e');
      return null;
    }
  }

  static Map<String, dynamic>? _section(
    Map<String, dynamic>? data,
    String key,
  ) {
    final value = data?[key];
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  static String? _string(Map<String, dynamic>? data, String key) {
    final value = data?[key];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }

  static double? _number(Map<String, dynamic>? data, String key) {
    final value = data?[key];
    return value is num ? value.toDouble() : null;
  }

  static DateTime? _dateTime(Map<String, dynamic>? data, String key) {
    final value = _string(data, key);
    return value == null ? null : DateTime.tryParse(value);
  }
}
