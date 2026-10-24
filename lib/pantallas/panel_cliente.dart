import 'package:flutter/material.dart';
import '../datos/datos_ejemplo.dart';
import '../tema/colores.dart';
import '../widgets/boton_emergencia.dart';
import '../widgets/menu_lateral.dart';
import 'pantalla_horario.dart';
import 'pantalla_chequeo.dart';
import 'pantalla_calendario.dart';

// Panel del adulto mayor.
class PanelCliente extends StatelessWidget {
  const PanelCliente({super.key});

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
              Text('Velia',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(nombreAdultoMayor, style: TextStyle(fontSize: 13)),
            ],
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.access_time), text: 'Horario'),
              Tab(icon: Icon(Icons.check_circle_outline), text: 'Chequeo'),
              Tab(icon: Icon(Icons.calendar_month), text: 'Calendario'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PantallaHorario(),
            PantallaChequeo(),
            PantallaCalendario(),
          ],
        ),
        floatingActionButton: const BotonEmergencia(),
      ),
    );
  }
}
