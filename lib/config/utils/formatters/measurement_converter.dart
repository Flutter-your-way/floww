class MeasurementConverter {
  MeasurementConverter._();

  static const double _centimetersPerInch = 2.54;
  static const double _poundsPerKilogram = 2.2046226218;

  static double cmToInches(double centimeters) =>
      centimeters / _centimetersPerInch;

  static double inchesToCm(double inches) => inches * _centimetersPerInch;

  static double kgToLbs(double kilograms) => kilograms * _poundsPerKilogram;

  static double lbsToKg(double pounds) => pounds / _poundsPerKilogram;

  static String trimmed(double value) {
    final rounded = (value * 10).round() / 10;
    return rounded % 1 == 0
        ? rounded.toStringAsFixed(0)
        : rounded.toStringAsFixed(1);
  }
}
