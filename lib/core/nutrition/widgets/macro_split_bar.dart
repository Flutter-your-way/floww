import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/nutrition_colors.dart';

class MacroSplitBar extends StatelessWidget {
  const MacroSplitBar({
    super.key,
    required this.shares,
    this.height = AppSizes.s8,
  });

  static const int _flexResolution = 1000;

  final List<MacroShare> shares;
  final double height;

  @override
  Widget build(BuildContext context) {
    final visible = shares.where((item) => item.share > 0).toList();
    if (visible.isEmpty) return AppProgressBar(progress: 0, height: height);

    return SizedBox(
      height: height,
      child: Row(
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) SizedBox(width: AppSpacing.xxs),
            Expanded(
              flex: (visible[i].share * _flexResolution).round().clamp(
                1,
                _flexResolution,
              ),
              child: AppProgressBar(
                progress: 1,
                height: height,
                color: visible[i].macro.colorOf(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
