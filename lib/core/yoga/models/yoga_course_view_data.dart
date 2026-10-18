class YogaPillarItem {
  const YogaPillarItem({required this.name, required this.meaning});

  final String name;
  final String meaning;
}

class YogaWeekItem {
  const YogaWeekItem({
    required this.label,
    required this.title,
    required this.summary,
    required this.isCurrent,
    required this.isDone,
  });

  final String label;
  final String title;
  final String summary;
  final bool isCurrent;
  final bool isDone;
}

class YogaTimelineItem {
  const YogaTimelineItem({
    required this.range,
    required this.title,
    required this.detail,
  });

  final String range;
  final String title;
  final String detail;
}

class YogaPostureRowItem {
  const YogaPostureRowItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isCautioned,
    this.sanskritName,
  });

  final String id;
  final String name;
  final String? sanskritName;
  final String imageUrl;
  final bool isCautioned;
}

class YogaFamilyItem {
  const YogaFamilyItem({
    required this.title,
    required this.intro,
    required this.postures,
  });

  final String title;
  final String intro;
  final List<YogaPostureRowItem> postures;
}
