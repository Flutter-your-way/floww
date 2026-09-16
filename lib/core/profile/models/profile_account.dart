import 'package:floww/config/entities/measurement_system.dart';
import 'package:floww/config/entities/subscription_entity.dart';

class ProfileAccount {
  const ProfileAccount({
    this.name,
    this.email,
    this.avatarUrl,
    this.heightCm,
    this.weightKg,
    this.unitSystem = MeasurementSystem.metric,
    this.goal,
    this.diet,
    this.experience,
    this.trainingType,
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
  final MeasurementSystem unitSystem;
  final String? goal;
  final String? diet;
  final String? experience;
  final String? trainingType;
  final double? stepsTarget;
  final double? sleepTargetHours;
  final double? waterTargetLiters;
  final DateTime? memberSince;
  final SubscriptionEntity? subscription;

  bool get isPremium => subscription?.isActive ?? false;

  ProfileAccount copyWith({SubscriptionEntity? subscription}) => ProfileAccount(
    name: name,
    email: email,
    avatarUrl: avatarUrl,
    heightCm: heightCm,
    weightKg: weightKg,
    unitSystem: unitSystem,
    goal: goal,
    diet: diet,
    experience: experience,
    trainingType: trainingType,
    stepsTarget: stepsTarget,
    sleepTargetHours: sleepTargetHours,
    waterTargetLiters: waterTargetLiters,
    memberSince: memberSince,
    subscription: subscription ?? this.subscription,
  );
}
