import 'package:flutter/material.dart';

// Botón de emergencia de demostración.
class BotonEmergencia extends StatelessWidget {
  const BotonEmergencia({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: Colors.red.shade700,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.warning_amber_rounded),
      label: const Text('EMERGENCIA'),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: Icon(Icons.sms, color: Colors.red.shade700, size: 40),
            title: const Text('Mensaje de emergencia'),
            content: const Text(
              'Demostración: aquí se enviaría un SMS de emergencia a los '
              'contactos registrados.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      },
    );
  }
}
