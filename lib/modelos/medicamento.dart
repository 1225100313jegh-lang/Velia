import 'package:flutter/material.dart';

// Medicamento programado.
class Medicamento {
  final String nombre; // Nombre de la medicina
  final String dosis; // Cuánto y cómo se toma
  final TimeOfDay hora; // A qué hora se toma

  Medicamento({
    required this.nombre,
    required this.dosis,
    required this.hora,
  });
}
