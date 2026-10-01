import 'package:flutter/material.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

class SleepDurationSummary extends StatelessWidget {
  final Duration duration;

  const SleepDurationSummary({super.key, required this.duration});

  String get _formatted {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (minutes == 0) return '${hours}hr';
    if (hours == 0) return '${minutes}min';
    return '${hours}hr and ${minutes}min';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'You sleep '),
          TextSpan(
            text: _formatted,
            style: AppTypography.bodyLargeSemiBold.copyWith(
              color: colors.primary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const TextSpan(text: ' a night'),
        ],
      ),
      textAlign: TextAlign.center,
      style: AppTypography.bodyLargeMedium.copyWith(
        color: colors.textSecondary,
      ),
    );
  }
}
