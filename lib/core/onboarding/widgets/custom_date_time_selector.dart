import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/theme/app_shapes.dart';

class CustomDateTimeSelector extends StatelessWidget {
  final String title;
  final IconData leadingIcon;
  final DateTime? currentValue;
  final bool isDate;
  final bool isYearOnly;
  final ValueChanged<DateTime> onChanged;

  const CustomDateTimeSelector({
    super.key,
    required this.title,
    required this.leadingIcon,
    this.currentValue,
    this.isDate = false,
    this.isYearOnly = false,
    required this.onChanged,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = context.colors;
    const backgroundColor = Color(0xFF1F1F1F);
    
    String displayValue;
    if (currentValue != null) {
      if (isYearOnly) {
        displayValue = currentValue!.year.toString();
      } else if (isDate) {
        displayValue = _formatDate(currentValue!);
      } else {
        displayValue = _formatTime(currentValue!);
      }
    } else {
      if (isYearOnly) {
        displayValue = "Select Year";
      } else {
        displayValue = isDate ? "Select Date" : "Select Time";
      }
    }

    return GestureDetector(
      onTap: () => _showPicker(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: AppShapes.decoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color(0xFF181818), width: 1),
        ),
        child: Row(
          children: [
            // Leading Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: AppShapes.decoration(
                color: themeColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                leadingIcon,
                color: themeColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Title
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyLargeMedium.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            
            // Value Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: AppShapes.decoration(
                color: const Color(0xFF131313),
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: const Color(0xFF181818), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayValue,
                    style: AppTypography.bodyMediumMedium.copyWith(
                      color: Colors.white,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isDate ? Icons.calendar_today_outlined : CupertinoIcons.clock,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.backgroundSurface,
      shape: AppShapes.border(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isYearOnly 
                          ? "Select Year" 
                          : (isDate ? "Select Date" : "Select Time"),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.check,
                        color: context.colors.primary,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isYearOnly
                    ? _buildYearPicker(context)
                    : CupertinoTheme(
                        data: CupertinoThemeData(
                          textTheme: CupertinoTextThemeData(
                            dateTimePickerTextStyle: TextStyle(
                              color: context.colors.textPrimary,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        child: CupertinoDatePicker(
                          mode: isDate ? CupertinoDatePickerMode.date : CupertinoDatePickerMode.time,
                          initialDateTime: currentValue ?? DateTime.now(),
                          onDateTimeChanged: onChanged,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildYearPicker(BuildContext context) {
    final int currentYear = DateTime.now().year;
    final int initialYear = currentValue?.year ?? 2000;
    final int initialIndex = currentYear - initialYear;

    return CupertinoPicker(
      itemExtent: 40.0,
      scrollController: FixedExtentScrollController(
        initialItem: initialIndex >= 0 ? initialIndex : 0,
      ),
      onSelectedItemChanged: (int index) {
        final selectedYear = currentYear - index;
        onChanged(DateTime(selectedYear, 1, 1));
      },
      children: List<Widget>.generate(currentYear - 1900 + 1, (int index) {
        return Center(
          child: Text(
            (currentYear - index).toString(),
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 24,
            ),
          ),
        );
      }),
    );
  }
}
