import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ForcedThemeMode extends StatelessWidget {
  const ForcedThemeMode({super.key, required this.mode, required this.child});

  final AppThemeMode mode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(data: AppTheme.buildTheme(mode), child: child);
  }
}
