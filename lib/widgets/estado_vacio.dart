import 'package:flutter/material.dart';

// Estado vacío de una lista.
class EstadoVacio extends StatelessWidget {
  final IconData icono; // Ícono grande
  final String titulo; // Título corto
  final String mensaje; // Explicación

  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          Icon(icono, size: 72, color: Colors.orange.shade200),
          const SizedBox(height: 12),
          Text(titulo,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
