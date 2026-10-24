import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estado/estado_app.dart';
import '../modelos/medicamento.dart';
import '../tema/colores.dart';
import '../utilidades/formatos.dart';
import '../utilidades/validadores.dart';

// Formulario para agregar o modificar un medicamento.
class PantallaAgregarHorario extends StatefulWidget {
  final Medicamento? medicamento;

  const PantallaAgregarHorario({super.key, this.medicamento});

  @override
  State<PantallaAgregarHorario> createState() =>
      _EstadoPantallaAgregarHorario();
}

class _EstadoPantallaAgregarHorario extends State<PantallaAgregarHorario> {
  final _llaveFormulario = GlobalKey<FormState>();
  final _controladorNombre = TextEditingController();
  final _controladorDosis = TextEditingController();
  TimeOfDay? _hora; // Hora elegida (null = todavía no elige)
  bool _mostrarErrores = false; // Para mostrar el error de la hora

  @override
  void initState() {
    super.initState();
    final medicamento = widget.medicamento;
    if (medicamento != null) {
      _controladorNombre.text = medicamento.nombre;
      _controladorDosis.text = medicamento.dosis;
      _hora = medicamento.hora;
    }
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorDosis.dispose();
    super.dispose();
  }

  // Permite elegir la hora.
  Future<void> _elegirHora() async {
    final elegida = await showTimePicker(
      context: context,
      initialTime: _hora ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (!mounted) return;
    if (elegida != null) setState(() => _hora = elegida);
  }

  // Valida y guarda los cambios.
  void _guardar() {
    final formularioValido = _llaveFormulario.currentState!.validate();
    setState(() => _mostrarErrores = true);
    if (!formularioValido || _hora == null) return;

    final actualizado = Medicamento(
      nombre: _controladorNombre.text.trim(),
      dosis: _controladorDosis.text.trim(),
      hora: _hora!,
    );
    final estado = context.read<EstadoApp>();
    if (widget.medicamento == null) {
      estado.agregarMedicamento(actualizado);
    } else {
      estado.editarMedicamento(widget.medicamento!, actualizado);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.medicamento == null
            ? 'Medicamento agregado al horario'
            : 'Medicamento actualizado'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final falta = _mostrarErrores && _hora == null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorNaranja,
        foregroundColor: Colors.white,
        title: Text(widget.medicamento == null
            ? 'Nuevo medicamento'
            : 'Modificar medicamento'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Form(
            key: _llaveFormulario,
            child: Column(
              children: [
                TextFormField(
                  controller: _controladorNombre,
                  validator: (v) => validarObligatorio(v, 'el medicamento'),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Medicamento',
                    prefixIcon: Icon(Icons.medication),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controladorDosis,
                  validator: (v) => validarObligatorio(v, 'la dosis'),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Dosis (ej. 1 tableta con la comida)',
                    prefixIcon: Icon(Icons.notes),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: falta
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.red))
                : null,
            child: ListTile(
              leading: const Icon(Icons.access_time, color: colorNaranja),
              title: const Text('Hora'),
              subtitle: falta
                  ? const Text('Elige una hora',
                      style: TextStyle(color: Colors.red))
                  : null,
              trailing: Text(_hora == null ? 'Elegir' : formatearHora(_hora!)),
              onTap: _elegirHora,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: Text(
                widget.medicamento == null
                    ? 'Guardar en el horario'
                    : 'Guardar cambios',
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
