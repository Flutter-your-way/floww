import 'package:floww/config/utils/formatters/number_formatter.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static const String rupee = '₹';

  static String rupees(int amount) =>
      '$rupee${NumberFormatter.grouped(amount)}';

  static String withCode(int amount, String currency) =>
      '$currency ${NumberFormatter.grouped(amount)}';
}
