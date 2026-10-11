import 'package:floww/core/wave/models/wave_action.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/models/wave_undo.dart';

class WaveActionOutcome {
  const WaveActionOutcome(
    this.title,
    this.detail, {
    this.tone = WaveConfirmationTone.success,
    this.link,
    this.undo,
    this.destination,
  });

  final String title;
  final String detail;
  final WaveConfirmationTone tone;
  final WaveConfirmationAction? link;
  final WaveUndo? undo;
  final WaveDestination? destination;

  WaveConfirmationAction? get action => undo != null
      ? WaveConfirmationAction.undo
      : destination != null
      ? WaveConfirmationAction.navigate
      : link;
}
