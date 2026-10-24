import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estado/estado_app.dart';
import '../modelos/usuario.dart';
import '../utilidades/navegacion.dart';
import '../utilidades/validadores.dart';
import '../tema/colores.dart';

// Registro de una cuenta.
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _EstadoPantallaRegistro();
}

class _EstadoPantallaRegistro extends State<PantallaRegistro> {
  final _llaveFormulario = GlobalKey<FormState>();
  final _controladorNombre = TextEditingController();
  final _controladorCorreo = TextEditingController();
  final _controladorContrasena = TextEditingController();
  final _controladorConfirmacion = TextEditingController();
  RolUsuario _rolElegido = RolUsuario.cliente; // Tipo de usuario elegido
  bool _ocultarContrasena = true;

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorCorreo.dispose();
    _controladorContrasena.dispose();
    _controladorConfirmacion.dispose();
    super.dispose();
  }

  // Valida y registra la cuenta.
  void _registrar() {
    if (!_llaveFormulario.currentState!.validate()) return;

    final error = context.read<EstadoApp>().registrar(
          nombre: _controladorNombre.text,
          correo: _controladorCorreo.text,
          contrasena: _controladorContrasena.text,
          rol: _rolElegido,
        );

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      irAlPanel(context, _rolElegido);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorNaranja,
        foregroundColor: Colors.white,
        title: const Text('Crear cuenta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _llaveFormulario,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _controladorNombre,
                validator: validarNombre,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controladorCorreo,
                validator: validarCorreo,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controladorContrasena,
                validator: validarContrasena,
                obscureText: _ocultarContrasena,
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _controladorConfirmacion,
                obscureText: _ocultarContrasena,
                validator: (valor) {
                  if (valor != _controladorContrasena.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Tipo de usuario',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final rol in [RolUsuario.cliente, RolUsuario.familiar])
                    ChoiceChip(
                      label: Text(rol.etiqueta),
                      avatar: Icon(rol.icono, size: 18),
                      selected: _rolElegido == rol,
                      onSelected: (_) => setState(() => _rolElegido = rol),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _registrar,
                  child: const Text('Crear cuenta',
                      style: TextStyle(fontSize: 17)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
