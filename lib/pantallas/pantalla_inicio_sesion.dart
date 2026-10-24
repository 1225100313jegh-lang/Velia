import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estado/estado_app.dart';
import '../tema/colores.dart';
import '../utilidades/navegacion.dart';
import '../utilidades/validadores.dart';
import 'pantalla_registro.dart';

// Inicio de sesión.
class PantallaInicioSesion extends StatefulWidget {
  const PantallaInicioSesion({super.key});

  @override
  State<PantallaInicioSesion> createState() => _EstadoPantallaInicioSesion();
}

class _EstadoPantallaInicioSesion extends State<PantallaInicioSesion> {
  final _llaveFormulario = GlobalKey<FormState>(); // Controla la validación
  final _controladorCorreo = TextEditingController();
  final _controladorContrasena = TextEditingController();
  bool _ocultarContrasena = true; // Ojito de la contraseña

  @override
  void dispose() {
    _controladorCorreo.dispose();
    _controladorContrasena.dispose();
    super.dispose();
  }

  // Valida los datos e inicia sesión.
  void _ingresar() {
    if (!_llaveFormulario.currentState!.validate()) return;

    final estado = context.read<EstadoApp>();
    final correcto = estado.iniciarSesion(
      _controladorCorreo.text,
      _controladorContrasena.text,
    );

    if (correcto) {
      irAlPanel(context, estado.rolActivo!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo o contraseña incorrectos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _llaveFormulario,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: colorNaranja,
                    child: Icon(Icons.favorite, color: Colors.white, size: 52),
                  ),
                  const SizedBox(height: 12),
                  const Text('Velia',
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: colorNaranja)),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _controladorCorreo,
                    keyboardType: TextInputType.emailAddress,
                    validator: validarCorreo,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _controladorContrasena,
                    obscureText: _ocultarContrasena,
                    validator: validarContrasena,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_ocultarContrasena
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () => setState(
                            () => _ocultarContrasena = !_ocultarContrasena),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _ingresar,
                      child: const Text('Iniciar sesión',
                          style: TextStyle(fontSize: 17)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PantallaRegistro()),
                      );
                    },
                    child: const Text('¿No tienes cuenta? Regístrate'),
                  ),
                  const ExpansionTile(
                    title: Text('Usuarios de prueba'),
                    childrenPadding: EdgeInsets.only(bottom: 8),
                    children: [
                      Text('Administrador: admin@velia.com / Admin123'),
                      Text('Cliente: carmen@velia.com / Carmen123'),
                      Text('Familiar: laura@velia.com / Laura123'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
