import 'package:flutter/material.dart';

import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/wave/widgets/wave_card.dart';

class WaveReplyCard extends StatelessWidget {
  const WaveReplyCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return WaveCard(
      sections: [
        WaveCardSection(
          child: Text(text, style: context.textTheme.bodyMedium),
        ),
      ],
    );
  }
}
