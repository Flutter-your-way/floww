import 'package:flutter/material.dart';

import 'package:floww/config/entities/measurement_system.dart';

enum HeightUnit { cm, inches }

enum WeightUnit { kg, lbs }

enum DailyTarget { steps, sleep, water }

class ProfileChoice {
  const ProfileChoice({required this.id, required this.label, this.icon});

  final String id;
  final String label;
  final IconData? icon;
}

class ProfileChoiceGroup {
  const ProfileChoiceGroup({
    required this.title,
    required this.choices,
    required this.selectedId,
  });

  final String title;
  final List<ProfileChoice> choices;
  final String selectedId;
}

class PersonalInformationDraft {
  const PersonalInformationDraft({
    required this.name,
    required this.height,
    required this.heightUnit,
    required this.weight,
    required this.weightUnit,
    required this.goalId,
    required this.dietId,
    required this.experienceId,
  });

  final String name;
  final String height;
  final HeightUnit heightUnit;
  final String weight;
  final WeightUnit weightUnit;
  final String goalId;
  final String dietId;
  final String experienceId;

  double get heightValue => double.tryParse(height.trim()) ?? 0;

  double get weightValue => double.tryParse(weight.trim()) ?? 0;

  MeasurementSystem get unitSystem =>
      heightUnit == HeightUnit.cm && weightUnit == WeightUnit.kg
      ? MeasurementSystem.metric
      : MeasurementSystem.imperial;

  @override
  bool operator ==(Object other) =>
      other is PersonalInformationDraft &&
      other.name == name &&
      other.height == height &&
      other.heightUnit == heightUnit &&
      other.weight == weight &&
      other.weightUnit == weightUnit &&
      other.goalId == goalId &&
      other.dietId == dietId &&
      other.experienceId == experienceId;

  @override
  int get hashCode => Object.hash(
    name,
    height,
    heightUnit,
    weight,
    weightUnit,
    goalId,
    dietId,
    experienceId,
  );
}

class DailyTargetSpec {
  const DailyTargetSpec({
    required this.target,
    required this.title,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
  });

  final DailyTarget target;
  final String title;
  final String unit;
  final double value;
  final double min;
  final double max;
  final double step;

  int get divisions => ((max - min) / step).round();

  DailyTargetSpec copyWith({double? value}) => DailyTargetSpec(
    target: target,
    title: title,
    unit: unit,
    value: value ?? this.value,
    min: min,
    max: max,
    step: step,
  );
}

class DailyTargetsDraft {
  const DailyTargetsDraft({required this.specs});

  final List<DailyTargetSpec> specs;

  double valueOf(DailyTarget target) =>
      specs.firstWhere((spec) => spec.target == target).value;
}
