import 'dart:async';

import 'package:flutter/foundation.dart';

Stream<List<Object?>> combineLatest(List<Stream<Object?>> streams) {
  late final StreamController<List<Object?>> controller;
  final subscriptions = <StreamSubscription<Object?>>[];
  final values = List<Object?>.filled(streams.length, null);
  final seeded = List<bool>.filled(streams.length, false);

  void emit() {
    if (seeded.contains(false)) return;
    controller.add(List<Object?>.of(values));
  }

  controller = StreamController<List<Object?>>(
    onListen: () {
      for (var index = 0; index < streams.length; index++) {
        final position = index;
        subscriptions.add(
          streams[position].listen(
            (value) {
              values[position] = value;
              seeded[position] = true;
              emit();
            },
            onError: (Object error, StackTrace stackTrace) {
              debugPrint('combineLatest source $position failed: $error');
              controller.addError(error, stackTrace);
            },
          ),
        );
      }
    },
    onCancel: () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
      subscriptions.clear();
    },
  );

  return controller.stream;
}
