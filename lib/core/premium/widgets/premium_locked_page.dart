import 'package:flutter/material.dart';

import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/headers/custom_header.dart';
import 'package:floww/core/premium/providers/premium_access_provider.dart';
import 'package:floww/core/premium/widgets/premium_locked_panel.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class PremiumLockedPage extends StatelessWidget {
  const PremiumLockedPage({
    super.key,
    required this.title,
    required this.capability,
  });

  final String title;
  final PremiumCapability capability;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.sizes.screenHorizontalPadding;

    return Scaffold(
      backgroundColor: context.colors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: CustomHeader(
                title: title,
                onBackPressed: () => NavigationService.instance.pop(),
              ),
            ),
            Expanded(child: PremiumLockedPanel(capability: capability)),
          ],
        ),
      ),
    );
  }
}
