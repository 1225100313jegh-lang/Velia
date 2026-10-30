import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'tema/colores.dart';
import 'pantallas/pantalla_inicio_sesion.dart';
import 'servicios/servicio_velia.dart';

// Aquí empieza la aplicación: esta función arranca todo.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServicioVelia.instancia.inicializar();
  runApp(const AplicacionVelia());
}

// Widget principal: define el nombre, el tema (colores) y la primera pantalla.
class AplicacionVelia extends StatelessWidget {
  const AplicacionVelia({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: ServicioVelia.instancia,
    builder: (context, _) => MaterialApp(
      title: 'Velia',
      locale: const Locale('es', 'MX'),
      supportedLocales: const [Locale('es', 'MX')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // Quita la etiqueta "debug" de la esquina.
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorNaranja,
          primary: colorNaranja,
          contrastLevel: ServicioVelia.instancia.altoContraste ? 1.0 : 0.0,
        ),
        // Color de fondo de todas las pantallas.
        scaffoldBackgroundColor: colorFondo,
      ),
      // La primera pantalla que se ve es el inicio de sesión.
      home: const PantallaInicioSesion(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(ServicioVelia.instancia.escalaTexto),
        ),
        child: child!,
      ),
    ),
  );
}
