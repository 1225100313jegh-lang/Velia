import 'package:flutter/material.dart';

// Roles disponibles.
enum RolUsuario { administrador, cliente, familiar }

// Nombre e ícono de cada rol.
extension DatosRol on RolUsuario {
  String get etiqueta => switch (this) {
        RolUsuario.administrador => 'Administrador',
        RolUsuario.cliente => 'Cliente (adulto mayor)',
        RolUsuario.familiar => 'Familiar',
      };

  IconData get icono => switch (this) {
        RolUsuario.administrador => Icons.admin_panel_settings,
        RolUsuario.cliente => Icons.elderly,
        RolUsuario.familiar => Icons.family_restroom,
      };
}

// Cuenta de usuario.
class Usuario {
  final String nombre;
  final String correo;
  final String contrasena;
  final RolUsuario rol;

  Usuario({
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.rol,
  });
}
