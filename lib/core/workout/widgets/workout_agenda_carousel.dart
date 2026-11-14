import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_agenda_hero_card.dart';

class WorkoutAgendaCarousel extends StatefulWidget {
  const WorkoutAgendaCarousel({
    super.key,
    required this.entries,
    required this.onAction,
    required this.onRemove,
  });

  final List<WorkoutAgendaEntryItem> entries;
  final ValueChanged<WorkoutAgendaEntryItem> onAction;
  final ValueChanged<WorkoutAgendaEntryItem> onRemove;

  @override
  State<WorkoutAgendaCarousel> createState() => _WorkoutAgendaCarouselState();
}

class _WorkoutAgendaCarouselState extends State<WorkoutAgendaCarousel> {
  static const double _viewportFraction = 0.84;
  static const double _heightRatio = 1.25;
  static const double _sideScale = 0.94;

  late final PageController _controller = PageController(
    viewportFraction: _viewportFraction,
    initialPage: _initialPage,
  );

  int get _initialPage {
    final entries = widget.entries;
    final pending = entries.indexWhere(
      (entry) =>
          entry.action == WorkoutAgendaAction.start ||
          entry.action == WorkoutAgendaAction.resume,
    );
    if (pending >= 0) return pending;
    final focused = entries.indexWhere((entry) => entry.isFocused);
    return focused < 0 ? 0 : focused;
  }

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
    final entries = widget.entries;

    return SizedBox(
      height: height,
      child: OverflowBox(
        minWidth: screenWidth,
        maxWidth: screenWidth,
        child: PageView.builder(
          controller: _controller,
          itemCount: entries.length,
          onPageChanged: (_) => HapticManager.selection(),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) =>
                  Transform.scale(scale: _scaleOf(index), child: child),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: WorkoutAgendaHeroCard(
                  key: ValueKey(entry.id),
                  entry: entry,
                  fillHeight: true,
                  onAction: () => widget.onAction(entry),
                  onRemove: () => widget.onRemove(entry),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
