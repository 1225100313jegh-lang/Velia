import 'package:flutter/material.dart';
import '../servicios/servicio_velia.dart';

class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes>
    with WidgetsBindingObserver {
  final _servicio = ServicioVelia.instancia;
  late final _telefono = TextEditingController(text: _servicio.telefonosEmergencia.join(', '));
  double _escala = ServicioVelia.instancia.escalaTexto;
  bool _contraste = ServicioVelia.instancia.altoContraste;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _servicio.actualizarEstadoNotificaciones();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _servicio.actualizarEstadoNotificaciones();
    }
  }

  @override
  void dispose() { WidgetsBinding.instance.removeObserver(this); _telefono.dispose(); super.dispose(); }

  Future<void> _guardarTelefono() async {
    final numeros = _telefono.text.split(RegExp(r'[,;\n]'))
        .map((numero) => numero.trim()).where((numero) => numero.isNotEmpty);
    if (numeros.any((numero) => numero.replaceAll(RegExp(r'\D'), '').length < 7)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisa los números: cada teléfono debe tener al menos 7 dígitos.')),
      );
      return;
    }
    await _servicio.guardarTelefonosEmergencia(numeros.join(','));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacto de emergencia guardado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ajustes')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Emergencias', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextFormField(controller: _telefono, keyboardType: TextInputType.text, maxLines: 3,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(labelText: 'Teléfonos de emergencia', helperText: 'Separa varios números con coma o punto y coma. La llamada o SMS se abrirán para confirmar el envío.', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
        onFieldSubmitted: (_) => _guardarTelefono()),
      const SizedBox(height: 8),
      FilledButton.icon(onPressed: _guardarTelefono, icon: const Icon(Icons.save), label: const Text('Guardar contacto')),
      const SizedBox(height: 24),
      const Text('Accesibilidad', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('Tamaño del texto: ${(_escala * 100).round()}%'),
      Slider(min: 0.9, max: 1.5, divisions: 6, value: _escala,
        label: '${(_escala * 100).round()}%',
        onChanged: (v) => setState(() => _escala = v),
        onChangeEnd: (v) => _servicio.guardarAccesibilidad(escala: v)),
      SwitchListTile(title: const Text('Alto contraste'),
        subtitle: const Text('Aumenta la diferencia entre texto y fondo.'),
        value: _contraste,
        onChanged: (v) { setState(() => _contraste = v); _servicio.guardarAccesibilidad(contraste: v); }),
      const SizedBox(height: 24),
      const Text('Notificaciones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      AnimatedBuilder(animation: _servicio, builder: (context, _) => Card(child: ListTile(
        leading: Icon(_servicio.notificacionesActivas ? Icons.notifications_active : Icons.notifications_off),
        title: Text(_servicio.notificacionesActivas ? 'Notificaciones activas' : 'Permiso desactivado'),
        subtitle: Text(_servicio.notificacionesActivas ? 'Los recordatorios pueden mostrarse.' : 'Activa el permiso para recibir los recordatorios.'),
      ))),
      OutlinedButton.icon(onPressed: _servicio.solicitarPermiso,
        icon: const Icon(Icons.notifications), label: const Text('Solicitar permiso de notificaciones')),
      const SizedBox(height: 24),
      const Text('Privacidad', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Las cuentas y los datos de citas, medicamentos, historial y contactos se guardan localmente en este teléfono. Cliente y familiares comparten la información de este dispositivo. No hay sincronización entre teléfonos ni servidor; las contraseñas locales son solo para demostración.'))),
    ]),
  );
}
