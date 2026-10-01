import 'package:floww/core/onboarding/models/onboarding_models.dart';

class OnboardingAnswerItem {
  const OnboardingAnswerItem({
    required this.question,
    required this.value,
    required this.isAnswered,
  });

  final OnboardingQuestion question;
  final String value;
  final bool isAnswered;
}

class OnboardingAnswerSection {
  const OnboardingAnswerSection({required this.title, required this.items});

  final String title;
  final List<OnboardingAnswerItem> items;
}

class OnboardingAnswerEditArgs {
  const OnboardingAnswerEditArgs({
    required this.questionId,
    required this.answers,
  });

  final String questionId;
  final Map<String, dynamic> answers;
}
