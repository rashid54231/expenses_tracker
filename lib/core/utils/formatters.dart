import 'dart:ui';

class CurrencyFormatter {
  static const String currencySymbol = 'Rs.';

  static String format(double amount, {int decimalDigits = 2}) {
    return '$currencySymbol${amount.toStringAsFixed(decimalDigits)}';
  }
}
