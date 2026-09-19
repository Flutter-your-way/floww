import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
import 'package:floww/core/wave/widgets/wave_message_item.dart';
import 'package:floww/core/wave/widgets/wave_quick_action_bar.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

Future<void> showWaveChatSheet(BuildContext context) {
  final theme = Theme.of(context);

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: AppMotion.expand,
    pageBuilder: (context, animation, secondaryAnimation) =>
        Theme(data: theme, child: const WaveChatSheet()),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.expandCurve,
        reverseCurve: AppMotion.collapseCurve,
      );

      return Theme(
        data: theme,
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
      case WavePlanAction.logMeal:
        viewModel.sendQuickAction(WaveQuickAction.logMeal);
      case WavePlanAction.logWater:
        viewModel.logWater();
    }
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
                    ),
                    const WaveCardDivider(),
                    Expanded(
                      child: ListView.separated(
                        controller: viewModel.scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.xl,
                        ),
                        itemCount: viewModel.messages.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: AppSpacing.xl),
                        itemBuilder: (context, index) {
                          final message = viewModel.messages[index];
                          return WaveMessageItem(
                            message: message,
                            viewModel: viewModel,
                            onPlanAction: (item) =>
                                _handlePlanAction(viewModel, item),
                            onOpenNutrition: _openNutrition,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    WaveQuickActionBar(
                      actions: viewModel.quickActions,
                      onSelected: (action) {
                        HapticManager.light();
                        viewModel.sendQuickAction(action);
                      },
                    ),
                    SizedBox(height: AppSpacing.xl),
                    const WaveCardDivider(),
                    Padding(
                      padding: EdgeInsets.only(
                        left: AppSpacing.xl,
                        right: AppSpacing.xl,
                        top: AppSpacing.xl,
                        bottom:
                            viewInsets.bottom +
                            viewPadding.bottom +
                            AppSpacing.md,
                      ),
                      child: WaveComposer(
                        controller: viewModel.composer,
                        hintText: WaveChatViewModel.composerHint,
                        canSend: viewModel.canSend,
                        onSubmit: () {
                          HapticManager.light();
                          viewModel.submitComposer();
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
