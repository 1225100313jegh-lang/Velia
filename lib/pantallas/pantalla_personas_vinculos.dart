import 'package:flutter/material.dart';
import '../servicios/servicio_velia.dart';

class PantallaPersonasVinculos extends StatelessWidget {
  final CuentaLocalVelia cuenta;
  const PantallaPersonasVinculos({super.key, required this.cuenta});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: ServicioVelia.instancia,
        builder: (context, _) {
          final servicio = ServicioVelia.instancia;
          final admin = cuenta.rol == 'admin';
          final cliente = cuenta.rol == 'cliente' || cuenta.rol == 'adulto';
          final adultos = servicio.cuentas
              .where((c) =>
                  (c.rol == 'cliente' || c.rol == 'adulto') &&
                  (admin ||
                      (cliente && c.email == cuenta.email) ||
                      (cuenta.rol == 'familiar' &&
                          cuenta.estadoVinculo == 'autorizado' &&
                          c.email == cuenta.adultoVinculado)))
              .toList();
          final familiares = servicio.cuentas
              .where((c) =>
                  c.rol == 'familiar' &&
                  (admin ||
                      (cliente && c.adultoVinculado == cuenta.email) ||
                      c.email == cuenta.email))
              .toList();

          return Scaffold(
            appBar: AppBar(title: const Text('Personas y vínculos')),
            body: ListView(padding: const EdgeInsets.all(16), children: [
              const Text('Adultos mayores',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              if (adultos.isEmpty)
                const Card(
                    child: ListTile(
                        title:
                            Text('No hay adultos vinculados a esta cuenta.'))),
              ...adultos.map((adulto) => Card(
                      child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.elderly)),
                    title: Text(
                        adulto.nombre.isEmpty ? adulto.email : adulto.nombre),
                    subtitle: Text(
                        'Nacimiento: ${adulto.fechaNacimiento.isEmpty ? 'Sin registrar' : adulto.fechaNacimiento}\nVínculo: ${_estadoAdulto(servicio.cuentas, adulto.email)}'),
                    isThreeLine: true,
                    onTap: () => _detalle(context, adulto),
                    trailing: admin || (cliente && adulto.email == cuenta.email)
                        ? IconButton(
                            tooltip: 'Editar perfil',
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editarAdulto(context, adulto))
                        : null,
                  ))),
              if (admin || cliente) ...[
                const SizedBox(height: 18),
                const Text('Familiares',
                    style:
                        TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                if (familiares.isEmpty)
                  const Card(
                      child: ListTile(
                          title: Text('Aún no hay familiares registrados.'))),
                ...familiares.map((familiar) => Card(
                        child: ListTile(
                      leading: const CircleAvatar(
                          child: Icon(Icons.family_restroom)),
                      title: Text(familiar.nombre.isEmpty
                          ? familiar.email
                          : familiar.nombre),
                      subtitle: Text(
                          '${familiar.parentesco.isEmpty ? 'Parentesco sin registrar' : familiar.parentesco} · ${familiar.tipoContacto.isEmpty ? 'Contacto sin registrar' : familiar.tipoContacto}\n${familiar.datoContacto}\nVínculo: ${familiar.estadoVinculo}'),
                      isThreeLine: true,
                      trailing: Wrap(children: [
                        if (familiar.estadoVinculo == 'pendiente')
                          IconButton(
                              tooltip: 'Autorizar vínculo',
                              icon: const Icon(Icons.check_circle,
                                  color: Colors.green),
                              onPressed: () =>
                                  servicio.autorizarVinculo(familiar.email)),
                        if (admin ||
                            (cliente &&
                                familiar.adultoVinculado == cuenta.email) ||
                            familiar.email == cuenta.email)
                          IconButton(
                              tooltip: 'Editar perfil',
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _editarFamiliar(context, familiar)),
                      ]),
                    ))),
              ],
              if (admin || cliente) ...[
                const SizedBox(height: 18),
                const Text('Vínculos',
                    style:
                        TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                ...familiares
                    .where((f) => admin || f.adultoVinculado == cuenta.email)
                    .map((familiar) => Card(
                          child: ListTile(
                            leading: Icon(
                                familiar.estadoVinculo == 'autorizado'
                                    ? Icons.link
                                    : Icons.link_off,
                                color: familiar.estadoVinculo == 'autorizado'
                                    ? Colors.green
                                    : Colors.orange),
                            title: Text(
                                '${familiar.nombre} → ${_nombreAdulto(servicio.cuentas, familiar.adultoVinculado)}'),
                            subtitle: Text(
                                familiar.estadoVinculo == 'autorizado'
                                    ? 'Autorizado'
                                    : 'Pendiente de autorización'),
                            trailing: familiar.estadoVinculo == 'autorizado'
                                ? IconButton(
                                    tooltip: 'Desvincular familiar',
                                    icon: const Icon(Icons.person_remove_alt_1),
                                    onPressed: () => _confirmarDesvincular(
                                        context, familiar))
                                : null,
                          ),
                        )),
              ],
              if (cuenta.rol == 'familiar') ...[
                const SizedBox(height: 18),
                Card(
                    child: ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: Text(cuenta.nombre),
                  subtitle: Text(
                      '${cuenta.parentesco} · ${cuenta.tipoContacto}\n${cuenta.datoContacto}'),
                  isThreeLine: true,
                  trailing: IconButton(
                      tooltip: 'Editar mi perfil',
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editarFamiliar(context, cuenta)),
                )),
              ],
              const SizedBox(height: 20),
              const Text(
                  'Los perfiles y permisos se guardan localmente en este teléfono.',
                  style: TextStyle(fontSize: 13)),
            ]),
          );
        },
      );

  static String _estadoAdulto(List<CuentaLocalVelia> cuentas, String email) {
    final relacionados =
        cuentas.where((c) => c.rol == 'familiar' && c.adultoVinculado == email);
    final autorizados =
        relacionados.where((c) => c.estadoVinculo == 'autorizado').length;
    final pendientes =
        relacionados.where((c) => c.estadoVinculo == 'pendiente').length;
    return '$autorizados autorizados · $pendientes pendientes';
  }

  static String _nombreAdulto(List<CuentaLocalVelia> cuentas, String email) {
    for (final cuenta in cuentas) {
      if (cuenta.email == email)
        return cuenta.nombre.isEmpty ? email : cuenta.nombre;
    }
    return 'Adulto mayor';
  }

  Future<void> _confirmarDesvincular(
      BuildContext context, CuentaLocalVelia familiar) async {
    final confirmar = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
              title: const Text('Desvincular familiar'),
              content: Text(
                  '¿Desvincular a ${familiar.nombre}? Dejará de acceder a la información de este adulto.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialog, false),
                    child: const Text('Cancelar')),
                FilledButton(
                    onPressed: () => Navigator.pop(dialog, true),
                    child: const Text('Desvincular'))
              ],
            ));
    if (confirmar == true)
      await ServicioVelia.instancia.desvincularFamiliar(familiar.email);
  }

  Future<void> _editarAdulto(
      BuildContext context, CuentaLocalVelia adulto) async {
    final nombre = TextEditingController(text: adulto.nombre);
    final fecha = TextEditingController(text: adulto.fechaNacimiento);
    final telefono = TextEditingController(text: adulto.telefonoEmergencia);
    final guardar = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
              title: const Text('Perfil del adulto mayor'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                    controller: nombre,
                    decoration: const InputDecoration(labelText: 'Nombre')),
                TextField(
                    controller: fecha,
                    readOnly: true,
                    decoration: const InputDecoration(
                        labelText: 'Fecha de nacimiento',
                        suffixIcon: Icon(Icons.calendar_month)),
                    onTap: () async {
                      final initial =
                          DateTime.tryParse(fecha.text) ?? DateTime(1950);
                      final seleccion = await showDatePicker(
                          context: dialog,
                          initialDate: initial,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now());
                      if (seleccion != null)
                        fecha.text =
                            '${seleccion.year}-${seleccion.month.toString().padLeft(2, '0')}-${seleccion.day.toString().padLeft(2, '0')}';
                    }),
                TextField(
                    controller: telefono,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: 'Teléfono de emergencia')),
              ]),
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
          email: adulto.email,
          nombre: nombre.text,
          fechaNacimiento: fecha.text,
          telefonoEmergencia: telefono.text);
    nombre.dispose();
    fecha.dispose();
    telefono.dispose();
  }

  Future<void> _editarFamiliar(
      BuildContext context, CuentaLocalVelia familiar) async {
    final nombre = TextEditingController(text: familiar.nombre);
    final parentesco = TextEditingController(text: familiar.parentesco);
    final contacto = TextEditingController(text: familiar.datoContacto);
    var tipo =
        familiar.tipoContacto.isEmpty ? 'Teléfono' : familiar.tipoContacto;
    final guardar = await showDialog<bool>(
        context: context,
        builder: (dialog) => StatefulBuilder(
              builder: (context, actualizar) => AlertDialog(
                title: const Text('Perfil del familiar'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: nombre,
                      decoration: const InputDecoration(labelText: 'Nombre')),
                  TextField(
                      controller: parentesco,
                      decoration:
                          const InputDecoration(labelText: 'Parentesco')),
                  DropdownButtonFormField<String>(
                      value: tipo,
                      decoration:
                          const InputDecoration(labelText: 'Tipo de contacto'),
                      items: const [
                        DropdownMenuItem(
                            value: 'Teléfono', child: Text('Teléfono')),
                        DropdownMenuItem(
                            value: 'Correo', child: Text('Correo')),
                        DropdownMenuItem(value: 'Otro', child: Text('Otro'))
                      ],
                      onChanged: (value) {
                        if (value != null) actualizar(() => tipo = value);
                      }),
                  TextField(
                      controller: contacto,
                      decoration:
                          const InputDecoration(labelText: 'Dato de contacto')),
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialog, false),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialog, true),
                      child: const Text('Guardar'))
                ],
              ),
            ));
    if (guardar == true)
      await ServicioVelia.instancia.guardarPerfil(
          email: familiar.email,
          nombre: nombre.text,
          parentesco: parentesco.text,
          tipoContacto: tipo,
          datoContacto: contacto.text);
    nombre.dispose();
    parentesco.dispose();
    contacto.dispose();
  }

  Future<void> _detalle(BuildContext context, CuentaLocalVelia adulto) async {
    final servicio = ServicioVelia.instancia;
    if (cuenta.rol == 'admin') await servicio.activarCuenta(adulto.email);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => SafeArea(
                child: ListView(padding: const EdgeInsets.all(20), children: [
              Text(adulto.nombre.isEmpty ? adulto.email : adulto.nombre,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text(
                  'Nacimiento: ${adulto.fechaNacimiento.isEmpty ? 'Sin registrar' : adulto.fechaNacimiento}'),
              Text(
                  'Emergencia: ${adulto.telefonoEmergencia.isEmpty ? 'Sin registrar' : adulto.telefonoEmergencia}'),
              const SizedBox(height: 14),
              const Text('Medicamentos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...servicio.medicamentos.map((m) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.medication),
                  title: Text(m.nombre),
                  subtitle: Text(
                      '${m.dosis} · ${m.hora.toString().padLeft(2, '0')}:${m.minuto.toString().padLeft(2, '0')}'))),
              const SizedBox(height: 8),
              const Text('Eventos y citas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...servicio.eventos.map((e) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.event),
                  title: Text(e.titulo),
                  subtitle: Text(ServicioVelia.formatearFecha(e.fecha)))),
              const SizedBox(height: 8),
              const Text('Avisos recientes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...servicio.historial.take(8).map((e) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.notifications),
                  title: Text(e['detalle'] as String),
                  subtitle: Text(e['fecha'] as String))),
              const SizedBox(height: 8),
              const Text('Alertas relacionadas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListTile(
                leading: Icon(servicio.notificacionesActivas
                    ? Icons.notifications_active
                    : Icons.notifications_off),
                title: Text(servicio.notificacionesActivas
                    ? 'Recordatorios activos'
                    : 'Notificaciones desactivadas'),
                subtitle: Text(
                    '${servicio.eventos.where((e) => e.tipo == 'cita').length} citas · ${servicio.medicamentos.length} recordatorios de medicamentos'),
              ),
            ])));
  }
}
