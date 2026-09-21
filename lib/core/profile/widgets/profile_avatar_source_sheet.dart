import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/profile/models/profile_edit_data.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class ProfileAvatarSourceSheet extends StatelessWidget {
  const ProfileAvatarSourceSheet({
    super.key,
    required this.title,
    required this.options,
  });

  static Future<ProfileAvatarOption?> show(
    BuildContext context, {
    required String title,
    required List<ProfileAvatarOption> options,
  }) {
    return showAppFloatingSheet<ProfileAvatarOption>(
      context: context,
      builder: (_) => ProfileAvatarSourceSheet(title: title, options: options),
    );
  }

  final String title;
  final List<ProfileAvatarOption> options;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppFloatingSheet(
      child: AppSheetPanel(
        title: title,
        icon: Icons.person_outline_rounded,
        onClose: () => NavigationService.instance.pop(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final option in options) ...[
              if (option != options.first)
                Divider(
                  height: AppSpacing.xl2,
                  thickness: AppSizes.s1,
                  color: colors.borderSubtle,
                ),
              _ProfileAvatarOptionRow(option: option),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatarOptionRow extends StatelessWidget {
  const _ProfileAvatarOptionRow({required this.option});

  final ProfileAvatarOption option;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDestructive = option.isDestructive;

    return PressScale(
      onTap: () => NavigationService.instance.pop(option),
      child: Row(
        children: [
          AppIconTile(
            icon: option.icon,
            iconColor: isDestructive ? colors.destructive : colors.textPrimary,
            borderColor: isDestructive ? colors.destructiveBorder : null,
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              option.label,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyLargeSemiBoldTall.copyWith(
                color: isDestructive ? colors.destructive : colors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Icon(
            Icons.chevron_right_rounded,
            size: AppSizes.s20,
            color: colors.textMuted,
          ),
        ],
      ),
    );
  }
}
