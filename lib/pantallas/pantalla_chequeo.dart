import 'package:flutter/material.dart';
import '../datos/datos_ejemplo.dart';
import '../servicios/servicio_velia.dart';

class PantallaChequeo extends StatefulWidget {
  final bool mostrarBotonEstoyBien;
  const PantallaChequeo({super.key, this.mostrarBotonEstoyBien = true});

  @override
  State<PantallaChequeo> createState() => _PantallaChequeoState();
}

class _PantallaChequeoState extends State<PantallaChequeo>
    with SingleTickerProviderStateMixin {
  final _servicio = ServicioVelia.instancia;
  late final AnimationController _animacion =
      AnimationController(vsync: this, duration: const Duration(seconds: 8))
        ..repeat();

  @override
  void dispose() {
    _animacion.dispose();
    super.dispose();
  }

  Future<void> _configurarHora() async {
    final p = _servicio.horaAviso.split(':').map(int.parse).toList();
    final hora = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: p[0], minute: p[1]));
    if (hora == null) return;
    await _servicio.guardarHoraAviso(hora.hour, hora.minute);
    if (mounted) setState(() {});
  }

  Future<void> _confirmarEstoyBien() async {
    final confirmado = await _servicio.registrarEstoyBien();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(confirmado
          ? '¡Aviso registrado! Tu racha ahora es de ${_servicio.racha} ${_servicio.racha == 1 ? 'día' : 'días'}. '
          : _servicio.avisoCumplidoHoy
              ? 'Ya registraste tu aviso de hoy.'
              : 'El aviso diario estará disponible a las ${_servicio.horaAviso}.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final racha = _servicio.racha;
    final cumplido = _servicio.avisoCumplidoHoy;
    final brillo = (racha / 14).clamp(0.0, 1.0).toDouble();
    final colorSol =
        Color.lerp(const Color(0xFF171717), const Color(0xFFFFC928), brillo)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 90),
      children: [
        Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.favorite, size: 48, color: Colors.green.shade600),
                const SizedBox(height: 10),
                const Text('¿Cómo te sientes hoy?',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (widget.mostrarBotonEstoyBien) SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade600),
                    onPressed: cumplido ? null : _confirmarEstoyBien,
                    child: Text(
                        cumplido ? 'Aviso registrado hoy' : 'Estoy bien',
                        style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Aviso diario: ${_servicio.horaAviso}',
                    style: const TextStyle(color: Colors.black54)),
                TextButton.icon(
                  onPressed: _configurarHora,
                  icon: const Icon(Icons.schedule),
                  label: const Text('Programar hora (cliente o familiar)'),
                ),
                Text(
                    'Último aviso: ${_servicio.ultimoAviso ?? 'Sin registrar'}',
                    style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _animacion,
                  builder: (context, child) => Transform.rotate(
                    angle: _animacion.value * 0.08,
                    child: Icon(Icons.wb_sunny_rounded,
                        size: 76 + brillo * 12,
                        color: colorSol,
                        shadows: [
                          Shadow(
                              color: Colors.amber.withValues(alpha: brillo),
                              blurRadius: 18 + brillo * 30)
                        ]),
                  ),
                ),
                const SizedBox(height: 6),
                Text('Racha: $racha ${racha == 1 ? 'día' : 'días'}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text(cumplido
                    ? '¡Hoy cumpliste tu aviso diario!'
                    : 'Confirma tu bienestar después de la hora programada.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Text('Rutina del día',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...rutinaDiaria.map((actividad) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  actividad.realizada
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color:
                      actividad.realizada ? Colors.green.shade600 : Colors.grey,
                ),
                title: Text(actividad.nombre),
                subtitle: Text(actividad.hora),
              ),
            )),
      ],
    );
  }
}
