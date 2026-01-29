import 'package:intl/intl.dart';

String dayMothFormat(DateTime fecha) {
  String dia = DateFormat('d').format(fecha);

  String mes = DateFormat('MMM', 'es').format(fecha);
  mes = mes[0].toUpperCase() + mes.substring(1);
  mes = mes.replaceAll('.', '');

  return '$dia $mes';
}
