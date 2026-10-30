import 'package:flutter/material.dart';
import '../servicios/servicio_velia.dart';
import '../tema/colores.dart';
import 'pantalla_principal.dart';
import 'pantalla_registro.dart';
import 'pantalla_espera_vinculo.dart';

class PantallaInicioSesion extends StatefulWidget {
  const PantallaInicioSesion({super.key});
  @override
  State<PantallaInicioSesion> createState() => _PantallaInicioSesionState();
}

class _PantallaInicioSesionState extends State<PantallaInicioSesion> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _ocultar = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    final servicio = ServicioVelia.instancia;
    final cuenta = servicio.autenticarCuenta(_email.text, _password.text);
    if (cuenta == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('Correo o contraseña incorrectos. Usa una cuenta @velia.com.'),
      ));
      return;
    }
    if (cuenta.rol == 'familiar' && cuenta.estadoVinculo != 'autorizado') {
      await servicio.registrarUsoCuenta(cuenta.email);
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  PantallaEsperaVinculo(emailFamiliar: cuenta!.email)));
      return;
    }
    await servicio.activarCuenta(cuenta.email);
    await servicio.registrarUsoCuenta(cuenta.email);
    if (!mounted) return;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PantallaPrincipal(cuenta: cuenta),
        ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const CircleAvatar(
                  radius: 48,
                  backgroundColor: colorNaranja,
                  child: Icon(Icons.favorite, color: Colors.white, size: 52)),
              const SizedBox(height: 14),
              const Text('Velia',
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: colorNaranja)),
              const Text('Cuidado digital para nuestros mayores',
                  textAlign: TextAlign.center),
              const SizedBox(height: 28),
              TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      labelText: 'Correo @velia.com',
                      prefixIcon: Icon(Icons.alternate_email),
                      border: OutlineInputBorder())),
              const SizedBox(height: 14),
              TextField(
                  controller: _password,
                  obscureText: _ocultar,
                  onSubmitted: (_) => _ingresar(),
                  decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                          onPressed: () => setState(() => _ocultar = !_ocultar),
                          icon: Icon(_ocultar
                              ? Icons.visibility
                              : Icons.visibility_off)))),
              const SizedBox(height: 18),
              SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                      onPressed: _ingresar,
                      icon: const Icon(Icons.login),
                      label: const Text('Iniciar sesión'))),
              const SizedBox(height: 8),
              SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PantallaRegistro())),
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Crear cuenta'),
                  )),
              const SizedBox(height: 20),
              const Card(
                  child: Padding(
                      padding: EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Accesos locales de demostración',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text('Administrador: admin@velia.com / admin123'),
                          Text('Cliente/adulto: adulto@velia.com / adulto123'),
                          Text('Familiar: familiar@velia.com / familiar123'),
                          SizedBox(height: 6),
                          Text(
                              'Solo funcionan en este dispositivo. Cambia las claves antes de guardar información real.',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ))),
            ]),
          ),
        ))),
      );
}
