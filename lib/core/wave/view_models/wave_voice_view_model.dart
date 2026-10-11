import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:floww/core/wave/services/wave_speech_service.dart';

enum WaveVoiceState { starting, listening, finishing, failed }

class WaveVoiceViewModel extends ChangeNotifier {
  WaveVoiceViewModel(this._speech, {required this.onFinished}) {
    _start();
  }

  static const String startingLabel = 'Getting ready';
  static const String listeningLabel = 'Listening';
  static const String heardLabel = 'Sending when you pause';
  static const String finishingLabel = 'Got it';
  static const String errorLabel = 'Mic unavailable';
  static const String hint =
      'Ask about your workout, meals, sleep or Flow Score';
  static const String permissionMessage =
      'Allow microphone and speech recognition for Floww in Settings to '
      'talk to WAVE.';
  static const String unavailableMessage =
      'Speech recognition is not available on this device right now.';
  static const String failedMessage =
      'I could not hear that clearly. Try again or type your message.';

  static const Duration holdDuration = Duration(seconds: 4);
  static const Duration _stopGrace = Duration(milliseconds: 1500);
  static const Duration _restartDelay = Duration(milliseconds: 300);
  static const double _levelSmoothing = 0.35;
  static const double _levelRange = 12;

  final WaveSpeechService _speech;
  final ValueChanged<String?> onFinished;

  WaveVoiceState _state = WaveVoiceState.starting;
  WaveSpeechFailure? _failure;
  String _committed = '';
  String _partial = '';
  String _lastFinal = '';
  double _level = 0;
  double? _levelFloor;
  bool _finished = false;
  bool _restarting = false;
  bool _disposed = false;
  Timer? _stopTimer;
  Timer? _holdTimer;

  WaveVoiceState get state => _state;

  String get transcript =>
      [_committed, _partial].where((part) => part.trim().isNotEmpty).join(' ');

  bool get hasTranscript => transcript.trim().isNotEmpty;

  double get level => _level;

  bool get isListening => _state == WaveVoiceState.listening;

  bool get canFinish => isListening && hasTranscript;

  String get statusLabel => switch (_state) {
    WaveVoiceState.starting => startingLabel,
    WaveVoiceState.listening => hasTranscript ? heardLabel : listeningLabel,
    WaveVoiceState.finishing => finishingLabel,
    WaveVoiceState.failed => errorLabel,
  };

  String? get failureMessage => switch (_failure) {
    WaveSpeechFailure.permissionDenied => permissionMessage,
    WaveSpeechFailure.unavailable => unavailableMessage,
    WaveSpeechFailure.failed => failedMessage,
    WaveSpeechFailure.noSpeech || null => null,
  };

  Future<void> finish() async {
    if (!isListening) return;
    _holdTimer?.cancel();
    _setState(WaveVoiceState.finishing);
    _stopTimer = Timer(_stopGrace, _complete);
    await _speech.stop();
  }

  Future<void> cancel() async {
    if (_finished) return;
    _finished = true;
    _holdTimer?.cancel();
    _stopTimer?.cancel();
    await _speech.cancel();
    onFinished(null);
  }

  Future<void> _start() async {
    await _listen();
    if (_state == WaveVoiceState.starting && !_finished) {
      _setState(WaveVoiceState.listening);
      _armHold();
    }
  }

  Future<void> _listen() => _speech.start(
    WaveSpeechSession(
      onWords: _onWords,
      onLevel: _onLevel,
      onDone: _onEngineDone,
      onFailure: _onFailure,
    ),
  );

  void _armHold() {
    _holdTimer?.cancel();
    _holdTimer = Timer(holdDuration, _onHoldElapsed);
  }

  void _onHoldElapsed() {
    if (_finished || !isListening) return;
    if (hasTranscript) {
      finish();
    } else {
      cancel();
    }
  }

  void _onWords(String words, bool isFinal) {
    if (_finished || _state == WaveVoiceState.failed) return;
    if (_partial.isEmpty && words == _lastFinal) return;
    if (words != _partial) {
      _partial = words;
      if (isListening) _armHold();
    }
    if (isFinal) _commit();
    notifyListeners();
  }

  void _commit() {
    if (_partial.isNotEmpty) _lastFinal = _partial;
    _committed = transcript;
    _partial = '';
  }

  void _onEngineDone() {
    if (_finished) return;
    if (_state == WaveVoiceState.finishing) {
      _complete();
      return;
    }
    if (isListening) _restart();
  }

  Future<void> _restart() async {
    if (_restarting) return;
    _restarting = true;
    _commit();
    await Future<void>.delayed(_restartDelay);
    if (!_finished && !_disposed && isListening) await _listen();
    _restarting = false;
  }

  void _onLevel(double raw) {
    if (_finished) return;
    final floor = _levelFloor == null || raw < _levelFloor!
        ? raw
        : _levelFloor!;
    _levelFloor = floor;
    final target = ((raw - floor) / _levelRange).clamp(0.0, 1.0);
    _level += (target - _level) * _levelSmoothing;
    notifyListeners();
  }

  void _onFailure(WaveSpeechFailure failure) {
    if (_finished) return;
    if (failure == WaveSpeechFailure.noSpeech) {
      _onEngineDone();
      return;
    }
    if (hasTranscript) {
      _complete();
      return;
    }
    _holdTimer?.cancel();
    _failure = failure;
    _level = 0;
    _setState(WaveVoiceState.failed);
  }

  void _complete() {
    if (_finished || _state == WaveVoiceState.failed) return;
    _finished = true;
    _holdTimer?.cancel();
    _stopTimer?.cancel();
    final text = transcript.trim();
    onFinished(text.isEmpty ? null : text);
  }

  void _setState(WaveVoiceState state) {
    if (_state == state) return;
    _state = state;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _holdTimer?.cancel();
    _stopTimer?.cancel();
    if (!_finished) _speech.cancel();
    super.dispose();
  }
}
