import 'package:flutter/material.dart';

// Categorías de eventos.
enum TipoEvento { cita, aniversario, otro }

// Nombre e ícono de cada categoría.
extension DatosTipoEvento on TipoEvento {
  String get etiqueta => switch (this) {
        TipoEvento.cita => 'Cita médica',
        TipoEvento.aniversario => 'Aniversario',
        TipoEvento.otro => 'Otro',
      };

  IconData get icono => switch (this) {
        TipoEvento.cita => Icons.local_hospital,
        TipoEvento.aniversario => Icons.cake,
        TipoEvento.otro => Icons.event,
      };
}

// Evento del calendario.
class Evento {
  final String titulo; // Nombre del evento
  final DateTime fecha; // Día del evento
  final TimeOfDay? hora; // Hora (null = todo el día)
  final TipoEvento tipo; // Tipo de evento
  final String notas; // Notas opcionales

  Evento({
    required this.titulo,
    required this.fecha,
    required this.hora,
    required this.tipo,
    this.notas = '',
  });
}
