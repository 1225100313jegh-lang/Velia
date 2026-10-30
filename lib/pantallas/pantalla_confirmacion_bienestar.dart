import 'dart:math';
import 'package:flutter/material.dart';
import '../datos/datos_ejemplo.dart';

// Recompensa por confirmar el bienestar.
class PantallaConfirmacionBienestar extends StatefulWidget {
  const PantallaConfirmacionBienestar({super.key});

  @override
  State<PantallaConfirmacionBienestar> createState() =>
      _EstadoPantallaConfirmacionBienestar();
}

class _EstadoPantallaConfirmacionBienestar
    extends State<PantallaConfirmacionBienestar> {
  static const _frases = [
    '¡Grandioso!',
    '¡Cada día cuenta!',
    '¡Tu bienestar también es una victoria!',
    '¡Qué alegría saber de ti!',
    '¡Un paso más para cuidarte!',
    '¡Hoy hiciste algo bueno por ti!',
  ];
  late final String _frase = _frases[Random().nextInt(_frases.length)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final diametro = (constraints.maxWidth * 0.68).clamp(220.0, 280.0);
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(42),
                  ),
                  padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: diametro,
                        height: diametro,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF4D4D4D),
                          ),
                          child: CustomPaint(painter: _PintorSol()),
                        ),
                      ),
                      const SizedBox(height: 46),
                      const Text(
                        '"Eso nos alegra el día"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'sans-serif-condensed',
                          fontSize: 28,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        _frase,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'sans-serif-condensed',
                          fontSize: 28,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Se avisó a $nombreFamiliar sobre tu buen estado de salud.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'sans-serif-condensed',
                          fontSize: 26,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 34),
                      SizedBox(
                        width: 176,
                        height: 52,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF104D83),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('CONTINUAR'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PintorSol extends CustomPainter {
  const _PintorSol();

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final pintura = Paint()
      ..color = const Color(0xFFF99B45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(centro, size.width * 0.218, pintura);
    for (var indice = 0; indice < 8; indice++) {
      final angulo = indice * pi / 4;
      final inicio = size.width * 0.275;
      final fin = size.width * 0.385;
      canvas.drawLine(
        centro + Offset(cos(angulo) * inicio, sin(angulo) * inicio),
        centro + Offset(cos(angulo) * fin, sin(angulo) * fin),
        pintura,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PintorSol oldDelegate) => false;
}
