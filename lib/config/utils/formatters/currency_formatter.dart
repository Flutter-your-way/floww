import 'package:floww/config/constants/app_subscription.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static const String rupee = '₹';

  static String rupees(int amount) =>
      '$rupee${NumberFormatter.grouped(amount)}';

  static String forCurrency(int amount, String currency) =>
      currency == AppSubscription.currency
      ? rupees(amount)
      : withCode(amount, currency);

  static String withCode(int amount, String currency) =>
      '$currency ${NumberFormatter.grouped(amount)}';
}
