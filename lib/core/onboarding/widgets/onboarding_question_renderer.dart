import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_constants.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/radio_select_button/custom_radio_select_button.dart';
import 'package:floww/config/widgets/buttons/select_buttons/custom_select_card_button.dart';
import 'package:floww/config/widgets/buttons/select_buttons/custom_select_button.dart';
import 'package:floww/config/widgets/text_field/custom_text_form_field.dart';
import 'package:floww/config/widgets/text_field/max_length_notice.dart';
import 'package:floww/config/widgets/animations/typewriter_text.dart';

import '../models/onboarding_models.dart';
import '../providers/onboarding_provider.dart';
import 'custom_progress_widget.dart';
import 'custom_date_time_selector.dart';

class OnboardingQuestionRenderer extends StatefulWidget {
  final OnboardingQuestion question;

  const OnboardingQuestionRenderer({super.key, required this.question});

  @override
  State<OnboardingQuestionRenderer> createState() =>
      _OnboardingQuestionRendererState();
}

class _OnboardingQuestionRendererState
    extends State<OnboardingQuestionRenderer> {
  bool _showSubtitle = false;
  bool _showOptions = false;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  @override
  void didUpdateWidget(covariant OnboardingQuestionRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      setState(() {
        _showSubtitle = false;
        _showOptions = false;
      });
      _checkInitialState();
    }
  }

  void _checkInitialState() {
    if (widget.question.title.isEmpty) {
      setState(() {
        _showSubtitle = true;
        _showOptions = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.question.title.isNotEmpty)
          TypewriterText(
            text: widget.question.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              fontFamily: 'PlusJakartaSans',
            ),
            onFinished: () {
              setState(() {
                _showSubtitle = true;
                if (widget.question.subtitle == null) {
                  _showOptions = true;
                }
              });
            },
          ),
        if (widget.question.subtitle != null) ...[
          SizedBox(height: AppSpacing.xl3),
          if (_showSubtitle)
            TypewriterText(
              text: widget.question.subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Color(0xFF919191),
                fontFamily: 'HankenGrotesk',
              ),
              onFinished: () {
                setState(() {
                  _showOptions = true;
                });
              },
            )
          else
            // Invisible placeholder to maintain layout structure
            Text(
              widget.question.subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Colors.transparent,
                fontFamily: 'HankenGrotesk',
              ),
            ),
        ],
        SizedBox(height: AppSpacing.xl5),
        Expanded(
          child: AnimatedOpacity(
            opacity: _showOptions ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: SingleChildScrollView(
              child: _buildInputWidget(context, widget.question),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputWidget(BuildContext context, OnboardingQuestion q) {
    final provider = context.watch<OnboardingProvider>();
    final currentValue = provider.getAnswer(q.id);

    switch (q.inputType) {
      case InputType.multiQuestion:
        return Column(
          children: (q.subQuestions ?? []).map((subQ) {
            final bool showTitle =
                subQ.title.isNotEmpty &&
                subQ.title != q.title &&
                subQ.inputType != InputType.timePicker &&
                subQ.inputType != InputType.datePicker &&
                subQ.inputType != InputType.inlineSlider;
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showTitle) ...[
                    const SizedBox(height: 32),
                    Center(
                      child: Text(
                        subQ.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildInputWidget(context, subQ),
                ],
              ),
            );
          }).toList(),
        );

      case InputType.text:
        final textAnswer = currentValue as String?;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextFormField(
              hintText: 'Enter answer',
              initialValue: textAnswer,
              onChanged: (val) => provider.setAnswer(q.id, val),
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              maxLength: AppLimits.displayNameMaxLength,
            ),
            MaxLengthNotice(
              length: textAnswer?.length ?? 0,
              maxLength: AppLimits.displayNameMaxLength,
            ),
          ],
        );

      case InputType.cardSelect:
        return Column(
          children: (q.options ?? []).map((option) {
            final isSelected = currentValue == option.title;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: CustomSelectCardButton(
                title: option.title,
                description: option.description,
                iconData: option.icon,
                isSelected: isSelected,
                onTap: () {
                  provider.setAnswer(q.id, option.title);
                },
              ),
            );
          }).toList(),
        );

      case InputType.singleSelect:
        return Column(
          children: (q.options ?? []).map((option) {
            final isSelected = currentValue == option.title;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: CustomRadioSelectButton(
                title: option.title,
                description: option.description,
                isSelected: isSelected,
                onTap: () {
                  provider.setAnswer(q.id, option.title);
                },
              ),
            );
          }).toList(),
        );

      case InputType.multiSelectPill:
        return Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          alignment: WrapAlignment.center,
          children: (q.options ?? []).map((option) {
            final List<String> currentList =
                (currentValue as List<dynamic>?)?.cast<String>() ?? [];
            final isSelected = currentList.contains(option.title);
            return CustomSelectButton(
              text: option.title,
              isSelected: isSelected,
              onTap: () {
                provider.toggleMultiSelectAnswer(q.id, option.title);
              },
            );
          }).toList(),
        );

      case InputType.multiSelect:
        return Column(
          children: (q.options ?? []).map((option) {
            final List<String> currentList =
                (currentValue as List<dynamic>?)?.cast<String>() ?? [];
            final isSelected = currentList.contains(option.title);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: CustomRadioSelectButton(
                title: option.title,
                description: option.description,
                isSelected: isSelected,
                onTap: () {
                  // For multi-select, tap toggles it in the list
                  provider.toggleMultiSelectAnswer(q.id, option.title);
                },
              ),
            );
          }).toList(),
        );

      case InputType.yesNo:
        return Row(
          children: [
            Expanded(
              child: CustomSelectButton(
                text: 'Yes',
                isSelected: currentValue == 'Yes',
                onTap: () => provider.setAnswer(q.id, 'Yes'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomSelectButton(
                text: 'No',
                isSelected: currentValue == 'No',
                onTap: () => provider.setAnswer(q.id, 'No'),
              ),
            ),
          ],
        );

      case InputType.numberSlider:
        final double val = (currentValue as double?) ?? q.min ?? 0.0;
        // Init default if null
        if (currentValue == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.setAnswer(q.id, val);
          });
        }
        return CustomProgressWidget(
          value: val,
          min: q.min ?? 0.0,
          max: q.max ?? 100.0,
          mainText: val.toInt().toString(),
          suffixText: q.suffixText,
          mainTextStyle: const TextStyle(
            fontSize: 64,
            height: 1.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'PlusJakartaSans',
          ),
          suffixTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Color(0xFF919191),
            fontFamily: 'HankenGrotesk',
          ),
          onChanged: (newVal) => provider.setAnswer(q.id, newVal),
          onDecrease: () => provider.setAnswer(
            q.id,
            (val - 1).clamp(q.min ?? 0.0, q.max ?? 100.0),
          ),
          onIncrease: () => provider.setAnswer(
            q.id,
            (val + 1).clamp(q.min ?? 0.0, q.max ?? 100.0),
          ),
        );

      case InputType.inlineSlider:
        final double val = (currentValue as double?) ?? q.min ?? 0.0;
        if (currentValue == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.setAnswer(q.id, val);
          });
        }

        String formattedValue;
        if (q.id == 'steps_target') {
          final intValue = val.toInt();
          final str = intValue.toString();
          if (str.length > 3) {
            formattedValue =
                '${str.substring(0, str.length - 3)},${str.substring(str.length - 3)}';
          } else {
            formattedValue = str;
          }
        } else {
          formattedValue = val.toInt().toString();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  q.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formattedValue,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: context.colors.primary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),
                    if (q.suffixText != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        q.suffixText!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF919191),
                          fontFamily: 'HankenGrotesk',
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomPillSlider(
              value: val,
              min: q.min ?? 0.0,
              max: q.max ?? 100.0,
              onChanged: (newVal) => provider.setAnswer(q.id, newVal),
            ),
          ],
        );

      case InputType.datePicker:
      case InputType.timePicker:
        final bool isDate = q.inputType == InputType.datePicker;
        return _buildDateTimePicker(context, provider, currentValue, isDate, q);

      case InputType.permission:
        return Column(
          children: (q.options ?? []).map((option) {
            final isSelected = currentValue == option.title;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: CustomRadioSelectButton(
                title: option.title,
                isSelected: isSelected,
                onTap: () => provider.setAnswer(q.id, option.title),
              ),
            );
          }).toList(),
        );

      case InputType.loading:
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF84CC16)),
        );

      case InputType.summary:
        return Center(
          child: Text(
            "Blueprint Complete!\nTap Continue to finish.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
    }
  }

  Widget _buildDateTimePicker(
    BuildContext context,
    OnboardingProvider provider,
    dynamic currentValue,
    bool isDate,
    OnboardingQuestion q,
  ) {
    // Determine the icon and title based on the question title (basic heuristic)
    IconData leadingIcon = Icons.calendar_today;
    final lowerTitle = q.title.toLowerCase();
    bool isYearOnly = false;
    String selectorTitle = 'Select';

    if (isDate) {
      leadingIcon = CupertinoIcons.calendar;
      if (lowerTitle.contains('born') || lowerTitle.contains('birth')) {
        leadingIcon = Icons.cake_outlined;
        isYearOnly = true;
        selectorTitle = 'Year';
      } else {
        selectorTitle = 'Date';
      }
    } else {
      leadingIcon = CupertinoIcons.clock;
      if (lowerTitle.contains('sleep') || lowerTitle.contains('bed')) {
        leadingIcon = Icons.nights_stay;
        selectorTitle = 'Bedtime';
      } else if (lowerTitle.contains('wake') ||
          lowerTitle.contains('morning')) {
        leadingIcon = Icons.wb_sunny_outlined;
        selectorTitle = 'Wake Up Time';
      } else {
        selectorTitle = 'Time';
      }
    }

    return CustomDateTimeSelector(
      title: selectorTitle,
      leadingIcon: leadingIcon,
      currentValue: currentValue as DateTime?,
      isDate: isDate,
      isYearOnly: isYearOnly,
      onChanged: (newDateTime) {
        provider.setAnswer(q.id, newDateTime);
      },
    );
  }
}
