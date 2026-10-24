import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../datos/datos_ejemplo.dart';
import '../estado/estado_app.dart';
import '../utilidades/formatos.dart';
import 'pantalla_confirmacion_bienestar.dart';

// Avisos de bienestar y rutina diaria.
class PantallaChequeo extends StatelessWidget {
  const PantallaChequeo({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoApp>();
    final ultimoAviso = estado.ultimoAviso;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 90),
      children: [
        Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.favorite, size: 48, color: Colors.green.shade600),
                const SizedBox(height: 10),
                const Text('¿Cómo te sientes hoy?',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                    ),
                    onPressed: () {
                      context.read<EstadoApp>().registrarBienestar();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const PantallaConfirmacionBienestar()),
                      );
                    },
                    child: const Text('Estoy bien',
                        style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  ultimoAviso == null
                      ? 'Todavía no hay avisos'
                      : 'Último aviso: ${describirMomento(ultimoAviso)}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Text('Rutina del día',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...estado.rutinas.map(
          (actividad) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              onTap: estado.puedeEditarCuidados
                  ? () => _mostrarAccionesRutina(context, actividad)
                  : null,
              leading: estado.puedeEditarCuidados
                  ? Checkbox(
                      value: actividad.realizada,
                      onChanged: (_) => context
                          .read<EstadoApp>()
                          .cambiarEstadoRutina(actividad),
                    )
                  : Icon(
                      actividad.realizada
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: actividad.realizada
                          ? Colors.green.shade600
                          : Colors.grey,
                    ),
              title: Text(actividad.nombre),
              subtitle: Text(actividad.hora),
            ),
          ),
        ),
        if (estado.puedeEditarCuidados)
          OutlinedButton.icon(
            onPressed: () => _editarRutina(context),
            icon: const Icon(Icons.add),
            label: const Text('Agregar actividad'),
          ),
      ],
    );
  }

  Future<void> _mostrarAccionesRutina(
      BuildContext context, Actividad actividad) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Modificar rutina'),
              onTap: () {
                Navigator.pop(context);
                _editarRutina(context, actividad: actividad);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Eliminar rutina'),
              onTap: () {
                context.read<EstadoApp>().eliminarRutina(actividad);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editarRutina(BuildContext context,
      {Actividad? actividad}) async {
    final nombre = TextEditingController(text: actividad?.nombre ?? '');
    final hora = TextEditingController(text: actividad?.hora ?? '');
    final formulario = GlobalKey<FormState>();
    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(actividad == null ? 'Nueva rutina' : 'Modificar rutina'),
        content: Form(
          key: formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombre,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Actividad'),
                validator: (valor) => valor == null || valor.trim().isEmpty
                    ? 'Obligatorio'
                    : null,
              ),
              TextFormField(
                controller: hora,
                decoration: const InputDecoration(labelText: 'Hora'),
                validator: (valor) => valor == null || valor.trim().isEmpty
                    ? 'Obligatorio'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formulario.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (guardar == true && context.mounted) {
      final actualizada = Actividad(
        hora.text.trim(),
        nombre.text.trim(),
        actividad?.realizada ?? false,
      );
      final estado = context.read<EstadoApp>();
      if (actividad == null) {
        estado.agregarRutina(actualizada);
      } else {
        estado.editarRutina(actividad, actualizada);
      }
    }
    nombre.dispose();
    hora.dispose();
  }
}
