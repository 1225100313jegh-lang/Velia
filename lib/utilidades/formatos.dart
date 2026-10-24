import 'package:flutter/material.dart';

// Formatos de fecha y hora.

const List<String> _nombresDias = [
  'Lun',
  'Mar',
  'Mié',
  'Jue',
  'Vie',
  'Sáb',
  'Dom'
];
const List<String> _nombresMeses = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic'
];

String formatearFecha(DateTime fecha) {
  final dia = _nombresDias[fecha.weekday - 1];
  final mes = _nombresMeses[fecha.month - 1];
  return '$dia ${fecha.day} $mes';
}

String formatearHora(TimeOfDay hora) {
  final esManana = hora.hour < 12;
  var hora12 = hora.hour % 12;
  if (hora12 == 0) hora12 = 12;
  final horas = hora12.toString().padLeft(2, '0');
  final minutos = hora.minute.toString().padLeft(2, '0');
  return '$horas:$minutos ${esManana ? 'a.m.' : 'p.m.'}';
}

String describirMomento(DateTime momento) {
  final ahora = DateTime.now();
  final esHoy = momento.year == ahora.year &&
      momento.month == ahora.month &&
      momento.day == ahora.day;
  final hora = formatearHora(TimeOfDay.fromDateTime(momento));
  return esHoy ? 'Hoy, $hora' : '${formatearFecha(momento)}, $hora';
}
