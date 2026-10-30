import 'package:flutter/material.dart';
import '../servicios/servicio_velia.dart';
import '../tema/colores.dart';

class PantallaAgregarMedicamento extends StatefulWidget {
  const PantallaAgregarMedicamento({super.key, this.medicamento});
  final MedicamentoPersistente? medicamento;

  @override
  State<PantallaAgregarMedicamento> createState() => _PantallaAgregarMedicamentoState();
}

class _PantallaAgregarMedicamentoState extends State<PantallaAgregarMedicamento> {
  final _formKey = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.medicamento?.nombre ?? '');
  late final _dosis = TextEditingController(text: widget.medicamento?.dosis ?? '');
  late TimeOfDay _hora = widget.medicamento == null
      ? const TimeOfDay(hour: 8, minute: 0)
      : TimeOfDay(hour: widget.medicamento!.hora, minute: widget.medicamento!.minuto);
  bool _guardando = false;

  @override
  void dispose() { _nombre.dispose(); _dosis.dispose(); super.dispose(); }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final anterior = widget.medicamento;
      final medicamento = anterior == null
          ? MedicamentoPersistente(_nombre.text.trim(), _dosis.text.trim(), _hora.hour, _hora.minute)
          : MedicamentoPersistente.conId(anterior.id, _nombre.text.trim(), _dosis.text.trim(), _hora.hour, _hora.minute);
      if (anterior == null) {
        await ServicioVelia.instancia.agregarMedicamento(medicamento);
      } else {
        await ServicioVelia.instancia.actualizarMedicamento(medicamento);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el medicamento. Inténtalo de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: colorNaranja, foregroundColor: Colors.white,
      title: Text(widget.medicamento == null ? 'Agregar medicamento' : 'Editar medicamento')),
    body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(20), children: [
      TextFormField(controller: _nombre, textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Nombre del medicamento', prefixIcon: Icon(Icons.medication), border: OutlineInputBorder()),
        validator: (v) => v == null || v.trim().isEmpty ? 'Escribe el nombre' : null),
      const SizedBox(height: 16),
      TextFormField(controller: _dosis, textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Dosis e indicaciones', prefixIcon: Icon(Icons.notes), border: OutlineInputBorder()),
        validator: (v) => v == null || v.trim().isEmpty ? 'Escribe la dosis' : null),
      const SizedBox(height: 16),
      Card(child: ListTile(leading: const Icon(Icons.access_time, color: colorNaranja),
        title: const Text('Hora del recordatorio'), trailing: Text(_hora.format(context)),
        onTap: () async { final nueva = await showTimePicker(context: context, initialTime: _hora); if (nueva != null) setState(() => _hora = nueva); })),
      const SizedBox(height: 8),
      const Text('Este recordatorio se repetirá diariamente. Confirma la dosis con el profesional de salud.'),
      const SizedBox(height: 24),
      SizedBox(height: 52, child: FilledButton.icon(onPressed: _guardando ? null : _guardar,
        icon: const Icon(Icons.save), label: Text(_guardando ? 'Guardando…' : 'Guardar medicamento'))),
    ])),
  );
}
