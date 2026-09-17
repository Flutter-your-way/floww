import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/recovery/models/muscle_recovery_item.dart';
import 'package:floww/core/recovery/models/muscle_recovery_status.dart';
import 'package:floww/core/recovery/services/muscle_map_service.dart';
import 'package:floww/core/recovery/widgets/muscle_recovery_tooltip.dart';
import 'package:floww/core/recovery/widgets/muscle_status_palette.dart';

class MuscleBodyMap extends StatelessWidget {
  const MuscleBodyMap({
    super.key,
    required this.template,
    required this.viewBox,
    required this.statuses,
    required this.onTapAt,
    this.selected,
    this.selectionAnchor = Offset.zero,
  });

  final MuscleMapTemplate template;
  final Size viewBox;
  final Map<MuscleGroup, MuscleRecoveryStatus> statuses;
  final ValueChanged<Offset> onTapAt;
  final MuscleRecoveryItem? selected;
  final Offset selectionAnchor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final svg = template.paint({
      for (final entry in statuses.entries)
        entry.key: entry.value.mapColor(colors),
    });
    final selected = this.selected;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = math.min(
          constraints.maxWidth / viewBox.width,
          constraints.maxHeight / viewBox.height,
        );
        final figureSize = Size(
          viewBox.width * scale,
          viewBox.height * scale,
        );

        return Center(
          child: SizedBox.fromSize(
            size: figureSize,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) =>
                        onTapAt(details.localPosition / scale),
                    child: SvgPicture.string(svg, fit: BoxFit.fill),
                  ),
                ),
                if (selected != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomSingleChildLayout(
                        delegate: _AnchoredTooltipLayout(
                          anchor: selectionAnchor * scale,
                        ),
                        child: AnimatedSwitcher(
                          duration: AppMotion.expand,
                          switchInCurve: AppMotion.expandCurve,
                          child: MuscleRecoveryTooltip(
                            key: ValueKey(selected.group),
                            item: selected,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnchoredTooltipLayout extends SingleChildLayoutDelegate {
  const _AnchoredTooltipLayout({required this.anchor});

  static const double _edgeInset = AppSpacing.md;

  final Offset anchor;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.loose(constraints.biggest);

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final maxX = math.max(_edgeInset, size.width - childSize.width);
    final maxY = math.max(_edgeInset, size.height - childSize.height);
    return Offset(
      (anchor.dx - childSize.width / 2).clamp(_edgeInset, maxX),
      (anchor.dy - childSize.height / 2).clamp(_edgeInset, maxY),
    );
  }

  @override
  bool shouldRelayout(_AnchoredTooltipLayout oldDelegate) =>
      oldDelegate.anchor != anchor;
}
