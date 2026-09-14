import 'package:floww/config/utils/formatters/number_formatter.dart';

class NutritionLabels {
  NutritionLabels._();

  static String number(double value) => NumberFormatter.grouped(value.round());

  static String grams(double value) => '${number(value)}g';

  static String preciseGrams(double value) {
    final rounded = (value * 10).round() / 10;
    final text = rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toStringAsFixed(1);
    return '${text}g';
  }

  static String kcal(double value) => '${number(value)} kcal';

  static String milligrams(double value) => '${number(value)}mg';

  static String liters(double milliliters) =>
      (milliliters / 1000).toStringAsFixed(1);

  static String percent(double ratio) => '${(ratio * 100).round()}%';

  static String points(int value) => '+$value';

  static String count(int value, String singular, String plural) =>
      '$value ${value == 1 ? singular : plural}';

  static String macroLine(double proteinG, double carbsG, double fatG) =>
      'P:${preciseGrams(proteinG)} · C:${preciseGrams(carbsG)} · '
      'F:${preciseGrams(fatG)}';
}
