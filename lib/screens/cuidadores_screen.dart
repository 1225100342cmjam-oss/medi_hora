import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import 'new_cuidador_screen.dart';
import 'ui.dart';

/// Pantalla "Cuidador" (lista de cuidadores del paciente).
class CuidadoresScreen extends StatelessWidget {
  const CuidadoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lista = context.watch<AppState>().misCuidadores;
    return RedPage(
      title: 'Cuidadores',
      fab: BigFab(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const NewCuidadorScreen())),
      ),
      child: PinkCard(
        child: lista.isEmpty
            ? const EmptyText('No hay elementos.\nToca "+" para agregar un cuidador.')
            : ListView.builder(
                itemCount: lista.length,
                itemBuilder: (_, i) {
                  final c = lista[i];
                  return Dismissible(
                    key: ValueKey(c.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      color: Colors.red.shade300,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => context.read<AppState>().deleteCuidador(c),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => NewCuidadorScreen(cuidador: c))),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(Icons.edit_outlined, size: 22, color: kTinta),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(c.nombre, style: const TextStyle(fontSize: 15)),
                            Text(c.parentesco,
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                            Text(c.contacto,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ]),
                        ),
                      ]),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
