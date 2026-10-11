import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/models/wave_message.dart';
import 'package:floww/core/wave/models/wave_quick_action.dart';
import 'package:floww/core/wave/view_models/wave_chat_view_model.dart';
import 'package:floww/core/wave/widgets/wave_action_prompt_card.dart';
import 'package:floww/core/wave/widgets/wave_check_in_card.dart';
import 'package:floww/core/wave/widgets/wave_confirmation_card.dart';
import 'package:floww/core/wave/widgets/wave_daily_brief_card.dart';
import 'package:floww/core/wave/widgets/wave_diet_plan_card.dart';
import 'package:floww/core/wave/widgets/wave_injury_swap_card.dart';
import 'package:floww/core/wave/widgets/wave_meal_log_card.dart';
import 'package:floww/core/wave/widgets/wave_plan_card.dart';
import 'package:floww/core/wave/widgets/wave_rating_bar.dart';
import 'package:floww/core/wave/widgets/wave_reply_card.dart';
import 'package:floww/core/wave/widgets/wave_reply_frame.dart';
import 'package:floww/core/wave/widgets/wave_score_report_card.dart';
import 'package:floww/core/wave/widgets/wave_user_bubble.dart';

class WaveMessageItem extends StatelessWidget {
  const WaveMessageItem({
    super.key,
    required this.message,
    required this.viewModel,
    required this.onPlanAction,
    required this.onOpenNutrition,
    required this.onOpenWorkout,
    required this.onOpenMemory,
    required this.onUpgrade,
  });

  final WaveMessage message;
  final WaveChatViewModel viewModel;
  final ValueChanged<WavePlanItem> onPlanAction;
  final VoidCallback onOpenNutrition;
  final VoidCallback onOpenWorkout;
  final VoidCallback onOpenMemory;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final isUser = message is WaveUserMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _framed(),
        if (isUser) ...[
          SizedBox(height: AppSpacing.sm),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: _TimeLabel(label: viewModel.timeLabel(message)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _framed() {
    final message = this.message;
    final content = _content();
    if (message is WaveUserMessage || message is WaveReplyMessage) {
      return content;
    }
    return WaveReplyFrame(
      fillWidth: message is! WaveConfirmationMessage,
      footer: _ReplyFooter(message: message, viewModel: viewModel),
      child: content,
    );
  }

  Widget _content() {
    final message = this.message;

    return switch (message) {
      WaveUserMessage() => WaveUserBubble(text: message.text),
      WaveReplyMessage() => WaveReplyCard(
        text: message.text,
        reveal: viewModel.isRevealing(message.id),
        onRevealed: () => viewModel.completeReveal(message.id),
        footer: _ReplyFooter(message: message, viewModel: viewModel),
      ),
      WaveDailyBriefMessage() => WaveDailyBriefCard(
        brief: message.brief,
        onStartDay: viewModel.startDay,
      ),
      WavePlanMessage() => WavePlanCard(
        title: message.title,
        items: message.items,
        onAction: onPlanAction,
      ),
      WaveInjurySwapMessage() => WaveInjurySwapCard(
        swap: message.swap,
        isResolved: viewModel.isResolved(message.id),
        onApply: () => viewModel.applySwap(message),
        onKeep: () => viewModel.keepOriginal(message),
      ),
      WaveConfirmationMessage() => _confirmationOf(message),
      WaveActionPromptMessage() => WaveActionPromptCard(
        title: message.title,
        detail: message.detail,
        confirmLabel: WaveChatViewModel.confirmLabel,
        cancelLabel: WaveChatViewModel.cancelLabel,
        isResolved: viewModel.isResolved(message.id),
        onConfirm: () => viewModel.confirmPending(message.id),
        onCancel: () => viewModel.dismissPending(message.id),
      ),
      WaveCheckInMessage() => WaveCheckInCard(
        title: message.title,
        subtitle: message.subtitle,
        selected: viewModel.feelingFor(message.id),
        onSelected: (feeling) => viewModel.selectFeeling(message.id, feeling),
      ),
      WaveScoreReportMessage() => WaveScoreReportCard(
        report: message.report,
        onLogMeal: () => viewModel.sendQuickAction(WaveQuickAction.logMeal),
        onLogWater: viewModel.logWater,
      ),
      WaveMealLogMessage() => WaveMealLogCard(
        title: message.title,
        subtitle: message.subtitle,
        foods: message.foods,
        selectedSlot: viewModel.mealSlotFor(message.id),
        totals: viewModel.mealTotals(message),
        isSelected: (food) => viewModel.isFoodSelected(message.id, food),
        onSlotSelected: (slot) => viewModel.selectMealSlot(message.id, slot),
        onFoodToggled: (food) => viewModel.toggleFood(message.id, food),
        onLogMeal: () => viewModel.logMeal(message),
      ),
      WaveDietPlanMessage() => WaveDietPlanCard(
        plan: message.plan,
        onViewInNutrition: onOpenNutrition,
      ),
    };
  }

  Widget _confirmationOf(WaveConfirmationMessage message) {
    return WaveConfirmationCard(
      title: message.title,
      detail: message.detail,
      tone: message.tone,
      actionLabel: viewModel.confirmationActionLabel(message),
      actionIcon: switch (message.action) {
        WaveConfirmationAction.undo => Icons.undo_rounded,
        WaveConfirmationAction.upgrade => Icons.auto_awesome_rounded,
        null => null,
        _ => Icons.arrow_forward_rounded,
      },
      onAction: switch (message.action) {
        WaveConfirmationAction.openWorkout => onOpenWorkout,
        WaveConfirmationAction.openMemory => onOpenMemory,
        WaveConfirmationAction.undo => () => viewModel.undo(message.id),
        WaveConfirmationAction.upgrade => onUpgrade,
        WaveConfirmationAction.navigate => () => viewModel.openDestination(
          message.id,
        ),
        null => null,
      },
    );
  }
}

class _ReplyFooter extends StatelessWidget {
  const _ReplyFooter({required this.message, required this.viewModel});

  final WaveMessage message;
  final WaveChatViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          if (viewModel.canRate(message.id))
            WaveRatingBar(
              selected: viewModel.ratingFor(message.id),
              onRated: (rating) {
                HapticManager.light();
                viewModel.rate(message.id, rating);
              },
            ),
          const Spacer(),
          _TimeLabel(label: viewModel.timeLabel(message)),
        ],
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  const _TimeLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.textTheme.labelSmall?.copyWith(
        color: context.colors.textQuiet,
      ),
    );
  }
}
