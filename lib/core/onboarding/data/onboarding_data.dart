import 'package:flutter/material.dart';
import '../models/onboarding_models.dart';

class OnboardingData {
  static List<OnboardingPhase> activePhasesFor(Map<String, dynamic> answers) {
    final trainingType = answers['training_type'];
    final type = switch (trainingType) {
      List(isNotEmpty: true) => trainingType.first.toString().toLowerCase(),
      String() => trainingType.toLowerCase(),
      _ => null,
    };
    return [
      ...corePhases,
      if (type == 'gym') gymPhase,
      if (type == 'calisthenics') calisthenicsPhase,
      if (type == 'yoga') yogaPhase,
      ...finalPhases,
    ];
  }

  static const List<OnboardingPhase> corePhases = [
    // Phase 1
    OnboardingPhase(
      id: 'phase_1',
      title: 'Basic Profile',
      questions: [
        OnboardingQuestion(
          id: 'name',
          title: 'What should we call you?',
          subtitle: 'WAVE will use this throughout the app.',
          inputType: InputType.text,
        ),
        OnboardingQuestion(
          id: 'dob',
          title: 'When were you born?',
          subtitle:
              'This helps us calculate your metabolic rate and age-specific metrics.',
          inputType: InputType.datePicker,
        ),
        OnboardingQuestion(
          id: 'biological_sex',
          title: 'Biological Sex',
          subtitle: 'Used to calculate precise physiological baselines.',
          inputType: InputType.singleSelect,
          options: [
            QuestionOption(
              title: 'Male',
              description: 'Assigned male at birth',
            ),
            QuestionOption(
              title: 'Female',
              description: 'Assigned female at birth',
            ),
          ],
        ),
        OnboardingQuestion(
          id: 'unit_system',
          title: 'Preferred Unit System',
          subtitle: 'Choose how you want to see weight and measurements.',
          inputType: InputType.singleSelect,
          options: [
            QuestionOption(
              title: 'Metric',
              description: 'Kilograms & Centimeters',
            ),
            QuestionOption(title: 'Imperial', description: 'Pounds & Inches'),
          ],
        ),
        OnboardingQuestion(
          id: 'height',
          title: 'How tall are you?',
          subtitle:
              'Essential for calculating your BMI and daily caloric needs.',
          inputType: InputType.numberSlider,
          min: 100.0,
          max: 250.0,
          suffixText: 'cm',
        ),
        OnboardingQuestion(
          id: 'weight',
          title: 'Current weight',
          subtitle: 'Where are we starting from?',
          inputType: InputType.numberSlider,
          min: 40.0,
          max: 200.0,
          suffixText: 'kg',
        ),
      ],
    ),
    // Phase 2
    OnboardingPhase(
      id: 'phase_2',
      title: 'Goals & Activity',
      questions: [
        OnboardingQuestion(
          id: 'primary_goal',
          title: 'What is your primary goal?',
          subtitle: 'This shapes your entire plan direction.',
          inputType: InputType.cardSelect,
          options: [
            QuestionOption(
              title: 'Lose Fat',
              description: 'Reduce body fat while preserving muscle',
              icon: Icons.local_fire_department_outlined,
            ),
            QuestionOption(
              title: 'Gain Muscle',
              description: 'Build strength and size progressively',
              icon: Icons.fitness_center,
            ),
            QuestionOption(
              title: 'Recomposition',
              description: 'Lose fat and gain muscle simultaneously',
              icon: Icons.sync,
            ),
            QuestionOption(
              title: 'Lifestyle',
              description: 'Improve overall health and wellbeing',
              icon: Icons.self_improvement,
            ),
            QuestionOption(
              title: 'Maintain',
              description: 'Sustain current body composition',
              icon: Icons.balance,
            ),
          ],
        ),
        OnboardingQuestion(
          id: 'target_weight_group',
          title: 'What is your target weight?',
          subtitle: 'Where are you headed?',
          inputType: InputType.multiQuestion,
          subQuestions: [
            OnboardingQuestion(
              id: 'target_weight',
              title: 'What is your target weight?',
              inputType: InputType.numberSlider,
              min: 40.0,
              max: 200.0,
              suffixText: 'kg',
            ),
            OnboardingQuestion(
              id: 'weighing_scale',
              title: 'Do you have a weighing scale?',
              inputType: InputType.yesNo,
            ),
          ],
        ),
        OnboardingQuestion(
          id: 'activity_level',
          title: 'Typical Daily Activity',
          subtitle: 'How much do you move outside of workouts?',
          inputType: InputType.singleSelect,
          options: [
            QuestionOption(
              title: 'Sedentary',
              description: 'Office job, mostly sitting down',
            ),
            QuestionOption(
              title: 'Lightly Active',
              description: 'Standing job, light movement',
            ),
            QuestionOption(
              title: 'Active',
              description: 'Physical job, constantly moving',
            ),
            QuestionOption(
              title: 'Very Active',
              description: 'Heavy physical labor or daily endurance',
            ),
          ],
        ),

        OnboardingQuestion(
          id: 'sleep_schedule',
          title: 'Sleep Schedule',
          subtitle: 'We use this to optimize your circadian rhythm.',
          inputType: InputType.multiQuestion,
          subQuestions: [
            OnboardingQuestion(
              id: 'sleep_time',
              title: 'Usual Sleep Time',
              inputType: InputType.timePicker,
            ),
            OnboardingQuestion(
              id: 'wake_time',
              title: 'Usual Wake-up Time',
              inputType: InputType.timePicker,
            ),
          ],
        ),
      ],
    ),
    // Phase 3
    OnboardingPhase(
      id: 'phase_3',
      title: 'Health & Diet',
      questions: [
        OnboardingQuestion(
          id: 'health_conditions',
          title: 'Any health conditions?',
          subtitle: 'Select all that apply to keep your training safe.',
          inputType: InputType.multiSelect,
          options: [
            QuestionOption(title: 'None'),
            QuestionOption(title: 'Diabetes', description: 'Type 1 or Type 2'),
            QuestionOption(title: 'High Blood Pressure'),
            QuestionOption(
              title: 'Thyroid',
              description: 'Hypo or Hyperthyroidism',
            ),
            QuestionOption(title: 'PCOS'),
            QuestionOption(title: 'Asthma'),
            QuestionOption(title: 'Other'),
          ],
        ),
        OnboardingQuestion(
          id: 'preferred_diet',
          title: 'Preferred Diet',
          subtitle: 'How do you prefer to eat?',
          inputType: InputType.singleSelect,
          options: [
            QuestionOption(
              title: 'Flexible',
              description: 'No specific restrictions',
            ),
            QuestionOption(title: 'Vegetarian', description: 'No meat or fish'),
            QuestionOption(title: 'Vegan', description: 'No animal products'),
            QuestionOption(
              title: 'Eggetarian',
              description: 'Vegetarian but includes eggs',
            ),
            QuestionOption(
              title: 'Non-Vegetarian',
              description: 'Eats all types of meat',
            ),
          ],
        ),
        OnboardingQuestion(
          id: 'food_allergies',
          title: 'Food Allergies',
          subtitle: 'Let us know if you have any severe allergies.',
          inputType: InputType.multiSelectPill,
          options: [
            QuestionOption(title: 'None'),
            QuestionOption(title: 'Nuts'),
            QuestionOption(title: 'Dairy'),
            QuestionOption(title: 'Gluten'),
            QuestionOption(title: 'Eggs'),
            QuestionOption(title: 'Seafood'),
            QuestionOption(title: 'Soy'),
            QuestionOption(title: 'Other'),
          ],
        ),
        OnboardingQuestion(
          id: 'dietary_restrictions',
          title: 'Dietary Restrictions',
          subtitle: 'Any other religious or personal restrictions?',
          inputType: InputType.multiSelectPill,
          options: [
            QuestionOption(title: 'None'),
            QuestionOption(title: 'Halal'),
            QuestionOption(title: 'Kosher'),
            QuestionOption(title: 'Jain'),
            QuestionOption(title: 'Lactose Free'),
            QuestionOption(title: 'Gluten Free'),
            QuestionOption(title: 'Other'),
          ],
        ),
        OnboardingQuestion(
          id: 'motivation',
          title: 'What drives you most?',
          subtitle: 'Understanding your "why" keeps you consistent.',
          inputType: InputType.singleSelect,
          options: [
            QuestionOption(
              title: 'Looking Better',
              description: 'Aesthetics and confidence',
            ),
            QuestionOption(
              title: 'Building Strength',
              description: 'Lifting heavier and feeling powerful',
            ),
            QuestionOption(
              title: 'Better Health',
              description: 'Longevity and vital stats',
            ),
            QuestionOption(
              title: 'Sports Performance',
              description: 'Agility, speed, and endurance',
            ),
            QuestionOption(
              title: 'Mental Wellbeing',
              description: 'Stress relief and mental clarity',
            ),
          ],
        ),
      ],
    ),
    // Phase 4
    OnboardingPhase(
      id: 'phase_4',
      title: 'Training Setup',
      questions: [
        OnboardingQuestion(
          id: 'create_plan',
          title: 'Create personalized training plan?',
          subtitle:
              'We can generate your custom plan now or you can do it later.',
          inputType: InputType.singleSelect,
          options: [
            QuestionOption(
              title: 'Yes',
              description: 'Build my custom program now',
            ),
            QuestionOption(
              title: "I'll do it later",
              description: 'Skip for now',
            ),
          ],
        ),
        OnboardingQuestion(
          id: 'training_type',
          title: 'Training Type',
          subtitle: 'How do you prefer to train?',
          inputType: InputType.singleSelect,
          options: [
            QuestionOption(
              title: 'Gym',
              description: 'Traditional weightlifting and machines',
            ),
            QuestionOption(
              title: 'Calisthenics',
              description: 'Bodyweight mastery and skills',
            ),
            QuestionOption(
              title: 'Yoga',
              description: 'Flexibility, balance, and mindfulness',
            ),
          ],
        ),
      ],
    ),
  ];

