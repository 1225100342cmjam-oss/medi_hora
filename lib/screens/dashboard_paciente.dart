
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import 'med_tile.dart';
import 'ui.dart';

/// DASHBOARD 1 · Paciente → Mis medicinas
class DashboardPaciente extends StatelessWidget {
  const DashboardPaciente({super.key});

  @override
  Widget build(BuildContext context) {
    final meds = context.watch<AppState>().visibleMeds;

    return PinkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader('Mis medicinas'),
          const SizedBox(height: 12),

          Expanded(
            child: meds.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No tienes medicinas registradas.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : MedList(meds: meds),
          ),

          const Divider(
            color: Colors.black26,
            height: 1,
          ),
        ],
      ),
    );
  }
}
