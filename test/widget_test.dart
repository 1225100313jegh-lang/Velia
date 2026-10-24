// Pruebas de permisos y edición.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:velia/estado/estado_app.dart';
import 'package:velia/modelos/medicamento.dart';
import 'package:velia/modelos/usuario.dart';

void main() {
  test('solo el administrador puede ver y eliminar otras cuentas', () {
    final estado = EstadoApp();

    expect(estado.iniciarSesion('carmen@velia.com', 'Carmen123'), isTrue);
    expect(estado.usuarios, hasLength(1));
    final cuentaCliente = estado.usuarios.single;
    expect(estado.usuarios.single, same(cuentaCliente));
    expect(estado.eliminarUsuario(cuentaCliente), isFalse);

    estado.cerrarSesion();
    expect(estado.iniciarSesion('admin@velia.com', 'Admin123'), isTrue);
    expect(estado.usuarios, hasLength(3));
    expect(estado.eliminarUsuario(estado.usuarioActual!), isFalse);
    expect(estado.eliminarUsuario(cuentaCliente), isTrue);
    expect(estado.usuarios, hasLength(2));
  });

  test('administrador no puede cambiar medicamentos y clientes sí', () {
    final estado = EstadoApp();
    final iniciales = estado.medicamentos.length;
    final medicamento = Medicamento(
      nombre: 'Prueba',
      dosis: '1 tableta',
      hora: const TimeOfDay(hour: 9, minute: 0),
    );

    estado.iniciarSesion('admin@velia.com', 'Admin123');
    estado.agregarMedicamento(medicamento);
    expect(estado.medicamentos, hasLength(iniciales));

    estado.cerrarSesion();
    estado.iniciarSesion('carmen@velia.com', 'Carmen123');
    estado.agregarMedicamento(medicamento);
    expect(estado.medicamentos, hasLength(iniciales + 1));
  });

  test('no se pueden registrar cuentas de administrador', () {
    final estado = EstadoApp();

    final error = estado.registrar(
      nombre: 'Otra administradora',
      correo: 'nueva@velia.com',
      contrasena: 'Clave123',
      rol: RolUsuario.administrador,
    );

    expect(error, isNotNull);
    expect(estado.usuarios, isEmpty);
  });
}
