import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class AppSheetOption<T> {
  const AppSheetOption({
    required this.icon,
    required this.label,
    required this.value,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final T value;
  final bool isDestructive;
}

class AppOptionSheet<T> extends StatelessWidget {
  const AppOptionSheet({
    super.key,
    required this.title,
    required this.icon,
    required this.options,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<AppSheetOption<T>> options,
  }) async {
    final picked = await showAppFloatingSheet<AppSheetOption<T>>(
      context: context,
      builder: (_) =>
          AppOptionSheet<T>(title: title, icon: icon, options: options),
    );
    return picked?.value;
  }

  final String title;
  final IconData icon;
  final List<AppSheetOption<T>> options;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppFloatingSheet(
      child: AppSheetPanel(
        title: title,
        icon: icon,
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
              _AppOptionRow<T>(option: option),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppOptionRow<T> extends StatelessWidget {
  const _AppOptionRow({required this.option});

  final AppSheetOption<T> option;

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
