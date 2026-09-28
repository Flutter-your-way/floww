import 'package:flutter/material.dart';

import 'package:floww/config/widgets/cards/app_toggle_card.dart';
import 'package:floww/core/settings/models/settings_view_data.dart';

class NotificationMasterCard extends StatelessWidget {
  const NotificationMasterCard({super.key, required this.item, this.onChanged});

  final NotificationToggleItem item;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppToggleCard(
      icon: Icons.notifications_none_rounded,
      title: item.title,
      subtitle: item.subtitle,
      value: item.isEnabled,
      onChanged: onChanged,
    );
  }
}
