import 'package:floww/core/health/models/health_metric_kind.dart';
import 'package:floww/core/health/models/health_metric_reading.dart';

enum DailyMetricTone { positive, negative, neutral }

class DailyMetricTile {
  const DailyMetricTile({
    required this.kind,
    required this.label,
    required this.value,
    required this.unit,
    this.trend = HealthTrend.flat,
    this.tone = DailyMetricTone.neutral,
    this.hasReading = false,
  });

  final HealthMetricKind kind;
  final String label;
  final String value;
  final String unit;
  final HealthTrend trend;
  final DailyMetricTone tone;
  final bool hasReading;

  bool get showsTrend => trend != HealthTrend.flat;
}

class DailyMetricOption {
  const DailyMetricOption({
    required this.kind,
    required this.label,
    required this.detail,
    required this.isAvailable,
    required this.isSelected,
    required this.canToggle,
  });

  final HealthMetricKind kind;
  final String label;
  final String detail;
  final bool isAvailable;
  final bool isSelected;
  final bool canToggle;
}

class DailyMetricsPickerViewData {
  const DailyMetricsPickerViewData({
    required this.title,
    required this.subtitle,
    required this.options,
  });

  final String title;
  final String subtitle;
  final List<DailyMetricOption> options;
}

class DailyMetricsViewData {
  const DailyMetricsViewData({
    required this.title,
    required this.infoTitle,
    required this.infoMessage,
    required this.bodyCompositionLabel,
    required this.tiles,
    required this.hasData,
    required this.canCustomize,
    required this.promptMessage,
    required this.allowLabel,
  });

  final String title;
  final String infoTitle;
  final String infoMessage;
  final String bodyCompositionLabel;
  final List<DailyMetricTile> tiles;
  final bool hasData;
  final bool canCustomize;
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
