import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'estado/estado_app.dart';
import 'tema/colores.dart';
import 'pantallas/pantalla_splash.dart';

// Inicio de Velia.
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => EstadoApp(),
      child: const AplicacionVelia(),
    ),
  );
}

// Configuración principal de la aplicación.
class AplicacionVelia extends StatelessWidget {
  const AplicacionVelia({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorNaranja,
          primary: colorNaranja,
        ),
        scaffoldBackgroundColor: colorFondo,
      ),
      locale: const Locale('es', 'MX'),
      supportedLocales: const [Locale('es', 'MX')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const PantallaSplash(),
    );
  }
}
