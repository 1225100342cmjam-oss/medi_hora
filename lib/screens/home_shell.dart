import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import 'dashboard_admin.dart';
import 'dashboard_paciente.dart';
import 'dashboard_cuidador.dart';
import 'meds_list_screen.dart';
import 'secondary_list_screen.dart';

/// Contenedor con navegación inferior. El dashboard cambia según el rol.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.current!;

    final dashboard = switch (user.rol) {
      Rol.admin => DashboardAdmin(onGoTo: (i) => setState(() => _tab = i)),
      Rol.paciente => DashboardPaciente(onGoTo: (i) => setState(() => _tab = i)),
      Rol.cuidador => DashboardCuidador(onGoTo: (i) => setState(() => _tab = i)),
    };

    final tercerTitulo = switch (user.rol) {
      Rol.admin => 'Usuarios',
      Rol.paciente => 'Historial',
      Rol.cuidador => 'Pacientes',
    };
    final tercerIcono = switch (user.rol) {
      Rol.admin => Icons.groups,
      Rol.paciente => Icons.history,
      Rol.cuidador => Icons.elderly,
    };

    final titulos = ['Inicio', 'Medicamentos', tercerTitulo];

    return Scaffold(
      appBar: AppBar(
        title: Text('MediHora · ${titulos[_tab]}'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AppState>().logout(),
          ),
        ],
      ),
      body: IndexedStack(index: _tab, children: [
        dashboard,
        const MedsListScreen(),
        const SecondaryListScreen(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Inicio'),
          const NavigationDestination(icon: Icon(Icons.medication_outlined), label: 'Medicamentos'),
          NavigationDestination(icon: Icon(tercerIcono), label: tercerTitulo),
        ],
      ),
    );
  }
}
