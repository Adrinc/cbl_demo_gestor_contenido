import 'package:intl/intl.dart';

String dateFormat(
  dynamic x, // Acepta DateTime o String
  [
  bool includeTime = false,
  bool includeDayName = true,
  bool includeTimeAgo = false,
  String language = 'es_MX',
]) {
  DateTime? date;

  // Verifica si es una cadena de fecha y conviértela a DateTime
  if (x is String) {
    date = DateTime.tryParse(x);
  } else if (x is DateTime) {
    date = x;
  }

  if (date == null) return '-';

  // Convierte a hora local
  date = date.toLocal();

  String formattedDate;

  // Formatea la fecha
  if (!includeTime) {
    if (includeDayName) {
      
    formattedDate = DateFormat('EEE. dd/MMM/yyyy', language).format(date);
    }
    else{
      formattedDate = DateFormat('dd/MMM/yyyy', language).format(date);
    }
  } else {
    formattedDate = DateFormat('EEE. dd/MMM/yyyy HH:mm', language).format(date);
  }

  // Capitaliza la primera letra del día
  List<String> parts = formattedDate.split(' ');

  if (parts.isNotEmpty) {
    parts[0] = parts[0][0].toUpperCase() + parts[0].substring(1).toLowerCase();
  }

  // Capitaliza la primera letra del mes
  if (parts.length >= 2) {
    String datePart = parts[1]; // "dd/MMM/yyyy" o "dd/MMM/yyyy HH:mm"
    List<String> dateComponents = datePart.split('/');

    if (dateComponents.length >= 2) {
      // Capitaliza el mes
      dateComponents[1] = dateComponents[1][0].toUpperCase() +
          dateComponents[1].substring(1).toLowerCase();
      parts[1] = dateComponents.join('/');
    }
  }

  formattedDate = parts.join(' ');

  // Manejo de includeTimeAgo
  if (includeTimeAgo) {
    final Duration difference = DateTime.now().difference(date);
    String timeAgo = '';

    if (difference.isNegative) {
      timeAgo = '\n(hace 0 segundos)';
    } else {
      if (difference.inSeconds < 60) {
        timeAgo = '\n(hace ${difference.inSeconds} segundos)';
      } else if (difference.inMinutes < 60) {
        timeAgo = '\n(hace ${difference.inMinutes} minutos)';
      } else if (difference.inHours < 48) {
        timeAgo = '\n(hace ${difference.inHours} horas)';
      } else if (difference.inDays <= 30) {
        timeAgo = '\n(hace ${difference.inDays} días)';
      } else if (difference.inDays > 30) {
        timeAgo = '\n(hace ${difference.inDays ~/ 30} meses)';
      }
    }

    formattedDate = '$formattedDate  $timeAgo';
  }

  return formattedDate;
}

// Definir una lista de nombres de los días de la semana
List<String> daysOfWeek = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo'
];

// Obtener el nombre del día de la semana
String getDayName(DateTime now) {
  String dayName = daysOfWeek[now.weekday - 1];
  return dayName;
}