  static const OnboardingPhase gymPhase = OnboardingPhase(
    id: 'gym_phase',
    title: 'Gym',
    questions: [
      OnboardingQuestion(
        id: 'gym_experience',
        title: 'Experience Level',
        subtitle: 'How comfortable are you in the gym?',
        inputType: InputType.singleSelect,
        options: [
          QuestionOption(
            title: 'Beginner',
            description: 'Just starting out or returning after a long break',
          ),
          QuestionOption(
            title: 'Intermediate',
            description: 'Consistent training for 6+ months',
          ),
          QuestionOption(
            title: 'Advanced',
            description: 'Years of consistent, structured training',
          ),
        ],
      ),
      OnboardingQuestion(
        id: 'gym_goals',
        title: 'Gym Goals',
        subtitle: 'What are you trying to achieve with weights?',
        inputType: InputType.multiSelect,
        options: [
          QuestionOption(
            title: 'Strength',
            description: 'Lift heavier weights',
          ),
          QuestionOption(
            title: 'Muscle Growth',
            description: 'Hypertrophy and size',
          ),
          QuestionOption(
            title: 'Fat Loss',
            description: 'Burn calories and tone up',
          ),
          QuestionOption(
            title: 'Endurance',
            description: 'Higher reps and stamina',
          ),
        ],
      ),
      OnboardingQuestion(
        id: 'gym_days',
        title: 'Training Days',
        subtitle: 'Which days can you commit to the gym?',
        inputType: InputType.multiSelect,
        options: [
          QuestionOption(title: 'Monday'),
          QuestionOption(title: 'Tuesday'),
          QuestionOption(title: 'Wednesday'),
          QuestionOption(title: 'Thursday'),
          QuestionOption(title: 'Friday'),
          QuestionOption(title: 'Saturday'),
          QuestionOption(title: 'Sunday'),
        ],
      ),
      OnboardingQuestion(
        id: 'gym_duration',
        title: 'Workout Duration',
        subtitle: 'How much time can you realistically commit per session?',
        inputType: InputType.singleSelect,
        options: [
          QuestionOption(title: '30 min', description: 'Quick and intense'),
          QuestionOption(
            title: '45 min',
            description: 'Efficient standard workout',
          ),
          QuestionOption(title: '60 min', description: 'Standard full session'),
          QuestionOption(
            title: '90 min',
            description: 'Longer rest periods and volume',
          ),
          QuestionOption(title: '120 min', description: 'Elite level volume'),
        ],
      ),
      OnboardingQuestion(
        id: 'gym_equipment',
        title: 'Available Equipment',
        subtitle: 'What do you have access to?',
        inputType: InputType.singleSelect,
        options: [
          QuestionOption(
            title: 'Full Gym',
            description: 'Commercial gym with all machines',
          ),
          QuestionOption(
            title: 'Basic Gym',
            description: 'Dumbbells, benches, basic cables',
          ),
          QuestionOption(
            title: 'Home Gym',
            description: 'Limited weights and space',
          ),
        ],
      ),
      OnboardingQuestion(
        id: 'gym_split',
        title: 'Preferred Split',
        subtitle: 'How do you want to organize your workouts?',
        inputType: InputType.singleSelect,
        options: [
          QuestionOption(
            title: 'Recommended',
            description: 'Let WAVE choose the optimal split for you',
          ),
          QuestionOption(
            title: 'Push Pull Legs',
            description: 'Classic 3-6 day cycle',
          ),
          QuestionOption(
            title: 'Upper Lower',
            description: 'Balanced 4 day cycle',
          ),
          QuestionOption(
            title: 'Full Body',
            description: 'Hit everything every session',
          ),
          QuestionOption(
            title: 'Bro Split',
            description: 'One muscle group per day',
          ),
        ],
      ),
      OnboardingQuestion(
        id: 'gym_muscle_groups',
        title: 'Target Muscle Groups',
        subtitle: 'Any areas you want to prioritize?',
        inputType: InputType.multiSelectPill,
        options: [
          QuestionOption(title: 'Chest'),
          QuestionOption(title: 'Back'),
          QuestionOption(title: 'Shoulders'),
          QuestionOption(title: 'Arms'),
          QuestionOption(title: 'Legs'),
          QuestionOption(title: 'Glutes'),
          QuestionOption(title: 'Core'),
        ],
      ),
    ],
  );

