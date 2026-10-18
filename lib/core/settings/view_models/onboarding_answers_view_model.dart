import 'package:flutter/foundation.dart';

import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/onboarding/data/onboarding_data.dart';
import 'package:floww/core/onboarding/models/onboarding_models.dart';
import 'package:floww/core/settings/models/onboarding_answers_data.dart';
import 'package:floww/core/settings/services/onboarding_answers_service.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';
import 'package:floww/core/workout/services/workout_plan_generator_service.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';
import 'package:floww/core/workout/services/workout_program_service.dart';

class OnboardingAnswersViewModel extends ChangeNotifier {
  OnboardingAnswersViewModel(
    this._service,
    this._generatorService,
    this._programService,
    this._planService,
  ) {
    load();
  }

  final OnboardingAnswersService _service;
  final WorkoutPlanGeneratorService _generatorService;
  final WorkoutProgramService _programService;
  final WorkoutPlanService _planService;

  Map<String, dynamic> _answers = const {};
  bool _isLoading = true;
  bool _isRebuilding = false;
  bool _disposed = false;
  String? _errorMessage;
  String? _rebuildMessage;

  bool get isRebuilding => _isRebuilding;

  String? get rebuildMessage => _rebuildMessage;

  String get rebuildTitle => 'Update your training plan?';

  String get rebuildPrompt =>
      'WAVE already knows your new answers. Rebuild your workout plan so '
      'your sessions match them, starting today.';

  String get rebuildConfirmLabel => 'Rebuild Plan';

  String get rebuildLaterLabel => 'Not Now';

  Future<void> rebuildPlan() async {
    if (_isRebuilding) return;
    _isRebuilding = true;
    _rebuildMessage = 'WAVE is rebuilding your plan…';
    _notify();
    try {
      final program = await _generatorService.generate();
      final today = DateTime.now();
      final active = _programService.activeEntryFor(program, startDate: today);
      await _planService.scheduleProgram(
        program,
        active,
        from: today,
        saveActive: true,
      );
      _rebuildMessage = 'Your new plan is ready in Workouts.';
    } on WorkoutException catch (error) {
      _rebuildMessage = error.message;
    } finally {
      _isRebuilding = false;
      _notify();
    }
  }

  String get title => 'Onboarding Answers';

  String get note =>
      'These answers shape your plan, targets, and how WAVE coaches you. '
      'Tap any answer to update it.';

  String get emptyValue => 'Not answered';

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<OnboardingAnswerSection> get sections => [
    for (final phase in OnboardingData.activePhasesFor(_answers))
      if (_editableQuestions(phase).isNotEmpty)
        OnboardingAnswerSection(
          title: phase.title,
          items: [
            for (final question in _editableQuestions(phase)) _itemOf(question),
          ],
        ),
  ];

  OnboardingAnswerEditArgs editArgsFor(OnboardingQuestion question) =>
      OnboardingAnswerEditArgs(
        questionId: question.id,
        answers: Map.of(_answers),
      );

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      _answers = await _service.loadAnswers();
    } on OnboardingAnswersException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  List<OnboardingQuestion> _editableQuestions(OnboardingPhase phase) => [
    for (final question in phase.questions)
      if (question.inputType != InputType.loading &&
          question.inputType != InputType.summary)
        question,
  ];

  OnboardingAnswerItem _itemOf(OnboardingQuestion question) {
    final value = _valueOf(question);
    return OnboardingAnswerItem(
      question: question,
      value: value ?? emptyValue,
      isAnswered: value != null,
    );
  }

  String? _valueOf(OnboardingQuestion question) {
    if (question.inputType == InputType.multiQuestion) {
      final parts = [
        for (final sub in question.subQuestions ?? const <OnboardingQuestion>[])
          ?_valueOf(sub),
      ];
      return parts.isEmpty ? null : parts.join(' · ');
    }

    final answer = _answers[question.id];
    return switch (answer) {
      String() when answer.trim().isNotEmpty => answer.trim(),
      List() when answer.isNotEmpty => answer.join(', '),
      num() => _numberOf(question, answer.toDouble()),
      DateTime() =>
        question.inputType == InputType.timePicker
            ? _timeOf(answer)
            : answer.year.toString(),
      _ => null,
    };
  }

  String _numberOf(OnboardingQuestion question, double value) {
    final number = question.id == 'steps_target'
        ? NumberFormatter.grouped(value.round())
        : NumberFormatter.trimmed(value);
    final suffix = question.suffixText;
    return suffix == null ? number : '$number $suffix';
  }

  String _timeOf(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
