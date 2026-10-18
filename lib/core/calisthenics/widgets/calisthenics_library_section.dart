import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/core/calisthenics/models/cal_library_view_data.dart';
import 'package:floww/core/calisthenics/widgets/cal_ladder_card.dart';
import 'package:floww/config/widgets/cards/app_bullet_card.dart';

class CalisthenicsLibrarySection extends StatelessWidget {
  const CalisthenicsLibrarySection({
    super.key,
    required this.levelLabel,
    required this.ladders,
    required this.warmUp,
    required this.coolDown,
    required this.principles,
    required this.onOpenMove,
  });

  final String levelLabel;
  final List<CalLadderItem> ladders;
  final List<CalRoutineItem> warmUp;
  final List<CalRoutineItem> coolDown;
  final List<String> principles;
  final ValueChanged<String> onOpenMove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppBulletCard(
          title: 'Principles & safety',
          icon: Icons.health_and_safety_outlined,
          items: principles,
        ),
        SizedBox(height: AppSpacing.xl3),
        const SectionLabel(label: 'Progressions'),
        SizedBox(height: AppSpacing.md),
        Text(
          'Highlighted steps are the $levelLabel standards.',
          style: AppTypography.bodySmallRegularTight.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        for (final ladder in ladders) ...[
          SizedBox(height: AppSpacing.lg),
          CalLadderCard(ladder: ladder, onOpen: onOpenMove),
        ],
        SizedBox(height: AppSpacing.xl3),
        _RoutineCard(
          title: 'Warm-up',
          icon: Icons.local_fire_department_outlined,
          items: warmUp,
          onOpen: onOpenMove,
        ),
        SizedBox(height: AppSpacing.lg),
        _RoutineCard(
          title: 'Cooldown',
          icon: Icons.spa_outlined,
          items: coolDown,
          onOpen: onOpenMove,
        ),
      ],
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.title,
    required this.icon,
    required this.items,
    required this.onOpen,
  });

  final String title;
  final IconData icon;
  final List<CalRoutineItem> items;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(title: title, icon: icon, iconColor: colors.primary),
          for (final item in items) ...[
            SizedBox(height: AppSpacing.lg),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onOpen(item.moveId),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTypography.bodyMediumSemiBold.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.detail,
                    style: AppTypography.bodySmallRegularTight.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
