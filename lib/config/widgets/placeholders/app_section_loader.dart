import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/placeholders/app_spinner.dart';

class AppSectionLoader extends StatelessWidget {
  const AppSectionLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl5),
      child: const Center(
        child: AppSpinner(
          size: AppSizes.s36,
          strokeWidth: AppSizes.s4,
          revealDelay: AppMotion.spinnerRevealDelay,
        ),
      ),
    );
  }
}
