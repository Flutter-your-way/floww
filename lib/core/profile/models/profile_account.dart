import 'package:floww/config/entities/measurement_system.dart';
import 'package:floww/config/entities/subscription_entity.dart';

class ProfileAccount {
  const ProfileAccount({
    this.name,
    this.email,
    this.avatarUrl,
    this.heightCm,
    this.weightKg,
    this.dateOfBirth,
    this.biologicalSex,
    this.activityLevel,
    this.targetWeightKg,
    this.unitSystem = MeasurementSystem.metric,
    this.goal,
    this.diet,
    this.experience,
    this.trainingType,
    this.trainingDaysPerWeek,
    this.stepsTarget,
    this.sleepTargetHours,
    this.waterTargetLiters,
    this.memberSince,
    this.subscription,
  });

  static const empty = ProfileAccount();

  final String? name;
  final String? email;
  final String? avatarUrl;
  final double? heightCm;
  final double? weightKg;
  final DateTime? dateOfBirth;
  final String? biologicalSex;
  final String? activityLevel;
  final double? targetWeightKg;
  final MeasurementSystem unitSystem;
  final String? goal;
  final String? diet;
  final String? experience;
  final String? trainingType;
  final int? trainingDaysPerWeek;
  final double? stepsTarget;
  final double? sleepTargetHours;
  final double? waterTargetLiters;
  final DateTime? memberSince;
  final SubscriptionEntity? subscription;

  bool get isPremium => subscription?.isActive ?? false;

  int? get ageYears {
    final birth = dateOfBirth;
    if (birth == null) return null;
    final now = DateTime.now();
    var age = now.year - birth.year;
    final hadBirthday =
        now.month > birth.month ||
        (now.month == birth.month && now.day >= birth.day);
    if (!hadBirthday) age -= 1;
    return age > 0 && age < 120 ? age : null;
  }

  ProfileAccount copyWith({SubscriptionEntity? subscription}) => ProfileAccount(
    name: name,
    email: email,
    avatarUrl: avatarUrl,
    heightCm: heightCm,
    weightKg: weightKg,
    dateOfBirth: dateOfBirth,
    biologicalSex: biologicalSex,
    activityLevel: activityLevel,
    targetWeightKg: targetWeightKg,
    unitSystem: unitSystem,
    goal: goal,
    diet: diet,
    experience: experience,
    trainingType: trainingType,
    trainingDaysPerWeek: trainingDaysPerWeek,
    stepsTarget: stepsTarget,
    sleepTargetHours: sleepTargetHours,
    waterTargetLiters: waterTargetLiters,
    memberSince: memberSince,
    subscription: subscription ?? this.subscription,
  );
}
