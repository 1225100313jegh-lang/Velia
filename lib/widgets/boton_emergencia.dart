import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../pantallas/pantalla_ajustes.dart';
import '../servicios/servicio_velia.dart';

class BotonEmergencia extends StatelessWidget {
  const BotonEmergencia({super.key});

  Future<void> _abrir(BuildContext context, Uri uri) async {
    final abierto = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!abierto && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la app de llamadas o mensajes.')),
      );
    }
  }

  Future<void> _configurar(BuildContext context) async {
    await Navigator.push<void>(context,
        MaterialPageRoute(builder: (_) => const PantallaAjustes()));
  }

  Future<void> _mostrarContactos(BuildContext context) async {
    final contactos = ServicioVelia.instancia.telefonosEmergencia;
    if (contactos.isEmpty) {
      await showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.contact_phone),
        title: const Text('Agrega un contacto de emergencia'),
        content: const Text('Guarda uno o varios teléfonos en Ajustes. Velia abrirá la llamada o el SMS para que confirmes.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Ahora no')),
          FilledButton(onPressed: () { Navigator.pop(dialogContext); _configurar(context); }, child: const Text('Configurar')),
        ],
      ));
      return;
    }
    await showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
      title: const Text('Contactar en una emergencia'),
      content: SizedBox(width: 420, child: ListView(shrinkWrap: true, children: [
        const Text('El teléfono abrirá la llamada o el mensaje. Confirma antes de enviarlo.'),
        const SizedBox(height: 12),
        ...contactos.map((numero) => Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Column(children: [
          ListTile(leading: const Icon(Icons.person), title: Text(numero), subtitle: const Text('Contacto de emergencia')),
          Wrap(alignment: WrapAlignment.end, children: [
            TextButton.icon(onPressed: () { Navigator.pop(dialogContext); _abrir(context, Uri(scheme: 'tel', path: numero)); }, icon: const Icon(Icons.call), label: const Text('Llamar')),
            TextButton.icon(onPressed: () { Navigator.pop(dialogContext); _abrir(context, Uri(scheme: 'sms', path: numero, queryParameters: {'body': 'Necesito ayuda. Por favor comunícate conmigo.'})); }, icon: const Icon(Icons.sms), label: const Text('Enviar SMS')),
          ]),
        ])))),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cerrar'))],
    ));
  }

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
    backgroundColor: Colors.red.shade700,
    foregroundColor: Colors.white,
    icon: const Icon(Icons.warning_amber_rounded),
    label: const Text('EMERGENCIA'),
    onPressed: () => _mostrarContactos(context),
  );
}
