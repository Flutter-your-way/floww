import 'package:floww/config/constants/app_images.dart';
import 'package:floww/core/workout/models/exercise.dart';

extension MuscleGroupArtwork on MuscleGroup {
  String get photo => switch (this) {
    MuscleGroup.chest => AppImages.chestGroupPhoto,
    MuscleGroup.back => AppImages.backGroupPhoto,
    MuscleGroup.legs => AppImages.legsGroupPhoto,
    MuscleGroup.shoulders => AppImages.shouldersGroupPhoto,
    MuscleGroup.arms => AppImages.armsGroupPhoto,
    MuscleGroup.core => AppImages.coreGroupPhoto,
    MuscleGroup.cardio => AppImages.cardioGroupPhoto,
    MuscleGroup.other => AppImages.programMobilityPhoto,
  };
}
