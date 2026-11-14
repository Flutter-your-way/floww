import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/onboarding/data/onboarding_data.dart';
import 'package:floww/core/settings/services/onboarding_answers_service.dart';
import 'package:floww/core/workout/models/workout_discipline.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_plan_generator_service.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';
import 'package:floww/core/workout/services/workout_program_service.dart';

class WorkoutPlanBuildService {
  WorkoutPlanBuildService({
    WorkoutPlanGeneratorService? generatorService,
    WorkoutProgramService? programService,
    WorkoutCatalogService? catalogService,
    WorkoutPlanService? planService,
    OnboardingAnswersService? answersService,
  }) : _generatorService = generatorService ?? WorkoutPlanGeneratorService(),
       _programService = programService ?? WorkoutProgramService(),
       _catalogService = catalogService ?? WorkoutCatalogService(),
       _answersService = answersService ?? OnboardingAnswersService(),
       _planService =
           planService ??
           WorkoutPlanService(catalogService ?? WorkoutCatalogService());

  static const int longPlanDays = 90;

  static Future<bool>? _renewal;

  final WorkoutPlanGeneratorService _generatorService;
  final WorkoutProgramService _programService;
  final WorkoutCatalogService _catalogService;
  final WorkoutPlanService _planService;
  final OnboardingAnswersService _answersService;

  static bool wantsLongPlan(Map<String, dynamic> answers) =>
      WorkoutDiscipline.fromAnswers(answers) == WorkoutDiscipline.gym &&
      answers[OnboardingData.gymPlanLengthId] == OnboardingData.threeMonthPlan;

  static bool hasEnded(WorkoutStateEntity state, DateTime date) {
    final active = state.activeProgram;
    return active != null && active.hasEndedBy(date);
  }

  static bool isGeneratedActive(WorkoutStateEntity state) {
    final active = state.activeProgram;
    return active != null && active.id == state.generatedProgramId;
  }

  Future<WorkoutProgramEntity> build({Map<String, dynamic>? answers}) async {
    final generated = await _generatorService.generate();
    final program = await _sizedPlanOf(generated, answers ?? await _answers());
    final today = AppDateUtils.dateOnly(DateTime.now());
    final active = _programService.activeEntryFor(program, startDate: today);
    await _planService.scheduleProgram(
      program,
      active,
      from: today,
      saveActive: true,
    );
    return program;
  }

  Future<bool> renewIfEnded() =>
      _renewal ??= _renew().whenComplete(() => _renewal = null);

  Future<bool> _renew() async {
    final state = await _programService.loadState();
    if (!isGeneratedActive(state) || !hasEnded(state, DateTime.now())) {
      return false;
    }
    await build();
    return true;
  }

  Future<Map<String, dynamic>> _answers() async {
    try {
      return await _answersService.loadAnswers();
    } on OnboardingAnswersException catch (_) {
      return const {};
    }
  }

  Future<WorkoutProgramEntity> _sizedPlanOf(
    WorkoutProgramEntity program,
    Map<String, dynamic> answers,
  ) async {
    if (!wantsLongPlan(answers) || program.course != null) return program;
    if (program.lengthDays == longPlanDays) return program;
    final sized = program.copyWith(
      lengthDays: longPlanDays,
      weeks: (longPlanDays / DateTime.daysPerWeek).ceil(),
    );
    await _catalogService.saveProgram(sized);
    return sized;
  }
}
