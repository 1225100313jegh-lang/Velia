// Datos de ejemplo fijos, solo para la demostración.
// Si quieres cambiar nombres, medicinas o fechas, hazlo aquí.

// Nombre del adulto mayor que se cuida.
const String nombreAdultoMayor = 'Doña Carmen Ramírez';

// Nombre del familiar que monitorea.
const String nombreFamiliar = 'Laura Ramírez (hija)';

// Texto del último aviso "Estoy bien".
const String ultimoAviso = 'Hoy, 08:05 a.m.';

// Un medicamento con su hora y dosis.
class Medicamento {
  final String hora; // A qué hora se toma
  final String nombre; // Nombre de la medicina
  final String dosis; // Cuánto y cómo se toma
  const Medicamento(this.hora, this.nombre, this.dosis);
}

// Un evento del calendario (cita, aniversario, etc.).
class Evento {
  final String titulo; // Nombre del evento
  final String fecha; // Día del evento
  final String hora; // Hora del evento
  final String tipo; // 'cita', 'aniversario' u otro
  const Evento(this.titulo, this.fecha, this.hora, this.tipo);
}

// Una actividad de la rutina diaria.
class Actividad {
  final String hora; // Hora de la actividad
  final String nombre; // Qué se hace
  final bool realizada; // true = ya se hizo, false = pendiente
  const Actividad(this.hora, this.nombre, this.realizada);
}

// Lista de medicamentos del día.
const List<Medicamento> medicamentos = [
  Medicamento('08:00 a.m.', 'Losartán', '1 tableta con el desayuno'),
  Medicamento('02:00 p.m.', 'Metformina', '1 tableta con la comida'),
  Medicamento('08:00 p.m.', 'Omeprazol', '1 cápsula antes de cenar'),
  Medicamento('10:00 p.m.', 'Atorvastatina', '1 tableta antes de dormir'),
];

// La siguiente pastilla que le toca tomar.
const Medicamento proximaPastilla =
    Medicamento('02:00 p.m.', 'Metformina', '1 tableta con la comida');

// Lista de próximos eventos del calendario.
const List<Evento> eventos = [
  Evento('Cita con cardiología', 'Mié 21 oct', '10:30 a.m.', 'cita'),
  Evento('Aniversario de bodas', 'Sáb 24 oct', 'Todo el día', 'aniversario'),
  Evento('Análisis de laboratorio', 'Mar 27 oct', '08:00 a.m.', 'cita'),
  Evento('Cumpleaños de Laura', 'Dom 1 nov', 'Todo el día', 'aniversario'),
  Evento('Revisión con el médico general', 'Jue 5 nov', '12:00 p.m.', 'cita'),
];

// Lista de actividades de la rutina del día.
const List<Actividad> rutinaDiaria = [
  Actividad('07:00 a.m.', 'Despertar y aseo personal', true),
  Actividad('08:00 a.m.', 'Desayuno y medicamento', true),
  Actividad('10:00 a.m.', 'Caminata en el jardín', true),
  Actividad('02:00 p.m.', 'Comida y medicamento', false),
  Actividad('05:00 p.m.', 'Taller de manualidades', false),
  Actividad('08:00 p.m.', 'Cena y medicamento', false),
];
