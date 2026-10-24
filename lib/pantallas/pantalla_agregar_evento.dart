import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estado/estado_app.dart';
import '../modelos/evento.dart';
import '../tema/colores.dart';
import '../utilidades/formatos.dart';
import '../utilidades/validadores.dart';

// Formulario para agregar un evento.
class PantallaAgregarEvento extends StatefulWidget {
  const PantallaAgregarEvento({super.key});

  @override
  State<PantallaAgregarEvento> createState() => _EstadoPantallaAgregarEvento();
}

class _EstadoPantallaAgregarEvento extends State<PantallaAgregarEvento> {
  final _llaveFormulario = GlobalKey<FormState>();
  final _controladorTitulo = TextEditingController();
  final _controladorNotas = TextEditingController();
  TipoEvento _tipo = TipoEvento.cita; // Tipo elegido
  DateTime? _fecha; // Fecha elegida
  TimeOfDay? _hora; // Hora elegida
  bool _todoElDia = false; // Si el evento dura todo el día
  bool _mostrarErrores = false; // Para marcar fecha/hora faltantes

  @override
  void dispose() {
    _controladorTitulo.dispose();
    _controladorNotas.dispose();
    super.dispose();
  }

  // Permite elegir la fecha.
  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (!mounted) return;
    if (elegida != null) setState(() => _fecha = elegida);
  }

  // Permite elegir la hora.
  Future<void> _elegirHora() async {
    final elegida = await showTimePicker(
      context: context,
      initialTime: _hora ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (!mounted) return;
    if (elegida != null) setState(() => _hora = elegida);
  }

  // Valida y guarda el evento.
  void _guardar() {
    final formularioValido = _llaveFormulario.currentState!.validate();
    setState(() => _mostrarErrores = true);
    final faltaFecha = _fecha == null;
    final faltaHora = !_todoElDia && _hora == null;
    if (!formularioValido || faltaFecha || faltaHora) return;

    context.read<EstadoApp>().agregarEvento(
          Evento(
            titulo: _controladorTitulo.text.trim(),
            fecha: _fecha!,
            hora: _todoElDia ? null : _hora,
            tipo: _tipo,
            notas: _controladorNotas.text.trim(),
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evento guardado')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final faltaFecha = _mostrarErrores && _fecha == null;
    final faltaHora = _mostrarErrores && !_todoElDia && _hora == null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorNaranja,
        foregroundColor: Colors.white,
        title: const Text('Agregar un evento'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Form(
            key: _llaveFormulario,
            child: Column(
              children: [
                TextFormField(
                  controller: _controladorTitulo,
                  validator: (v) => validarObligatorio(v, 'el título'),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Título del evento',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controladorNotas,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Tipo de evento',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final tipo in TipoEvento.values)
                ChoiceChip(
                  label: Text(tipo.etiqueta),
                  selected: _tipo == tipo,
                  onSelected: (_) => setState(() => _tipo = tipo),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            shape: faltaFecha
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.red))
                : null,
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: colorNaranja),
              title: const Text('Fecha'),
              subtitle: faltaFecha
                  ? const Text('Elige una fecha',
                      style: TextStyle(color: Colors.red))
                  : null,
              trailing:
                  Text(_fecha == null ? 'Elegir' : formatearFecha(_fecha!)),
              onTap: _elegirFecha,
            ),
          ),
          SwitchListTile(
            title: const Text('Todo el día'),
            value: _todoElDia,
            activeColor: colorNaranja,
            onChanged: (valor) => setState(() => _todoElDia = valor),
          ),
          if (!_todoElDia)
            Card(
              shape: faltaHora
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.red))
                  : null,
              child: ListTile(
                leading: const Icon(Icons.access_time, color: colorNaranja),
                title: const Text('Hora'),
                subtitle: faltaHora
                    ? const Text('Elige una hora',
                        style: TextStyle(color: Colors.red))
                    : null,
                trailing:
                    Text(_hora == null ? 'Elegir' : formatearHora(_hora!)),
                onTap: _elegirHora,
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label:
                  const Text('Guardar evento', style: TextStyle(fontSize: 17)),
            ),
          ),
        ],
      ),
    );
  }
}
