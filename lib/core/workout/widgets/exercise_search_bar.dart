import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';

class ExerciseSearchBar extends StatelessWidget {
  const ExerciseSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    this.onCreate,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onCreate = this.onCreate;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: AppSizes.s56,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            decoration: AppShapes.decoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: AppSizes.s24,
                  color: colors.textSecondary,
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: TextField(
                    onChanged: onChanged,
                    style: context.textTheme.bodyLarge,
                    cursorColor: colors.primary,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: hint,
                      hintStyle: context.textTheme.bodyLarge?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onCreate != null) ...[
          SizedBox(width: AppSpacing.lg),
          PressScale(
            onTap: onCreate,
            child: Container(
              width: AppSizes.s56,
              height: AppSizes.s56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.bgTinted,
                shape: BoxShape.circle,
                border: Border.all(color: colors.primary, width: AppSizes.s1),
              ),
              child: Icon(
                Icons.add,
                size: AppSizes.s24,
                color: colors.primaryAlt,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
