import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estado/estado_app.dart';
import '../modelos/usuario.dart';
import '../pantallas/panel_administrador.dart';
import '../pantallas/panel_cliente.dart';
import '../pantallas/panel_familiar.dart';

// Devuelve el panel correspondiente al rol.
Widget panelSegunRol(RolUsuario rol) {
  return switch (rol) {
    RolUsuario.administrador => const PanelAdministrador(),
    RolUsuario.cliente => const PanelCliente(),
    RolUsuario.familiar => const PanelFamiliar(),
  };
}

// Abre el panel de la cuenta activa.
void irAlPanel(BuildContext context, RolUsuario rol) {
  final estado = context.read<EstadoApp>();
  if (estado.usuarioActual == null || estado.usuarioActual!.rol != rol) return;
  estado.cambiarPanel(rol);
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => panelSegunRol(rol)),
    (ruta) => false,
  );
}