  static const OnboardingPhase calisthenicsPhase = OnboardingPhase(
    id: 'calisthenics_phase',
    title: 'Calisthenics',
    questions: [
      OnboardingQuestion(
        id: 'cal_experience',
        title: 'Experience Level',
        subtitle: 'How comfortable are you with bodyweight training?',
        inputType: InputType.singleSelect,
        options: [
          QuestionOption(
            title: 'Beginner',
            description: 'Learning basic pull-ups and push-ups',
          ),
          QuestionOption(
            title: 'Intermediate',
            description: 'Mastered basics, learning skills',
          ),
          QuestionOption(
            title: 'Advanced',
            description: 'Can perform advanced levers and holds',
          ),
        ],
      ),
      OnboardingQuestion(
        id: 'cal_bodyweight',
        title: 'Current Bodyweight',
        subtitle: 'Bodyweight is the core resistance in calisthenics.',
        inputType: InputType.numberSlider,
        min: 40.0,
        max: 200.0,
        suffixText: 'kg',
      ),
      OnboardingQuestion(
        id: 'cal_max_pushups',
        title: 'Maximum Push-ups',
        subtitle: 'Unbroken strict repetitions',
        inputType: InputType.numberSlider,
        min: 0.0,
        max: 100.0,
      ),
      OnboardingQuestion(
        id: 'cal_max_pullups',
        title: 'Maximum Pull-ups',
        subtitle: 'Unbroken strict repetitions',
        inputType: InputType.numberSlider,
        min: 0.0,
        max: 50.0,
      ),
      OnboardingQuestion(
        id: 'cal_max_dips',
        title: 'Maximum Dips',
        subtitle: 'Unbroken strict repetitions',
        inputType: InputType.numberSlider,
        min: 0.0,
        max: 50.0,
      ),
      OnboardingQuestion(
        id: 'cal_skills',
        title: 'Current Skills',
        subtitle: 'Which skills can you currently hold for 3+ seconds?',
        inputType: InputType.multiSelect,
        options: [
          QuestionOption(title: 'L-Sit'),
          QuestionOption(title: 'Handstand'),
          QuestionOption(title: 'Muscle-Up'),
          QuestionOption(title: 'Front Lever'),
          QuestionOption(title: 'Planche'),
          QuestionOption(title: 'Human Flag'),
        ],
      ),
      OnboardingQuestion(
        id: 'cal_skill_goals',
        title: 'Skill Goals',
        subtitle: 'What skills do you want to unlock next?',
        inputType: InputType.multiSelect,
        options: [
          QuestionOption(title: 'L-Sit'),
          QuestionOption(title: 'Handstand'),
          QuestionOption(title: 'Muscle-Up'),
          QuestionOption(title: 'Front Lever'),
          QuestionOption(title: 'Planche'),
          QuestionOption(title: 'Human Flag'),
        ],
      ),
      OnboardingQuestion(
        id: 'cal_equipment',
        title: 'Equipment',
        subtitle: 'What calisthenics equipment do you have access to?',
        inputType: InputType.multiSelectPill,
        options: [
          QuestionOption(title: 'Pull-up Bar'),
          QuestionOption(title: 'Rings'),
          QuestionOption(title: 'Bands'),
          QuestionOption(title: 'Parallettes'),
          QuestionOption(title: 'Dip Bars'),
        ],
      ),
      OnboardingQuestion(
        id: 'cal_days',
        title: 'Training Days',
        subtitle: 'Which days can you commit to training?',
        inputType: InputType.multiSelect,
        options: [
          QuestionOption(title: 'Monday'),
          QuestionOption(title: 'Tuesday'),
          QuestionOption(title: 'Wednesday'),
          QuestionOption(title: 'Thursday'),
          QuestionOption(title: 'Friday'),
          QuestionOption(title: 'Saturday'),
          QuestionOption(title: 'Sunday'),
        ],
      ),
      OnboardingQuestion(
        id: 'cal_duration',
        title: 'Workout Duration',
        subtitle: 'How long can you train per session?',
        inputType: InputType.singleSelect,
        options: [
          QuestionOption(title: '30 min', description: 'Quick circuit'),
          QuestionOption(title: '45 min', description: 'Standard workout'),
          QuestionOption(
            title: '60 min',
            description: 'Full session with skill work',
          ),
          QuestionOption(
            title: '90 min',
            description: 'Advanced skill and volume',
          ),
        ],
      ),
      OnboardingQuestion(
        id: 'cal_workout_time',
        title: 'Preferred Workout Time',
        subtitle: 'When do you feel most energetic?',
        inputType: InputType.singleSelect,
        options: [
          QuestionOption(title: 'Morning'),
          QuestionOption(title: 'Afternoon'),
          QuestionOption(title: 'Evening'),
          QuestionOption(title: 'Flexible'),
        ],
      ),
      OnboardingQuestion(
        id: 'cal_injuries',
        title: 'Injuries / Limitations',
        subtitle: 'Any joint issues we need to program around?',
        inputType: InputType.multiSelectPill,
        options: [
          QuestionOption(title: 'None'),
          QuestionOption(title: 'Knee'),
          QuestionOption(title: 'Back'),
          QuestionOption(title: 'Shoulder'),
          QuestionOption(title: 'Elbow'),
          QuestionOption(title: 'Wrist'),
          QuestionOption(title: 'Other'),
        ],
      ),
    ],
  );

