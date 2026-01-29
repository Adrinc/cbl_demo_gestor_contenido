import 'package:intl/intl.dart';

String dateTimeFormat(DateTime? date) {
  if (date == null) {
    return '-';
  }
  final formato = DateFormat('MM-dd-yyyy HH:mm:ss');
  return formato.format(date);
}
