import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/widgets/habit_heatmap_tooltip.dart';

class HabitHeatmapGrid extends StatefulWidget {
  const HabitHeatmapGrid({super.key, required this.data, this.selectedDate});

  static const double cellSize = AppSizes.s12;
  static const double cellGap = AppSizes.s3;
  static const double monthRowHeight = AppSizes.s16;
  static const double step = cellSize + cellGap;
  static const double _weekdayColumnWidth = AppSizes.s28;

  final HabitHeatmapData data;
  final DateTime? selectedDate;

  @override
  State<HabitHeatmapGrid> createState() => _HabitHeatmapGridState();
}

class _HabitHeatmapGridState extends State<HabitHeatmapGrid> {
  final OverlayPortalController _portal = OverlayPortalController();
  final GlobalKey _contentKey = GlobalKey();
  Timer? _hideTimer;
  HabitHeatmapCell? _active;
  Rect _anchor = Rect.zero;

  @override
  void didUpdateWidget(HabitHeatmapGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.data, widget.data)) _hide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  HabitHeatmapCell? _cellAt(Offset position, void Function(Offset) onOrigin) {
    final dy = position.dy - HabitHeatmapGrid.monthRowHeight;
    if (position.dx < 0 || dy < 0) return null;
    final week = position.dx ~/ HabitHeatmapGrid.step;
    final row = dy ~/ HabitHeatmapGrid.step;
    final weeks = widget.data.weeks;
    if (week >= weeks.length || row >= weeks[week].length) return null;
    onOrigin(
      Offset(
        week * HabitHeatmapGrid.step,
        HabitHeatmapGrid.monthRowHeight + row * HabitHeatmapGrid.step,
      ),
    );
    return weeks[week][row];
  }

  void _showAt(Offset position, {bool sticky = false}) {
    var local = Offset.zero;
    final cell = _cellAt(position, (origin) => local = origin);
    if (cell == null) return;
    _hideTimer?.cancel();
    if (sticky) _hideTimer = Timer(AppMotion.notice, _hide);
    if (identical(cell, _active)) return;
    final box = _contentKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached) return;
    HapticManager.soft();
    setState(() {
      _active = cell;
      _anchor =
          box.localToGlobal(local) &
          const Size.square(HabitHeatmapGrid.cellSize);
    });
    _portal.show();
  }

  void _hide() {
    _hideTimer?.cancel();
    if (_active == null) return;
    setState(() => _active = null);
    _portal.hide();
  }

  bool _onScroll(ScrollNotification notification) {
    _hide();
    return false;
  }

  Map<Type, GestureRecognizerFactory> get _gestures => {
    TapGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          TapGestureRecognizer.new,
          (recognizer) {
            recognizer.onTapUp = (details) {
              _showAt(details.localPosition, sticky: true);
            };
          },
        ),
    LongPressGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
          () => LongPressGestureRecognizer(duration: AppMotion.scrubHold),
          (recognizer) {
            recognizer
              ..onLongPressStart = (details) {
                _showAt(details.localPosition);
              }
              ..onLongPressMoveUpdate = (details) {
                _showAt(details.localPosition);
              }
              ..onLongPressEnd = (_) {
                _hide();
              }
              ..onLongPressCancel = _hide;
          },
        ),
  };

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final active = _active;
    final labelStyle = AppTypography.captionMediumMicro.copyWith(
      color: context.colors.textSecondary,
    );

    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) => active == null
          ? const SizedBox.shrink()
          : _HeatmapTooltipOverlay(anchor: _anchor, cell: active),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WeekdayColumn(labels: data.weekdayLabels, style: labelStyle),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TapRegion(
                        onTapOutside: (_) => _hide(),
                        child: MouseRegion(
                          onHover: (event) => _showAt(event.localPosition),
                          onExit: (_) => _hide(),
                          child: RawGestureDetector(
                            behavior: HitTestBehavior.opaque,
                            gestures: _gestures,
                            child: _HeatmapContent(
                              key: _contentKey,
                              data: data,
                              labelStyle: labelStyle,
                              selectedDate: widget.selectedDate,
                              activeDate: active?.date,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekdayColumn extends StatelessWidget {
  const _WeekdayColumn({required this.labels, required this.style});

  final List<String?> labels;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: HabitHeatmapGrid._weekdayColumnWidth,
      child: Padding(
        padding: const EdgeInsets.only(top: HabitHeatmapGrid.monthRowHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var row = 0; row < labels.length; row++)
              Padding(
                padding: EdgeInsets.only(
                  top: row > 0 ? HabitHeatmapGrid.cellGap : 0,
                ),
                child: SizedBox(
                  height: HabitHeatmapGrid.cellSize,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(labels[row] ?? '', style: style),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeatmapContent extends StatelessWidget {
  const _HeatmapContent({
    super.key,
    required this.data,
    required this.labelStyle,
    required this.selectedDate,
    required this.activeDate,
  });

  final HabitHeatmapData data;
  final TextStyle labelStyle;
  final DateTime? selectedDate;
  final DateTime? activeDate;

  @override
  Widget build(BuildContext context) {
    final gridWidth =
        data.weeks.length * HabitHeatmapGrid.step - HabitHeatmapGrid.cellGap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: gridWidth,
          height: HabitHeatmapGrid.monthRowHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final month in data.months)
                Positioned(
                  left: month.weekIndex * HabitHeatmapGrid.step,
                  top: 0,
                  child: Text(month.label, style: labelStyle),
                ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var week = 0; week < data.weeks.length; week++)
              Padding(
                padding: EdgeInsets.only(
                  left: week > 0 ? HabitHeatmapGrid.cellGap : 0,
                ),
                child: _HeatmapWeek(
                  cells: data.weeks[week],
                  selectedDate: selectedDate,
                  activeDate: activeDate,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _HeatmapWeek extends StatelessWidget {
  const _HeatmapWeek({
    required this.cells,
    required this.selectedDate,
    required this.activeDate,
  });

  final List<HabitHeatmapCell?> cells;
  final DateTime? selectedDate;
  final DateTime? activeDate;

  bool _matches(HabitHeatmapCell? cell, DateTime? date) =>
      cell != null && date != null && AppDateUtils.isSameDay(cell.date, date);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < cells.length; row++)
          Padding(
            padding: EdgeInsets.only(
              top: row > 0 ? HabitHeatmapGrid.cellGap : 0,
            ),
            child: HabitHeatmapCellBox(
              level: cells[row]?.level,
              isToday: cells[row]?.isToday ?? false,
              isSelected:
                  _matches(cells[row], activeDate) ||
                  _matches(cells[row], selectedDate),
            ),
          ),
      ],
    );
  }
}

class _HeatmapTooltipOverlay extends StatelessWidget {
  const _HeatmapTooltipOverlay({required this.anchor, required this.cell});

  final Rect anchor;
  final HabitHeatmapCell cell;

  @override
  Widget build(BuildContext context) {
    final overlayBox = Overlay.of(context).context.findRenderObject();
    final shift = overlayBox is RenderBox
        ? overlayBox.globalToLocal(Offset.zero)
        : Offset.zero;

    return IgnorePointer(
      child: CustomSingleChildLayout(
        delegate: _TooltipLayout(
          anchor: anchor.shift(shift),
          padding: MediaQuery.paddingOf(context),
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppMotion.press,
          curve: AppMotion.expandCurve,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.scale(
              scale:
                  AppMotion.tooltipStartScale +
                  (1 - AppMotion.tooltipStartScale) * value,
              child: child,
            ),
          ),
          child: HabitHeatmapTooltip(cell: cell),
        ),
      ),
    );
  }
}

class _TooltipLayout extends SingleChildLayoutDelegate {
  const _TooltipLayout({required this.anchor, required this.padding});

  static const double _gap = AppSpacing.md;
  static const double _edge = AppSpacing.xl;

  final Rect anchor;
  final EdgeInsets padding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.loose(
        constraints.biggest,
      ).deflate(const EdgeInsets.symmetric(horizontal: _edge));

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final maxX = math.max(_edge, size.width - childSize.width - _edge);
    final x = (anchor.center.dx - childSize.width / 2).clamp(_edge, maxX);
    final top = padding.top + _edge;
    final above = anchor.top - _gap - childSize.height;
    if (above >= top) return Offset(x, above);
    final maxY = math.max(
      top,
      size.height - padding.bottom - childSize.height - _edge,
    );
    return Offset(x, (anchor.bottom + _gap).clamp(top, maxY));
  }

  @override
  bool shouldRelayout(_TooltipLayout oldDelegate) =>
      oldDelegate.anchor != anchor || oldDelegate.padding != padding;
}

class HabitHeatmapCellBox extends StatelessWidget {
  const HabitHeatmapCellBox({
    super.key,
    required this.level,
    this.isToday = false,
    this.isSelected = false,
  });

  final HabitHeatmapLevel? level;
  final bool isToday;
  final bool isSelected;

  Color _colorOf(AppColorTokens colors, HabitHeatmapLevel level) =>
      switch (level) {
        HabitHeatmapLevel.empty => colors.borderSubtle,
        HabitHeatmapLevel.low => colors.primary.withValues(
          alpha: AppOpacity.heatmapLow,
        ),
        HabitHeatmapLevel.medium => colors.primary.withValues(
          alpha: AppOpacity.heatmapMedium,
        ),
        HabitHeatmapLevel.high => colors.primary.withValues(
          alpha: AppOpacity.heatmapHigh,
        ),
        HabitHeatmapLevel.full => colors.primary,
      };

  @override
  Widget build(BuildContext context) {
    final level = this.level;
    if (level == null) {
      return const SizedBox.square(dimension: HabitHeatmapGrid.cellSize);
    }
    final colors = context.colors;
    final outlined = isSelected || isToday;

    return Container(
      width: HabitHeatmapGrid.cellSize,
      height: HabitHeatmapGrid.cellSize,
      decoration: BoxDecoration(
        color: _colorOf(colors, level),
        borderRadius: BorderRadius.circular(AppSizes.s3),
        border: outlined
            ? Border.all(
                color: isSelected ? colors.textPrimary : colors.primaryAlt,
                width: AppSizes.s1,
              )
            : null,
      ),
    );
  }
}
