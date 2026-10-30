import 'package:flutter/material.dart';
import '../servicios/servicio_velia.dart';
import '../tema/colores.dart';
import 'pantalla_agregar_evento.dart';

class PantallaCalendario extends StatefulWidget {
  const PantallaCalendario({super.key});

  @override
  State<PantallaCalendario> createState() => _PantallaCalendarioState();
}

class _PantallaCalendarioState extends State<PantallaCalendario> {
  Future<void> _agregar() async {
    await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => const PantallaAgregarEvento()));
    if (mounted) setState(() {});
  }

  Future<void> _eliminar(EventoPersistente evento) async {
    final confirmar = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Eliminar evento'),
      content: Text('¿Eliminar “${evento.titulo}” y su recordatorio?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
      ],
    ));
    if (confirmar == true) await ServicioVelia.instancia.eliminarEvento(evento);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final eventos = ServicioVelia.instancia.eventos;
    final servicio = ServicioVelia.instancia;
    final medicamentos = servicio.medicamentos;
    final ahora = DateTime.now();
    final pendientes = medicamentos.where((m) =>
        !servicio.medicamentoTomadoHoy(m) &&
        (m.hora * 60 + m.minuto) >= (ahora.hour * 60 + ahora.minute)).toList();
    final restantes = medicamentos
        .where((m) => !servicio.medicamentoTomadoHoy(m)).toList();
    final proxima = pendientes.isNotEmpty
        ? pendientes.first
        : restantes.isNotEmpty ? restantes.first : null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        Card(
          color: Colors.orange.shade100,
          child: ListTile(
            leading: const Icon(Icons.medication_liquid,
                size: 36, color: colorNaranja),
            title: const Text('Próximo medicamento',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(proxima == null
                ? 'No hay medicamentos pendientes'
                : '${proxima.nombre} · ${proxima.dosis}'),
            trailing: proxima == null ? null : Text(
                '${proxima.hora.toString().padLeft(2, '0')}:${proxima.minuto.toString().padLeft(2, '0')}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Próximos eventos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (eventos.isEmpty)
          const Card(child: ListTile(title: Text('Aún no hay eventos'))),
        ...eventos.map((evento) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade50,
                  child: Icon(
                      evento.tipo == 'cita'
                          ? Icons.local_hospital
                          : evento.tipo == 'aniversario'
                              ? Icons.cake
                              : Icons.event,
                      color: colorNaranja),
                ),
                title: Text(evento.titulo),
                subtitle: Text(
                    '${MaterialLocalizations.of(context).formatMediumDate(evento.fecha)} · ${evento.fecha.hour.toString().padLeft(2, '0')}:${evento.fecha.minute.toString().padLeft(2, '0')}${evento.notas.isEmpty ? '' : '\n${evento.notas}'}'),
                isThreeLine: evento.notas.isNotEmpty,
                trailing: PopupMenuButton<String>(
                  tooltip: 'Opciones de ${evento.titulo}',
                  onSelected: (accion) {
                    if (accion == 'editar') {
                      Navigator.push<bool>(context, MaterialPageRoute(
                        builder: (_) => PantallaAgregarEvento(evento: evento),
                      )).then((_) { if (mounted) setState(() {}); });
                    } else if (accion == 'eliminar') {
                      _eliminar(evento);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                    PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 10),
        SizedBox(
          height: 50,
          child: FilledButton.icon(
            onPressed: _agregar,
            icon: const Icon(Icons.add),
            label: const Text('Agregar un evento'),
          ),
        ),
      ],
    );
  }
}
