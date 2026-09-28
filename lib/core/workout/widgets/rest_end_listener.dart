import 'dart:async';

import 'package:flutter/material.dart';

import 'package:floww/config/utils/haptics/haptic_manager.dart';

class RestEndListener extends StatefulWidget {
  const RestEndListener({super.key, required this.events, required this.child});

  final Stream<void> events;
  final Widget child;

  @override
  State<RestEndListener> createState() => _RestEndListenerState();
}

class _RestEndListenerState extends State<RestEndListener> {
  StreamSubscription<void>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(RestEndListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.events != widget.events) _subscribe();
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = widget.events.listen((_) => HapticManager.heavy());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
