import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_glass.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/effects/liquid_glass.dart';
import 'package:floww/core/guide/providers/guide_controller.dart';

class GuideReplayButton extends StatelessWidget {
  const GuideReplayButton({super.key});

  void _play(BuildContext context) {
    HapticManager.light();
    context.read<GuideController>().replay();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Play app tutorial',
      child: PressScale(
        onTap: () => _play(context),
        child: LiquidGlass(
          borderRadius: BorderRadius.circular(AppRadius.full),
          blurSigma: AppGlass.blurSigmaLight,
          refraction: AppGlass.refractionSoft,
          thickness: AppGlass.edgeThicknessTight,
          child: SizedBox.square(
            dimension: AppSizes.s40,
            child: Icon(
              Icons.explore_outlined,
              color: context.colors.primary,
              size: AppSizes.s20,
            ),
          ),
        ),
      ),
    );
  }
}
