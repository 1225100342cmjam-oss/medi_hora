
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../theme.dart';
import 'new_cuidador_screen.dart';
import 'ui.dart';

/// Pantalla de cuidadores registrados por el paciente.
class CuidadoresScreen extends StatelessWidget {
  const CuidadoresScreen({super.key});

  Future<void> _confirmarEliminacion(
    BuildContext context,
    dynamic cuidador,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar cuidador'),
        content: Text(
          '¿Seguro que deseas eliminar a ${cuidador.nombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: kRojo,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      context.read<AppState>().deleteCuidador(cuidador);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuidador eliminado correctamente'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final lista = app.misCuidadores;

    return RedPage(
      title: 'Cuidadores',
      fab: BigFab(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NewCuidadorScreen(),
            ),
          );
        },
      ),
      child: PinkCard(
        child: lista.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: kVerde,
                      ),
                      SizedBox(height: 12),
                      CardHeader('Mis cuidadores'),
                      SizedBox(height: 8),
                      Text(
                        'Todavía no tienes cuidadores registrados.\n'
                        'Toca el botón + para agregar uno.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kTextoSecundario,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: lista.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: Colors.black12,
                ),
                itemBuilder: (context, index) {
                  final cuidador = lista[index];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: kVerdeClaro,
                      child: Icon(
                        Icons.person_outline,
                        color: kVerde,
                      ),
                    ),
                    title: Text(
                      cuidador.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: kTinta,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Parentesco: ${cuidador.parentesco}'),
                          const SizedBox(height: 2),
                          Text('Contacto: ${cuidador.contacto}'),
                        ],
                      ),
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      tooltip: 'Opciones del cuidador',
                      onSelected: (opcion) {
                        if (opcion == 'editar') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NewCuidadorScreen(
                                cuidador: cuidador,
                              ),
                            ),
                          );
                        } else if (opcion == 'eliminar') {
                          _confirmarEliminacion(context, cuidador);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'editar',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: kRojo),
                              SizedBox(width: 8),
                              Text('Eliminar'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
