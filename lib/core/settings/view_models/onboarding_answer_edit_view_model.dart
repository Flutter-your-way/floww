import 'package:flutter/foundation.dart';

import 'package:floww/core/onboarding/data/onboarding_data.dart';
import 'package:floww/core/onboarding/models/onboarding_models.dart';
import 'package:floww/core/onboarding/providers/onboarding_provider.dart';
import 'package:floww/core/settings/models/onboarding_answers_data.dart';
import 'package:floww/core/settings/services/onboarding_answers_service.dart';

class OnboardingAnswerEditViewModel extends ChangeNotifier {
  OnboardingAnswerEditViewModel(this._service, OnboardingAnswerEditArgs args)
    : answers = OnboardingProvider(initialAnswers: args.answers),
      _currentId = args.questionId {
    answers.addListener(_notify);
  }

  final OnboardingAnswersService _service;
  final OnboardingProvider answers;
  final List<String> _history = [];

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

  String get actionLabel => _nextMissing == null ? 'Save Changes' : 'Continue';

  OnboardingQuestion? get _nextMissing {
    for (final phase in _phases) {
      for (final question in phase.questions) {
        if (question.id == _currentId ||
            question.inputType == InputType.loading ||
            question.inputType == InputType.summary) {
          continue;
        }
        if (!answers.isAnswered(question)) return question;
      }
    }
    return null;
  }

  bool back() {
    if (_history.isEmpty) return false;
    _currentId = _history.removeLast();
    _notify();
    return true;
  }

  Future<bool> proceed() async {
    if (_isSaving || !canContinue) return false;
    final next = _nextMissing;
    if (next != null) {
      _history.add(_currentId);
      _currentId = next.id;
      _notify();
      return false;
    }
    return _save();
  }

  Future<bool> _save() async {
    _isSaving = true;
    _errorMessage = null;
    _notify();

    try {
      await _service.saveAnswers(Map.of(answers.answers));
      return true;
    } on OnboardingAnswersException catch (e) {
      _errorMessage = e.message;
      return false;
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
