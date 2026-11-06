import 'package:floww/config/utils/formatters/number_formatter.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static const int _centsPerUnit = 100;
  static const int _centDigits = 2;

  static const Map<String, String> _symbols = {
    'INR': '₹',
    'USD': r'$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CNY': '¥',
    'KRW': '₩',
    'AUD': r'A$',
    'CAD': r'C$',
    'NZD': r'NZ$',
    'SGD': r'S$',
    'HKD': r'HK$',
    'AED': 'AED ',
    'BRL': r'R$',
    'TRY': '₺',
    'RUB': '₽',
    'PHP': '₱',
    'NGN': '₦',
    'VND': '₫',
    'THB': '฿',
    'ILS': '₪',
    'PKR': 'Rs ',
    'IDR': 'Rp ',
    'ZAR': 'R ',
    'CHF': 'CHF ',
  };

  static String forCurrency(num amount, String currency) {
    final symbol = _symbols[currency.toUpperCase()];
    if (symbol != null) return '$symbol${amountLabel(amount)}';
    return withCode(amount, currency);
  }

  static String withCode(num amount, String currency) => currency.isEmpty
      ? amountLabel(amount)
      : '${currency.toUpperCase()} ${amountLabel(amount)}';

  static String amountLabel(num amount) {
    final cents = (amount * _centsPerUnit).round();
    final whole = cents ~/ _centsPerUnit;
    final fraction = (cents % _centsPerUnit).abs();
    final grouped = NumberFormatter.grouped(whole);
    if (fraction == 0) return grouped;
    return '$grouped.${fraction.toString().padLeft(_centDigits, '0')}';
  }
}
