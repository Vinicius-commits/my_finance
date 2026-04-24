import 'package:intl/intl.dart';

class DateFormatter {
  static String formatShortDate(DateTime date) {
    return DateFormat("dd/MM/yyyy").format(date);
  }

  static String formatCurrency(double amount) {
  final format = NumberFormat.currency(locale: 'pt_BR', symbol: "R\$");
    return format.format(amount);
  }
}