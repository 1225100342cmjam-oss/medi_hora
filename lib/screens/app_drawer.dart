import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import 'configuracion_screen.dart';
import 'cuidadores_screen.dart';
import 'historial_screen.dart';

/// Pantalla "Menú lateral".
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final rol = context.watch<AppState>().current!.rol;
    final nav = Navigator.of(context);

    Widget item(String t, Widget Function() page) => InkWell(
          onTap: () {
            nav.pop();
            nav.push(MaterialPageRoute(builder: (_) => page()));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            child: Text(t, style: const TextStyle(fontSize: 15)),
          ),
        );

    return Drawer(
      width: w,
      backgroundColor: kRojo,
      shape: const RoundedRectangleBorder(),
      child: Row(children: [
        SizedBox(
          width: w * 0.37,
          child: SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, left: 16),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 34, color: kTinta),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: kRosaMenu,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 14, left: 6),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              item('Historial', () => const HistorialScreen()),
              if (rol == Rol.paciente) item('Cuidadores', () => const CuidadoresScreen()),
              item('Configuración', () => const ConfiguracionScreen()),
            ]),
          ),
        ),
      ]),
    );
  }
}
