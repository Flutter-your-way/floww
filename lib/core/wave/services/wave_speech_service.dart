import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum WaveSpeechFailure { unavailable, permissionDenied, noSpeech, failed }

class WaveSpeechSession {
  const WaveSpeechSession({
    required this.onWords,
    required this.onLevel,
    required this.onDone,
    required this.onFailure,
  });

  final void Function(String words, bool isFinal) onWords;
  final ValueChanged<double> onLevel;
  final VoidCallback onDone;
  final ValueChanged<WaveSpeechFailure> onFailure;
}

class WaveSpeechService {
  WaveSpeechService._();

  static final WaveSpeechService instance = WaveSpeechService._();

  static const Duration silenceTimeout = Duration(seconds: 5);
  static const Duration maxListen = Duration(seconds: 60);
  static const Duration finalTimeout = Duration(milliseconds: 1200);

  static const Set<String> _noSpeechErrors = {
    'error_speech_timeout',
    'error_no_match',
  };

  static const Set<String> _permissionErrors = {
    'error_permission',
    'error_insufficient_permissions',
    'error_speech_recognizer_disabled',
  };

  final SpeechToText _speech = SpeechToText();
  WaveSpeechSession? _session;

  bool get isListening => _speech.isListening;

  Future<void> start(WaveSpeechSession session) async {
    _session = session;
    try {
      final available = await _speech.initialize(
        onStatus: _onStatus,
        onError: _onError,
        finalTimeout: finalTimeout,
      );
      if (!identical(_session, session)) return;
      if (!available) {
        session.onFailure(
          await _speech.hasPermission
              ? WaveSpeechFailure.unavailable
              : WaveSpeechFailure.permissionDenied,
        );
        return;
      }

      await _speech.listen(
        onResult: (result) => _onResult(session, result),
        onSoundLevelChange: (level) {
          if (identical(_session, session)) session.onLevel(level);
        },
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          autoPunctuation: true,
          listenMode: ListenMode.dictation,
          pauseFor: silenceTimeout,
          listenFor: maxListen,
        ),
      );
    } catch (e) {
      debugPrint('wave speech start failed: $e');
      if (identical(_session, session)) {
        session.onFailure(WaveSpeechFailure.failed);
      }
    }
  }

  Future<void> stop() => _speech.stop();

  Future<void> cancel() async {
    _session = null;
    await _speech.cancel();
  }

  void _onResult(WaveSpeechSession session, SpeechRecognitionResult result) {
    if (!identical(_session, session)) return;
    session.onWords(result.recognizedWords, result.finalResult);
  }

  void _onStatus(String status) {
    if (status != SpeechToText.doneStatus || _speech.isListening) return;
    _session?.onDone();
  }

  void _onError(SpeechRecognitionError error) {
    final session = _session;
    if (session == null) return;
    debugPrint('wave speech error: ${error.errorMsg}');
    if (_noSpeechErrors.contains(error.errorMsg)) {
      if (_speech.isListening) return;
      session.onFailure(WaveSpeechFailure.noSpeech);
    } else if (_permissionErrors.contains(error.errorMsg)) {
      session.onFailure(WaveSpeechFailure.permissionDenied);
    } else if (error.permanent) {
      session.onFailure(WaveSpeechFailure.failed);
    }
  }
}
