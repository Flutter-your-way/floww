import 'package:flutter/material.dart';

import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class ProfileTargetsNoteCard extends StatelessWidget {
  const ProfileTargetsNoteCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Text(
        message,
        style: AppTypography.bodyMediumRegular.copyWith(
          color: context.colors.textSubtle,
        ),
      ),
    );
  }
}
