import 'dart:collection';
import 'package:flutter/material.dart';
import '../datos/datos_ejemplo.dart';
import '../modelos/usuario.dart';
import '../modelos/medicamento.dart';
import '../modelos/evento.dart';

// Estado compartido y permisos de la aplicación.
class EstadoApp extends ChangeNotifier {
  final List<Usuario> _usuarios = List.of(usuariosEjemplo);
  final List<Medicamento> _medicamentos = List.of(medicamentosEjemplo);
  final List<Evento> _eventos = List.of(eventosEjemplo);
  final List<Actividad> _rutinas = List.of(rutinaDiaria);
  final List<DateTime> _avisosBienestar = [];
  int _avisosLeidos = 0;

  Usuario? _usuarioActual; // Quién inició sesión
  RolUsuario? _rolActivo; // Qué panel se está viendo

  // Datos

  Usuario? get usuarioActual => _usuarioActual;
  RolUsuario? get rolActivo => _rolActivo;
  bool get esAdministrador => _usuarioActual?.rol == RolUsuario.administrador;
  bool get puedeEditarCuidados =>
      _usuarioActual?.rol == RolUsuario.cliente ||
      _usuarioActual?.rol == RolUsuario.familiar;

  List<Usuario> get usuarios => UnmodifiableListView(
        esAdministrador
            ? _usuarios
            : _usuarios.where((usuario) => identical(usuario, _usuarioActual)),
      );
  List<Actividad> get rutinas => UnmodifiableListView(_rutinas);

  // Ordena los medicamentos por hora.
  List<Medicamento> get medicamentos {
    final copia = List.of(_medicamentos);
    copia.sort((a, b) => _minutos(a.hora).compareTo(_minutos(b.hora)));
    return copia;
  }

  // Ordena los eventos por fecha y hora.
  List<Evento> get eventos {
    final copia = List.of(_eventos);
    copia.sort((a, b) {
      final porFecha = a.fecha.compareTo(b.fecha);
      if (porFecha != 0) return porFecha;
      final horaA = a.hora == null ? -1 : _minutos(a.hora!);
      final horaB = b.hora == null ? -1 : _minutos(b.hora!);
      return horaA.compareTo(horaB);
    });
    return copia;
  }

  // Avisos del más reciente al más antiguo.
  List<DateTime> get avisosBienestar => _avisosBienestar.reversed.toList();
  int get avisosPendientes => _avisosBienestar.length - _avisosLeidos;

  // Fecha del aviso más reciente.
  DateTime? get ultimoAviso =>
      _avisosBienestar.isEmpty ? null : _avisosBienestar.last;

  // Próximo medicamento programado.
  Medicamento? get proximaPastilla {
    final lista = medicamentos;
    if (lista.isEmpty) return null;
    final minutosAhora = _minutos(TimeOfDay.now());
    for (final medicamento in lista) {
      if (_minutos(medicamento.hora) >= minutosAhora) return medicamento;
    }
    // Si ya pasaron todas, devuelve la primera de mañana.
    return lista.first;
  }

  // Convierte la hora a minutos.
  int _minutos(TimeOfDay hora) => hora.hour * 60 + hora.minute;

  // Sesión y registro

  // Inicia sesión con correo y contraseña.
  bool iniciarSesion(String correo, String contrasena) {
    final correoLimpio = correo.trim().toLowerCase();
    for (final usuario in _usuarios) {
      if (usuario.correo == correoLimpio && usuario.contrasena == contrasena) {
        _usuarioActual = usuario;
        _rolActivo = usuario.rol;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // Registra una cuenta nueva.
  String? registrar({
    required String nombre,
    required String correo,
    required String contrasena,
    required RolUsuario rol,
  }) {
    if (rol == RolUsuario.administrador) {
      return 'No se pueden crear cuentas de administrador desde el registro';
    }
    final correoLimpio = correo.trim().toLowerCase();
    final yaExiste = _usuarios.any((u) => u.correo == correoLimpio);
    if (yaExiste) return 'Ese correo ya está registrado';

    final nuevo = Usuario(
      nombre: nombre.trim(),
      correo: correoLimpio,
      contrasena: contrasena,
      rol: rol,
    );
    _usuarios.add(nuevo);
    _usuarioActual = nuevo;
    _rolActivo = rol;
    notifyListeners();
    return null;
  }

  void cerrarSesion() {
    _usuarioActual = null;
    _rolActivo = null;
    notifyListeners();
  }

  void cambiarPanel(RolUsuario rol) {
    if (_usuarioActual?.rol != rol) return;
    _rolActivo = rol;
    notifyListeners();
  }

  bool eliminarUsuario(Usuario usuario) {
    if (!esAdministrador || identical(usuario, _usuarioActual)) return false;
    final eliminado = _usuarios.remove(usuario);
    if (eliminado) notifyListeners();
    return eliminado;
  }

  // Medicamentos

  void agregarMedicamento(Medicamento medicamento) {
    if (!puedeEditarCuidados) return;
    _medicamentos.add(medicamento);
    notifyListeners();
  }

  void editarMedicamento(Medicamento anterior, Medicamento actualizado) {
    if (!puedeEditarCuidados) return;
    final indice = _medicamentos.indexOf(anterior);
    if (indice == -1) return;
    _medicamentos[indice] = actualizado;
    notifyListeners();
  }

  void eliminarMedicamento(Medicamento medicamento) {
    if (!puedeEditarCuidados) return;
    _medicamentos.remove(medicamento);
    notifyListeners();
  }

  void vaciarMedicamentos() {
    if (!puedeEditarCuidados) return;
    _medicamentos.clear();
    notifyListeners();
  }

  void agregarRutina(Actividad actividad) {
    if (!puedeEditarCuidados) return;
    _rutinas.add(actividad);
    notifyListeners();
  }

  void editarRutina(Actividad anterior, Actividad actualizada) {
    if (!puedeEditarCuidados) return;
    final indice = _rutinas.indexOf(anterior);
    if (indice == -1) return;
    _rutinas[indice] = actualizada;
    notifyListeners();
  }

  void eliminarRutina(Actividad actividad) {
    if (!puedeEditarCuidados) return;
    _rutinas.remove(actividad);
    notifyListeners();
  }

  void cambiarEstadoRutina(Actividad actividad) {
    if (!puedeEditarCuidados) return;
    editarRutina(
      actividad,
      Actividad(actividad.hora, actividad.nombre, !actividad.realizada),
    );
  }

  // Eventos

  void agregarEvento(Evento evento) {
    if (!puedeEditarCuidados) return;
    _eventos.add(evento);
    notifyListeners();
  }

  void eliminarEvento(Evento evento) {
    if (!puedeEditarCuidados) return;
    _eventos.remove(evento);
    notifyListeners();
  }

  void vaciarEventos() {
    if (!puedeEditarCuidados) return;
    _eventos.clear();
    notifyListeners();
  }

  // Avisos de bienestar

  // Registra que la persona indicó que está bien.
  void registrarBienestar() {
    _avisosBienestar.add(DateTime.now());
    notifyListeners();
  }

  void marcarAvisosLeidos() {
    _avisosLeidos = _avisosBienestar.length;
    notifyListeners();
  }
}
