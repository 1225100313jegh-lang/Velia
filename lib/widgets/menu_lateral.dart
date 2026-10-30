import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estado/estado_app.dart';
import '../modelos/usuario.dart';
import '../tema/colores.dart';
import '../pantallas/pantalla_inicio_sesion.dart';

// Menú de la cuenta.
class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoApp>();
    final usuario = estado.usuarioActual;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: colorNaranja),
            accountName: Text(usuario?.nombre ?? 'Invitado'),
            accountEmail: Text(usuario?.correo ?? ''),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: colorNaranja, size: 36),
            ),
          ),
          ListTile(
            leading: Icon(estado.usuarioActual?.rol.icono ?? Icons.person),
            title: Text(estado.usuarioActual?.rol.etiqueta ?? 'Mi cuenta'),
            subtitle: const Text('Cuenta personal'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () {
              context.read<EstadoApp>().cerrarSesion();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const PantallaInicioSesion()),
                (ruta) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
