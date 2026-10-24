// Validaciones de formularios.
String? validarObligatorio(String? valor, String nombreCampo) {
  if (valor == null || valor.trim().isEmpty) {
    return 'Escribe $nombreCampo';
  }
  return null;
}

String? validarNombre(String? valor) {
  if (valor == null || valor.trim().length < 3) {
    return 'El nombre debe tener al menos 3 letras';
  }
  return null;
}

String? validarCorreo(String? valor) {
  if (valor == null || valor.trim().isEmpty) {
    return 'Escribe tu correo';
  }
  final formato = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!formato.hasMatch(valor.trim())) {
    return 'El correo no es válido';
  }
  return null;
}

String? validarContrasena(String? valor) {
  if (valor == null || valor.isEmpty) {
    return 'Escribe tu contraseña';
  }
  if (valor.length < 6) {
    return 'Debe tener al menos 6 caracteres';
  }
  if (!valor.contains(RegExp(r'[0-9]'))) {
    return 'Debe incluir al menos un número';
  }
  return null;
}
