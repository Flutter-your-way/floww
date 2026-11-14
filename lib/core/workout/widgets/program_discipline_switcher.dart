import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/workout/models/workout_discipline.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';

class ProgramDisciplineSwitcher extends StatefulWidget {
  const ProgramDisciplineSwitcher({
    super.key,
    required this.disciplines,
    required this.onSelect,
  });

  final List<ProgramFilterItem<WorkoutDiscipline>> disciplines;
  final ValueChanged<WorkoutDiscipline> onSelect;

  @override
  State<ProgramDisciplineSwitcher> createState() =>
      _ProgramDisciplineSwitcherState();
}

class _ProgramDisciplineSwitcherState extends State<ProgramDisciplineSwitcher>
    with SingleTickerProviderStateMixin {
  static const double _flickVelocity = 400;

  late final AnimationController _position = AnimationController.unbounded(
    vsync: this,
    value: _selectedIndex.toDouble(),
  );
  int _lastTick = 0;

  int get _selectedIndex {
    final index = widget.disciplines.indexWhere((item) => item.isSelected);
    return index < 0 ? 0 : index;
  }

  double get _maxPosition => (widget.disciplines.length - 1).toDouble();

  @override
  void initState() {
    super.initState();
    _lastTick = _selectedIndex;
    _position.addListener(_onPositionChanged);
  }

  @override
  void didUpdateWidget(ProgramDisciplineSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = _selectedIndex.toDouble();
    if (_position.isAnimating || _position.value == target) return;
    _position.animateTo(
      target,
      duration: AppMotion.tabSwitch,
      curve: AppMotion.segmentCurve,
    );
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  void _onPositionChanged() {
    final index = _position.value.round();
    if (index == _lastTick) return;
    _lastTick = index;
    HapticManager.selection();
  }

  Future<void> _settleAt(int index) async {
    await _position.animateTo(
      index.toDouble(),
      duration: AppMotion.tabSwitch,
      curve: AppMotion.segmentCurve,
    );
    if (!mounted) return;
    final item = widget.disciplines[index];
    if (!item.isSelected) widget.onSelect(item.value);
  }

  void _onTap(TapUpDetails details, double width) {
    final segment = width / widget.disciplines.length;
    final index = (details.localPosition.dx / segment).floor().clamp(
      0,
      widget.disciplines.length - 1,
    );
    _settleAt(index);
  }

  void _onDragStart(DragStartDetails details) => _position.stop();

  void _onDragUpdate(DragUpdateDetails details, double width) {
    final segment = width / widget.disciplines.length;
    _position.value = (_position.value + details.delta.dx / segment).clamp(
      0.0,
      _maxPosition,
    );
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final current = _position.value;
    final target = velocity > _flickVelocity
        ? current.ceil()
        : velocity < -_flickVelocity
        ? current.floor()
        : current.round();
    _settleAt(target.clamp(0, _maxPosition.toInt()));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final disciplines = widget.disciplines;
    final count = disciplines.length;
    if (count == 0) return const SizedBox.shrink();

    return Container(
      height: AppSizes.s48,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: AppShapes.decoration(
        gradient: context.gradients.darkGlow.withOpacity(
          AppOpacity.frostedCard,
        ),
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) => _onTap(details, width),
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: (details) => _onDragUpdate(details, width),
            onHorizontalDragEnd: _onDragEnd,
            child: AnimatedBuilder(
              animation: _position,
              builder: (context, child) {
                final position = _position.value.clamp(0.0, _maxPosition);
                final activeIndex = position.round();
                final alignX = count == 1
                    ? 0.0
                    : -1 + 2 * position / (count - 1);
                return Stack(
                  children: [
                    Align(
                      alignment: Alignment(alignX, 0),
                      child: FractionallySizedBox(
                        widthFactor: 1 / count,
                        heightFactor: 1,
                        child: child,
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < count; i++)
                          Expanded(
                            child: _DisciplineSegment(
                              item: disciplines[i],
                              isActive: i == activeIndex,
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
              child: const _SelectionPill(),
            ),
          );
        },
      ),
    );
  }
}

class _SelectionPill extends StatelessWidget {
  const _SelectionPill();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: AppShapes.decoration(
        gradient: context.gradients.primaryButton,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(color: colors.surfaceTranslucent, width: AppSizes.s1),
        shadows: [
          BoxShadow(
            color: colors.primary.withValues(
              alpha: AppOpacity.buttonGlowStrong,
            ),
            offset: const Offset(0, AppSizes.s8),
            blurRadius: AppSizes.s24,
            spreadRadius: -AppSizes.s8,
          ),
        ],
      ),
    );
  }
}

class _DisciplineSegment extends StatelessWidget {
  const _DisciplineSegment({required this.item, required this.isActive});

  final ProgramFilterItem<WorkoutDiscipline> item;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = isActive ? colors.backgroundSecondary : colors.textSecondary;

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: AppMotion.tabSwitch,
              curve: AppMotion.segmentCurve,
              scale: isActive ? 1 : AppMotion.tooltipStartScale,
              child: TweenAnimationBuilder<Color?>(
                duration: AppMotion.tabSwitch,
                tween: ColorTween(end: color),
                builder: (context, value, child) =>
                    Icon(item.value.icon, size: AppSizes.s16, color: value),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            AnimatedDefaultTextStyle(
              duration: AppMotion.tabSwitch,
              curve: AppMotion.segmentCurve,
              style: AppTypography.labelMediumSemiBold.copyWith(color: color),
              child: Text(item.label, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}
