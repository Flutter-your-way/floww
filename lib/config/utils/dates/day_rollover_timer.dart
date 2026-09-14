import 'dart:async';

import 'package:floww/config/utils/dates/app_date_utils.dart';

class DayRolloverTimer {
  DayRolloverTimer(this._onNewDay) {
    _schedule();
  }

  static const Duration _buffer = Duration(seconds: 1);

  final void Function() _onNewDay;
  Timer? _timer;

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(AppDateUtils.untilNextDay(DateTime.now()) + _buffer, () {
      _onNewDay();
      _schedule();
    });
  }

  void cancel() => _timer?.cancel();
}
