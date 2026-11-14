import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/progress/page_dots.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_summary_card.dart';

class WorkoutSummaryCarousel extends StatefulWidget {
  const WorkoutSummaryCarousel({
    super.key,
    required this.summaries,
    required this.index,
    required this.onSelect,
    required this.onOpen,
    this.onInfo,
  });

  final List<WorkoutSummaryItem> summaries;
  final int index;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onOpen;
  final VoidCallback? onInfo;

  @override
  State<WorkoutSummaryCarousel> createState() => _WorkoutSummaryCarouselState();
}

class _WorkoutSummaryCarouselState extends State<WorkoutSummaryCarousel> {
  late int _index = widget.index;
  late int _reported = widget.index;
  PageController? _controller;
  double? _viewportFraction;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth - context.sizes.screenHorizontalPadding * 2;
    final fraction = (cardWidth + AppSpacing.md) / screenWidth;
    if (fraction == _viewportFraction) return;
    _viewportFraction = fraction;
    _controller?.dispose();
    _controller = PageController(
      viewportFraction: fraction,
      initialPage: _index,
    );
  }

  @override
  void didUpdateWidget(WorkoutSummaryCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = widget.index;
    _reported = target;
    if (target == _index) return;
    _index = target;
    final controller = _controller;
    if (controller == null || !controller.hasClients) return;
    controller.animateToPage(
      target,
      duration: AppMotion.expand,
      curve: AppMotion.expandCurve,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (index == _index) return;
    HapticManager.selection();
    setState(() => _index = index);
  }

  bool _onScrollEnd(ScrollEndNotification notification) {
    if (_index == _reported) return false;
    _reported = _index;
    final id = widget.summaries[_index].sessionId;
    if (id != null) widget.onSelect(id);
    return false;
  }

  void _jumpTo(int index) {
    HapticManager.selection();
    _controller?.animateToPage(
      index,
      duration: AppMotion.expand,
      curve: AppMotion.expandCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final summaries = widget.summaries;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final index = _index.clamp(0, summaries.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: WorkoutSummaryCard(summary: summaries[index]),
            ),
            Positioned.fill(
              child: OverflowBox(
                minWidth: screenWidth,
                maxWidth: screenWidth,
                child: NotificationListener<ScrollEndNotification>(
                  onNotification: _onScrollEnd,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: summaries.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, page) {
                      final summary = summaries[page];
                      final id = summary.sessionId;
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          minHeight: 0,
                          maxHeight: double.infinity,
                          child: WorkoutSummaryCard(
                            summary: summary,
                            onInfo: widget.onInfo,
                            onTap: id == null ? null : () => widget.onOpen(id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        PageDots(
          count: summaries.length,
          activeIndex: index,
          onSelected: _jumpTo,
        ),
      ],
    );
  }
}
