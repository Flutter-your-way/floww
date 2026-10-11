import 'package:floww/config/constants/app_motion.dart';

class WaveReveal {
  const WaveReveal._();

  static final RegExp _token = RegExp(r'\S+\s*');

  static List<String> tokensOf(String text) => [
    for (final match in _token.allMatches(text.trimLeft())) match.group(0)!,
  ];

  static Duration durationFor(String text) {
    final steps = tokensOf(text).length + AppMotion.waveRevealFadeWords;
    final duration = AppMotion.waveRevealPerWord * steps;
    if (duration < AppMotion.waveRevealMin) return AppMotion.waveRevealMin;
    if (duration > AppMotion.waveRevealMax) return AppMotion.waveRevealMax;
    return duration;
  }
}
