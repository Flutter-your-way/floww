import 'dart:async';

class SharedReplayStream<T> {
  SharedReplayStream(this._source, {T Function(T value)? copy})
    : _copy = copy ?? _identity;

  final Stream<T> Function() _source;
  final T Function(T value) _copy;
  final Set<MultiStreamController<T>> _listeners = {};
  StreamSubscription<T>? _subscription;
  T? _latest;
  bool _hasLatest = false;

  static T _identity<T>(T value) => value;

  late final Stream<T> stream = Stream<T>.multi((controller) {
    final latest = _latest;
    if (_hasLatest) controller.add(_copy(latest as T));
    _listeners.add(controller);
    _subscription ??= _source().listen(
      (value) {
        _latest = value;
        _hasLatest = true;
        for (final listener in List.of(_listeners)) {
          listener.add(_copy(value));
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        for (final listener in List.of(_listeners)) {
          listener.addError(error, stackTrace);
        }
      },
      onDone: () {
        _subscription = null;
        _latest = null;
        _hasLatest = false;
        final listeners = List.of(_listeners);
        _listeners.clear();
        for (final listener in listeners) {
          listener.closeSync();
        }
      },
    );
    controller.onCancel = () {
      _listeners.remove(controller);
      if (_listeners.isNotEmpty) return null;
      final subscription = _subscription;
      _subscription = null;
      _latest = null;
      _hasLatest = false;
      return subscription?.cancel();
    };
  });
}
