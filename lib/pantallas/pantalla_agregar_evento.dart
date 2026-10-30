import 'package:flutter/material.dart';
import '../servicios/servicio_velia.dart';
import '../tema/colores.dart';

class PantallaAgregarEvento extends StatefulWidget {
  const PantallaAgregarEvento({super.key, this.evento});
  final EventoPersistente? evento;

  @override
  State<PantallaAgregarEvento> createState() => _PantallaAgregarEventoState();
}

class _PantallaAgregarEventoState extends State<PantallaAgregarEvento> {
  final _formKey = GlobalKey<FormState>();
  late final _titulo = TextEditingController(text: widget.evento?.titulo ?? '');
  late final _notas = TextEditingController(text: widget.evento?.notas ?? '');
  late DateTime _fecha = widget.evento?.fecha ??
      DateTime.now().add(const Duration(days: 1));
  late TimeOfDay _hora = widget.evento == null
      ? const TimeOfDay(hour: 11, minute: 0)
      : TimeOfDay.fromDateTime(widget.evento!.fecha);
  late String _tipo = widget.evento?.tipo ?? 'cita';
  bool _guardando = false;

  @override
  void dispose() {
    _titulo.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: widget.evento == null ? DateTime.now() : DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  Future<void> _elegirHora() async {
    final elegida = await showTimePicker(context: context, initialTime: _hora);
    if (elegida != null) setState(() => _hora = elegida);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final fecha = DateTime(
        _fecha.year, _fecha.month, _fecha.day, _hora.hour, _hora.minute);
    if (widget.evento == null && fecha.isBefore(DateTime.now())) {
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elige una fecha y hora futuras.')),
      );
      return;
    }
    try {
      final anterior = widget.evento;
      final evento = anterior == null
          ? EventoPersistente(_titulo.text.trim(), fecha, _tipo, _notas.text.trim())
          : EventoPersistente.conId(anterior.id, _titulo.text.trim(), fecha, _tipo,
              _notas.text.trim());
      if (anterior == null) {
        await ServicioVelia.instancia.agregarEvento(evento);
      } else {
        await ServicioVelia.instancia.actualizarEvento(evento);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el evento. Inténtalo de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: colorNaranja,
          foregroundColor: Colors.white,
          title: Text(widget.evento == null ? 'Agregar un evento' : 'Editar evento'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _titulo,
                decoration: const InputDecoration(
                  labelText: 'Título del evento',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Escribe un título'
                    : null,
              ),
              const SizedBox(height: 18),
              const Text('Tipo de evento',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ('cita', 'Cita médica'),
                  ('medicamento', 'Medicamento'),
                  ('aniversario', 'Aniversario'),
                  ('otro', 'Otro'),
                ]
                    .map((opcion) => ChoiceChip(
                          label: Text(opcion.$2),
                          selected: _tipo == opcion.$1,
                          onSelected: (_) => setState(() => _tipo = opcion.$1),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading:
                      const Icon(Icons.calendar_today, color: colorNaranja),
                  title: const Text('Fecha'),
                  trailing: Text(MaterialLocalizations.of(context)
                      .formatMediumDate(_fecha)),
                  onTap: _elegirFecha,
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time, color: colorNaranja),
                  title: const Text('Hora'),
                  trailing: Text(_hora.format(context)),
                  onTap: _elegirHora,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notas,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: const Icon(Icons.save),
                  label: Text(_guardando
                      ? 'Guardando…'
                      : widget.evento == null
                          ? 'Guardar evento'
                          : 'Guardar cambios',
                      style: const TextStyle(fontSize: 17)),
                ),
              ),
            ],
          ),
        ),
      );
}
