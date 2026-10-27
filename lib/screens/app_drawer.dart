
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import 'configuracion_screen.dart';
import 'cuidadores_screen.dart';
import 'historial_screen.dart';

/// Menú lateral de navegación de MediHora.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final usuario = app.current;

    final w = MediaQuery.of(context).size.width;

    Widget item({
      required String titulo,
      required IconData icono,
      required Widget Function() pagina,
    }) {
      return ListTile(
        leading: Icon(icono, color: kVerdeOscuro),
        title: Text(
          titulo,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: kTinta,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        onTap: () {
          Navigator.pop(context);

          if (usuario == null) return;

          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => pagina()),
          );
        },
      );
    }

    return Drawer(
      width: w,
      backgroundColor: kRojo,
      shape: const RoundedRectangleBorder(),
      child: Row(
        children: [
          // Lado de color rojo con botón para cerrar.
          SizedBox(
            width: w * 0.30,
            child: SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 12,
                    left: 12,
                  ),
                  child: IconButton(
                    tooltip: 'Cerrar menú',
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),

          // Panel de navegación.
          Expanded(
            child: Container(
              color: kRosaMenu,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 24, 12, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: kVerdeClaro,
                            child: Icon(
                              Icons.favorite_outline,
                              size: 30,
                              color: kVerde,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'MediHora',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: kVerdeOscuro,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            usuario?.nombre ?? 'Sin sesión activa',
                            style: const TextStyle(
                              fontSize: 13,
                              color: kTextoSecundario,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (usuario != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              usuario.rol.label,
                              style: const TextStyle(
                                fontSize: 12,
                                color: kTextoSecundario,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const Divider(
                      color: Colors.black12,
                      height: 1,
                    ),

                    item(
                      titulo: 'Historial',
                      icono: Icons.history,
                      pagina: () => const HistorialScreen(),
                    ),

                    if (usuario?.rol == Rol.paciente)
                      item(
                        titulo: 'Cuidadores',
                        icono: Icons.people_outline,
                        pagina: () => const CuidadoresScreen(),
                      ),

                    item(
                      titulo: 'Configuración',
                      icono: Icons.settings_outlined,
                      pagina: () => const ConfiguracionScreen(),
                    ),

                    const Spacer(),

                    const Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        'Tu salud, organizada.',
                        style: TextStyle(
                          fontSize: 12,
                          color: kTextoSecundario,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
