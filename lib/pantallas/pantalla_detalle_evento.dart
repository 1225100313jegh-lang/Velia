import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estado/estado_app.dart';
import '../modelos/evento.dart';
import '../tema/colores.dart';
import '../utilidades/formatos.dart';

// Detalle del evento seleccionado.
class PantallaDetalleEvento extends StatelessWidget {
  final Evento evento; // El evento que se va a mostrar

  const PantallaDetalleEvento({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorNaranja,
        foregroundColor: Colors.white,
        title: const Text('Detalle del evento'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: Colors.orange.shade100,
              child: Icon(evento.tipo.icono, size: 46, color: colorNaranja),
            ),
          ),
          const SizedBox(height: 16),
          Text(evento.titulo,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.category, color: colorNaranja),
              title: const Text('Tipo'),
              trailing: Text(evento.tipo.etiqueta),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: colorNaranja),
              title: const Text('Fecha'),
              trailing: Text(formatearFecha(evento.fecha)),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.access_time, color: colorNaranja),
              title: const Text('Hora'),
              trailing: Text(evento.hora == null
                  ? 'Todo el día'
                  : formatearHora(evento.hora!)),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notes, color: colorNaranja),
              title: const Text('Notas'),
              subtitle: Text(evento.notas.isEmpty ? 'Sin notas' : evento.notas),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<EstadoApp>().eliminarEvento(evento);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Eliminar evento',
                  style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}
