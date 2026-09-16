import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/profile/models/profile_edit_data.dart';

class ProfileChoiceCard extends StatelessWidget {
  const ProfileChoiceCard({
    super.key,
    required this.group,
    required this.onSelected,
  });

  final ProfileChoiceGroup group;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title: group.title, titleStyle: AppTypography.heading4),
          SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: [
              for (final choice in group.choices)
                ProfileChoiceChip(
                  choice: choice,
                  isSelected: choice.id == group.selectedId,
                  onTap: () => onSelected(choice.id),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileChoiceChip extends StatelessWidget {
  const ProfileChoiceChip({
    super.key,
    required this.choice,
    required this.isSelected,
    required this.onTap,
  });

  static const Duration _duration = Duration(milliseconds: 180);

  final ProfileChoice choice;
  final bool isSelected;
  final VoidCallback onTap;

  void _handleTap() {
    HapticManager.selection();
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final icon = choice.icon;
    final foreground = isSelected ? colors.primary : colors.textPrimary;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: _duration,
        curve: Curves.easeOut,
        height: AppSizes.s52,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        decoration: AppShapes.decoration(
          color: isSelected ? colors.bgTinted : colors.backgroundSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: isSelected ? colors.primary : colors.borderSubtle,
            width: AppSizes.s1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: AppSizes.s20,
                color: isSelected ? colors.primary : colors.textMuted,
              ),
              SizedBox(width: AppSpacing.md),
            ],
            AnimatedDefaultTextStyle(
              duration: _duration,
              curve: Curves.easeOut,
              style: AppTypography.bodyLargeSemiBold.copyWith(
                color: foreground,
              ),
              child: Text(choice.label),
            ),
          ],
        ),
      ),
    );
  }
}
