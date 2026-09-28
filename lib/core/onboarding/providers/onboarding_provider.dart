import 'package:flutter/material.dart';
import '../data/onboarding_data.dart';
import '../models/onboarding_models.dart';
import '../services/onboarding_service.dart';

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider({OnboardingService? onboardingService})
    : _onboardingService = onboardingService ?? OnboardingService();

  final OnboardingService _onboardingService;

  int _currentPhaseIndex = 0;
  int _currentQuestionIndex = 0;
  final Map<String, dynamic> _answers = {};

  bool isSubmitting = false;
  String? submitError;

  int get currentPhaseIndex => _currentPhaseIndex;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, dynamic> get answers => _answers;

  /// Dynamically computes the list of active phases based on the user's answers.
  List<OnboardingPhase> get activePhases {
    List<OnboardingPhase> phases = [];
    // Phases 1 through 4
    phases.addAll(OnboardingData.corePhases);

    // Dynamic Phase 4.1 based on Training Type selection
    final trainingType = _answers['training_type'];
    if (trainingType != null) {
      if (trainingType is List && trainingType.isNotEmpty) {
        // Just in case it's stored as a list
        final type = trainingType.first.toString().toLowerCase();
        if (type == 'gym') phases.add(OnboardingData.gymPhase);
        if (type == 'calisthenics')
          phases.add(OnboardingData.calisthenicsPhase);
        if (type == 'yoga') phases.add(OnboardingData.yogaPhase);
      } else if (trainingType is String) {
        final type = trainingType.toLowerCase();
        if (type == 'gym') phases.add(OnboardingData.gymPhase);
        if (type == 'calisthenics')
          phases.add(OnboardingData.calisthenicsPhase);
        if (type == 'yoga') phases.add(OnboardingData.yogaPhase);
      }
    }

    // Phases 5, 6, and Final
    phases.addAll(OnboardingData.finalPhases);
    return phases;
  }

  OnboardingPhase get currentPhase => activePhases[_currentPhaseIndex];
  OnboardingQuestion get currentQuestion =>
      currentPhase.questions[_currentQuestionIndex];

  /// Progress across all active phases (0.0 to 1.0)
  double get globalProgress {
    int totalQuestions = 0;
    for (var phase in activePhases) {
      totalQuestions += phase.questions.length;
    }

    int currentGlobalIndex = 0;
    for (int i = 0; i < _currentPhaseIndex; i++) {
      currentGlobalIndex += activePhases[i].questions.length;
    }
    currentGlobalIndex += _currentQuestionIndex;

    if (totalQuestions == 0) return 0.0;
    return (currentGlobalIndex + 1) / totalQuestions;
  }

  /// Get answer for a specific question
  dynamic getAnswer(String questionId) {
    return _answers[questionId];
  }

  /// Save an answer and notify listeners so UI updates instantly
  void setAnswer(String questionId, dynamic answer) {
    _answers[questionId] = answer;
    notifyListeners();
  }

  /// Helper for Multi-Select toggling
  void toggleMultiSelectAnswer(String questionId, String option) {
    List<String> currentList = [];
    if (_answers[questionId] != null) {
      currentList = List<String>.from(_answers[questionId]);
    }

    if (currentList.contains(option)) {
      currentList.remove(option);
    } else {
      currentList.add(option);
    }

    _answers[questionId] = currentList;
    notifyListeners();
  }

  /// Go back to the previous question or phase
  void previousQuestion(PageController pageController) {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      _animateToCurrentPage(pageController);
    } else if (_currentPhaseIndex > 0) {
      _currentPhaseIndex--;
      _currentQuestionIndex = currentPhase.questions.length - 1;
      _animateToCurrentPage(pageController);
    }
    notifyListeners();
  }

  /// Proceed to the next question or phase. Returns true once the whole
  /// flow is complete and the answers have been submitted successfully.
  Future<bool> nextQuestion(PageController pageController) async {
    if (_currentQuestionIndex < currentPhase.questions.length - 1) {
      _currentQuestionIndex++;
      _animateToCurrentPage(pageController);
      notifyListeners();
      return false;
    } else if (_currentPhaseIndex < activePhases.length - 1) {
      _currentPhaseIndex++;
      _currentQuestionIndex = 0;
      _animateToCurrentPage(pageController);
      notifyListeners();
      return false;
    }

    submitError = null;
    isSubmitting = true;
    notifyListeners();

    try {
      await _onboardingService.submitOnboardingAnswers(_answers);
      return true;
    } on OnboardingException catch (e) {
      submitError = e.message;
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  /// Private helper to animate the page view smoothly
  void _animateToCurrentPage(PageController pageController) {
    if (pageController.hasClients) {
      // Calculate global page index across all active phases
      int globalIndex = 0;
      for (int i = 0; i < _currentPhaseIndex; i++) {
        globalIndex += activePhases[i].questions.length;
      }
      globalIndex += _currentQuestionIndex;

      pageController.animateToPage(
        globalIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Validates if the current question has an answer so the Continue button can be enabled
  bool get canContinue {
    if (currentQuestion.inputType == InputType.multiQuestion) {
      if (currentQuestion.subQuestions == null ||
          currentQuestion.subQuestions!.isEmpty)
        return true;
      for (final subQ in currentQuestion.subQuestions!) {
        final ans = _answers[subQ.id];
        if (ans == null) return false;
      }
      return true;
    }

    final answer = _answers[currentQuestion.id];
    switch (currentQuestion.inputType) {
      case InputType.text:
        return answer != null && answer.toString().trim().isNotEmpty;
      case InputType.multiSelect:
      case InputType.multiSelectPill:
        return answer != null && (answer as List).isNotEmpty;
      case InputType.inlineSlider:
        return answer != null; // Will be initialized by renderer if null
      case InputType.loading:
      case InputType.summary:
        return true; // Always allow continue for non-input screens
      default:
        return answer != null; // Most others just need a non-null answer
    }
  }
}
