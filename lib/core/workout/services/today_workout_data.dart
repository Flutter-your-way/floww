import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/core/workout/models/today_workout.dart';

class TodayWorkoutData {
  TodayWorkoutData._();

  static const legDay = TodayWorkout(
    id: 'leg-day-today',
    name: 'Leg Day',
    programLabel: 'Strength Builder Program · Week 4',
    durationMinutes: 45,
    focusLabel: 'Strength',
    recoveryLabel: 'High',
    goal: 'Increase squat weight.',
    insight:
        'WAVE has prepared this session based on your recovery score and last '
        "workout 48h ago. You're ready to push hard today.",
    exercises: [
      TodayWorkoutExercise(
        id: 'barbell-back-squat',
        imageUrl: AppImages.barbellBackSquat,
        name: 'Barbell Back Squat',
        sets: 4,
        reps: 8,
        restSeconds: 165,
        repsInReserve: 2,
        weightKg: 100,
        infoSections: [
          ExerciseInfoSection(
            id: 'personal-best',
            icon: Icons.emoji_events_outlined,
            title: 'Personal Best',
            tone: ExerciseInfoTone.neutral,
            items: [],
            emptyMessage: 'No PR logged yet. This could be your first!',
          ),
          ExerciseInfoSection(
            id: 'common-mistakes',
            icon: Icons.warning_amber_rounded,
            title: 'Common Mistakes',
            tone: ExerciseInfoTone.negative,
            items: [
              ExerciseInfoItem(text: 'Heels lifting off ground'),
              ExerciseInfoItem(text: 'Knees caving inward'),
              ExerciseInfoItem(text: 'Not reaching parallel depth'),
              ExerciseInfoItem(text: 'Forward lean of torso'),
            ],
          ),
          ExerciseInfoSection(
            id: 'guidelines',
            icon: Icons.checklist_rounded,
            title: 'Guidelines',
            tone: ExerciseInfoTone.positive,
            items: [
              ExerciseInfoItem(text: 'Feet shoulder-width, toes slightly out'),
              ExerciseInfoItem(text: 'Arms forward for balance'),
              ExerciseInfoItem(text: 'Sit back and down — chest up'),
              ExerciseInfoItem(text: 'Drive through full foot'),
            ],
          ),
          ExerciseInfoSection(
            id: 'equipment',
            icon: Icons.fitness_center,
            title: 'Equipment Required',
            tone: ExerciseInfoTone.positive,
            items: [
              ExerciseInfoItem(
                label: 'Barbell',
                text: 'Standard or Olympic bar',
              ),
              ExerciseInfoItem(
                label: 'Weight plates',
                text: 'Plus collars/clips',
              ),
              ExerciseInfoItem(label: 'Rack', text: 'Squat rack or power rack'),
              ExerciseInfoItem(
                label: 'Optional',
                text: 'flat lifting shoes, lifting belt, bar pad/towel.',
              ),
            ],
          ),
        ],
      ),
      TodayWorkoutExercise(
        id: 'romanian-deadlift',
        imageUrl: AppImages.romanianDeadlift,
        name: 'Romanian Deadlift',
        sets: 4,
        reps: 12,
        restSeconds: 120,
        repsInReserve: 2,
        weightKg: 120,
        infoSections: [
          ExerciseInfoSection(
            id: 'personal-best',
            icon: Icons.emoji_events_outlined,
            title: 'Personal Best',
            tone: ExerciseInfoTone.neutral,
            items: [],
            emptyMessage: 'No PR logged yet. This could be your first!',
          ),
          ExerciseInfoSection(
            id: 'common-mistakes',
            icon: Icons.warning_amber_rounded,
            title: 'Common Mistakes',
            tone: ExerciseInfoTone.negative,
            items: [
              ExerciseInfoItem(text: 'Rounding the lower back'),
              ExerciseInfoItem(text: 'Bending the knees too much'),
              ExerciseInfoItem(text: 'Letting the bar drift forward'),
              ExerciseInfoItem(text: 'Hyperextending at the top'),
            ],
          ),
          ExerciseInfoSection(
            id: 'guidelines',
            icon: Icons.checklist_rounded,
            title: 'Guidelines',
            tone: ExerciseInfoTone.positive,
            items: [
              ExerciseInfoItem(text: 'Hinge from the hips, soft knees'),
              ExerciseInfoItem(text: 'Keep the bar against your legs'),
              ExerciseInfoItem(text: 'Stretch the hamstrings, then drive up'),
              ExerciseInfoItem(text: 'Brace your core throughout'),
            ],
          ),
          ExerciseInfoSection(
            id: 'equipment',
            icon: Icons.fitness_center,
            title: 'Equipment Required',
            tone: ExerciseInfoTone.positive,
            items: [
              ExerciseInfoItem(
                label: 'Barbell',
                text: 'Standard or Olympic bar',
              ),
              ExerciseInfoItem(
                label: 'Weight plates',
                text: 'Plus collars/clips',
              ),
              ExerciseInfoItem(
                label: 'Optional',
                text: 'lifting straps, lifting belt.',
              ),
            ],
          ),
        ],
      ),
      TodayWorkoutExercise(
        id: 'leg-press',
        imageUrl: AppImages.legPress,
        name: 'Leg Press',
        sets: 4,
        reps: 12,
        restSeconds: 120,
        repsInReserve: 2,
        weightKg: 120,
        infoSections: [
          ExerciseInfoSection(
            id: 'personal-best',
            icon: Icons.emoji_events_outlined,
            title: 'Personal Best',
            tone: ExerciseInfoTone.neutral,
            items: [],
            emptyMessage: 'No PR logged yet. This could be your first!',
          ),
          ExerciseInfoSection(
            id: 'common-mistakes',
            icon: Icons.warning_amber_rounded,
            title: 'Common Mistakes',
            tone: ExerciseInfoTone.negative,
            items: [
              ExerciseInfoItem(text: 'Lifting hips off the seat'),
              ExerciseInfoItem(text: 'Locking out the knees'),
              ExerciseInfoItem(text: 'Partial range of motion'),
              ExerciseInfoItem(text: 'Pushing through the toes'),
            ],
          ),
          ExerciseInfoSection(
            id: 'guidelines',
            icon: Icons.checklist_rounded,
            title: 'Guidelines',
            tone: ExerciseInfoTone.positive,
            items: [
              ExerciseInfoItem(text: 'Feet shoulder-width on the platform'),
              ExerciseInfoItem(text: 'Lower until knees reach 90°'),
              ExerciseInfoItem(text: 'Keep the lower back flat'),
              ExerciseInfoItem(text: 'Drive through mid-foot and heel'),
            ],
          ),
          ExerciseInfoSection(
            id: 'equipment',
            icon: Icons.fitness_center,
            title: 'Equipment Required',
            tone: ExerciseInfoTone.positive,
            items: [
              ExerciseInfoItem(label: 'Machine', text: 'Leg press sled'),
              ExerciseInfoItem(label: 'Weight plates', text: 'Loaded per side'),
            ],
          ),
        ],
      ),
      TodayWorkoutExercise(
        id: 'walking-lunges',
        imageUrl: AppImages.walkingLunges,
        name: 'Walking Lunges',
        sets: 3,
        reps: 12,
        restSeconds: 90,
        repsInReserve: 3,
        weightKg: 20,
        infoSections: [
          ExerciseInfoSection(
            id: 'personal-best',
            icon: Icons.emoji_events_outlined,
            title: 'Personal Best',
            tone: ExerciseInfoTone.neutral,
            items: [],
            emptyMessage: 'No PR logged yet. This could be your first!',
          ),
          ExerciseInfoSection(
            id: 'common-mistakes',
            icon: Icons.warning_amber_rounded,
            title: 'Common Mistakes',
            tone: ExerciseInfoTone.negative,
            items: [
              ExerciseInfoItem(text: 'Front knee travelling past the toes'),
              ExerciseInfoItem(text: 'Short, unstable steps'),
              ExerciseInfoItem(text: 'Leaning the torso forward'),
              ExerciseInfoItem(text: 'Rear knee slamming the floor'),
            ],
          ),
          ExerciseInfoSection(
            id: 'guidelines',
            icon: Icons.checklist_rounded,
            title: 'Guidelines',
            tone: ExerciseInfoTone.positive,
            items: [
              ExerciseInfoItem(text: 'Long step, chest tall'),
              ExerciseInfoItem(text: 'Lower until both knees reach 90°'),
              ExerciseInfoItem(text: 'Push through the front heel'),
              ExerciseInfoItem(text: 'Alternate legs each step'),
            ],
          ),
          ExerciseInfoSection(
            id: 'equipment',
            icon: Icons.fitness_center,
            title: 'Equipment Required',
            tone: ExerciseInfoTone.positive,
            items: [
              ExerciseInfoItem(label: 'Dumbbells', text: 'One per hand'),
              ExerciseInfoItem(label: 'Space', text: 'Clear walking lane'),
            ],
          ),
        ],
      ),
      TodayWorkoutExercise(
        id: 'leg-extension',
        imageUrl: AppImages.legExtension,
        name: 'Leg Extension',
        sets: 3,
        reps: 15,
        restSeconds: 75,
        repsInReserve: 2,
        weightKg: 60,
        infoSections: [
          ExerciseInfoSection(
            id: 'personal-best',
            icon: Icons.emoji_events_outlined,
            title: 'Personal Best',
            tone: ExerciseInfoTone.neutral,
            items: [],
            emptyMessage: 'No PR logged yet. This could be your first!',
          ),
          ExerciseInfoSection(
            id: 'common-mistakes',
            icon: Icons.warning_amber_rounded,
            title: 'Common Mistakes',
            tone: ExerciseInfoTone.negative,
            items: [
              ExerciseInfoItem(text: 'Swinging the weight up'),
              ExerciseInfoItem(text: 'Pad resting too high on the shin'),
              ExerciseInfoItem(text: 'Dropping the weight on the way down'),
              ExerciseInfoItem(text: 'Lifting the hips off the seat'),
            ],
          ),
          ExerciseInfoSection(
            id: 'guidelines',
            icon: Icons.checklist_rounded,
            title: 'Guidelines',
            tone: ExerciseInfoTone.positive,
            items: [
              ExerciseInfoItem(text: 'Align knees with the machine pivot'),
              ExerciseInfoItem(text: 'Extend fully, pause at the top'),
              ExerciseInfoItem(text: 'Lower under control'),
              ExerciseInfoItem(text: 'Keep the back against the pad'),
            ],
          ),
          ExerciseInfoSection(
            id: 'equipment',
            icon: Icons.fitness_center,
            title: 'Equipment Required',
            tone: ExerciseInfoTone.positive,
            items: [
              ExerciseInfoItem(label: 'Machine', text: 'Leg extension machine'),
            ],
          ),
        ],
      ),
      TodayWorkoutExercise(
        id: 'standing-calf-raise',
        imageUrl: AppImages.standingCalfRaise,
        name: 'Standing Calf Raise',
        sets: 3,
        reps: 20,
        restSeconds: 60,
        repsInReserve: 2,
        weightKg: 40,
        infoSections: [
          ExerciseInfoSection(
            id: 'personal-best',
            icon: Icons.emoji_events_outlined,
            title: 'Personal Best',
            tone: ExerciseInfoTone.neutral,
            items: [],
            emptyMessage: 'No PR logged yet. This could be your first!',
          ),
          ExerciseInfoSection(
            id: 'common-mistakes',
            icon: Icons.warning_amber_rounded,
            title: 'Common Mistakes',
            tone: ExerciseInfoTone.negative,
            items: [
              ExerciseInfoItem(text: 'Bouncing out of the bottom'),
              ExerciseInfoItem(text: 'Bending the knees to cheat'),
              ExerciseInfoItem(text: 'Cutting the range of motion short'),
              ExerciseInfoItem(text: 'Rushing every rep'),
            ],
          ),
          ExerciseInfoSection(
            id: 'guidelines',
            icon: Icons.checklist_rounded,
            title: 'Guidelines',
            tone: ExerciseInfoTone.positive,
            items: [
              ExerciseInfoItem(text: 'Balls of the feet on the platform'),
              ExerciseInfoItem(text: 'Drop the heels for a full stretch'),
              ExerciseInfoItem(text: 'Rise as high as possible, pause'),
              ExerciseInfoItem(text: 'Keep the legs straight'),
            ],
          ),
          ExerciseInfoSection(
            id: 'equipment',
            icon: Icons.fitness_center,
            title: 'Equipment Required',
            tone: ExerciseInfoTone.positive,
            items: [
              ExerciseInfoItem(label: 'Machine', text: 'Standing calf raise'),
              ExerciseInfoItem(label: 'Step', text: 'Or raised platform'),
            ],
          ),
        ],
      ),
    ],
  );
}
