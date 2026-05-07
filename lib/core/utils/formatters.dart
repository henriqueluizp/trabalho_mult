import 'package:intl/intl.dart';

abstract class Formatters {
  static String currency(double value) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);

  static String date(DateTime date) =>
      DateFormat('dd/MM/yyyy').format(date);
}
