import 'package:flutter/material.dart';
import 'package:floww/config/widgets/images/wave_avatar_badge.dart';

import 'package:floww/config/constants/app_sizes.dart';

class WaveLogoTile extends StatelessWidget {
  const WaveLogoTile({super.key, this.size = AppSizes.s48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return WaveAvatarBadge(size: size, contained: true);
  }
}
