import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../servicios/servicio_velia.dart';
import '../tema/colores.dart';
import 'pantalla_principal.dart';
import 'pantalla_espera_vinculo.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});
  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  final _confirmacion = TextEditingController();
  final _codigoCliente = TextEditingController();
  String _rol = 'cliente';
  bool _ocultar = true;
  bool _guardando = false;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    _confirmacion.dispose();
    _codigoCliente.dispose();
    super.dispose();
  }

  Future<void> _crearCuenta() async {
    if (_contrasena.text != _confirmacion.text) {
      _mensaje('Las contraseñas no coinciden.');
      return;
    }
    setState(() => _guardando = true);
    final servicio = ServicioVelia.instancia;
    final error = await servicio.crearCuenta(
      email: _correo.text,
      password: _contrasena.text,
      rol: _rol,
      codigoVinculacion: _rol == 'familiar' ? _codigoCliente.text : null,
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    if (error != null) {
      _mensaje(error);
      return;
    }
    if (_rol == 'cliente') {
      final codigo = servicio.codigoParaCuenta(_correo.text);
      if (codigo != null) await _mostrarCodigo(codigo);
      if (!mounted) return;
    }
    final cuenta = servicio.autenticarCuenta(_correo.text, _contrasena.text);
    if (cuenta == null) {
      _mensaje(
          'La cuenta se creó, pero no se pudo iniciar sesión. Regresa al acceso.');
      return;
    }
    await servicio.registrarUsoCuenta(cuenta.email);
    if (!mounted) return;
    if (cuenta.rol == 'familiar' && cuenta.estadoVinculo != 'autorizado') {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  PantallaEsperaVinculo(emailFamiliar: cuenta!.email)),
          (_) => false);
      return;
    }
    await servicio.activarCuenta(cuenta.email);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => PantallaPrincipal(cuenta: cuenta)),
        (_) => false);
  }

  void _mensaje(String texto) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _mostrarCodigo(String codigo) async {
    await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
              icon: const Icon(Icons.link, color: colorNaranja, size: 36),
              title: const Text('Código para vincular familiares'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text(
                    'Comparte este código con tu familiar. Debe crear su cuenta e ingresarlo.'),
                const SizedBox(height: 16),
                SelectableText(codigo,
                    style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8)),
                const SizedBox(height: 8),
                const Text('El código solo funciona en este dispositivo.',
                    textAlign: TextAlign.center),
              ]),
              actions: [
                TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: codigo));
                      if (dialogContext.mounted)
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(content: Text('Código copiado.')));
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar')),
                FilledButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Continuar')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Crear cuenta')),
        body: SafeArea(
            child: ListView(padding: const EdgeInsets.all(24), children: [
          const CircleAvatar(
              radius: 38,
              backgroundColor: colorNaranja,
              child:
                  Icon(Icons.person_add_alt_1, color: Colors.white, size: 38)),
          const SizedBox(height: 16),
          const Text('Únete a Velia',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                  labelText: 'Correo @velia.com',
                  hintText: 'nombre@velia.com',
                  prefixIcon: Icon(Icons.alternate_email),
                  border: OutlineInputBorder())),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
              value: _rol,
              decoration: const InputDecoration(
                  labelText: 'Tipo de cuenta', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(
                    value: 'cliente', child: Text('Cliente / adulto')),
                DropdownMenuItem(value: 'familiar', child: Text('Familiar')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _rol = value);
              }),
          if (_rol == 'familiar') ...[
            const SizedBox(height: 14),
            TextField(
                controller: _codigoCliente,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    labelText: 'Código del cliente',
                    hintText: '6 dígitos',
                    prefixIcon: Icon(Icons.link),
                    border: OutlineInputBorder(),
                    counterText: '')),
          ],
          const SizedBox(height: 14),
          TextField(
              controller: _contrasena,
              obscureText: _ocultar,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                  labelText: 'Contraseña (mínimo 6 caracteres)',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                      onPressed: () => setState(() => _ocultar = !_ocultar),
                      icon: Icon(_ocultar
                          ? Icons.visibility
                          : Icons.visibility_off)))),
          const SizedBox(height: 14),
          TextField(
              controller: _confirmacion,
              obscureText: true,
              onSubmitted: (_) => _crearCuenta(),
              decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                  prefixIcon: Icon(Icons.lock_reset),
                  border: OutlineInputBorder())),
          const SizedBox(height: 20),
          SizedBox(
              height: 52,
              child: FilledButton.icon(
                  onPressed: _guardando ? null : _crearCuenta,
                  icon: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.person_add),
                  label: const Text('Crear cuenta y entrar'))),
          const SizedBox(height: 12),
          const Text(
              'Cuenta local de este dispositivo. No se crea un correo real ni se sincroniza con otros teléfonos.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12)),
        ])),
      );
}
