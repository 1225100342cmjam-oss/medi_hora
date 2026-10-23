import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'med_tile.dart';
import 'ui.dart';

/// DASHBOARD 1 · Paciente  →  "Mis medicinas"
class DashboardPaciente extends StatelessWidget {
  const DashboardPaciente({super.key});

  @override
  Widget build(BuildContext context) {
    final meds = context.watch<AppState>().visibleMeds;
    return PinkCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const CardHeader('Mis medicinas'),
        Expanded(child: MedList(meds: meds)),
        const Divider(color: Colors.black54, height: 1),
      ]),
    );
  }
}
