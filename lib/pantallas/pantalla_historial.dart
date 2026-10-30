import 'package:flutter/material.dart';
import '../servicios/servicio_velia.dart';

class PantallaHistorial extends StatelessWidget {
  const PantallaHistorial({super.key});

  IconData _icono(String tipo) => switch (tipo) {
        'bienestar' => Icons.favorite,
        'medicamento' => Icons.medication,
        'cita' => Icons.event,
        _ => Icons.history,
      };

  @override
  Widget build(BuildContext context) {
    final registros = ServicioVelia.instancia.historial;
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: registros.isEmpty
          ? const Center(child: Padding(
              padding: EdgeInsets.all(28),
              child: Text('Aquí aparecerán los avisos de bienestar, las dosis marcadas y los cambios de citas o medicamentos.', textAlign: TextAlign.center),
            ))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: registros.length,
              itemBuilder: (context, index) {
                final registro = registros[index];
                final fecha = DateTime.parse(registro['fecha'] as String).toLocal();
                return Card(child: ListTile(
                  leading: CircleAvatar(child: Icon(_icono(registro['tipo'] as String))),
                  title: Text(registro['detalle'] as String),
                  subtitle: Text(
                    '${MaterialLocalizations.of(context).formatFullDate(fecha)} · ${TimeOfDay.fromDateTime(fecha).format(context)}',
                  ),
                ));
              },
            ),
    );
  }
}
