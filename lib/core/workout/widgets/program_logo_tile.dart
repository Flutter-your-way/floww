import 'package:flutter/material.dart';

import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/images/app_photo_tile.dart';
import 'package:floww/core/workout/widgets/wave_logo_tile.dart';

class ProgramLogoTile extends StatelessWidget {
  const ProgramLogoTile({
    super.key,
    required this.imageUrl,
    this.isHighlighted = false,
    this.isWave = false,
  });

  final String imageUrl;
  final bool isHighlighted;
  final bool isWave;

  @override
  Widget build(BuildContext context) {
    if (isWave) return const WaveLogoTile();
    return AppPhotoTile(
      url: imageUrl,
      fallbackIcon: Icons.fitness_center,
      borderColor: isHighlighted
          ? context.colors.borderAccent
          : context.colors.borderGlow,
    );
  }
}
