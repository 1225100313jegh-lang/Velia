import 'package:flutter/material.dart';
import '../modelos/usuario.dart';
import '../modelos/medicamento.dart';
import '../modelos/evento.dart';

// Datos de ejemplo iniciales.

const String nombreAdultoMayor = 'Doña Carmen Ramírez';

const String nombreFamiliar = 'Laura Ramírez (hija)';

// Cuentas iniciales.
final List<Usuario> usuariosEjemplo = [
  Usuario(
    nombre: 'Administrador Velia',
    correo: 'admin@velia.com',
    contrasena: 'Admin123',
    rol: RolUsuario.administrador,
  ),
  Usuario(
    nombre: 'Carmen Ramírez',
    correo: 'carmen@velia.com',
    contrasena: 'Carmen123',
    rol: RolUsuario.cliente,
  ),
  Usuario(
    nombre: 'Laura Ramírez',
    correo: 'laura@velia.com',
    contrasena: 'Laura123',
    rol: RolUsuario.familiar,
  ),
];

// Medicamentos iniciales.
final List<Medicamento> medicamentosEjemplo = [
  Medicamento(
      nombre: 'Losartán',
      dosis: '1 tableta con el desayuno',
      hora: const TimeOfDay(hour: 8, minute: 0)),
  Medicamento(
      nombre: 'Metformina',
      dosis: '1 tableta con la comida',
      hora: const TimeOfDay(hour: 14, minute: 0)),
  Medicamento(
      nombre: 'Omeprazol',
      dosis: '1 cápsula antes de cenar',
      hora: const TimeOfDay(hour: 20, minute: 0)),
  Medicamento(
      nombre: 'Atorvastatina',
      dosis: '1 tableta antes de dormir',
      hora: const TimeOfDay(hour: 22, minute: 0)),
];

// Eventos iniciales.
final List<Evento> eventosEjemplo = [
  Evento(
      titulo: 'Cita con cardiología',
      fecha: DateTime(2026, 10, 21),
      hora: const TimeOfDay(hour: 10, minute: 30),
      tipo: TipoEvento.cita,
      notas: 'Llevar la lista de medicamentos y estudios anteriores.'),
  Evento(
      titulo: 'Aniversario de bodas',
      fecha: DateTime(2026, 10, 24),
      hora: null,
      tipo: TipoEvento.aniversario,
      notas: 'Preparar una comida con la familia.'),
  Evento(
      titulo: 'Análisis de laboratorio',
      fecha: DateTime(2026, 10, 27),
      hora: const TimeOfDay(hour: 8, minute: 0),
      tipo: TipoEvento.cita,
      notas: 'Ir en ayunas.'),
  Evento(
      titulo: 'Cumpleaños de Laura',
      fecha: DateTime(2026, 11, 1),
      hora: null,
      tipo: TipoEvento.aniversario),
];

// Actividad de la rutina diaria.
class Actividad {
  final String hora;
  final String nombre;
  final bool realizada; // Indica si ya se completó.
  const Actividad(this.hora, this.nombre, this.realizada);
}

// Rutina diaria inicial.
const List<Actividad> rutinaDiaria = [
  Actividad('07:00 a.m.', 'Despertar y aseo personal', true),
  Actividad('08:00 a.m.', 'Desayuno y medicamento', true),
  Actividad('10:00 a.m.', 'Caminata en el jardín', true),
  Actividad('02:00 p.m.', 'Comida y medicamento', false),
  Actividad('05:00 p.m.', 'Taller de manualidades', false),
  Actividad('08:00 p.m.', 'Cena y medicamento', false),
];
