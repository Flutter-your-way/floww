import 'package:floww/core/yoga/models/yoga_class_section.dart';

class YogaCourseWeek {
  const YogaCourseWeek({
    required this.number,
    required this.title,
    required this.summary,
    required this.sections,
    this.suryaRounds = 0,
  });

  final int number;
  final String title;
  final String summary;
  final Map<YogaClassSection, List<String>> sections;
  final int suryaRounds;

  String get label => 'Week $number';
}
