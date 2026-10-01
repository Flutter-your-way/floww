import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/core/workout/models/program_goal.dart';
import 'package:floww/core/workout/services/workout_catalog_data.dart';

class ProgramArtwork {
  ProgramArtwork._();

  static const Map<String, String> _byProgram = {
    'strength-builder': AppImages.programStrengthPhoto,
    'fat-loss-shred': AppImages.programFatLossPhoto,
    'muscle-hypertrophy': AppImages.programHypertrophyPhoto,
    'cardio-base': AppImages.programCardioPhoto,
    'beginner-full-body': AppImages.programFullBodyPhoto,
    'upper-lower-split': AppImages.programSplitPhoto,
    'home-bodyweight': AppImages.programHomePhoto,
    'glute-leg-focus': AppImages.programLegsPhoto,
    'conditioning-express': AppImages.programConditioningPhoto,
    'core-mobility': AppImages.programMobilityPhoto,
  };

  static const Map<ProgramGoal, String> _byGoal = {
    ProgramGoal.strength: AppImages.programStrengthPhoto,
    ProgramGoal.muscle: AppImages.programHypertrophyPhoto,
    ProgramGoal.fatLoss: AppImages.programFatLossPhoto,
    ProgramGoal.cardio: AppImages.programCardioPhoto,
    ProgramGoal.home: AppImages.programHomePhoto,
    ProgramGoal.mobility: AppImages.programMobilityPhoto,
  };

  static String of(WorkoutProgramEntity program) =>
      _byProgram[program.id] ??
      _byProgram[program.basedOn] ??
      _byGoal[program.goal] ??
      AppImages.programStrengthPhoto;

  static String? ofPlan(WorkoutPlanEntity plan) =>
      _ofEntries(plan.exercises, plan.programId);

  static String? ofSession(WorkoutSessionEntity session) =>
      _ofEntries(session.exercises, session.programId);

  static String? _ofEntries(
    List<WorkoutEntryEntity> entries,
    String? programId,
  ) {
    for (final exercise in entries) {
      final image =
          exercise.imageUrl ?? WorkoutCatalogData.imageFor(exercise.exerciseId);
      if (image != null) return image;
    }
    return programId == null ? null : _byProgram[programId];
  }
}
