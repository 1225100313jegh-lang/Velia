import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estado/estado_app.dart';
import '../modelos/medicamento.dart';
import '../tema/colores.dart';
import '../utilidades/formatos.dart';
import '../widgets/estado_vacio.dart';
import 'pantalla_agregar_horario.dart';

// Horario de medicamentos.
class PantallaHorario extends StatelessWidget {
  const PantallaHorario({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoApp>();
    final lista = estado.medicamentos;
    final puedeEditar = estado.puedeEditarCuidados;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        const Text('Medicamentos de hoy',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (lista.isEmpty)
          const EstadoVacio(
            icono: Icons.medication_outlined,
            titulo: 'Sin medicamentos',
            mensaje:
                'Todavía no hay medicamentos en el horario. Toca "Añadir al horario" para agregar el primero.',
          )
        else
          ...lista.map(
            (medicamento) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Dismissible(
                key: ObjectKey(medicamento),
                direction: puedeEditar
                    ? DismissDirection.endToStart
                    : DismissDirection.none,
                background: Container(
                  color: Colors.red.shade400,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  context.read<EstadoApp>().eliminarMedicamento(medicamento);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Medicamento eliminado')),
                  );
                },
                child: Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: const Icon(Icons.medication, color: colorNaranja),
                    ),
                    title: Text(medicamento.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(medicamento.dosis),
                    onTap: puedeEditar
                        ? () =>
                            _mostrarAccionesMedicamento(context, medicamento)
                        : null,
                    trailing: Text(
                      formatearHora(medicamento.hora),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: colorNaranja),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (puedeEditar) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PantallaAgregarHorario()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Añadir al horario'),
            ),
          ),
        ],
        if (lista.isNotEmpty && puedeEditar)
          TextButton.icon(
            onPressed: () => context.read<EstadoApp>().vaciarMedicamentos(),
            icon: const Icon(Icons.delete_sweep),
            label: const Text('Vaciar lista'),
          ),
      ],
    );
  }

  void _mostrarAccionesMedicamento(
      BuildContext context, Medicamento medicamento) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Modificar medicamento'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PantallaAgregarHorario(medicamento: medicamento),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Eliminar medicamento'),
              onTap: () {
                context.read<EstadoApp>().eliminarMedicamento(medicamento);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
