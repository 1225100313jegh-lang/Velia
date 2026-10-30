import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../datos/datos_ejemplo.dart';
import '../servicios/servicio_velia.dart';
import '../tema/colores.dart';
import '../widgets/boton_emergencia.dart';
import 'pantalla_ajustes.dart';
import 'pantalla_calendario.dart';
import 'pantalla_chequeo.dart';
import 'pantalla_historial.dart';
import 'pantalla_horario.dart';
import 'pantalla_inicio_sesion.dart';
import 'pantalla_personas_vinculos.dart';

class PantallaPrincipal extends StatelessWidget {
  final CuentaLocalVelia cuenta;
  const PantallaPrincipal({super.key, required this.cuenta});

  Future<void> _cerrarSesion(BuildContext context) async {
    await ServicioVelia.instancia.registrarSalidaCuenta(cuenta.email);
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PantallaInicioSesion()),
        (_) => false);
  }

  Future<void> _mostrarCodigoVinculacion(BuildContext context) async {
    final codigo = ServicioVelia.instancia.codigoParaCuenta(cuenta.email);
    if (codigo == null) return;
    await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: const Text('Código para vincular familiar'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text(
                    'Comparte este código con el familiar para que se registre en este dispositivo.'),
                const SizedBox(height: 14),
                SelectableText(codigo,
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 7)),
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
                    child: const Text('Cerrar')),
              ],
            ));
  }

  String _nombreAdultoActivo() {
    if (cuenta.rol == 'cliente' || cuenta.rol == 'adulto') {
      return cuenta.nombre.isEmpty ? nombreAdultoMayor : cuenta.nombre;
    }
    for (final persona in ServicioVelia.instancia.cuentas) {
      if (persona.email == cuenta.adultoVinculado)
        return persona.nombre.isEmpty ? nombreAdultoMayor : persona.nombre;
    }
    return nombreAdultoMayor;
  }

  @override
  Widget build(BuildContext context) {
    if (cuenta.rol == 'admin')
      return _PanelAdministrador(
          cuenta: cuenta, cerrarSesion: () => _cerrarSesion(context));
    final esCliente = cuenta.rol == 'cliente' || cuenta.rol == 'adulto';
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: colorNaranja,
              foregroundColor: Colors.white,
              title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Velia',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(_nombreAdultoActivo(),
                        style: const TextStyle(fontSize: 13)),
                  ]),
              actions: [
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Center(
                        child:
                            Text(esCliente ? 'Cliente / adulto' : 'Familiar'))),
                if (esCliente)
                  IconButton(
                      tooltip: 'Vincular familiar',
                      icon: const Icon(Icons.link),
                      onPressed: () => _mostrarCodigoVinculacion(context)),
                IconButton(
                    tooltip: 'Personas y vínculos',
                    icon: const Icon(Icons.groups),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                PantallaPersonasVinculos(cuenta: cuenta)))),
                IconButton(
                    tooltip: 'Historial',
                    icon: const Icon(Icons.history),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PantallaHistorial()))),
                IconButton(
                    tooltip: 'Ajustes',
                    icon: const Icon(Icons.settings),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PantallaAjustes()))),
                IconButton(
                    tooltip: 'Cerrar sesión',
                    icon: const Icon(Icons.logout),
                    onPressed: () => _cerrarSesion(context)),
              ],
              bottom: const TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(icon: Icon(Icons.access_time), text: 'Horario'),
                    Tab(
                        icon: Icon(Icons.check_circle_outline),
                        text: 'Chequeo'),
                    Tab(icon: Icon(Icons.calendar_month), text: 'Calendario'),
                  ])),
          body: TabBarView(children: [
            const PantallaHorario(),
            PantallaChequeo(mostrarBotonEstoyBien: esCliente),
            const PantallaCalendario(),
          ]),
          floatingActionButton: const BotonEmergencia(),
        ));
  }
}

class _PanelAdministrador extends StatefulWidget {
  final CuentaLocalVelia cuenta;
  final VoidCallback cerrarSesion;
  const _PanelAdministrador({required this.cuenta, required this.cerrarSesion});
  @override
  State<_PanelAdministrador> createState() => _PanelAdministradorState();
}

class _PanelAdministradorState extends State<_PanelAdministrador> {
  final _servicio = ServicioVelia.instancia;

