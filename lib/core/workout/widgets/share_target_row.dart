import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/core/workout/models/workout_completion.dart';
import 'package:floww/core/workout/models/workout_completion_view_data.dart';

class ShareTargetRow extends StatelessWidget {
  const ShareTargetRow({
    super.key,
    required this.targets,
    this.onSelected,
    this.busyTarget,
    this.isBusy = false,
  });

  final List<ShareTargetItem> targets;
  final ValueChanged<ShareTarget>? onSelected;
  final ShareTarget? busyTarget;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final target in targets)
          Expanded(
            child: _ShareTargetTile(
              target: target,
              isBusy: busyTarget == target.target,
              onTap: onSelected == null || isBusy
                  ? null
                  : () => onSelected!(target.target),
            ),
          ),
      ],
    );
  }
}

class _ShareTargetTile extends StatelessWidget {
  const _ShareTargetTile({
    required this.target,
    required this.isBusy,
    this.onTap,
  });

  static const double _disabledOpacity = 0.45;

  final ShareTargetItem target;
  final bool isBusy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Opacity(
      opacity: onTap == null && !isBusy ? _disabledOpacity : 1,
      child: PressScale(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizes.s56,
              height: AppSizes.s56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.backgroundElevated,
                shape: BoxShape.circle,
              ),
              child: isBusy
                  ? _ShareTargetSpinner(color: colors.textPrimary)
                  : _ShareTargetGlyph(target: target),
            ),
            SizedBox(height: AppSpacing.md),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Text(
                target.label,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmallMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareTargetGlyph extends StatelessWidget {
  const _ShareTargetGlyph({required this.target});

  static const double _brandSize = AppSizes.s28;

  final ShareTargetItem target;

  @override
  Widget build(BuildContext context) {
    final assetPath = target.assetPath;
    if (assetPath != null) {
      return SvgPicture.asset(assetPath, width: _brandSize, height: _brandSize);
    }

    final icon = target.icon;
    if (icon == null) return const SizedBox.shrink();

    return Icon(icon, size: AppSizes.s24, color: context.colors.textPrimary);
  }
}

class _ShareTargetSpinner extends StatelessWidget {
  const _ShareTargetSpinner({required this.color});

  static const double _size = AppSizes.s20;
  static const double _strokeWidth = AppSizes.s2;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: CircularProgressIndicator(strokeWidth: _strokeWidth, color: color),
    );
  }
}
