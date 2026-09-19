enum AppThemeMode {
  flow,
  steady,
  restore;

  static const int restoreCeiling = 30;
  static const int steadyCeiling = 70;

  static const AppThemeMode? forcedMode = null;

  static AppThemeMode fromFlowScore(int score) {
    final forced = forcedMode;
    if (forced != null) return forced;
    if (score <= restoreCeiling) return AppThemeMode.restore;
    if (score <= steadyCeiling) return AppThemeMode.steady;
    return AppThemeMode.flow;
  }
}
