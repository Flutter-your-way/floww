import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/models/wave_message.dart';
import 'package:floww/core/wave/models/wave_quick_action.dart';
import 'package:floww/core/wave/view_models/wave_chat_view_model.dart';
import 'package:floww/core/wave/widgets/wave_check_in_card.dart';
import 'package:floww/core/wave/widgets/wave_confirmation_card.dart';
import 'package:floww/core/wave/widgets/wave_daily_brief_card.dart';
import 'package:floww/core/wave/widgets/wave_diet_plan_card.dart';
import 'package:floww/core/wave/widgets/wave_injury_swap_card.dart';
import 'package:floww/core/wave/widgets/wave_meal_log_card.dart';
import 'package:floww/core/wave/widgets/wave_plan_card.dart';
import 'package:floww/core/wave/widgets/wave_reply_card.dart';
import 'package:floww/core/wave/widgets/wave_score_report_card.dart';
import 'package:floww/core/wave/widgets/wave_user_bubble.dart';

class WaveMessageItem extends StatelessWidget {
  const WaveMessageItem({
    super.key,
    required this.message,
    required this.viewModel,
    required this.onPlanAction,
    required this.onOpenNutrition,
  });

  final WaveMessage message;
  final WaveChatViewModel viewModel;
  final ValueChanged<WavePlanItem> onPlanAction;
  final VoidCallback onOpenNutrition;

  @override
  Widget build(BuildContext context) {
    final isUser = message is WaveUserMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _content(),
        SizedBox(height: AppSpacing.md),
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            viewModel.timeLabel(message),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.textDim,
            ),
          ),
        ),
      ],
    );
  }

  Widget _content() {
    final message = this.message;

    return switch (message) {
      WaveUserMessage() => WaveUserBubble(text: message.text),
      WaveReplyMessage() => WaveReplyCard(text: message.text),
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
      WaveConfirmationMessage() => WaveConfirmationCard(
        title: message.title,
        detail: message.detail,
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
}
