import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/widgets/placeholders/app_spinner.dart';
import 'package:floww/core/premium/providers/premium_access_provider.dart';

class PremiumGate extends StatelessWidget {
  const PremiumGate({
    super.key,
    required this.capability,
    required this.locked,
    required this.child,
    this.placeholder = const Center(child: AppSpinner()),
  });

  final PremiumCapability capability;
  final Widget locked;
  final Widget child;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) {
    final access = context.watch<PremiumAccessProvider>();
    if (access.isLoading) return placeholder;
    return access.canUse(capability) ? child : locked;
  }
}