  static const OnboardingPhase yogaPhase = OnboardingPhase(
    id: 'yoga_phase',
    title: 'Yoga',
    questions: [
      OnboardingQuestion(
        id: 'yoga_experience',
        title: 'Experience Level',
        subtitle: 'How familiar are you with yoga asanas?',
        inputType: InputType.singleSelect,
        options: [
          QuestionOption(title: 'Beginner', description: 'New to yoga'),
          QuestionOption(
            title: 'Intermediate',
            description: 'Familiar with basic flows',
          ),
          QuestionOption(
            title: 'Advanced',
            description: 'Comfortable with advanced inversions',
          ),
        ],
      ),
      OnboardingQuestion(
        id: 'yoga_style',
        title: 'Preferred Yoga Style',
        subtitle: 'Which style resonates with you?',
        inputType: InputType.singleSelect,
        options: [
          QuestionOption(
            title: 'Hatha',
            description: 'Slow-paced and grounding',
          ),
          QuestionOption(
            title: 'Vinyasa',
            description: 'Breath-synchronized movement',
          ),
          QuestionOption(
            title: 'Ashtanga',
            description: 'Rigorous and structured',
          ),
          QuestionOption(
            title: 'Yin',
            description: 'Deep, long-held passive stretches',
          ),
          QuestionOption(
            title: 'Power',
            description: 'Fitness-based and intense',
          ),
        ],
      ),
      OnboardingQuestion(
        id: 'yoga_goal',
        title: 'Primary Goal',
        subtitle: 'What brings you to the mat?',
        inputType: InputType.singleSelect,
        options: [
          QuestionOption(
            title: 'Flexibility',
            description: 'Increase range of motion',
          ),
          QuestionOption(title: 'Mobility', description: 'Better joint health'),
          QuestionOption(
            title: 'Stress Relief',
            description: 'Calm the nervous system',
          ),
          QuestionOption(
            title: 'Balance',
            description: 'Improve physical stability',
          ),
          QuestionOption(
            title: 'Strength',
            description: 'Build functional strength',
          ),
        ],
      ),
      OnboardingQuestion(
        id: 'yoga_meditation',
        title: 'Meditation Interest',
        subtitle: 'Do you want meditation included in your flows?',
        inputType: InputType.yesNo,
      ),
      OnboardingQuestion(
        id: 'yoga_flexibility',
        title: 'Flexibility Level',
        subtitle: 'How flexible are you currently?',
        inputType: InputType.singleSelect,
        options: [
          QuestionOption(title: 'Low', description: 'Can barely touch knees'),
          QuestionOption(
            title: 'Moderate',
            description: 'Can touch shins/toes',
          ),
          QuestionOption(title: 'High', description: 'Palms flat on the floor'),
        ],
      ),
      OnboardingQuestion(
        id: 'yoga_duration',
        title: 'Practice Duration',
        subtitle: 'How long do you want to flow?',
        inputType: InputType.singleSelect,
        options: [
          QuestionOption(title: '15 min', description: 'Quick morning stretch'),
          QuestionOption(title: '30 min', description: 'Standard daily flow'),
          QuestionOption(title: '45 min', description: 'Deep session'),
          QuestionOption(
            title: '60 min',
            description: 'Full studio-length practice',
          ),
        ],
      ),
      OnboardingQuestion(
        id: 'yoga_days',
        title: 'Practice Days',
        subtitle: 'Which days will you unroll your mat?',
        inputType: InputType.multiSelect,
        options: [
          QuestionOption(title: 'Monday'),
          QuestionOption(title: 'Tuesday'),
          QuestionOption(title: 'Wednesday'),
          QuestionOption(title: 'Thursday'),
          QuestionOption(title: 'Friday'),
          QuestionOption(title: 'Saturday'),
          QuestionOption(title: 'Sunday'),
        ],
      ),
      OnboardingQuestion(
        id: 'yoga_workout_time',
        title: 'Preferred Practice Time',
        subtitle: 'When is your ideal time to practice?',
        inputType: InputType.singleSelect,
        options: [
          QuestionOption(title: 'Morning', description: 'Start the day right'),
          QuestionOption(title: 'Afternoon', description: 'Midday reset'),
          QuestionOption(title: 'Evening', description: 'Wind down for sleep'),
          QuestionOption(title: 'Flexible'),
        ],
      ),
      OnboardingQuestion(
        id: 'yoga_equipment',
        title: 'Equipment',
        subtitle: 'What props do you have?',
        inputType: InputType.multiSelect,
        options: [
          QuestionOption(title: 'Yoga Mat'),
          QuestionOption(title: 'Blocks'),
          QuestionOption(title: 'Strap'),
          QuestionOption(title: 'Bolster'),
        ],
      ),
      OnboardingQuestion(
        id: 'yoga_injuries',
        title: 'Injuries / Limitations',
        subtitle: 'Any areas we should be gentle with?',
        inputType: InputType.multiSelectPill,
        options: [
          QuestionOption(title: 'None'),
          QuestionOption(title: 'Back'),
          QuestionOption(title: 'Knee'),
          QuestionOption(title: 'Shoulder'),
          QuestionOption(title: 'Neck'),
          QuestionOption(title: 'Wrist'),
          QuestionOption(title: 'Other'),
        ],
      ),
    ],
  );

