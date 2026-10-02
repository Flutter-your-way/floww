import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_motion.dart';
import '../data/onboarding_data.dart';
import '../models/goal_pace.dart';
import '../models/onboarding_analysis.dart';
import '../models/onboarding_models.dart';
import '../services/onboarding_service.dart';

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider({
    OnboardingService? onboardingService,
    Map<String, dynamic>? initialAnswers,
  }) : _onboardingService = onboardingService ?? OnboardingService() {
    if (initialAnswers != null) _answers.addAll(initialAnswers);
  }

  final OnboardingService _onboardingService;

  int _currentPhaseIndex = 0;
  int _currentQuestionIndex = 0;
  final Map<String, dynamic> _answers = {};

  bool isSubmitting = false;
  String? submitError;

  OnboardingAnalysis? _analysis;
  bool isAnalyzing = false;
  String? analysisError;
  int _analysisRun = 0;

  int get currentPhaseIndex => _currentPhaseIndex;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, dynamic> get answers => _answers;
  OnboardingAnalysis? get analysis => _analysis;

  List<OnboardingPhase> get activePhases =>
      OnboardingData.activePhasesFor(_answers);

  OnboardingPhase get currentPhase => activePhases[_currentPhaseIndex];
  OnboardingQuestion get currentQuestion =>
      currentPhase.questions[_currentQuestionIndex];

  bool get isOnAnalysis => currentQuestion.inputType == InputType.loading;

  bool get isOnBlueprint =>
      currentQuestion.inputType == InputType.summary && _analysis != null;

  List<String> get analysisSteps => [
    for (final option in currentQuestion.options ?? const <QuestionOption>[])
      option.title,
  ];

  String get blueprintTitle {
    final name = _answers['name'];
    final firstName = name is String ? name.trim().split(' ').first : '';
    return firstName.isEmpty ? 'Your Blueprint' : "$firstName's Blueprint";
  }

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

  Duration? sleepDurationFor(String questionId) {
    if (questionId != 'sleep_schedule') return null;
    final sleep = _answers['sleep_time'];
    final wake = _answers['wake_time'];
    if (sleep is! DateTime || wake is! DateTime) return null;
    final sleepMinutes = sleep.hour * 60 + sleep.minute;
    final wakeMinutes = wake.hour * 60 + wake.minute;
    return Duration(
      minutes: (wakeMinutes - sleepMinutes) % Duration.minutesPerDay,
    );
  }

  static const String primaryGoalId = 'primary_goal';
  static const String goalPaceId = 'goal_pace';
  static const String goalPaceUnitId = 'goal_pace_unit';

  bool hasGoalPace(String questionId, String option) =>
      questionId == primaryGoalId && GoalPaceConfig.byGoal.containsKey(option);

  GoalPaceProjection? goalPaceProjectionFor(String questionId, String option) {
    if (questionId != primaryGoalId) return null;
    final config = GoalPaceConfig.byGoal[option];
    if (config == null) return null;
    final pace = _answers[goalPaceId];
    final weight = _answers['weight'];
    return GoalPaceProjection.from(
      config: config,
      pace: pace is double && _answers[primaryGoalId] == option
          ? config.snap(pace)
          : config.initial,
      weight: weight is double ? weight : GoalPaceConfig.fallbackWeight,
      today: DateTime.now(),
    );
  }

  void setGoalPace(GoalPaceConfig config, double pace) {
    final snapped = config.snap(pace);
    if (_answers[goalPaceId] == snapped) return;
    setAnswer(goalPaceId, snapped);
  }

  /// Save an answer and notify listeners so UI updates instantly
  void setAnswer(String questionId, dynamic answer) {
    if (questionId == primaryGoalId && _answers[questionId] != answer) {
      _resetGoalPace(GoalPaceConfig.byGoal[answer]);
    }
    _answers[questionId] = answer;
    _analysis = null;
    notifyListeners();
  }

  void toggleAnswer(String questionId, String option) {
    if (_answers[questionId] != option) {
      setAnswer(questionId, option);
      return;
    }
    _answers.remove(questionId);
    if (questionId == primaryGoalId) _resetGoalPace(null);
    _analysis = null;
    notifyListeners();
  }

  void _resetGoalPace(GoalPaceConfig? config) {
    if (config == null) {
      _answers
        ..remove(goalPaceId)
        ..remove(goalPaceUnitId);
      return;
    }
    _answers[goalPaceId] = config.initial;
    _answers[goalPaceUnitId] = config.unit;
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
    _analysis = null;
    notifyListeners();
  }

  bool _stepForward() {
    if (_currentQuestionIndex < currentPhase.questions.length - 1) {
      _currentQuestionIndex++;
      return true;
    }
    if (_currentPhaseIndex < activePhases.length - 1) {
      _currentPhaseIndex++;
      _currentQuestionIndex = 0;
      return true;
    }
    return false;
  }

  bool _stepBack() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      return true;
    }
    if (_currentPhaseIndex > 0) {
      _currentPhaseIndex--;
      _currentQuestionIndex = currentPhase.questions.length - 1;
      return true;
    }
    return false;
  }

  /// Go back to the previous question or phase
  void previousQuestion(PageController pageController) {
    if (isOnAnalysis) {
      _analysisRun++;
      isAnalyzing = false;
      analysisError = null;
    }
    if (_stepBack()) {
      if (isOnAnalysis) _stepBack();
      _animateToCurrentPage(pageController);
    }
    notifyListeners();
  }

  /// Proceed to the next question or phase. Returns true once the whole
  /// flow is complete and the answers have been submitted successfully.
  Future<bool> nextQuestion(PageController pageController) async {
    if (_stepForward()) {
      _animateToCurrentPage(pageController);
      notifyListeners();
      if (isOnAnalysis) analyzeProfile(pageController);
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

  Future<void> analyzeProfile(PageController pageController) async {
    if (isAnalyzing) return;
    final run = ++_analysisRun;
    isAnalyzing = true;
    analysisError = null;
    notifyListeners();

    final minimumDisplay = Future<void>.delayed(AppMotion.profileAnalysis);
    try {
      final analysis =
          _analysis ??
          await _onboardingService.analyzeOnboardingAnswers(Map.of(_answers));
      await minimumDisplay;
      if (run != _analysisRun) return;
      _analysis = analysis;
      if (isOnAnalysis && _stepForward()) {
        _animateToCurrentPage(pageController);
      }
    } on OnboardingException catch (e) {
      await minimumDisplay;
      if (run != _analysisRun) return;
      analysisError = e.message;
    }
    isAnalyzing = false;
    notifyListeners();
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

  bool get canContinue => isAnswered(currentQuestion);

  bool isAnswered(OnboardingQuestion question) {
    if (question.inputType == InputType.multiQuestion) {
      if (question.subQuestions == null || question.subQuestions!.isEmpty) {
        return true;
      }
      for (final subQ in question.subQuestions!) {
        final ans = _answers[subQ.id];
        if (ans == null) return false;
      }
      return true;
    }

    final answer = _answers[question.id];
    switch (question.inputType) {
      case InputType.text:
        return answer != null && answer.toString().trim().isNotEmpty;
      case InputType.multiSelect:
      case InputType.multiSelectPill:
        return answer is List && answer.isNotEmpty;
      case InputType.inlineSlider:
        return answer != null; // Will be initialized by renderer if null
      case InputType.loading:
        return false;
      case InputType.summary:
        return _analysis != null;
      default:
        return answer != null; // Most others just need a non-null answer
    }
  }

  @override
  void dispose() {
    _analysisRun++;
    super.dispose();
  }
}
