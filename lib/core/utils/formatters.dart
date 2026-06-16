import 'dart:ui';

class CurrencyFormatter {
  static String get currencySymbol {
    final locale = PlatformDispatcher.instance.locale;
    if (locale.countryCode == 'PK' || locale.languageCode == 'ur') {
      return 'Rs.';
    }
    return '\$';
  }

  static String format(double amount, {int decimalDigits = 2}) {
    return '$currencySymbol${amount.toStringAsFixed(decimalDigits)}';
  }
}
