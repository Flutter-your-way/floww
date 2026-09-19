import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

class AppStatColumn extends StatelessWidget {
  const AppStatColumn({
    super.key,
    this.label,
    required this.value,
    this.dotColor,
    this.leadingIcon,
    this.valueColor,
    this.showInfoIcon = false,
    this.onTap,
  });

  final String? label;
  final String value;
  final Color? dotColor;
  final IconData? leadingIcon;
  final Color? valueColor;
  final bool showInfoIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return _buildContent(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final label = this.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          AppStatLabel(label: label, showInfoIcon: showInfoIcon),
          SizedBox(height: AppSpacing.xs),
        ],
        AppStatValue(
          value: value,
          dotColor: dotColor,
          leadingIcon: leadingIcon,
          valueColor: valueColor,
        ),
      ],
    );
  }
}

class AppStatLabel extends StatelessWidget {
  const AppStatLabel({
    super.key,
    required this.label,
    this.showInfoIcon = false,
  });

  final String label;
  final bool showInfoIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        if (showInfoIcon) ...[
          SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.info_outline,
            size: AppSizes.s12,
            color: context.colors.textSecondary,
          ),
        ],
      ],
    );
  }
}

class AppStatValue extends StatelessWidget {
  const AppStatValue({
    super.key,
    required this.value,
    this.dotColor,
    this.leadingIcon,
    this.valueColor,
  });

  final String value;
  final Color? dotColor;
  final IconData? leadingIcon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final dotColor = this.dotColor;
    final leadingIcon = this.leadingIcon;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dotColor != null) ...[
          Container(
            width: AppSizes.s8,
            height: AppSizes.s8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          SizedBox(width: AppSpacing.xs),
        ],
        if (leadingIcon != null) ...[
          Icon(
            leadingIcon,
            size: AppSizes.s18,
            color: valueColor ?? context.colors.textPrimary,
          ),
          SizedBox(width: AppSpacing.xs),
        ],
        Text(
          value,
          style: AppTypography.bodyLargeBold.copyWith(
            color: valueColor ?? context.colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
