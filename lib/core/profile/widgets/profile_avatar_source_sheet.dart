import 'package:flutter/material.dart';

import 'package:floww/config/widgets/sheets/app_option_sheet.dart';
import 'package:floww/core/profile/models/profile_edit_data.dart';

class ProfileAvatarSourceSheet {
  ProfileAvatarSourceSheet._();

  static Future<ProfileAvatarOption?> show(
    BuildContext context, {
    required String title,
    required List<ProfileAvatarOption> options,
  }) {
    return AppOptionSheet.show<ProfileAvatarOption>(
      context,
      title: title,
      icon: Icons.person_outline_rounded,
      options: [
        for (final option in options)
          AppSheetOption(
            icon: option.icon,
            label: option.label,
            value: option,
            isDestructive: option.isDestructive,
          ),
      ],
    );
  }
}
