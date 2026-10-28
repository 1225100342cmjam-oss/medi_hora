import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import 'botiquin_screen.dart';
import 'configuracion_screen.dart';
import 'dashboard_admin.dart';
import 'dashboard_cuidador.dart';
import 'dashboard_paciente.dart';
import 'historial_screen.dart';
import 'new_medicina_screen.dart';
import 'racha_screen.dart';
import 'ui.dart';

/// Pantalla principal: muestra el dashboard que corresponde al rol del
/// usuario y la barra inferior de navegación
/// (Inicio · Botiquín · Racha · Historial · Ajustes).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pestana = 0;

  void _agregarMedicina(AppState app) {
    final usuario = app.current;
    if (usuario == null) return;

    // Cuidador y administrador eligen un paciente: debe existir al menos uno.
    if (usuario.rol != Rol.paciente && app.pacientes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aún no hay pacientes registrados.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewMedicinaScreen()),
    );
  }

  Widget _dashboardDe(Rol rol) {
    return switch (rol) {
      Rol.paciente => const DashboardPaciente(),
      Rol.cuidador => const DashboardCuidador(),
      Rol.admin => const DashboardAdmin(),
    };
  }

  Widget _inicio(AppState app, AppUser usuario) {
    return Scaffold(
      backgroundColor: kFondo,
      appBar: AppBar(
        title: const Text('MediHora'),
        backgroundColor: kPrimario,
        foregroundColor: kBlanco,
        elevation: 0,
      ),
      floatingActionButton: BigFab(onPressed: () => _agregarMedicina(app)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner de bienvenida
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: kPrimario,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: kBlanco.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.waving_hand_rounded,
                        color: kBlanco,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola, ${usuario.nombre}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: kBlanco,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            usuario.rol.label,
                            style: TextStyle(
                              color: kBlanco.withValues(alpha: 0.88),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Espacio inferior para que el botón + no tape la lista.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 84),
                  child: _dashboardDe(usuario.rol),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final usuario = app.current;

    // AuthGate muestra el login cuando no hay sesión.
    if (usuario == null) return const SizedBox.shrink();

    return Scaffold(
      body: IndexedStack(
        index: _pestana,
        children: [
          _inicio(app, usuario),
          const BotiquinScreen(),
          const RachaScreen(),
          const HistorialScreen(),
          const ConfiguracionScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestana,
        onDestinationSelected: (i) => setState(() => _pestana = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_liquid_outlined),
            selectedIcon: Icon(Icons.medication_liquid_rounded),
            label: 'Botiquín',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_outlined),
            selectedIcon: Icon(Icons.local_fire_department_rounded),
            label: 'Racha',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
