import 'package:flutter/foundation.dart';

import 'package:floww/core/onboarding/data/onboarding_data.dart';
import 'package:floww/core/onboarding/models/onboarding_models.dart';
import 'package:floww/core/onboarding/providers/onboarding_provider.dart';
import 'package:floww/core/settings/models/onboarding_answers_data.dart';
import 'package:floww/core/settings/services/onboarding_answers_service.dart';

class OnboardingAnswerEditViewModel extends ChangeNotifier {
  OnboardingAnswerEditViewModel(this._service, OnboardingAnswerEditArgs args)
    : answers = OnboardingProvider(initialAnswers: args.answers),
      _initialAnswers = Map.of(args.answers),
      _initialPhaseIds = {
        for (final phase in OnboardingData.activePhasesFor(args.answers))
          phase.id,
      },
      _currentId = args.questionId {
    _visited.add(_currentId);
    answers.addListener(_notify);
  }

  static const String _trainingSetupPhaseId = 'phase_4';

  final OnboardingAnswersService _service;
  final OnboardingProvider answers;
  final Map<String, dynamic> _initialAnswers;
  final Set<String> _initialPhaseIds;
  final List<String> _history = [];
  final Set<String> _visited = {};

  String _currentId;
  bool _isSaving = false;
  bool _disposed = false;
  String? _errorMessage;

  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  List<OnboardingPhase> get _phases =>
      OnboardingData.activePhasesFor(answers.answers);

  OnboardingPhase get phase => _phases.firstWhere(
    (phase) => phase.questions.any((question) => question.id == _currentId),
    orElse: () => _phases.first,
  );

  OnboardingQuestion get question => phase.questions.firstWhere(
    (question) => question.id == _currentId,
    orElse: () => phase.questions.first,
  );

  bool get canContinue => answers.isAnswered(question);

  String get actionLabel => _nextPending == null ? 'Save Changes' : 'Continue';

  OnboardingQuestion? get _nextPending {
    for (final phase in _phases) {
      final isNewPhase = !_initialPhaseIds.contains(phase.id);
      for (final question in phase.questions) {
        if (_visited.contains(question.id) ||
            question.inputType == InputType.loading ||
            question.inputType == InputType.summary) {
          continue;
        }
        if (isNewPhase || !answers.isAnswered(question)) return question;
      }
    }
    return null;
  }

  Set<String> get _trainingQuestionIds {
    final initialPhases = OnboardingData.activePhasesFor(_initialAnswers);
    final corePhaseIds = {
      for (final phase in [
        ...OnboardingData.corePhases,
        ...OnboardingData.finalPhases,
      ])
        if (phase.id != _trainingSetupPhaseId) phase.id,
    };
    return {
      for (final phase in [...initialPhases, ..._phases])
        if (!corePhaseIds.contains(phase.id))
          for (final question in phase.questions) ...[
            question.id,
            for (final sub in question.subQuestions ?? const <OnboardingQuestion>[])
              sub.id,
          ],
    };
  }

  bool get _changesTraining {
    final current = answers.answers;
    for (final id in _trainingQuestionIds) {
      if (!_isSame(_initialAnswers[id], current[id])) return true;
    }
    return false;
  }

  static bool _isSame(Object? a, Object? b) {
    if (a is List && b is List) {
      return listEquals(
        [for (final item in a) item.toString()],
        [for (final item in b) item.toString()],
      );
    }
    return a == b;
  }

  bool back() {
    if (_history.isEmpty) return false;
    _visited.remove(_currentId);
    _currentId = _history.removeLast();
    _notify();
    return true;
  }

  Future<OnboardingAnswerEditResult?> proceed() async {
    if (_isSaving || !canContinue) return null;
    final next = _nextPending;
    if (next != null) {
      _history.add(_currentId);
      _currentId = next.id;
      _visited.add(next.id);
      _notify();
      return null;
    }
    return _save();
  }

  Future<OnboardingAnswerEditResult?> _save() async {
    _isSaving = true;
    _errorMessage = null;
    _notify();

    try {
      await _service.saveAnswers(Map.of(answers.answers));
      return _changesTraining
          ? OnboardingAnswerEditResult.trainingChanged
          : OnboardingAnswerEditResult.saved;
    } on OnboardingAnswersException catch (e) {
      _errorMessage = e.message;
      return null;
    } finally {
      _isSaving = false;
      _notify();
    }
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    answers.removeListener(_notify);
    answers.dispose();
    super.dispose();
  }
}
