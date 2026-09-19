import 'package:floww/config/theme/app_mode.dart';
import 'package:flutter/foundation.dart';

@immutable
class FlowModeChange {
  const FlowModeChange({
    required this.previousMode,
    required this.mode,
    required this.id,
  });

  final AppThemeMode previousMode;
  final AppThemeMode mode;
  final int id;

  bool get isAscending => mode.index < previousMode.index;

  @override
  bool operator ==(Object other) =>
      other is FlowModeChange &&
      other.id == id &&
      other.mode == mode &&
      other.previousMode == previousMode;

  @override
  int get hashCode => Object.hash(id, mode, previousMode);
}

class FlowModeCopy {
  const FlowModeCopy._();

  static const Map<AppThemeMode, String> titles = {
    AppThemeMode.restore: 'RESTORE MODE',
    AppThemeMode.steady: 'STEADY MODE',
    AppThemeMode.flow: 'FLOW MODE',
  };

  static const Map<AppThemeMode, String> messages = {
    AppThemeMode.restore: 'Take a breath. Give yourself room to reset.',
    AppThemeMode.steady: "You're finding your rhythm.",
    AppThemeMode.flow: "You're in the zone.",
  };

  static String titleOf(AppThemeMode mode) => titles[mode]!;

  static String messageOf(AppThemeMode mode) => messages[mode]!;
}
