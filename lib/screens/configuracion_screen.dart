
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../services/reporte_medico_service.dart';
import 'cuidadores_screen.dart';
import 'notificacion_screen.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  Future<void> _descargarReporte(
    BuildContext context,
    AppUser paciente,
  ) async {
    final app = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);

    // Solo se incluyen datos del paciente que inició sesión.
    final medicamentos = app.medsDe(paciente.email);
    final tomas = app.tomas
        .where((t) => t.pacienteEmail == paciente.email)
        .toList();

    try {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Generando reporte médico...'),
          duration: Duration(seconds: 2),
        ),
      );

      final bytes = await ReporteMedicoService.generar(
        paciente: paciente,
        medicamentos: medicamentos,
        tomas: tomas,
      );

      if (!context.mounted) return;

      final nombre = paciente.nombre
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'reporte_medicamentos_${nombre.isEmpty ? 'paciente' : nombre}.pdf',
      );
    } catch (e) {
      if (!context.mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo generar el reporte. Inténtalo de nuevo.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
          'Tendrás que iniciar sesión nuevamente para entrar a MediHora.',
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
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmar != true || !context.mounted) return;

    context.read<AppState>().logout();

    if (!context.mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final usuario = app.current;

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: kFondo,
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: kPrimario,
        foregroundColor: kBlanco,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
          children: [
            // Perfil
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kBlanco,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kPrimarioClaro),
              ),
              child: Column(
                children: [
                  Container(
                    width: 95,
                    height: 95,
                    decoration: const BoxDecoration(
                      color: kPrimarioClaro,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 56,
                      color: kPrimario,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    usuario.nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: kOscuro,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimarioClaro,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      usuario.rol.label,
                      style: const TextStyle(
                        color: kPrimarioOscuro,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            const Text(
              'Datos de tu cuenta',
              style: TextStyle(
                color: kOscuro,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: kBlanco,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _DatoUsuario(
                    icono: Icons.badge_outlined,
                    titulo: 'Nombre completo',
                    valor: usuario.nombre,
                  ),
                  const Divider(height: 1),
                  _DatoUsuario(
                    icono: Icons.cake_outlined,
                    titulo: 'Edad',
                    valor: '${usuario.edad} años',
                  ),
                  const Divider(height: 1),
                  _DatoUsuario(
                    icono: Icons.email_outlined,
                    titulo: 'Correo electrónico',
                    valor: usuario.email,
                  ),
                  const Divider(height: 1),
                  _DatoUsuario(
                    icono: Icons.verified_user_outlined,
                    titulo: 'Tipo de cuenta',
                    valor: usuario.rol.label,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // Cuidadores: antes estaba en el menú lateral.
            if (usuario.rol == Rol.paciente) ...[
              const Text(
                'Mis cuidadores',
                style: TextStyle(
                  color: kOscuro,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: kBlanco,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kPrimarioClaro),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: kPrimarioClaro,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.people_outline_rounded,
                      color: kPrimario,
                      size: 27,
                    ),
                  ),
                  title: const Text(
                    'Administrar cuidadores',
                    style: TextStyle(
                      color: kOscuro,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${app.misCuidadores.length} registrados',
                    style: const TextStyle(color: kTextoSecundario),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: kTextoSecundario,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CuidadoresScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
            ],

            // Reporte médico: disponible para el paciente.
            if (usuario.rol == Rol.paciente) ...[
              const Text(
                'Reporte médico',
                style: TextStyle(
                  color: kOscuro,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: kBlanco,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kPrimarioClaro),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: kPrimarioClaro,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: kPrimario,
                        size: 27,
                      ),
                    ),
                    const SizedBox(height: 13),
                    const Text(
                      'Descarga tu reporte de medicamentos',
                      style: TextStyle(
                        color: kOscuro,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Incluye tus datos, medicamentos registrados, dosis, '
                      'horarios, historial de tomas y un resumen del día.',
                      style: TextStyle(
                        color: kTextoSecundario,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _descargarReporte(
                          context,
                          usuario,
                        ),
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Descargar reporte PDF'),
                        style: FilledButton.styleFrom(
                          backgroundColor: kPrimario,
                          foregroundColor: kBlanco,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Podrás guardar o compartir el documento según las opciones disponibles en tu dispositivo.',
                      style: TextStyle(
                        color: kTextoSecundario,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
            ],

            // Recordatorio de prueba
            if (usuario.rol == Rol.paciente) ...[
              const Text(
                'Recordatorios',
                style: TextStyle(
                  color: kOscuro,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: kBlanco,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kPrimarioClaro),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Probar un recordatorio',
                      style: TextStyle(
                        color: kOscuro,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Abre un recordatorio de uno de tus medicamentos pendientes.',
                      style: TextStyle(
                        color: kTextoSecundario,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final pendientes = app.visibleMeds
                              .where((m) => !app.tomadoHoy(m))
                              .toList();

                          if (pendientes.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No tienes medicamentos pendientes hoy.',
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NotificacionScreen(
                                med: pendientes.first,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.notifications_outlined),
                        label: const Text('Probar recordatorio'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kPrimario,
                          side: const BorderSide(color: kPrimario),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
            ],

            OutlinedButton.icon(
              onPressed: () => _cerrarSesion(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kRojo,
                side: const BorderSide(color: kRojo),
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Center(
              child: Text(
                'MediHora · Tu salud, organizada',
                style: TextStyle(
                  color: kTextoSecundario,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatoUsuario extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _DatoUsuario({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kPrimarioClaro,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: kPrimario, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: kTextoSecundario,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  valor,
                  style: const TextStyle(
                    color: kOscuro,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
