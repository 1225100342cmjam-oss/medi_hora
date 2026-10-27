
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import 'confirmacion_screen.dart';
import 'new_medicina_screen.dart';

/// Tarjeta de medicamento para las listas de MediHora.
class MedTile extends StatelessWidget {
  final Medicamento med;
  final bool mostrarPaciente;

  const MedTile({
    super.key,
    required this.med,
    this.mostrarPaciente = false,
  });

  Future<bool> _confirmarEliminacion(BuildContext context) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: kRojo,
          size: 34,
        ),
        title: const Text('¿Eliminar medicamento?'),
        content: Text(
          'Se eliminará "${med.nombre}" de tu lista de medicamentos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: kRojo,
              foregroundColor: kBlanco,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    return resultado ?? false;
  }

  void _editar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewMedicinaScreen(med: med),
      ),
    );
  }

  void _cambiarEstado(BuildContext context, bool tomado) {
    final app = context.read<AppState>();

    if (tomado) {
      app.desmarcar(med);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La toma se marcó como pendiente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    // AppState también comprueba que no exista otra toma de hoy.
    final racha = app.marcarTomado(med);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmacionScreen(racha: racha),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tomado = app.tomadoHoy(med);

    return Dismissible(
      key: ValueKey(med.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmarEliminacion(context),
      onDismissed: (_) {
        context.read<AppState>().deleteMed(med);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${med.nombre} eliminado.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: kRojo,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: kBlanco, size: 26),
            SizedBox(height: 4),
            Text(
              'Eliminar',
              style: TextStyle(
                color: kBlanco,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: kBlanco,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: tomado ? kVerdeClaro : Colors.grey.shade200,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono del medicamento
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: kVerdeClaro,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.medication_rounded,
                color: kVerde,
                size: 27,
              ),
            ),

            const SizedBox(width: 12),

            // Datos del medicamento
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kOscuro,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    med.dosis,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kTextoSecundario,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: kVerde,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _formatearHora(context, med.hora),
                        style: const TextStyle(
                          color: kVerde,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  if (mostrarPaciente) ...[
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          color: kTextoSecundario,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            app.nombreDe(med.pacienteEmail),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: kTextoSecundario,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Estado y acción
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _EstadoMedicamento(tomado: tomado),
                      OutlinedButton(
                        onPressed: () => _cambiarEstado(context, tomado),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: tomado ? kNaranja : kVerde,
                          side: BorderSide(
                            color: tomado ? kNaranja : kVerde,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          minimumSize: const Size(0, 34),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          tomado ? 'Desmarcar' : 'Registrar toma',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Acciones adicionales
            PopupMenuButton<String>(
              tooltip: 'Opciones del medicamento',
              icon: const Icon(
                Icons.more_vert_rounded,
                color: kTextoSecundario,
              ),
              onSelected: (opcion) {
                if (opcion == 'editar') {
                  _editar(context);
                } else if (opcion == 'eliminar') {
                  _confirmarEliminacion(context).then((confirmado) {
                    if (confirmado && context.mounted) {
                      context.read<AppState>().deleteMed(med);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${med.nombre} eliminado.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  });
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 10),
                      Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'eliminar',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: kRojo),
                      SizedBox(width: 10),
                      Text('Eliminar'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatearHora(BuildContext context, String hora) {
    final partes = hora.split(':');

    if (partes.length != 2) return hora;

    final h = int.tryParse(partes[0]);
    final m = int.tryParse(partes[1]);

    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
      return hora;
    }

    return TimeOfDay(hour: h, minute: m).format(context);
  }
}

class _EstadoMedicamento extends StatelessWidget {
  final bool tomado;

  const _EstadoMedicamento({required this.tomado});

  @override
  Widget build(BuildContext context) {
    final color = tomado ? kVerde : kNaranja;
    final fondo = tomado ? kVerdeClaro : const Color(0xFFFFF1DB);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tomado ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            tomado ? 'Tomado' : 'Pendiente',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista reutilizable para las pantallas de MediHora.
class MedList extends StatelessWidget {
  final List<Medicamento> meds;
  final bool mostrarPaciente;

  const MedList({
    super.key,
    required this.meds,
    this.mostrarPaciente = false,
  });

  @override
  Widget build(BuildContext context) {
    if (meds.isEmpty) {
      return Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: kBlanco,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kVerdeClaro),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.medication_outlined,
                color: kVerde,
                size: 48,
              ),
              SizedBox(height: 12),
              Text(
                'Tu lista está vacía',
                style: TextStyle(
                  color: kOscuro,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Agrega un medicamento para comenzar a organizar tus recordatorios.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kTextoSecundario,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: meds.length,
      itemBuilder: (context, index) {
        return MedTile(
          key: ValueKey(meds[index].id),
          med: meds[index],
          mostrarPaciente: mostrarPaciente,
        );
      },
    );
  }
}
