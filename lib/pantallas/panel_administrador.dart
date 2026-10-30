import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estado/estado_app.dart';
import '../modelos/usuario.dart';
import '../tema/colores.dart';
import '../widgets/menu_lateral.dart';

// Panel del administrador.
class PanelAdministrador extends StatelessWidget {
  const PanelAdministrador({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoApp>();
    final usuarios = estado.usuarios;

    return Scaffold(
      drawer: const MenuLateral(),
      appBar: AppBar(
        backgroundColor: colorNaranja,
        foregroundColor: Colors.white,
        title: const Text('Panel de administrador'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _TarjetaDato(
                  titulo: 'Usuarios',
                  valor: usuarios.length,
                  icono: Icons.people),
              _TarjetaDato(
                  titulo: 'Eventos',
                  valor: estado.eventos.length,
                  icono: Icons.event),
              _TarjetaDato(
                  titulo: 'Medicinas',
                  valor: estado.medicamentos.length,
                  icono: Icons.medication),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Usuarios registrados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...usuarios.map(
            (usuario) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: Icon(usuario.rol.icono, color: colorNaranja),
                ),
                title: Text(usuario.nombre),
                subtitle: Text('${usuario.correo}\n${usuario.rol.etiqueta}'),
                isThreeLine: true,
                trailing: identical(usuario, estado.usuarioActual)
                    ? const Tooltip(
                        message: 'No puedes eliminar tu propia cuenta',
                        child: Icon(Icons.lock_outline),
                      )
                    : IconButton(
                        tooltip: 'Eliminar cuenta',
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Eliminar cuenta'),
                              content: Text(
                                  '¿Quieres eliminar la cuenta de ${usuario.nombre}?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                          if (confirmar == true && context.mounted) {
                            context.read<EstadoApp>().eliminarUsuario(usuario);
                          }
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dato resumido del panel.
class _TarjetaDato extends StatelessWidget {
  final String titulo;
  final int valor;
  final IconData icono;

  const _TarjetaDato({
    required this.titulo,
    required this.valor,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icono, color: colorNaranja, size: 30),
              const SizedBox(height: 6),
              Text('$valor',
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold)),
              Text(titulo),
            ],
          ),
        ),
      ),
    );
  }
}
