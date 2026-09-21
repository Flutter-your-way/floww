import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/config/utils/share/share_service.dart';
import 'package:floww/core/nutrition/services/food_camera_service.dart';
import 'package:floww/core/nutrition/services/photo_library_service.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/core/workout/models/workout_completion.dart';
import 'package:floww/core/workout/models/workout_completion_view_data.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/services/workout_metrics.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';

typedef ShareCardCapture = Future<Uint8List> Function();

class WorkoutCompletionViewModel extends ChangeNotifier {
  WorkoutCompletionViewModel(
    this._service,
    this._result, {
    ShareService shareService = const ShareService(),
    PhotoLibraryService? photoLibraryService,
  }) : _shareService = shareService,
       _photoLibraryService = photoLibraryService ?? PhotoLibraryService();

  static const int _secondsPerMinute = 60;
  static const int _photoCardIndex = 1;
  static const String _fileNameFallback = 'floww-workout';
  static const String _savedMessage = 'Saved to your photos.';
  static const String _genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String _siteLabel = 'flowwapp.com';
  static const String _handleLabel = '@flowwapp_';
  static const int _maxMuscleTags = 3;

  final WorkoutSessionService _service;
  final WorkoutCompletionResult _result;
  final ShareService _shareService;
  final PhotoLibraryService _photoLibraryService;

  int _sharePageIndex = 0;
  RecoveryMood? _selectedMood;
  Uint8List? _sharePhotoBytes;
  ShareTarget? _busyTarget;
  String? _statusMessage;

  int get sharePageIndex => _sharePageIndex;

  ShareTarget? get busyTarget => _busyTarget;

  bool get isSharing => _busyTarget != null;

  String? get statusMessage => _statusMessage;

  Uint8List? get sharePhotoBytes => _sharePhotoBytes;

  RecoveryMood? get selectedMood => _selectedMood;

  bool get canSaveRecovery => _selectedMood != null;

  WorkoutSessionEntity get _session => _result.session;

  int get _flowScoreGain => _result.flowScoreAfter - _result.flowScoreBefore;

  List<String> get _muscleTags {
    final muscles = _session.muscleActivation;
    final count = muscles.length < _maxMuscleTags
        ? muscles.length
        : _maxMuscleTags;
    return [for (var i = 0; i < count; i++) muscles[i].name];
  }

  String get _modeLabel =>
      _session.focus.isEmpty ? 'FLOW MODE' : _session.focus.toUpperCase();

  String get _headline {
    final effect = _session.trainingEffect;
    if (effect >= 4.5) return 'Absolute machine! 💪';
    if (effect >= 3.5) return 'Strong session! 🔥';
    if (effect >= 2.5) return 'Solid work today.';
    return 'Movement logged. 👏';
  }

  String get _caption =>
      '${WorkoutMetrics.effectRatingOf(_session.trainingEffect)} training '
      'effect · ${_session.totalSets} sets';

  int get _durationMinutes => _session.durationSeconds ~/ _secondsPerMinute;

  String get _durationValue => '$_durationMinutes';

  String get _volumeValue => NumberFormatter.grouped(_session.volumeKg.round());

  WorkoutCompleteItem get summary => WorkoutCompleteItem(
    glyph: '🎉',
    title: 'Workout Complete!',
    message: 'Outstanding effort. Your Flow Score has been updated.',
    scoreLabel: 'Flow Score',
    previousScoreLabel: '${_result.flowScoreBefore}',
    newScoreLabel: '${_result.flowScoreAfter}',
    gainLabel: '+$_flowScoreGain pts',
    gainCaption: 'from workout',
    stats: [
      WorkoutStatItem(
        icon: Icons.schedule,
        title: 'Duration',
        value: '~ $_durationValue',
        unit: 'min',
      ),
      WorkoutStatItem(
        icon: Icons.local_fire_department,
        title: 'Calories',
        value: '~ ${NumberFormatter.grouped(_session.caloriesKcal)}',
        unit: 'kcal',
      ),
    ],
    shareLabel: 'Share',
    doneLabel: 'Back to Workouts',
  );

  WorkoutShareItem get share => WorkoutShareItem(
    promptLabel: 'Share & get reposted!',
    cards: [_heroCard, _statsCard],
    targets: const [
      ShareTargetItem(
        target: ShareTarget.stories,
        assetPath: AppImages.instagramIcon,
        label: 'Stories',
      ),
      ShareTargetItem(
        target: ShareTarget.strava,
        assetPath: AppImages.stravaIcon,
        label: 'Strava',
      ),
      ShareTargetItem(
        target: ShareTarget.addImage,
        icon: Icons.add_photo_alternate_outlined,
        label: 'Add an image',
      ),
      ShareTargetItem(
        target: ShareTarget.downloadImage,
        icon: Icons.download_rounded,
        label: 'Download image',
      ),
      ShareTargetItem(
        target: ShareTarget.share,
        icon: Icons.share_outlined,
        label: 'Share',
      ),
    ],
  );

