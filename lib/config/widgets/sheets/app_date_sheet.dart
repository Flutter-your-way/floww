import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class AppDateSheet extends StatefulWidget {
  const AppDateSheet({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.title = 'Select date',
    this.cancelLabel = 'Cancel',
    this.confirmLabel = 'Select',
  });

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showAppFloatingSheet<DateTime>(
      context: context,
      centered: true,
      builder: (_) => AppDateSheet(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );
  }

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;
  final String cancelLabel;
  final String confirmLabel;

  @override
  State<AppDateSheet> createState() => _AppDateSheetState();
}

class _AppDateSheetState extends State<AppDateSheet> {
  late DateTime _selected = AppDateUtils.dateOnly(widget.initialDate);
  late DateTime _displayedMonth = _selected;

  @override
  Widget build(BuildContext context) {
    return AppFloatingSheet(
      frosted: true,
      alignment: Alignment.center,
      child: AppSheetPanel(
        title: widget.title,
        titleStyle: AppTypography.heading4SemiBold.copyWith(
          color: context.colors.textPrimary,
        ),
        subtitle: AppDateUtils.relativeDay(_selected),
        icon: Icons.calendar_today_rounded,
        onClose: () => NavigationService.instance.pop(),
        body: _AppCalendarTheme(
          child: _FittedCalendar(
            month: _displayedMonth,
            child: CalendarDatePicker(
              initialDate: _selected,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              onDateChanged: (date) => setState(() => _selected = date),
              onDisplayedMonthChanged: (month) =>
                  setState(() => _displayedMonth = month),
            ),
          ),
        ),
        footer: Row(
          children: [
            Expanded(
              child: PillButton(
                variant: PillButtonVariant.outline,
                label: widget.cancelLabel,
                height: AppSizes.s56,
                labelStyle: AppTypography.labelLargeSemiBold,
                onPressed: () => NavigationService.instance.pop(),
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: PillButton(
                variant: PillButtonVariant.primary,
                label: widget.confirmLabel,
                height: AppSizes.s56,
                labelStyle: AppTypography.labelLargeSemiBold,
                onPressed: () => NavigationService.instance.pop(_selected),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FittedCalendar extends StatelessWidget {
  const _FittedCalendar({required this.month, required this.child});

  static const double _headerHeight = AppSizes.s52;
  static const double _rowHeight = AppSizes.s48;
  static const int _maxWeeks = 6;
  static const int _daysPerWeek = DateTime.daysPerWeek;
  static const double _textScaleProbe = 14;
  static const double _maxUnscaledTextFactor = 1.3;
  static const double _maxHeight = _headerHeight + _rowHeight * (_maxWeeks + 1);

  final DateTime month;
  final Widget child;

  int _weeksIn(BuildContext context) {
    final firstWeekday = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final leading =
        (DateTime(month.year, month.month).weekday % _daysPerWeek -
            firstWeekday) %
        _daysPerWeek;
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    return ((leading + days) / _daysPerWeek).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final isScaledText =
        MediaQuery.textScalerOf(context).scale(_textScaleProbe) /
            _textScaleProbe >
        _maxUnscaledTextFactor;
    if (isScaledText) return child;
    final height = _headerHeight + _rowHeight * (_weeksIn(context) + 1);

    return AnimatedContainer(
      duration: AppMotion.expand,
      curve: AppMotion.expandCurve,
      height: height,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      child: OverflowBox(
        alignment: Alignment.topCenter,
        minHeight: _maxHeight,
        maxHeight: _maxHeight,
        child: child,
      ),
    );
  }
}

class _AppCalendarTheme extends StatelessWidget {
  const _AppCalendarTheme({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    WidgetStateProperty<Color?> selectable({
      required Color selected,
      required Color idle,
      Color? disabled,
    }) {
      return WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return selected;
        if (states.contains(WidgetState.disabled)) return disabled;
        return idle;
      });
    }

    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: colors.primary,
          onPrimary: colors.backgroundPrimary,
          surface: Colors.transparent,
          onSurface: colors.textPrimary,
          onSurfaceVariant: colors.textSecondary,
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.transparent,
          subHeaderForegroundColor: colors.textPrimary,
          weekdayStyle: AppTypography.bodySmallSemiBold,
          dayStyle: AppTypography.bodyMediumMedium,
          yearStyle: AppTypography.bodyMediumMedium,
          dayForegroundColor: selectable(
            selected: colors.backgroundPrimary,
            idle: colors.textPrimary,
            disabled: colors.textSecondary,
          ),
          dayBackgroundColor: selectable(
            selected: colors.primary,
            idle: Colors.transparent,
          ),
          dayOverlayColor: WidgetStatePropertyAll(colors.tint),
          todayForegroundColor: selectable(
            selected: colors.backgroundPrimary,
            idle: colors.primary,
          ),
          todayBackgroundColor: selectable(
            selected: colors.primary,
            idle: Colors.transparent,
          ),
          todayBorder: BorderSide(color: colors.primary, width: 1),
          yearForegroundColor: selectable(
            selected: colors.backgroundPrimary,
            idle: colors.textPrimary,
            disabled: colors.textSecondary,
          ),
          yearBackgroundColor: selectable(
            selected: colors.primary,
            idle: Colors.transparent,
          ),
          yearOverlayColor: WidgetStatePropertyAll(colors.tint),
        ),
      ),
      child: child,
    );
  }
}
