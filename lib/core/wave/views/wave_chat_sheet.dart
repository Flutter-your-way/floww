import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/widgets/theme/sheet_theme.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/models/wave_quick_action.dart';
import 'package:floww/core/wave/services/wave_chat_service.dart';
import 'package:floww/core/wave/services/wave_context_service.dart';
import 'package:floww/core/wave/services/wave_transcript_service.dart';
import 'package:floww/core/wave/view_models/wave_chat_view_model.dart';
import 'package:floww/core/wave/widgets/wave_card.dart';
import 'package:floww/core/wave/widgets/wave_chat_header.dart';
import 'package:floww/core/wave/widgets/wave_composer.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/core/wave/views/wave_history_sheet.dart';
import 'package:floww/core/wave/widgets/wave_message_item.dart';
import 'package:floww/core/wave/widgets/wave_typing_indicator.dart';
import 'package:floww/core/wave/widgets/wave_quick_action_bar.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

Future<void> showWaveChatSheet(BuildContext context) {
  final forcedMode = SheetTheme.forcedModeOf(context);

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: AppMotion.expand,
    pageBuilder: (context, animation, secondaryAnimation) =>
        SheetTheme(forcedMode: forcedMode, child: const WaveChatSheet()),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.expandCurve,
        reverseCurve: AppMotion.collapseCurve,
      );

      return SheetTheme(
        forcedMode: forcedMode,
        child: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: FadeTransition(
                opacity: curved,
                child: const _WaveBackdrop(),
              ),
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          ],
        ),
      );
    },
  );
}

class WaveChatSheet extends StatelessWidget {
  const WaveChatSheet({super.key});

  void _close() => NavigationService.instance.pop();

  void _handlePlanAction(WaveChatViewModel viewModel, WavePlanItem item) {
    HapticManager.light();
    switch (item.action) {
      case WavePlanAction.startWorkout:
        _close();
        NavigationService.instance.push(AppRouter.todaysWorkout);
      case WavePlanAction.resumeWorkout:
        _openActiveWorkout();
      case WavePlanAction.logMeal:
        viewModel.sendQuickAction(WaveQuickAction.logMeal);
      case WavePlanAction.logWater:
        viewModel.logWater();
    }
  }

  Future<void> _openHistory(
    BuildContext context,
    WaveChatViewModel viewModel,
  ) async {
    HapticManager.light();
    final day = await WaveHistorySheet.show(
      context,
      days: viewModel.days,
      selectedDay: viewModel.selectedDay,
    );
    if (day != null) viewModel.selectDay(day);
  }

  void _openActiveWorkout() {
    HapticManager.medium();
    _close();
    NavigationService.instance.push(AppRouter.activeWorkout);
  }

  void _openNutrition() {
    HapticManager.light();
    _close();
    NavigationService.instance.push(AppRouter.dietPlan);
  }

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return ChangeNotifierProvider(
      create: (_) => WaveChatViewModel(
        WaveChatService(),
        WaveContextService(),
        WaveTranscriptService(),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: viewPadding.top + AppSizes.s64),
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: AppShapes.decoration(
              color: context.colors.backgroundPrimary,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
              side: BorderSide(
                color: context.colors.borderSubtle,
                width: AppSizes.s1,
              ),
            ),
            child: Consumer<WaveChatViewModel>(
              builder: (context, viewModel, child) {
                return Column(
                  children: [
                    WaveChatHeader(
                      title: WaveChatViewModel.title,
                      status: viewModel.statusLabel,
                      onClose: _close,
                      onHistory: () => _openHistory(context, viewModel),
                    ),
                    const WaveCardDivider(),
                    Expanded(
                      child: ListView.separated(
                        controller: viewModel.scrollController,
                        reverse: true,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.xl,
                        ),
                        itemCount:
                            viewModel.messages.length +
                            (viewModel.isBusy ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: AppSpacing.xl),
                        itemBuilder: (context, index) {
                          if (viewModel.isBusy && index == 0) {
                            return const WaveTypingIndicator();
                          }
                          final offset = viewModel.isBusy ? 1 : 0;
                          final messages = viewModel.messages;
                          final message =
                              messages[messages.length - 1 - (index - offset)];
                          return WaveMessageItem(
                            message: message,
                            viewModel: viewModel,
                            onPlanAction: (item) =>
                                _handlePlanAction(viewModel, item),
                            onOpenNutrition: _openNutrition,
                            onOpenWorkout: _openActiveWorkout,
                          );
                        },
                      ),
                    ),
                    AnimatedSize(
                      duration: AppMotion.composerGrow,
                      curve: AppMotion.composerGrowCurve,
                      alignment: Alignment.bottomCenter,
                      child: viewModel.showQuickActions
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: AppSpacing.md),
                                WaveQuickActionBar(
                                  actions: viewModel.quickActions,
                                  onSelected: (action) {
                                    HapticManager.light();
                                    viewModel.sendQuickAction(action);
                                  },
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    SizedBox(height: AppSpacing.md),
                    const WaveCardDivider(),
                    Padding(
                      padding: EdgeInsets.only(
                        left: AppSpacing.xl,
                        right: AppSpacing.xl,
                        top: AppSpacing.md,
                        bottom: viewInsets.bottom + viewPadding.bottom,
                      ),
                      child: viewModel.isViewingToday
                          ? WaveComposer(
                              controller: viewModel.composer,
                              hintText: WaveChatViewModel.composerHint,
                              canSend: viewModel.canSend,
                              onSubmit: () {
                                HapticManager.light();
                                viewModel.submitComposer();
                              },
                            )
                          : PillButton(
                              variant: PillButtonVariant.neutral,
                              label: 'Back to Today',
                              height: AppSizes.s48,
                              labelColor: context.colors.primary,
                              onPressed: () {
                                HapticManager.light();
                                viewModel.goToToday();
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveBackdrop extends StatelessWidget {
  const _WaveBackdrop();

  static const double _blurSigma = 12;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
      child: ColoredBox(color: context.colors.scrim),
    );
  }
}
