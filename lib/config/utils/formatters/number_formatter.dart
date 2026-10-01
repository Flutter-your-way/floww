class NumberFormatter {
  NumberFormatter._();

  static String grouped(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer(value < 0 ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static String clock(int seconds) {
    final minutes = seconds ~/ Duration.secondsPerMinute;
    final remainder = seconds % Duration.secondsPerMinute;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainder.toString().padLeft(2, '0')}';
  }

  static String trimmed(double value, {int digits = 1}) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(digits);
  }
}
