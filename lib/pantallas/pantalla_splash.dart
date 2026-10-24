import 'package:flutter/material.dart';
import '../tema/colores.dart';
import 'pantalla_inicio_sesion.dart';

// Presentación inicial.
class PantallaSplash extends StatefulWidget {
  const PantallaSplash({super.key});

  @override
  State<PantallaSplash> createState() => _EstadoPantallaSplash();
}

class _EstadoPantallaSplash extends State<PantallaSplash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PantallaInicioSesion()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOut,
          builder: (context, valor, hijo) => Opacity(
            opacity: valor,
            child: Transform.scale(scale: 0.6 + 0.4 * valor, child: hijo),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: colorNaranja,
                child: Icon(Icons.favorite, color: Colors.white, size: 60),
              ),
              SizedBox(height: 20),
              Text('Velia',
                  style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: colorNaranja)),
              SizedBox(height: 6),
              Text('Cuidado digital para nuestros mayores',
                  style: TextStyle(fontSize: 16, color: Colors.black87)),
              SizedBox(height: 30),
              CircularProgressIndicator(color: colorNaranja),
            ],
          ),
        ),
      ),
    );
  }
}
