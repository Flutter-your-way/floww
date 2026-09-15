import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/utils/share/widget_capture.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/progress/page_dots.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/core/workout/models/workout_completion.dart';
import 'package:floww/core/workout/models/workout_completion_view_data.dart';
import 'package:floww/core/workout/view_models/workout_completion_view_model.dart';
import 'package:floww/core/workout/widgets/share_target_row.dart';
import 'package:floww/core/workout/widgets/workout_share_card.dart';

class WorkoutShareSheet extends StatefulWidget {
  const WorkoutShareSheet({super.key});

  static Future<void> show({
    required BuildContext context,
    required WorkoutCompletionViewModel viewModel,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: const WorkoutShareSheet(),
      ),
    );
  }

  @override
  State<WorkoutShareSheet> createState() => _WorkoutShareSheetState();
}

class _WorkoutShareSheetState extends State<WorkoutShareSheet> {
  static const double _cardViewportFraction = 1.0;

  late final PageController _pageController = PageController(
    viewportFraction: _cardViewportFraction,
  );
  final Map<int, GlobalKey> _cardKeys = {};

  WorkoutCompletionViewModel get _viewModel =>
      context.read<WorkoutCompletionViewModel>();

  GlobalKey _cardKey(int index) => _cardKeys.putIfAbsent(index, GlobalKey.new);

  void _onPageChanged(int index) {
    HapticManager.selection();
    _viewModel.selectSharePage(index);
  }

  void _onDotSelected(int index) {
    _pageController.animateToPage(
      index,
      duration: AppMotion.expand,
      curve: AppMotion.expandCurve,
    );
  }

  Future<Uint8List> _captureActiveCard() {
    return WidgetCapture.toPngBytes(_cardKey(_viewModel.sharePageIndex));
  }

  Future<void> _onTargetSelected(ShareTarget target) async {
    HapticManager.light();
    final viewModel = _viewModel;
    await viewModel.handleShareTarget(target, _captureActiveCard);
    if (!mounted) return;
    if (target == ShareTarget.addImage &&
        _pageController.hasClients &&
        _pageController.page?.round() != viewModel.sharePageIndex) {
      _onDotSelected(viewModel.sharePageIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutCompletionViewModel>(
      builder: (context, viewModel, child) {
        final share = viewModel.share;
        final statusMessage = viewModel.statusMessage;

        return AppFloatingSheet(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xl2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ShareCardPager(
                      cards: share.cards,
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      onAddPhoto: () => _onTargetSelected(ShareTarget.addImage),
                      cardKeyBuilder: _cardKey,
                    ),
                    SizedBox(height: AppSpacing.xl2),
                    PageDots(
                      count: share.cards.length,
                      activeIndex: viewModel.sharePageIndex,
                      onSelected: _onDotSelected,
                    ),
                    SizedBox(height: AppSpacing.xl2),
                    Text(
                      share.promptLabel,
                      textAlign: TextAlign.center,
                      style: AppTypography.heading4SemiBold.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    if (statusMessage != null) ...[
                      SizedBox(height: AppSpacing.md),
                      _ShareStatusMessage(message: statusMessage),
                    ],
                    SizedBox(height: AppSpacing.xl),
                    ShareTargetRow(
                      targets: share.targets,
                      onSelected: _onTargetSelected,
                      busyTarget: viewModel.busyTarget,
                      isBusy: viewModel.isSharing,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: AppSpacing.xl2,
                right: AppSpacing.xl,
                child: CircularHeaderButton(
                  icon: Icons.close_rounded,
                  size: AppSizes.s40,
                  iconSize: AppSizes.s20,
                  backgroundColor: context.colors.backgroundPrimary,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShareStatusMessage extends StatelessWidget {
  const _ShareStatusMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: AppTypography.bodySmallMedium.copyWith(
        color: context.colors.textSecondary,
      ),
    );
  }
}

class _ShareCardPager extends StatelessWidget {
  const _ShareCardPager({
    required this.cards,
    required this.controller,
    required this.onPageChanged,
    required this.onAddPhoto,
    required this.cardKeyBuilder,
  });

  final List<WorkoutShareCardItem> cards;
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onAddPhoto;
  final GlobalKey Function(int index) cardKeyBuilder;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final card in cards)
          Visibility(
            visible: false,
            maintainSize: true,
            maintainState: true,
            maintainAnimation: true,
            child: WorkoutShareCard(card: card),
          ),
        Positioned.fill(
          child: PageView(
            controller: controller,
            onPageChanged: onPageChanged,
            children: [
              for (var index = 0; index < cards.length; index++)
                RepaintBoundary(
                  key: cardKeyBuilder(index),
                  child: ColoredBox(
                    color: context.colors.backgroundSecondary,
                    child: WorkoutShareCard(
                      card: cards[index],
                      onAddPhoto: onAddPhoto,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
