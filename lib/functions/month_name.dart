import 'package:intl/intl.dart';

String monthName(int mes) {
  DateTime dateTime = DateTime(DateTime.now().year, mes);

  String value = DateFormat('MMMM', 'es').format(dateTime);

  value = value[0].toUpperCase() + value.substring(1);

  return value;
}
