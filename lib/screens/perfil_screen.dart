import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../security.dart';
import '../theme.dart';

String _fmtFecha(DateTime f) =>
    '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';

String _fmtFechaHora(DateTime f) =>
    '${_fmtFecha(f)} ${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}';

/// Perfil, cambio de contraseña, consentimientos vigentes, exportación y
/// eliminación de datos.
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _telefono;
  late DateTime _fecha;
  bool _editando = false;

  @override
  void initState() {
    super.initState();
    final u = context.read<AppState>().current!;
    _nombre = TextEditingController(text: u.nombre);
    _telefono = TextEditingController(text: u.telefono ?? '');
    _fecha = u.fechaNacimiento;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    super.dispose();
  }

  void _msg(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final f = await showDatePicker(
      context: context,
      initialDate: _fecha.isAfter(hoy) ? hoy : _fecha,
      firstDate: DateTime(hoy.year - 120, 1, 1),
      lastDate: hoy,
      helpText: 'Fecha de nacimiento',
    );
    if (f != null) setState(() => _fecha = f);
  }

  void _guardar() {
    if (!_form.currentState!.validate()) return;
    context.read<AppState>().actualizarPerfil(
          nombre: _nombre.text,
          fechaNacimiento: _fecha,
          telefono: _telefono.text,
        );
    setState(() => _editando = false);
    _msg('Perfil actualizado.');
  }

  Future<void> _cambiarPassword() async {
    final actual = TextEditingController();
    final nueva = TextEditingController();
    final confirmar = TextEditingController();
    final form = GlobalKey<FormState>();
    String? error;
    var cargando = false;

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Cambiar contraseña'),
          content: Form(
            key: form,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: actual,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Contraseña actual'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
                  ),
                  TextFormField(
                    controller: nueva,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Contraseña nueva'),
                    validator: (v) => Seguridad.validarPassword(v ?? ''),
                  ),
                  TextFormField(
                    controller: confirmar,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Confirmar contraseña nueva'),
                    validator: (v) =>
                        v != nueva.text ? 'Las contraseñas no coinciden' : null,
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(error!, style: const TextStyle(color: kRojo)),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  cargando ? null : () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: cargando
                  ? null
                  : () async {
                      if (!form.currentState!.validate()) return;
                      setD(() {
                        cargando = true;
                        error = null;
                      });
                      final err = await context
                          .read<AppState>()
                          .cambiarPassword(actual.text, nueva.text);
                      if (err == null) {
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext, true);
                        }
                      } else {
                        setD(() {
                          cargando = false;
                          error = err;
                        });
                      }
                    },
              child: Text(cargando ? 'Guardando...' : 'Guardar'),
            ),
          ],
        ),
      ),
    );

    actual.dispose();
    nueva.dispose();
    confirmar.dispose();
    if (ok == true && mounted) _msg('Contraseña actualizada.');
  }

  Future<void> _retirarCompartir() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('¿Retirar el consentimiento?'),
        content: const Text(
          'Se revocarán todos tus vínculos con cuidadores y dejarán de ver tu '
          'información. Puedes volver a otorgarlo más adelante.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kRojo),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Retirar'),
          ),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      context.read<AppState>().retirarConsentimientoCompartir();
      _msg('Consentimiento retirado y vínculos revocados.');
    }
  }

  Future<void> _exportar() async {
    final app = context.read<AppState>();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Exportar mis datos'),
        content: const Text(
          'Se copiará a tu portapapeles un archivo de texto (JSON) con tu '
          'perfil, medicamentos, tomas, vínculos, consentimientos y '
          'actividad. Contiene información de salud: guárdalo en un lugar '
          'seguro y no lo compartas sin necesidad.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Copiar datos')),
        ],
      ),
    );
    if (confirmar != true) return;
    await Clipboard.setData(ClipboardData(text: app.exportarDatos()));
    if (mounted) _msg('Tus datos se copiaron al portapapeles.');
  }

  Future<void> _eliminar() async {
    final pass = TextEditingController();
    String? error;
    var cargando = false;

    final eliminado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Eliminar mi cuenta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Se eliminarán tu cuenta, tus medicamentos, tomas, existencias, '
                'vínculos y consentimientos. Esta acción no se puede deshacer. '
                'Escribe tu contraseña para confirmar.',
              ),
              TextField(
                controller: pass,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(error!, style: const TextStyle(color: kRojo)),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed:
                  cargando ? null : () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: kRojo),
              onPressed: cargando
                  ? null
                  : () async {
                      setD(() {
                        cargando = true;
                        error = null;
                      });
                      final err = await context
                          .read<AppState>()
                          .eliminarCuenta(pass.text);
                      if (err == null) {
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext, true);
                        }
                      } else {
                        setD(() {
                          cargando = false;
                          error = err;
                        });
                      }
                    },
              child: Text(cargando ? 'Eliminando...' : 'Eliminar'),
            ),
          ],
        ),
      ),
    );
    pass.dispose();
    if (eliminado == true && mounted) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final u = app.current;
    if (u == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: kFondo,
      appBar: AppBar(
        title: const Text('Perfil y consentimientos'),
        backgroundColor: kPrimario,
        foregroundColor: kBlanco,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          children: [
            _tarjeta(
              titulo: 'Datos personales',
              accion: TextButton(
                onPressed: () => setState(() => _editando = !_editando),
                child: Text(_editando ? 'Cancelar' : 'Editar'),
              ),
              hijo: _editando ? _formulario() : _datos(u),
            ),
            const SizedBox(height: 18),
            _tarjeta(
              titulo: 'Seguridad',
              hijo: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_outline_rounded, color: kPrimario),
                title: const Text('Cambiar contraseña'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _cambiarPassword,
              ),
            ),
            const SizedBox(height: 18),
            _tarjeta(
              titulo: 'Consentimientos',
              hijo: _consentimientos(app, u),
            ),
            const SizedBox(height: 18),
            _tarjeta(
              titulo: 'Mis datos',
              hijo: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.download_rounded, color: kPrimario),
                    title: const Text('Exportar mis datos'),
                    subtitle: const Text('Copia tu información en formato JSON.'),
                    onTap: _exportar,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.delete_forever_rounded, color: kRojo),
                    title: const Text(
                      'Eliminar mi cuenta y mis datos',
                      style: TextStyle(color: kRojo),
                    ),
                    onTap: _eliminar,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'MediHora apoya la organización de medicamentos y no sustituye '
              'las indicaciones de un profesional de la salud.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextoSecundario, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjeta({
    required String titulo,
    required Widget hijo,
    Widget? accion,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kBlanco,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimarioClaro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: kOscuro,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (accion != null) accion,
            ],
          ),
          const SizedBox(height: 8),
          hijo,
        ],
      ),
    );
  }

  Widget _datos(AppUser u) {
    Widget fila(String t, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(t, style: const TextStyle(color: kTextoSecundario)),
              ),
              Expanded(
                child: SelectableText(
                  v,
                  style: const TextStyle(
                      color: kOscuro, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );

    return Column(
      children: [
        fila('Nombre', u.nombre),
        fila('Correo', u.email),
        fila('Teléfono', u.telefono ?? 'Sin registrar'),
        fila('Nacimiento',
            '${_fmtFecha(u.fechaNacimiento)} (${u.edad} años)'),
        if (u.fechaNacimientoEstimada)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Tu fecha de nacimiento es aproximada. Edítala para corregirla.',
              style: TextStyle(color: kNaranja, fontSize: 13),
            ),
          ),
        fila('Tipo de cuenta', u.rol.label),
        fila('Estado', u.estado.label),
      ],
    );
  }

  Widget _formulario() {
    return Form(
      key: _form,
      child: Column(
        children: [
          TextFormField(
            controller: _nombre,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nombre completo'),
            validator: (v) => (v == null || v.trim().length < 3)
                ? 'Escribe tu nombre completo'
                : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _telefono,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Teléfono'),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _elegirFecha,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Fecha de nacimiento'),
              child: Text(_fmtFecha(_fecha)),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _guardar,
              child: const Text('Guardar cambios'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _consentimientos(AppState app, AppUser u) {
    final lista = app.misConsentimientos;
    final compartir = app.tieneConsentimiento(
        u.email, TipoConsentimiento.compartirConCuidadores);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final c in lista)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              c.vigente ? Icons.check_circle_rounded : Icons.cancel_outlined,
              color: c.vigente ? kPrimario : kTextoSecundario,
            ),
            title: Text(c.tipo.label),
            subtitle: Text(
              'Versión ${c.version} · otorgado ${_fmtFechaHora(c.aceptadoEn)}'
              '${c.revocadoEn != null ? '\nRetirado ${_fmtFechaHora(c.revocadoEn!)}' : ''}',
            ),
          ),
        if (u.rol == Rol.paciente) ...[
          const SizedBox(height: 6),
          if (compartir)
            OutlinedButton.icon(
              onPressed: _retirarCompartir,
              icon: const Icon(Icons.block_rounded),
              label: const Text('Retirar consentimiento de compartir'),
              style: OutlinedButton.styleFrom(foregroundColor: kRojo),
            )
          else
            FilledButton.icon(
              onPressed: () {
                context
                    .read<AppState>()
                    .otorgarConsentimiento(TipoConsentimiento.compartirConCuidadores);
                _msg('Consentimiento otorgado.');
              },
              icon: const Icon(Icons.verified_user_outlined),
              label: const Text('Autorizar compartir con cuidadores'),
            ),
        ],
        const SizedBox(height: 8),
        const Text(
          'Para retirar el consentimiento de tratamiento de datos de salud '
          'elimina tu cuenta desde "Mis datos".',
          style: TextStyle(color: kTextoSecundario, fontSize: 12),
        ),
      ],
    );
  }
}

/// Se muestra cuando una cuenta (por ejemplo, creada con una versión
/// anterior) no tiene consentimiento vigente para tratar datos de salud.
class ConsentimientoPendienteScreen extends StatelessWidget {
  const ConsentimientoPendienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return Scaffold(
      backgroundColor: kFondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.privacy_tip_outlined,
                      size: 56, color: kPrimario),
                  const SizedBox(height: 16),
                  const Text(
                    'Necesitamos tu consentimiento',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kOscuro,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'MediHora trata datos de salud (medicamentos, tomas y '
                    'existencias) para darte recordatorios y seguimiento. '
                    'No sustituye las indicaciones de un profesional de la '
                    'salud ni sugiere dosis. Puedes exportar o eliminar tus '
                    'datos cuando quieras.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => app
                        .otorgarConsentimiento(TipoConsentimiento.tratamientoDatosSalud),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Acepto'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: app.logout,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('No acepto (cerrar sesión)'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
