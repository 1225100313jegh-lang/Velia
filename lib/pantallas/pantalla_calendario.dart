import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estado/estado_app.dart';
import '../modelos/evento.dart';
import '../tema/colores.dart';
import '../utilidades/formatos.dart';
import '../widgets/estado_vacio.dart';
import 'pantalla_agregar_evento.dart';
import 'pantalla_detalle_evento.dart';

// Calendario de eventos y próxima medicina.
class PantallaCalendario extends StatelessWidget {
  const PantallaCalendario({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoApp>();
    final hoy = DateUtils.dateOnly(DateTime.now());
    final lista = estado.eventos
        .where((evento) => !DateUtils.dateOnly(evento.fecha).isBefore(hoy))
        .toList();
    final proxima = estado.proximaPastilla;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        if (proxima != null)
          Card(
            color: Colors.orange.shade100,
            child: ListTile(
              leading: const Icon(Icons.medication_liquid,
                  size: 36, color: colorNaranja),
              title: const Text('Próxima pastilla',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${proxima.nombre} · ${proxima.dosis}'),
              trailing: Text(formatearHora(proxima.hora),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        const SizedBox(height: 18),
        const Text('Próximos eventos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (lista.isEmpty)
          const EstadoVacio(
            icono: Icons.event_busy,
            titulo: 'No hay eventos',
            mensaje:
                'Tu calendario está vacío. Toca "Agregar un evento" para crear el primero.',
          )
        else
          ...lista.map(
            (evento) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Dismissible(
                key: ObjectKey(evento),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red.shade400,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  context.read<EstadoApp>().eliminarEvento(evento);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Evento eliminado')),
                  );
                },
                child: Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade50,
                      child: Icon(evento.tipo.icono, color: colorNaranja),
                    ),
                    title: Text(evento.titulo),
                    subtitle: Text(
                        '${formatearFecha(evento.fecha)} · ${evento.hora == null ? 'Todo el día' : formatearHora(evento.hora!)}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                PantallaDetalleEvento(evento: evento)),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 10),
        SizedBox(
          height: 50,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PantallaAgregarEvento()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Agregar un evento'),
          ),
        ),
        if (lista.isNotEmpty)
          TextButton.icon(
            onPressed: () => context.read<EstadoApp>().vaciarEventos(),
            icon: const Icon(Icons.delete_sweep),
            label: const Text('Vaciar lista'),
          ),
      ],
    );
  }
}