  WorkoutShareCardItem get _heroCard => WorkoutShareCardItem(
    brandLabel: 'Floww',
    sessionLabel: _session.name,
    modeLabel: _modeLabel,
    caption: _caption,
    headline: _headline,
    stats: [_timeStat, _volumeStat],
    tags: _muscleTags,
    siteLabel: _siteLabel,
    handleLabel: _handleLabel,
    hasPhotoSlot: false,
    photoHint: '',
    photoHintSuffix: '',
  );

  WorkoutShareCardItem get _statsCard => WorkoutShareCardItem(
    brandLabel: 'Floww',
    sessionLabel: _session.name,
    modeLabel: null,
    caption: null,
    headline: null,
    stats: [
      _timeStat,
      ShareStatItem(
        label: 'Records',
        value: '${_session.personalRecords.length}',
        unit: '',
        glyph: '🏆',
      ),
      ShareStatItem(
        label: 'Calories',
        value: NumberFormatter.grouped(_session.caloriesKcal),
        unit: 'kcal',
      ),
      _volumeStat,
    ],
    tags: _muscleTags,
    siteLabel: _siteLabel,
    handleLabel: _handleLabel,
    hasPhotoSlot: true,
    photoHint: 'Add a photo and share\nyour progress',
    photoHintSuffix: ' (Optional)',
    photoBytes: _sharePhotoBytes,
  );

  ShareStatItem get _timeStat =>
      ShareStatItem(label: 'Time', value: _durationValue, unit: 'min');

  ShareStatItem get _volumeStat =>
      ShareStatItem(label: 'Total Weight', value: _volumeValue, unit: 'kg');

  RecoveryCheckInItem get recovery => const RecoveryCheckInItem(
    title: 'Recovery Check-In',
    subtitle: 'How do you feel after today\'s session?',
    moods: [
      RecoveryMoodItem(mood: RecoveryMood.great, glyph: '😊', label: 'Great'),
      RecoveryMoodItem(mood: RecoveryMood.okay, glyph: '😐', label: 'Okay'),
      RecoveryMoodItem(mood: RecoveryMood.tired, glyph: '😓', label: 'Tired'),
      RecoveryMoodItem(mood: RecoveryMood.sore, glyph: '🤕', label: 'Sore'),
    ],
    skipLabel: 'Skip',
    saveLabel: 'Save',
  );

  String get _shareFileName {
    final slug = _session.name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? _fileNameFallback : 'floww-$slug';
  }

  String get _shareText =>
      '${_session.name} · $_durationValue min · $_volumeValue kg '
      '$_siteLabel';

  void selectSharePage(int index) {
    if (index == _sharePageIndex) return;
    _sharePageIndex = index;
    _statusMessage = null;
    notifyListeners();
  }

  void clearStatusMessage() {
    if (_statusMessage == null) return;
    _statusMessage = null;
    notifyListeners();
  }

  Future<void> handleShareTarget(
    ShareTarget target,
    ShareCardCapture capture,
  ) async {
    if (_busyTarget != null) return;
    _busyTarget = target;
    _statusMessage = null;
    notifyListeners();
    try {
      switch (target) {
        case ShareTarget.addImage:
          await _pickSharePhoto();
        case ShareTarget.downloadImage:
          await _shareService.saveImageToGallery(
            await capture(),
            name: _shareFileName,
          );
          _statusMessage = _savedMessage;
        case ShareTarget.stories:
        case ShareTarget.strava:
        case ShareTarget.share:
          await _shareService.shareImage(
            await capture(),
            name: _shareFileName,
            text: _shareText,
          );
      }
    } on ShareException catch (error) {
      _statusMessage = error.message;
    } on FoodCameraException catch (error) {
      _statusMessage = error.message;
    } catch (error, stackTrace) {
      debugPrint('handleShareTarget failed: $error\n$stackTrace');
      _statusMessage = _genericErrorMessage;
    } finally {
      _busyTarget = null;
      notifyListeners();
    }
  }

  Future<void> _pickSharePhoto() async {
    final bytes = await _photoLibraryService.pickPhoto();
    if (bytes == null) return;
    _sharePhotoBytes = bytes;
    _sharePageIndex = _photoCardIndex;
  }

  void selectMood(RecoveryMood mood) {
    if (mood == _selectedMood) return;
    _selectedMood = mood;
    notifyListeners();
  }

  Future<void> saveRecovery() async {
    final mood = _selectedMood;
    if (mood == null) return;
    await _service.saveRecoveryMood(_session.id, mood);
  }
}
