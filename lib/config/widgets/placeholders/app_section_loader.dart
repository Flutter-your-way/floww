import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class AppSectionLoader extends StatelessWidget {
  const AppSectionLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl5),
      child: Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      ),
    );
  }
}
