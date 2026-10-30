import 'package:flutter/material.dart';
import '../servicios/servicio_velia.dart';
import '../tema/colores.dart';
import 'pantalla_agregar_medicamento.dart';

class PantallaHorario extends StatefulWidget {
  const PantallaHorario({super.key});

  @override
  State<PantallaHorario> createState() => _PantallaHorarioState();
}

class _PantallaHorarioState extends State<PantallaHorario> {
  final _servicio = ServicioVelia.instancia;

  @override
  void initState() {
    super.initState();
    _servicio.addListener(_refrescar);
  }

  @override
  void dispose() {
    _servicio.removeListener(_refrescar);
    super.dispose();
  }

  void _refrescar() { if (mounted) setState(() {}); }

  Future<void> _editar(MedicamentoPersistente? medicamento) async {
    await Navigator.push<bool>(context, MaterialPageRoute(
      builder: (_) => PantallaAgregarMedicamento(medicamento: medicamento),
    ));
    if (mounted) setState(() {});
  }

  Future<void> _eliminar(MedicamentoPersistente medicamento) async {
    final confirmar = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Eliminar medicamento'),
      content: Text('¿Eliminar ${medicamento.nombre} y su recordatorio?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
      ],
    ));
    if (confirmar == true) await _servicio.eliminarMedicamento(medicamento);
  }

  @override
  Widget build(BuildContext context) {
    final medicamentos = _servicio.medicamentos;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        const Text('Medicamentos de hoy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Los recordatorios se repiten cada día a la hora indicada.'),
        const SizedBox(height: 12),
        if (medicamentos.isEmpty) const Card(child: ListTile(title: Text('Aún no hay medicamentos'), subtitle: Text('Agrega uno para programar un recordatorio.'))),
        ...medicamentos.map((medicamento) {
          final tomado = _servicio.medicamentoTomadoHoy(medicamento);
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: tomado ? Colors.green.shade100 : Colors.orange.shade100,
                child: Icon(tomado ? Icons.check : Icons.medication, color: tomado ? Colors.green.shade800 : colorNaranja),
              ),
              title: Text(medicamento.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${medicamento.dosis}\n${medicamento.hora.toString().padLeft(2, '0')}:${medicamento.minuto.toString().padLeft(2, '0')} · ${tomado ? 'Tomado hoy' : 'Pendiente'}'),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                tooltip: 'Opciones de ${medicamento.nombre}',
                onSelected: (accion) {
                  if (accion == 'editar') _editar(medicamento);
                  if (accion == 'eliminar') _eliminar(medicamento);
                  if (accion == 'tomado' && !tomado) _servicio.registrarMedicamentoTomado(medicamento);
                },
                itemBuilder: (_) => [
                  if (!tomado) const PopupMenuItem(value: 'tomado', child: Text('Marcar como tomado')),
                  const PopupMenuItem(value: 'editar', child: Text('Editar')),
                  const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 10),
        SizedBox(height: 50, child: FilledButton.icon(
          onPressed: () => _editar(null),
          icon: const Icon(Icons.add), label: const Text('Agregar medicamento'),
        )),
      ],
    );
  }
}
