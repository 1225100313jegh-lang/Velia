import 'package:flutter_test/flutter_test.dart';
import 'package:velia/servicios/servicio_velia.dart';

void main() {
  group('racha diaria', () {
    final hoy = DateTime(2026, 10, 29, 9);

    test('suma un día cuando el aviso anterior fue ayer', () {
      final ayer = ServicioVelia.fechaClave(DateTime(2026, 10, 28));
      expect(ServicioVelia.siguienteRacha(4, ayer, hoy), 5);
    });

    test('reinicia a uno si se perdió un día', () {
      final haceDosDias = ServicioVelia.fechaClave(DateTime(2026, 10, 27));
      expect(ServicioVelia.siguienteRacha(4, haceDosDias, hoy), 1);
    });

    test('no suma dos veces dentro del mismo día', () {
      final hoyClave = ServicioVelia.fechaClave(hoy);
      expect(ServicioVelia.siguienteRacha(4, hoyClave, hoy), 4);
    });
  });

  test('una cita conserva sus campos al guardarse y cargarse', () {
    final cita = EventoPersistente(
      'Consulta', DateTime(2026, 11, 2, 10, 30), 'cita', 'Llevar estudios',
    );
    final recuperada = EventoPersistente.fromJson(cita.toJson());

    expect(recuperada.id, cita.id);
    expect(recuperada.titulo, 'Consulta');
    expect(recuperada.fecha, DateTime(2026, 11, 2, 10, 30));
    expect(recuperada.notas, 'Llevar estudios');
  });

  test('un medicamento conserva sus datos al guardarse y cargarse', () {
    final dosis = MedicamentoPersistente('Vitamina D', '1 cápsula', 9, 15);
    final recuperada = MedicamentoPersistente.fromJson(dosis.toJson());

    expect(recuperada.id, dosis.id);
    expect(recuperada.nombre, 'Vitamina D');
    expect(recuperada.dosis, '1 cápsula');
    expect(recuperada.minutosDia, 555);
  });
}
