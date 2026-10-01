import 'package:floww/config/constants/app_api.dart';
import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/config/services/app_api_client.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';

class WorkoutPlanGeneratorService {
  WorkoutPlanGeneratorService({AppApiClient? apiClient})
    : _apiClient = apiClient ?? AppApiClient();

  static const String _failure =
      'WAVE could not build your plan. Please try again.';

  final AppApiClient _apiClient;

  Future<WorkoutProgramEntity> generate() async {
    try {
      final data = await _apiClient.post(
        AppApi.generateWorkoutPlan,
        timeout: AppApi.aiResponseTimeout,
      );
      final program = data['program'];
      if (program is! Map) throw WorkoutException(_failure);
      return WorkoutProgramEntity.fromJson(Map<String, dynamic>.from(program));
    } on AppApiException catch (error) {
      throw WorkoutException(error.message);
    }
  }
}
