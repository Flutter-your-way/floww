import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:floww/config/theme/theme_controller.dart';
import 'package:floww/config/widgets/theme/forced_theme_mode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SheetTheme extends StatelessWidget {
  const SheetTheme({super.key, required this.forcedMode, required this.child});

  final AppThemeMode? forcedMode;
  final Widget child;

  static AppThemeMode? forcedModeOf(BuildContext context) =>
      context.findAncestorWidgetOfExactType<ForcedThemeMode>()?.mode;

  @override
  Widget build(BuildContext context) {
    final mode = forcedMode ?? context.watch<ThemeModeController>().mode;

    return AnimatedTheme(
      data: AppTheme.buildTheme(mode),
      duration: AppMotion.modeShift,
      curve: AppMotion.modeRelease,
      child: child,
    );
  }
}
