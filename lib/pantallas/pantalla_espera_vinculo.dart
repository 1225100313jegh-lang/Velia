import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../servicios/servicio_velia.dart';
import 'pantalla_inicio_sesion.dart';
import 'pantalla_principal.dart';

class PantallaEsperaVinculo extends StatelessWidget {
  final String emailFamiliar;
  const PantallaEsperaVinculo({super.key, required this.emailFamiliar});

  Future<void> _solicitarVinculo(BuildContext context) async {
    final codigo = TextEditingController();
    final confirmado = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
              title: const Text('Solicitar un nuevo vínculo'),
              content: TextField(
                  controller: codigo,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration:
                      const InputDecoration(labelText: 'Código de 6 dígitos')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialog, false),
                    child: const Text('Cancelar')),
                FilledButton(
                    onPressed: () => Navigator.pop(dialog, true),
                    child: const Text('Enviar solicitud'))
              ],
            ));
    if (confirmado == true) {
      final error = await ServicioVelia.instancia
          .solicitarVinculo(emailFamiliar, codigo.text);
      if (context.mounted && error != null)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
    }
    codigo.dispose();
  }

  Future<void> _entrar(BuildContext context, CuentaLocalVelia familiar) async {
    final servicio = ServicioVelia.instancia;
    await servicio.activarCuenta(familiar.email);
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => PantallaPrincipal(cuenta: familiar)),
        (_) => false);
  }

  Future<void> _editarPerfil(
      BuildContext context, CuentaLocalVelia familiar) async {
    final nombre = TextEditingController(text: familiar.nombre);
    final parentesco = TextEditingController(text: familiar.parentesco);
    final tipoContacto = TextEditingController(text: familiar.tipoContacto);
    final datoContacto = TextEditingController(text: familiar.datoContacto);
    final guardar = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
              title: const Text('Completar perfil familiar'),
              content: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                    controller: nombre,
                    decoration: const InputDecoration(labelText: 'Nombre')),
                TextField(
                    controller: parentesco,
                    decoration: const InputDecoration(labelText: 'Parentesco')),
                TextField(
                    controller: tipoContacto,
                    decoration:
                        const InputDecoration(labelText: 'Tipo de contacto')),
                TextField(
                    controller: datoContacto,
                    decoration:
                        const InputDecoration(labelText: 'Dato de contacto')),
              ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialog, false),
                    child: const Text('Cancelar')),
                FilledButton(
                    onPressed: () => Navigator.pop(dialog, true),
                    child: const Text('Guardar'))
              ],
            ));
    if (guardar == true)
      await ServicioVelia.instancia.guardarPerfil(
          email: familiar.email,
          nombre: nombre.text,
          parentesco: parentesco.text,
          tipoContacto: tipoContacto.text,
          datoContacto: datoContacto.text);
    nombre.dispose();
    parentesco.dispose();
    tipoContacto.dispose();
    datoContacto.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: ServicioVelia.instancia,
        builder: (context, _) {
          CuentaLocalVelia? familiar;
          for (final cuenta in ServicioVelia.instancia.cuentas) {
            if (cuenta.email == emailFamiliar) {
              familiar = cuenta;
              break;
            }
          }
          if (familiar == null)
            return const Scaffold(
                body: Center(child: Text('La cuenta ya no está disponible.')));
          final autorizado = familiar.estadoVinculo == 'autorizado';
          final estado = familiar.estadoVinculo;
          return Scaffold(
            appBar: AppBar(title: const Text('Vínculo familiar')),
            body: Center(
                child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(autorizado ? Icons.link : Icons.hourglass_top,
                          size: 72,
                          color: autorizado ? Colors.green : Colors.orange),
                      const SizedBox(height: 16),
                      Text(
                          autorizado
                              ? 'Vínculo autorizado'
                              : estado == 'pendiente'
                                  ? 'Solicitud enviada'
                                  : 'Sin vínculo autorizado',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Text(
                          autorizado
                              ? 'Ya puedes consultar la información del adulto mayor vinculado.'
                              : estado == 'pendiente'
                                  ? 'Tu cuenta se creó, pero todavía no puedes ver la información. El adulto mayor o el administrador debe autorizar el vínculo.'
                                  : 'No puedes consultar la información del adulto mayor hasta enviar una solicitud y recibir autorización.',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: () => _editarPerfil(context, familiar!),
                        icon: const Icon(Icons.edit),
                        label: const Text('Completar mi perfil'),
                      ),
                      if (estado == 'desvinculado')
                        OutlinedButton.icon(
                            onPressed: () => _solicitarVinculo(context),
                            icon: const Icon(Icons.link),
                            label: const Text(
                                'Solicitar vínculo con otro código')),
                      if (autorizado)
                        FilledButton.icon(
                            onPressed: () => _entrar(context, familiar!),
                            icon: const Icon(Icons.login),
                            label: const Text('Entrar a Velia')),
                      OutlinedButton.icon(
                          onPressed: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const PantallaInicioSesion()),
                              (_) => false),
                          icon: const Icon(Icons.logout),
                          label: const Text('Cerrar sesión')),
                    ]),
              ),
            )),
          );
        },
      );
}
