import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../datos/datos_ejemplo.dart';
import '../estado/estado_app.dart';
import '../tema/colores.dart';
import '../utilidades/formatos.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/menu_lateral.dart';
import 'pantalla_horario.dart';
import 'pantalla_calendario.dart';

// Panel familiar.
class PanelFamiliar extends StatelessWidget {
  const PanelFamiliar({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: const MenuLateral(),
        appBar: AppBar(
          backgroundColor: colorNaranja,
          foregroundColor: Colors.white,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Panel familiar',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('Cuidando a $nombreAdultoMayor',
                  style: TextStyle(fontSize: 13)),
            ],
          ),
          bottom: TabBar(
            onTap: (indice) {
              if (indice == 0) {
                context.read<EstadoApp>().marcarAvisosLeidos();
              }
            },
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                icon: Badge(
                  label: Text('${context.watch<EstadoApp>().avisosPendientes}'),
                  isLabelVisible:
                      context.watch<EstadoApp>().avisosPendientes > 0,
                  child: const Icon(Icons.notifications_active),
                ),
                text: 'Avisos',
              ),
              Tab(icon: Icon(Icons.access_time), text: 'Horario'),
              Tab(icon: Icon(Icons.calendar_month), text: 'Calendario'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ResumenFamiliar(),
            PantallaHorario(),
            PantallaCalendario(),
          ],
        ),
      ),
    );
  }
}

// Resumen e historial de avisos.
class _ResumenFamiliar extends StatelessWidget {
  const _ResumenFamiliar();

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoApp>();
    final ultimoAviso = estado.ultimoAviso;
    final proxima = estado.proximaPastilla;
    final avisos = estado.avisosBienestar;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: ultimoAviso == null
              ? Colors.orange.shade100
              : Colors.green.shade50,
          child: ListTile(
            leading: Icon(
              ultimoAviso == null ? Icons.help_outline : Icons.check_circle,
              size: 40,
              color: ultimoAviso == null ? colorNaranja : Colors.green.shade600,
            ),
            title: const Text('Estado de hoy',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(ultimoAviso == null
                ? 'Todavía no hay avisos "Estoy bien".'
                : 'Último aviso: ${describirMomento(ultimoAviso)}'),
          ),
        ),
        const SizedBox(height: 8),
        if (proxima != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.medication_liquid,
                  size: 36, color: colorNaranja),
              title: const Text('Próxima pastilla',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${proxima.nombre} · ${proxima.dosis}'),
              trailing: Text(formatearHora(proxima.hora),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        const SizedBox(height: 16),
        const Text('Historial de avisos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (avisos.isEmpty)
          const EstadoVacio(
            icono: Icons.notifications_none,
            titulo: 'Sin avisos',
            mensaje:
                'Cuando el adulto mayor toque "Estoy bien" aparecerá aquí.',
          )
        else
          ...avisos.map(
            (aviso) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green.shade600),
                title: const Text('Estoy bien'),
                subtitle: Text(describirMomento(aviso)),
              ),
            ),
          ),
      ],
    );
  }
}
