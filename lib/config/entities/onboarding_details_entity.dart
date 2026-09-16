String _hhmm(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

List<String> _stringList(dynamic value) =>
    value == null ? const [] : List<String>.from(value as List);

class OnboardingProfileDetails {
  const OnboardingProfileDetails({
    required this.name,
    required this.dateOfBirth,
    required this.biologicalSex,
    required this.unitSystem,
    required this.heightCm,
    required this.weightKg,
  });

  final String name;
  final DateTime dateOfBirth;
  final String biologicalSex;
  final String unitSystem;
  final double heightCm;
  final double weightKg;

  factory OnboardingProfileDetails.fromJson(Map<String, dynamic> json) =>
      OnboardingProfileDetails(
        name: json['name'] as String,
        dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
        biologicalSex: json['biologicalSex'] as String,
        unitSystem: json['unitSystem'] as String,
        heightCm: (json['heightCm'] as num).toDouble(),
        weightKg: (json['weightKg'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'dateOfBirth': dateOfBirth.toIso8601String(),
    'biologicalSex': biologicalSex,
    'unitSystem': unitSystem,
    'heightCm': heightCm,
    'weightKg': weightKg,
  };
}

class OnboardingGoalsActivityDetails {
  const OnboardingGoalsActivityDetails({
    required this.primaryGoal,
    required this.targetWeightKg,
    required this.hasWeighingScale,
    required this.activityLevel,
    required this.sleepTime,
    required this.wakeTime,
  });

  final String primaryGoal;
  final double targetWeightKg;
  final bool hasWeighingScale;
  final String activityLevel;
  final String sleepTime;
  final String wakeTime;

  factory OnboardingGoalsActivityDetails.fromJson(Map<String, dynamic> json) =>
      OnboardingGoalsActivityDetails(
        primaryGoal: json['primaryGoal'] as String,
        targetWeightKg: (json['targetWeightKg'] as num).toDouble(),
        hasWeighingScale: json['hasWeighingScale'] as bool,
        activityLevel: json['activityLevel'] as String,
        sleepTime: json['sleepTime'] as String,
        wakeTime: json['wakeTime'] as String,
      );

  Map<String, dynamic> toJson() => {
    'primaryGoal': primaryGoal,
    'targetWeightKg': targetWeightKg,
    'hasWeighingScale': hasWeighingScale,
    'activityLevel': activityLevel,
    'sleepTime': sleepTime,
    'wakeTime': wakeTime,
  };
}

class OnboardingHealthDietDetails {
  const OnboardingHealthDietDetails({
    required this.healthConditions,
    required this.preferredDiet,
    required this.foodAllergies,
    required this.dietaryRestrictions,
    required this.motivation,
  });

  final List<String> healthConditions;
  final String preferredDiet;
  final List<String> foodAllergies;
  final List<String> dietaryRestrictions;
  final String motivation;

  factory OnboardingHealthDietDetails.fromJson(Map<String, dynamic> json) =>
      OnboardingHealthDietDetails(
        healthConditions: _stringList(json['healthConditions']),
        preferredDiet: json['preferredDiet'] as String,
        foodAllergies: _stringList(json['foodAllergies']),
        dietaryRestrictions: _stringList(json['dietaryRestrictions']),
        motivation: json['motivation'] as String,
      );

  Map<String, dynamic> toJson() => {
    'healthConditions': healthConditions,
    'preferredDiet': preferredDiet,
    'foodAllergies': foodAllergies,
    'dietaryRestrictions': dietaryRestrictions,
    'motivation': motivation,
  };
}

class OnboardingTrainingSetupDetails {
  const OnboardingTrainingSetupDetails({
    required this.wantsPersonalizedPlan,
    required this.trainingType,
    this.experienceLevel,
  });

  final bool wantsPersonalizedPlan;
  final String trainingType;
  final String? experienceLevel;

  factory OnboardingTrainingSetupDetails.fromJson(Map<String, dynamic> json) =>
      OnboardingTrainingSetupDetails(
        wantsPersonalizedPlan: json['wantsPersonalizedPlan'] as bool,
        trainingType: json['trainingType'] as String,
        experienceLevel: json['experienceLevel'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'wantsPersonalizedPlan': wantsPersonalizedPlan,
    'trainingType': trainingType,
    'experienceLevel': experienceLevel,
  };
}

class OnboardingGymDetails {
  const OnboardingGymDetails({
    required this.experienceLevel,
    required this.goals,
    required this.trainingDays,
    required this.workoutDuration,
    required this.equipment,
    required this.preferredSplit,
    required this.targetMuscleGroups,
  });

  final String experienceLevel;
  final List<String> goals;
  final List<String> trainingDays;
  final String workoutDuration;
  final String equipment;
  final String preferredSplit;
  final List<String> targetMuscleGroups;

  factory OnboardingGymDetails.fromJson(Map<String, dynamic> json) =>
      OnboardingGymDetails(
        experienceLevel: json['experienceLevel'] as String,
        goals: _stringList(json['goals']),
        trainingDays: _stringList(json['trainingDays']),
        workoutDuration: json['workoutDuration'] as String,
        equipment: json['equipment'] as String,
        preferredSplit: json['preferredSplit'] as String,
        targetMuscleGroups: _stringList(json['targetMuscleGroups']),
      );

  Map<String, dynamic> toJson() => {
    'experienceLevel': experienceLevel,
    'goals': goals,
    'trainingDays': trainingDays,
    'workoutDuration': workoutDuration,
    'equipment': equipment,
    'preferredSplit': preferredSplit,
    'targetMuscleGroups': targetMuscleGroups,
  };
}

class OnboardingCalisthenicsDetails {
  const OnboardingCalisthenicsDetails({
    required this.experienceLevel,
    required this.bodyweightKg,
    required this.maxPushups,
    required this.maxPullups,
    required this.maxDips,
    required this.currentSkills,
    required this.skillGoals,
    required this.equipment,
    required this.trainingDays,
    required this.workoutDuration,
    required this.preferredWorkoutTime,
    required this.injuries,
  });

  final String experienceLevel;
  final double bodyweightKg;
  final double maxPushups;
  final double maxPullups;
  final double maxDips;
  final List<String> currentSkills;
  final List<String> skillGoals;
  final List<String> equipment;
  final List<String> trainingDays;
  final String workoutDuration;
  final String preferredWorkoutTime;
  final List<String> injuries;

  factory OnboardingCalisthenicsDetails.fromJson(Map<String, dynamic> json) =>
      OnboardingCalisthenicsDetails(
        experienceLevel: json['experienceLevel'] as String,
        bodyweightKg: (json['bodyweightKg'] as num).toDouble(),
        maxPushups: (json['maxPushups'] as num).toDouble(),
        maxPullups: (json['maxPullups'] as num).toDouble(),
        maxDips: (json['maxDips'] as num).toDouble(),
        currentSkills: _stringList(json['currentSkills']),
        skillGoals: _stringList(json['skillGoals']),
        equipment: _stringList(json['equipment']),
        trainingDays: _stringList(json['trainingDays']),
        workoutDuration: json['workoutDuration'] as String,
        preferredWorkoutTime: json['preferredWorkoutTime'] as String,
        injuries: _stringList(json['injuries']),
      );

  Map<String, dynamic> toJson() => {
    'experienceLevel': experienceLevel,
    'bodyweightKg': bodyweightKg,
    'maxPushups': maxPushups,
    'maxPullups': maxPullups,
    'maxDips': maxDips,
    'currentSkills': currentSkills,
    'skillGoals': skillGoals,
    'equipment': equipment,
    'trainingDays': trainingDays,
    'workoutDuration': workoutDuration,
    'preferredWorkoutTime': preferredWorkoutTime,
    'injuries': injuries,
  };
}

class OnboardingYogaDetails {
  const OnboardingYogaDetails({
    required this.experienceLevel,
    required this.preferredStyle,
    required this.primaryGoal,
    required this.wantsMeditation,
    required this.flexibilityLevel,
    required this.practiceDuration,
    required this.practiceDays,
    required this.preferredPracticeTime,
    required this.equipment,
    required this.injuries,
  });

  final String experienceLevel;
  final String preferredStyle;
  final String primaryGoal;
  final bool wantsMeditation;
  final String flexibilityLevel;
  final String practiceDuration;
  final List<String> practiceDays;
  final String preferredPracticeTime;
  final List<String> equipment;
  final List<String> injuries;

  factory OnboardingYogaDetails.fromJson(Map<String, dynamic> json) =>
      OnboardingYogaDetails(
        experienceLevel: json['experienceLevel'] as String,
        preferredStyle: json['preferredStyle'] as String,
        primaryGoal: json['primaryGoal'] as String,
        wantsMeditation: json['wantsMeditation'] as bool,
        flexibilityLevel: json['flexibilityLevel'] as String,
        practiceDuration: json['practiceDuration'] as String,
        practiceDays: _stringList(json['practiceDays']),
        preferredPracticeTime: json['preferredPracticeTime'] as String,
        equipment: _stringList(json['equipment']),
        injuries: _stringList(json['injuries']),
      );

  Map<String, dynamic> toJson() => {
    'experienceLevel': experienceLevel,
    'preferredStyle': preferredStyle,
    'primaryGoal': primaryGoal,
    'wantsMeditation': wantsMeditation,
    'flexibilityLevel': flexibilityLevel,
    'practiceDuration': practiceDuration,
    'practiceDays': practiceDays,
    'preferredPracticeTime': preferredPracticeTime,
    'equipment': equipment,
    'injuries': injuries,
  };
}

class OnboardingTargetsPermissionsDetails {
  const OnboardingTargetsPermissionsDetails({
    required this.stepsTarget,
    required this.sleepTargetHours,
    required this.waterTargetLiters,
    required this.wearablesConnected,
    required this.referralSource,
  });

  final double stepsTarget;
  final double sleepTargetHours;
  final double waterTargetLiters;
  final bool wearablesConnected;
  final String referralSource;

  factory OnboardingTargetsPermissionsDetails.fromJson(
    Map<String, dynamic> json,
  ) => OnboardingTargetsPermissionsDetails(
    stepsTarget: (json['stepsTarget'] as num).toDouble(),
    sleepTargetHours: (json['sleepTargetHours'] as num).toDouble(),
    waterTargetLiters: (json['waterTargetLiters'] as num).toDouble(),
    wearablesConnected: json['wearablesConnected'] as bool,
    referralSource: json['referralSource'] as String,
  );

  Map<String, dynamic> toJson() => {
    'stepsTarget': stepsTarget,
    'sleepTargetHours': sleepTargetHours,
    'waterTargetLiters': waterTargetLiters,
    'wearablesConnected': wearablesConnected,
    'referralSource': referralSource,
  };
}

class OnboardingFloStateDetails {
  const OnboardingFloStateDetails({
    required this.morningEnergy,
    required this.recoverySpeed,
    required this.stressLevel,
    required this.sleepQuality,
    required this.missWorkoutReasons,
    required this.badDayBehaviour,
    required this.communicationStyle,
    required this.pushIntensity,
  });

  final String morningEnergy;
  final String recoverySpeed;
  final String stressLevel;
  final String sleepQuality;
  final List<String> missWorkoutReasons;
  final String badDayBehaviour;
  final String communicationStyle;
  final String pushIntensity;

  factory OnboardingFloStateDetails.fromJson(Map<String, dynamic> json) =>
      OnboardingFloStateDetails(
        morningEnergy: json['morningEnergy'] as String,
        recoverySpeed: json['recoverySpeed'] as String,
        stressLevel: json['stressLevel'] as String,
        sleepQuality: json['sleepQuality'] as String,
        missWorkoutReasons: _stringList(json['missWorkoutReasons']),
        badDayBehaviour: json['badDayBehaviour'] as String,
        communicationStyle: json['communicationStyle'] as String,
        pushIntensity: json['pushIntensity'] as String,
      );

  Map<String, dynamic> toJson() => {
    'morningEnergy': morningEnergy,
    'recoverySpeed': recoverySpeed,
    'stressLevel': stressLevel,
    'sleepQuality': sleepQuality,
    'missWorkoutReasons': missWorkoutReasons,
    'badDayBehaviour': badDayBehaviour,
    'communicationStyle': communicationStyle,
    'pushIntensity': pushIntensity,
  };
}

class OnboardingDetailsEntity {
  const OnboardingDetailsEntity({
    required this.uid,
    this.profile,
    this.goalsActivity,
    this.healthDiet,
    this.trainingSetup,
    this.gymDetails,
    this.calisthenicsDetails,
    this.yogaDetails,
    this.targetsPermissions,
    this.floState,
    required this.startedAt,
    this.completedAt,
    required this.updatedAt,
  });

  final String uid;
  final OnboardingProfileDetails? profile;
  final OnboardingGoalsActivityDetails? goalsActivity;
  final OnboardingHealthDietDetails? healthDiet;
  final OnboardingTrainingSetupDetails? trainingSetup;
  final OnboardingGymDetails? gymDetails;
  final OnboardingCalisthenicsDetails? calisthenicsDetails;
  final OnboardingYogaDetails? yogaDetails;
  final OnboardingTargetsPermissionsDetails? targetsPermissions;
  final OnboardingFloStateDetails? floState;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime updatedAt;

  factory OnboardingDetailsEntity.fromAnswers({
    required String uid,
    required Map<String, dynamic> answers,
    required DateTime startedAt,
    DateTime? completedAt,
    required DateTime updatedAt,
  }) {
    OnboardingProfileDetails? profile;
    if (answers['name'] != null) {
      profile = OnboardingProfileDetails(
        name: answers['name'] as String,
        dateOfBirth: answers['dob'] as DateTime,
        biologicalSex: answers['biological_sex'] as String,
        unitSystem: answers['unit_system'] as String,
        heightCm: (answers['height'] as num).toDouble(),
        weightKg: (answers['weight'] as num).toDouble(),
      );
    }

    OnboardingGoalsActivityDetails? goalsActivity;
    if (answers['primary_goal'] != null) {
      goalsActivity = OnboardingGoalsActivityDetails(
        primaryGoal: answers['primary_goal'] as String,
        targetWeightKg: (answers['target_weight'] as num).toDouble(),
        hasWeighingScale: answers['weighing_scale'] == 'Yes',
        activityLevel: answers['activity_level'] as String,
        sleepTime: _hhmm(answers['sleep_time'] as DateTime),
        wakeTime: _hhmm(answers['wake_time'] as DateTime),
      );
    }

    OnboardingHealthDietDetails? healthDiet;
    if (answers['preferred_diet'] != null) {
      healthDiet = OnboardingHealthDietDetails(
        healthConditions: _stringList(answers['health_conditions']),
        preferredDiet: answers['preferred_diet'] as String,
        foodAllergies: _stringList(answers['food_allergies']),
        dietaryRestrictions: _stringList(answers['dietary_restrictions']),
        motivation: answers['motivation'] as String,
      );
    }

    OnboardingTrainingSetupDetails? trainingSetup;
    if (answers['training_type'] != null) {
      trainingSetup = OnboardingTrainingSetupDetails(
        wantsPersonalizedPlan: answers['create_plan'] == 'Yes',
        trainingType: answers['training_type'] as String,
        experienceLevel: switch (answers['training_type']) {
          'Gym' => answers['gym_experience'] as String?,
          'Calisthenics' => answers['cal_experience'] as String?,
          'Yoga' => answers['yoga_experience'] as String?,
          _ => null,
        },
      );
    }

    OnboardingGymDetails? gymDetails;
    OnboardingCalisthenicsDetails? calisthenicsDetails;
    OnboardingYogaDetails? yogaDetails;
    switch (trainingSetup?.trainingType) {
      case 'Gym':
        gymDetails = OnboardingGymDetails(
          experienceLevel: answers['gym_experience'] as String,
          goals: _stringList(answers['gym_goals']),
          trainingDays: _stringList(answers['gym_days']),
          workoutDuration: answers['gym_duration'] as String,
          equipment: answers['gym_equipment'] as String,
          preferredSplit: answers['gym_split'] as String,
          targetMuscleGroups: _stringList(answers['gym_muscle_groups']),
        );
      case 'Calisthenics':
        calisthenicsDetails = OnboardingCalisthenicsDetails(
          experienceLevel: answers['cal_experience'] as String,
          bodyweightKg: (answers['cal_bodyweight'] as num).toDouble(),
          maxPushups: (answers['cal_max_pushups'] as num).toDouble(),
          maxPullups: (answers['cal_max_pullups'] as num).toDouble(),
          maxDips: (answers['cal_max_dips'] as num).toDouble(),
          currentSkills: _stringList(answers['cal_skills']),
          skillGoals: _stringList(answers['cal_skill_goals']),
          equipment: _stringList(answers['cal_equipment']),
          trainingDays: _stringList(answers['cal_days']),
          workoutDuration: answers['cal_duration'] as String,
          preferredWorkoutTime: answers['cal_workout_time'] as String,
          injuries: _stringList(answers['cal_injuries']),
        );
      case 'Yoga':
        yogaDetails = OnboardingYogaDetails(
          experienceLevel: answers['yoga_experience'] as String,
          preferredStyle: answers['yoga_style'] as String,
          primaryGoal: answers['yoga_goal'] as String,
          wantsMeditation: answers['yoga_meditation'] == 'Yes',
          flexibilityLevel: answers['yoga_flexibility'] as String,
          practiceDuration: answers['yoga_duration'] as String,
          practiceDays: _stringList(answers['yoga_days']),
          preferredPracticeTime: answers['yoga_workout_time'] as String,
          equipment: _stringList(answers['yoga_equipment']),
          injuries: _stringList(answers['yoga_injuries']),
        );
    }

    OnboardingTargetsPermissionsDetails? targetsPermissions;
    if (answers['steps_target'] != null) {
      targetsPermissions = OnboardingTargetsPermissionsDetails(
        stepsTarget: (answers['steps_target'] as num).toDouble(),
        sleepTargetHours: (answers['sleep_target'] as num).toDouble(),
        waterTargetLiters: (answers['water_target'] as num).toDouble(),
        wearablesConnected: answers['apple_health'] as bool? ?? false,
        referralSource: answers['referral'] as String? ?? '',
      );
    }

    OnboardingFloStateDetails? floState;
    if (answers['morning_energy'] != null) {
      floState = OnboardingFloStateDetails(
        morningEnergy: answers['morning_energy'] as String,
        recoverySpeed: answers['recovery_speed'] as String,
        stressLevel: answers['stress_level'] as String,
        sleepQuality: answers['sleep_quality'] as String,
        missWorkoutReasons: _stringList(answers['miss_workouts']),
        badDayBehaviour: answers['training_behaviour'] as String,
        communicationStyle: answers['wave_communication'] as String,
        pushIntensity: answers['push_intensity'] as String,
      );
    }

    return OnboardingDetailsEntity(
      uid: uid,
      profile: profile,
      goalsActivity: goalsActivity,
      healthDiet: healthDiet,
      trainingSetup: trainingSetup,
      gymDetails: gymDetails,
      calisthenicsDetails: calisthenicsDetails,
      yogaDetails: yogaDetails,
      targetsPermissions: targetsPermissions,
      floState: floState,
      startedAt: startedAt,
      completedAt: completedAt,
      updatedAt: updatedAt,
    );
  }

  factory OnboardingDetailsEntity.fromJson(Map<String, dynamic> json) =>
      OnboardingDetailsEntity(
        uid: json['uid'] as String,
        profile: json['profile'] == null
            ? null
            : OnboardingProfileDetails.fromJson(
                json['profile'] as Map<String, dynamic>,
              ),
        goalsActivity: json['goalsActivity'] == null
            ? null
            : OnboardingGoalsActivityDetails.fromJson(
                json['goalsActivity'] as Map<String, dynamic>,
              ),
        healthDiet: json['healthDiet'] == null
            ? null
            : OnboardingHealthDietDetails.fromJson(
                json['healthDiet'] as Map<String, dynamic>,
              ),
        trainingSetup: json['trainingSetup'] == null
            ? null
            : OnboardingTrainingSetupDetails.fromJson(
                json['trainingSetup'] as Map<String, dynamic>,
              ),
        gymDetails: json['gymDetails'] == null
            ? null
            : OnboardingGymDetails.fromJson(
                json['gymDetails'] as Map<String, dynamic>,
              ),
        calisthenicsDetails: json['calisthenicsDetails'] == null
            ? null
            : OnboardingCalisthenicsDetails.fromJson(
                json['calisthenicsDetails'] as Map<String, dynamic>,
              ),
        yogaDetails: json['yogaDetails'] == null
            ? null
            : OnboardingYogaDetails.fromJson(
                json['yogaDetails'] as Map<String, dynamic>,
              ),
        targetsPermissions: json['targetsPermissions'] == null
            ? null
            : OnboardingTargetsPermissionsDetails.fromJson(
                json['targetsPermissions'] as Map<String, dynamic>,
              ),
        floState: json['floState'] == null
            ? null
            : OnboardingFloStateDetails.fromJson(
                json['floState'] as Map<String, dynamic>,
              ),
        startedAt: DateTime.parse(json['startedAt'] as String),
        completedAt: json['completedAt'] == null
            ? null
            : DateTime.parse(json['completedAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'profile': profile?.toJson(),
    'goalsActivity': goalsActivity?.toJson(),
    'healthDiet': healthDiet?.toJson(),
    'trainingSetup': trainingSetup?.toJson(),
    'gymDetails': gymDetails?.toJson(),
    'calisthenicsDetails': calisthenicsDetails?.toJson(),
    'yogaDetails': yogaDetails?.toJson(),
    'targetsPermissions': targetsPermissions?.toJson(),
    'floState': floState?.toJson(),
    'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
