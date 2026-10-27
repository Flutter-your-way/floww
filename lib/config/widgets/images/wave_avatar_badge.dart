import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class WaveAvatarBadge extends StatelessWidget {
  const WaveAvatarBadge({super.key, this.size = AppSizes.s44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppImages.waveIcon,
      width: size,
      height: size,
      theme: SvgTheme(currentColor: context.colors.primary),
    );
  }
}