  Future<void> _crearCuenta() async {
    final email = TextEditingController();
    final password = TextEditingController();
    final codigo = TextEditingController();
    var rol = 'cliente';
    var creada = false;
    final resultado = await showDialog<String?>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
              builder: (context, setDialogState) => AlertDialog(
                title: const Text('Crear cuenta'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'Correo @velia.com')),
                  TextField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Contraseña (mínimo 6 caracteres)')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                      value: rol,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: const [
                        DropdownMenuItem(
                            value: 'cliente', child: Text('Cliente / adulto')),
                        DropdownMenuItem(
                            value: 'familiar', child: Text('Familiar'))
                      ],
                      onChanged: (value) {
                        if (value != null) setDialogState(() => rol = value);
                      }),
                  if (rol == 'familiar')
                    TextField(
                        controller: codigo,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                            labelText: 'Código de vinculación del cliente')),
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () async {
                        final error = await _servicio.crearCuenta(
                            email: email.text,
                            password: password.text,
                            rol: rol,
                            codigoVinculacion:
                                rol == 'familiar' ? codigo.text : null);
                        creada = error == null;
                        if (dialogContext.mounted)
                          Navigator.pop(dialogContext, error);
                      },
                      child: const Text('Guardar'))
                ],
              ),
            ));
    final emailCreado = email.text.trim();
    email.dispose();
    password.dispose();
    codigo.dispose();
    if (!mounted) return;
    if (resultado != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(resultado)));
      return;
    }
    if (creada && rol == 'cliente') {
      final nuevoCodigo = _servicio.codigoParaCuenta(emailCreado);
      if (nuevoCodigo != null)
        await showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
                  title: const Text('Código de vinculación'),
                  content: SelectableText(nuevoCodigo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6)),
                  actions: [
                    TextButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: nuevoCodigo));
                          if (dialogContext.mounted)
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                    content: Text('Código copiado.')));
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Copiar')),
                    FilledButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cerrar')),
                  ],
                ));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Administración Velia'), actions: [
          IconButton(
              tooltip: 'Personas y vínculos',
              icon: const Icon(Icons.groups),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          PantallaPersonasVinculos(cuenta: widget.cuenta)))),
          IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: widget.cerrarSesion,
              icon: const Icon(Icons.logout)),
        ]),
        body: AnimatedBuilder(
            animation: _servicio,
            builder: (context, _) {
              final cuentas = _servicio.cuentas;
              return ListView(padding: const EdgeInsets.all(16), children: [
                const Card(
                    child: ListTile(
                        leading: Icon(Icons.admin_panel_settings),
                        title: Text('Administración de cuentas'),
                        subtitle: Text(
                            'El cliente comparte los datos locales solo con familiares cuyo vínculo haya sido autorizado.'))),
                const SizedBox(height: 8),
                ...cuentas.map((cuenta) => Card(
                        child: ListTile(
                      leading: CircleAvatar(
                          child: Icon(cuenta.activa
                              ? Icons.circle
                              : cuenta.rol == 'admin'
                                  ? Icons.shield
                                  : cuenta.rol == 'cliente'
                                      ? Icons.person
                                      : Icons.family_restroom),
                          foregroundColor: cuenta.activa ? Colors.green : null),
                      title: Text(cuenta.email),
                      subtitle: Text(
                          '${cuenta.rol == 'admin' ? 'Administrador' : cuenta.rol == 'cliente' ? 'Cliente / adulto' : 'Familiar'} · ${cuenta.activa ? 'Sesión activa' : 'Sesión cerrada'} · ${cuenta.usos} inicios de sesión${cuenta.ultimaActividad == null ? '' : '\nÚltimo uso: ${cuenta.ultimaActividad}'}'),
                      isThreeLine: cuenta.ultimaActividad != null,
                      trailing: cuenta.rol == 'admin'
                          ? null
                          : IconButton(
                              tooltip: 'Eliminar cuenta',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                await _servicio.eliminarCuenta(cuenta);
                              }),
                    ))),
                const SizedBox(height: 12),
                FilledButton.icon(
                    onPressed: _crearCuenta,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Crear cuenta de cliente o familiar')),
                const SizedBox(height: 20),
                const Text(
                    'Actividad registrada solo en este teléfono. Los familiares no reciben cambios de otros dispositivos sin sincronización en línea.',
                    style: TextStyle(fontSize: 13)),
              ]);
            }),
      );
}
