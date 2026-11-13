import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/program_goal_card.dart';

class ProgramGoalCarousel extends StatefulWidget {
  const ProgramGoalCarousel({super.key, required this.goals, this.onSelect});

  final List<ProgramGoalCardItem> goals;
  final ValueChanged<ProgramGoalCardItem>? onSelect;

  @override
  State<ProgramGoalCarousel> createState() => _ProgramGoalCarouselState();
}

class _ProgramGoalCarouselState extends State<ProgramGoalCarousel> {
  static const double _viewportFraction = 0.84;
  static const double _heightRatio = 1.2;
  static const double _sideScale = 0.94;

  final PageController _controller = PageController(
    viewportFraction: _viewportFraction,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _scaleOf(int index) {
    if (!_controller.hasClients || !_controller.position.haveDimensions) {
      return index == _controller.initialPage ? 1 : _sideScale;
    }
    final page = _controller.page ?? _controller.initialPage.toDouble();
    final distance = (page - index).abs().clamp(0.0, 1.0);
    return 1 - (1 - _sideScale) * distance;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final height = screenWidth * _viewportFraction * _heightRatio;
    final onSelect = widget.onSelect;

    return SizedBox(
      height: height,
      child: OverflowBox(
        minWidth: screenWidth,
        maxWidth: screenWidth,
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.goals.length,
          onPageChanged: (_) => HapticManager.selection(),
          itemBuilder: (context, index) {
            final goal = widget.goals[index];
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) =>
                  Transform.scale(scale: _scaleOf(index), child: child),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: ProgramGoalCard(
                  goal: goal,
                  onTap: onSelect == null ? null : () => onSelect(goal),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
