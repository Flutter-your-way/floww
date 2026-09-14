import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';

class SwipeToDelete extends StatelessWidget {
  const SwipeToDelete({
    super.key,
    required this.id,
    required this.child,
    this.onDelete,
  });

  final String id;
  final Widget child;
  final ValueChanged<String>? onDelete;

  @override
  Widget build(BuildContext context) {
    final onDelete = this.onDelete;
    if (onDelete == null) return child;

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        decoration: AppShapes.decoration(
          color: context.colors.destructive,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: context.colors.textPrimary,
          size: AppSizes.s20,
        ),
      ),
      child: child,
    );
  }
}
