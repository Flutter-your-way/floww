import 'package:flutter/material.dart';

import 'package:floww/config/widgets/buttons/custom_buttons/destructive_pill_button.dart';

class ProfileLogOutButton extends StatelessWidget {
  const ProfileLogOutButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DestructivePillButton(
      label: label,
      icon: Icons.logout_rounded,
      onPressed: onPressed,
    );
  }
}
