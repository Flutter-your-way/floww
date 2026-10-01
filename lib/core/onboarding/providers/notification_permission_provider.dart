import 'package:floww/core/onboarding/services/notification_permission_service.dart';
import 'package:flutter/material.dart';

enum NotificationPermissionStatus { idle, requesting, granted, denied }

class NotificationPreview {
  const NotificationPreview({
    required this.title,
    required this.body,
    required this.timeLabel,
  });

  final String title;
  final String body;
  final String timeLabel;
}

class NotificationPermissionProvider extends ChangeNotifier {
  NotificationPermissionProvider(this._service);

  final NotificationPermissionService _service;

  NotificationPermissionStatus _status = NotificationPermissionStatus.idle;
  bool _hasPrompted = false;
  bool _disposed = false;

  NotificationPermissionStatus get status => _status;

  bool get isRequesting => _status == NotificationPermissionStatus.requesting;

  bool get hasAnswered =>
      _status == NotificationPermissionStatus.granted ||
      _status == NotificationPermissionStatus.denied;

  String get appName => 'Floww';

  String get title => 'Stay in the flow';

  String get subtitle =>
      'Workout reminders, rest timers and the odd check-in from WAVE. '
      'Nothing else.';

  String get primaryLabel => hasAnswered ? 'Continue' : 'Allow notifications';

  String get statusNote => switch (_status) {
    NotificationPermissionStatus.granted => "You're all set.",
    NotificationPermissionStatus.denied =>
      'No problem. You can turn them on later in Settings.',
    _ => 'You can change this anytime in Settings.',
  };

  List<NotificationPreview> get previews => const [
    NotificationPreview(
      title: 'Time to train',
      body: 'Upper Body is ready. 45 minutes, you have got this.',
      timeLabel: 'now',
    ),
    NotificationPreview(
      title: 'Rest is over',
      body: 'Set 3 of Bench Press. Go.',
      timeLabel: '2m ago',
    ),
  ];

  Future<void> promptOnce() async {
    if (_hasPrompted) return;
    await allow();
  }

  Future<void> allow() async {
    if (isRequesting) return;
    _hasPrompted = true;
    _setStatus(NotificationPermissionStatus.requesting);

    final granted = await _service.requestPermission();

    _setStatus(
      granted
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.denied,
    );
  }

  void _setStatus(NotificationPermissionStatus status) {
    _status = status;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
