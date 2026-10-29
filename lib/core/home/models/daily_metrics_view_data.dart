import 'package:floww/core/health/models/health_metric_reading.dart';

enum DailyMetricTone { positive, negative, neutral }

enum DailyMetricSectionKind { recovery, cardio, body }

class DailyMetricTile {
  const DailyMetricTile({
    required this.label,
    required this.value,
    required this.unit,
    this.trend = HealthTrend.flat,
    this.tone = DailyMetricTone.neutral,
  });

  final String label;
  final String value;
  final String unit;
  final HealthTrend trend;
  final DailyMetricTone tone;

  bool get showsTrend => trend != HealthTrend.flat;
}

class DailyMetricSection {
  const DailyMetricSection({
    required this.kind,
    required this.title,
    required this.tiles,
  });

  final DailyMetricSectionKind kind;
  final String title;
  final List<DailyMetricTile> tiles;
}

class DailyMetricsViewData {
  const DailyMetricsViewData({
    required this.title,
    required this.infoTitle,
    required this.infoMessage,
    required this.bodyCompositionLabel,
    required this.sections,
    required this.hasData,
    required this.promptMessage,
    required this.allowLabel,
  });

  final String title;
  final String infoTitle;
  final String infoMessage;
  final String bodyCompositionLabel;
  final List<DailyMetricSection> sections;
  final bool hasData;
  final String promptMessage;
  final String allowLabel;
}

class BodyCompositionViewData {
  const BodyCompositionViewData({
    required this.title,
    required this.subtitle,
    required this.tiles,
    required this.emptyMessage,
    required this.hasData,
  });

  final String title;
  final String subtitle;
  final List<DailyMetricTile> tiles;
  final String emptyMessage;
  final bool hasData;
}