  static const List<OnboardingPhase> finalPhases = [
    // Phase 5
    OnboardingPhase(
      id: 'phase_5',
      title: 'Targets & Permissions',
      questions: [
        OnboardingQuestion(
          id: 'daily_targets',
          title: 'Your daily targets',
          subtitle: 'Set your baseline goals.',
          inputType: InputType.multiQuestion,
          subQuestions: [
            OnboardingQuestion(
              id: 'steps_target',
              title: 'Daily Steps',
              inputType: InputType.inlineSlider,
              min: 1000.0,
              max: 20000.0,
              suffixText: 'steps',
            ),
            OnboardingQuestion(
              id: 'sleep_target',
              title: 'Sleep Goal',
              inputType: InputType.inlineSlider,
              min: 4.0,
              max: 12.0,
              suffixText: 'hrs/night',
            ),
            OnboardingQuestion(
              id: 'water_target',
              title: 'Water Intake',
              inputType: InputType.inlineSlider,
              min: 1.0,
              max: 8.0,
              suffixText: 'liters',
            ),
          ],
        ),
        OnboardingQuestion(
          id: 'referral',
          title: 'Referral Source',
          subtitle: 'How did you hear about FLOWW?',
          inputType: InputType.singleSelect,
          options: [
            QuestionOption(title: 'Instagram'),
            QuestionOption(title: 'TikTok'),
            QuestionOption(title: 'YouTube'),
            QuestionOption(title: 'Friend'),
            QuestionOption(title: 'App Store'),
            QuestionOption(title: 'Google'),
            QuestionOption(title: 'Other'),
          ],
        ),
      ],
    ),
    // Phase 6
    OnboardingPhase(
      id: 'phase_6',
      title: 'FloState Calibration',
      questions: [
        OnboardingQuestion(
          id: 'morning_energy',
          title: 'Morning Energy',
          subtitle: 'How do you typically feel waking up?',
          inputType: InputType.singleSelect,
          options: [
            QuestionOption(
              title: 'Very Low',
              description: 'Struggle to get out of bed',
            ),
            QuestionOption(title: 'Low', description: 'Groggy and slow'),
            QuestionOption(
              title: 'Average',
              description: 'Normal, takes a bit to wake up',
            ),
            QuestionOption(title: 'High', description: 'Ready to go'),
            QuestionOption(
              title: 'Very High',
              description: 'Bursting with energy',
            ),
          ],
        ),
        OnboardingQuestion(
          id: 'recovery_speed',
          title: 'Recovery Speed',
          subtitle: 'How fast do you bounce back from sore muscles?',
          inputType: InputType.singleSelect,
          options: [
            QuestionOption(title: 'Very Slow', description: 'Sore for 4+ days'),
            QuestionOption(title: 'Slow', description: 'Sore for 3 days'),
            QuestionOption(title: 'Average', description: 'Sore for 1-2 days'),
            QuestionOption(title: 'Fast', description: 'Rarely sore for long'),
            QuestionOption(
              title: 'Very Fast',
              description: 'Ready to train the next day',
            ),
          ],
        ),
        OnboardingQuestion(
          id: 'stress_level',
          title: 'Stress Level',
          subtitle: 'High stress impacts recovery and performance.',
          inputType: InputType.singleSelect,
          options: [
            QuestionOption(
              title: 'Very Low',
              description: 'Completely relaxed lifestyle',
            ),
            QuestionOption(title: 'Low', description: 'Minimal stress'),
            QuestionOption(
              title: 'Moderate',
              description: 'Standard daily pressures',
            ),
            QuestionOption(
              title: 'High',
              description: 'Demanding job or lifestyle',
            ),
            QuestionOption(
              title: 'Very High',
              description: 'Constantly overwhelmed',
            ),
          ],
        ),
        OnboardingQuestion(
          id: 'sleep_quality',
          title: 'Sleep Quality',
          subtitle: 'Do you wake up feeling rested?',
          inputType: InputType.singleSelect,
          options: [
            QuestionOption(title: 'Poor', description: 'Wake up constantly'),
            QuestionOption(title: 'Fair', description: 'Restless sleep'),
            QuestionOption(
              title: 'Good',
              description: 'Solid, uninterrupted sleep',
            ),
            QuestionOption(
              title: 'Excellent',
              description: 'Deep, rejuvenating sleep',
            ),
          ],
        ),
        OnboardingQuestion(
          id: 'miss_workouts',
          title: 'Why do you miss workouts?',
          subtitle: 'Identifying barriers helps us build resilience.',
          inputType: InputType.multiSelect,
          options: [
            QuestionOption(
              title: 'Busy',
              description: 'Too many meetings or commitments',
            ),
            QuestionOption(
              title: 'Low Motivation',
              description: 'Just don\'t feel like it',
            ),
            QuestionOption(
              title: 'Work',
              description: 'Unexpected work delays',
            ),
            QuestionOption(
              title: 'Family',
              description: 'Prioritizing family time',
            ),
            QuestionOption(
              title: 'Travel',
              description: 'Frequent trips disrupt routine',
            ),
            QuestionOption(
              title: 'Poor Sleep',
              description: 'Too tired to train safely',
            ),
          ],
        ),
        OnboardingQuestion(
          id: 'training_behaviour',
          title: 'Training Behaviour',
          subtitle: 'What do you do on bad days?',
          inputType: InputType.singleSelect,
          options: [
            QuestionOption(
              title: 'Push Through',
              description: 'I force myself to do it anyway',
            ),
            QuestionOption(
              title: 'Reduce Intensity',
              description: 'I show up but take it easy',
            ),
            QuestionOption(
              title: 'Skip Workout',
              description: 'I take a rest day instead',
            ),
          ],
        ),
        OnboardingQuestion(
          id: 'wave_communication',
          title: 'WAVE Communication Style',
          subtitle: 'How do you want your AI coach to talk to you?',
          inputType: InputType.singleSelect,
          options: [
            QuestionOption(
              title: 'Motivating',
              description: 'Hype me up and keep me going',
            ),
            QuestionOption(
              title: 'Data Driven',
              description: 'Just give me the facts and numbers',
            ),
            QuestionOption(
              title: 'Supportive',
              description: 'Gentle, understanding check-ins',
            ),
            QuestionOption(
              title: 'Minimal',
              description: 'Only speak when necessary',
            ),
          ],
        ),
        OnboardingQuestion(
          id: 'push_intensity',
          title: 'Push Intensity Preference',
          subtitle: 'How hard should WAVE push you?',
          inputType: InputType.singleSelect,
          options: [
            QuestionOption(
              title: 'Gentle',
              description: 'Focus on habit building, not intensity',
            ),
            QuestionOption(
              title: 'Balanced',
              description: 'Push me, but respect my limits',
            ),
            QuestionOption(
              title: 'Push Me',
              description: 'Hold me strictly accountable',
            ),
          ],
        ),
      ],
    ),
    // Final
    OnboardingPhase(
      id: 'final',
      title: 'Final',
      questions: [
        OnboardingQuestion(
          id: 'loading_screen',
          title: 'WAVE is analyzing…',
          subtitle: 'WAVE is calculating your optimal starting point.',
          inputType: InputType.loading,
          options: [
            QuestionOption(title: 'Analyzing recovery profile'),
            QuestionOption(title: 'Learning energy patterns'),
            QuestionOption(title: 'Building nutrition model'),
            QuestionOption(title: 'Designing workout system'),
          ],
        ),
        OnboardingQuestion(
          id: 'summary_screen',
          title: 'Your FLOWW Blueprint is Ready',
          subtitle:
              'We have crafted a plan designed uniquely for your goals and lifestyle.',
          inputType: InputType.summary,
        ),
      ],
    ),
  ];
}
