import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'secure_store.dart';
import 'security.dart';

bool mismoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Resumen del día de un paciente, limitado a lo que el vínculo autoriza.
/// Los campos son `null` cuando el cuidador no tiene permiso para verlos.
class ResumenPaciente {
  final int? totalMedicamentos, pendientesHoy, omitidasHoy, existenciasBajas;
  const ResumenPaciente({
    this.totalMedicamentos,
    this.pendientesHoy,
    this.omitidasHoy,
    this.existenciasBajas,
  });
}

class _Intentos {
  int fallos = 0;
  DateTime? bloqueadoHasta;
}

/// Manejo de estado: Provider (ChangeNotifier) + persistencia cifrada.
class AppState extends ChangeNotifier {
  final SecureStore _store = SecureStore();

  List<AppUser> users = [];
  List<Medicamento> meds = [];
  List<Cuidador> cuidadores = [];
  List<Toma> tomas = [];
  List<Consentimiento> consentimientos = [];
  final Map<String, ConfiguracionGeneral> _configs = {};
  List<EntradaBitacora> _bitacora = [];

  /// Existencias del botiquín: id de medicamento -> unidades disponibles.
  Map<String, int> existencias = {};
  AppUser? current;

  /// Recordatorios pospuestos: id de medicamento -> hasta cuándo.
  final Map<String, DateTime> snoozeUntil = {};

  final Map<String, _Intentos> _intentos = {};
  static const int _maxIntentos = 5;
  static const Duration _bloqueo = Duration(minutes: 5);

  /// Minutos de tolerancia para considerar una toma "a tiempo".
  static const int toleranciaTomaMin = 60;

  int _seq = 0;
  String _id() => '${DateTime.now().microsecondsSinceEpoch}${_seq++}';

  // ---------- Persistencia ----------
  Future<void> load() async {
    await _migrarDesdePreferencias();

    Future<List<dynamic>> l(String k) async =>
        jsonDecode(await _store.read(k) ?? '[]') as List;

    users = (await l('users')).map((e) => AppUser.fromJson(e)).toList();
    meds = (await l('meds')).map((e) => Medicamento.fromJson(e)).toList();
    cuidadores =
        (await l('cuidadores')).map((e) => Cuidador.fromJson(e)).toList();
    tomas = (await l('tomas')).map((e) => Toma.fromJson(e)).toList();
    consentimientos = (await l('consentimientos'))
        .map((e) => Consentimiento.fromJson(e))
        .toList();
    _bitacora =
        (await l('bitacora')).map((e) => EntradaBitacora.fromJson(e)).toList();

    final ex = jsonDecode(await _store.read('existencias') ?? '{}')
        as Map<String, dynamic>;
    existencias = ex.map((k, v) => MapEntry(k, (v as num).toInt()));

    final cfg =
        jsonDecode(await _store.read('configs') ?? '{}') as Map<String, dynamic>;
    _configs
      ..clear()
      ..addAll(cfg.map((k, v) =>
          MapEntry(k, ConfiguracionGeneral.fromJson(v as Map<String, dynamic>))));

    final sn =
        jsonDecode(await _store.read('snooze') ?? '{}') as Map<String, dynamic>;
    snoozeUntil
      ..clear()
      ..addAll(sn.map((k, v) => MapEntry(k, DateTime.parse(v as String))));

    // Migración: contraseñas guardadas en texto legible por versiones previas.
    var migrado = false;
    for (final u in users) {
      final antigua = u.legacyPassword;
      if (antigua != null) {
        await _asignarPassword(u, antigua);
        u.legacyPassword = null;
        migrado = true;
      }
    }
    if (migrado) await _guardar();

    final session = await _store.read('session');
    for (final u in users) {
      if (u.email == session && u.estado == EstadoCuenta.activa) current = u;
    }
  }

  /// Mueve los datos de SharedPreferences (sin cifrar) al almacén cifrado y
  /// borra los originales.
  Future<void> _migrarDesdePreferencias() async {
    if (await _store.read('schema') != null) return;
    final p = await SharedPreferences.getInstance();
    const claves = ['users', 'meds', 'cuidadores', 'tomas', 'existencias'];
    for (final k in claves) {
      final v = p.getString(k);
      if (v != null) await _store.write(k, v);
    }
    await _store.write('schema', '2');
    for (final k in [...claves, 'session']) {
      await p.remove(k);
    }
  }

  Future<void> _asignarPassword(AppUser u, String password) async {
    final sal = Seguridad.nuevaSal();
    u.passwordSalt = sal;
    u.passwordIter = Seguridad.iteraciones;
    u.passwordHash = await Seguridad.hash(password, sal, Seguridad.iteraciones);
  }

  Future<void> _guardando = Future.value();

  Future<void> _guardar() {
    _guardando = _guardando.then((_) async {
      String j(List<Map<String, dynamic>> l) => jsonEncode(l);
      await _store.write('users', j(users.map((e) => e.toJson()).toList()));
      await _store.write('meds', j(meds.map((e) => e.toJson()).toList()));
      await _store.write(
          'cuidadores', j(cuidadores.map((e) => e.toJson()).toList()));
      await _store.write('tomas', j(tomas.map((e) => e.toJson()).toList()));
      await _store.write('consentimientos',
          j(consentimientos.map((e) => e.toJson()).toList()));
      await _store.write(
          'bitacora', j(_bitacora.map((e) => e.toJson()).toList()));
      await _store.write('existencias', jsonEncode(existencias));
      await _store.write('configs',
          jsonEncode(_configs.map((k, v) => MapEntry(k, v.toJson()))));
      await _store.write(
          'snooze',
          jsonEncode(
              snoozeUntil.map((k, v) => MapEntry(k, v.toIso8601String()))));
      if (current == null) {
        await _store.delete('session');
      } else {
        await _store.write('session', current!.email);
      }
    });
    return _guardando;
  }

  /// Espera a que terminen las escrituras pendientes (útil al cerrar la app
  /// o en pruebas).
  Future<void> esperarGuardado() => _guardando;

  void _changed() {
    _guardar();
    notifyListeners();
  }

  // ---------- Bitácora ----------
  /// Lista de solo lectura. No existe ninguna operación para editarla.
  List<EntradaBitacora> get bitacoraCompleta => List.unmodifiable(_bitacora);

  void _log(
    AccionBitacora accion, {
    String? paciente,
    String? tipoObjeto,
    String? objetoId,
    String? detalle,
    String? actor,
    bool usarActor = true,
  }) {
    final previo = _bitacora.isEmpty ? '' : _bitacora.last.hash;
    final base = EntradaBitacora(
      id: _id(),
      fecha: DateTime.now(),
      actor: usarActor ? (actor ?? current?.email) : null,
      paciente: paciente,
      accion: accion,
      tipoObjeto: tipoObjeto,
      objetoId: objetoId,
      detalle: detalle,
      hashPrevio: previo,
    );
    _bitacora.add(base.sellar(previo));
  }

  /// Recalcula la cadena tras una eliminación de datos legítima (derecho de
  /// supresión), para que la verificación siga siendo válida.
  void _resellarBitacora() {
    var previo = '';
    final nueva = <EntradaBitacora>[];
    for (final e in _bitacora) {
      final s = e.sellar(previo);
      nueva.add(s);
      previo = s.hash;
    }
    _bitacora = nueva;
  }

  /// `true` si ninguna entrada fue alterada o retirada de la cadena.
  bool get bitacoraIntegra {
    var previo = '';
    for (final e in _bitacora) {
      if (e.hashPrevio != previo || e.calcularHash() != e.hash) return false;
      previo = e.hash;
    }
    return true;
  }

  /// El paciente consulta su actividad. El cuidador y el administrador no.
  List<EntradaBitacora> get miBitacora {
    final u = current;
    if (u == null || u.rol != Rol.paciente) return const [];
    final l = _bitacora
        .where((e) => e.paciente == u.email || e.actor == u.email)
        .toList();
    return l.reversed.toList();
  }

  // ---------- Permisos ----------
  AppUser? usuarioPorEmail(String email) {
    for (final u in users) {
      if (u.email == email) return u;
    }
    return null;
  }

  Consentimiento? _consentimientoVigente(String email, TipoConsentimiento t) {
    for (final c in consentimientos.reversed) {
      if (c.usuarioEmail == email && c.tipo == t && c.vigente) return c;
    }
    return null;
  }

  bool tieneConsentimiento(String email, TipoConsentimiento t) =>
      _consentimientoVigente(email, t) != null;

  /// Vínculo activo del usuario actual con un paciente. Exige que el paciente
  /// mantenga vigente su consentimiento para compartir información.
  Cuidador? _vinculoActivoCon(String pacienteEmail) {
    final u = current;
    if (u == null || u.rol == Rol.admin) return null;
    if (!tieneConsentimiento(
        pacienteEmail, TipoConsentimiento.compartirConCuidadores)) {
      return null;
    }
    for (final c in cuidadores) {
      if (c.pacienteEmail == pacienteEmail &&
          c.cuidadorEmail == u.email &&
          c.estado == EstadoVinculo.activo) {
        return c;
      }
    }
    return null;
  }

  /// Dueño de los datos o cuidador con el permiso expreso.
  bool tienePermiso(String pacienteEmail, Permiso permiso) {
    final u = current;
    if (u == null) return false;
    if (u.email == pacienteEmail) return true;
    return _vinculoActivoCon(pacienteEmail)?.permisos.contains(permiso) ??
        false;
  }

  void _exigir(String pacienteEmail, Permiso permiso) {
    if (!tienePermiso(pacienteEmail, permiso)) {
      throw StateError('Acción no autorizada para este paciente.');
    }
  }

  bool puedeEditarMed(Medicamento m) =>
      tienePermiso(m.pacienteEmail, Permiso.editarMedicamentos);

  bool puedeRegistrarToma(Medicamento m) =>
      tienePermiso(m.pacienteEmail, Permiso.registrarTomas);

  // ---------- Cuenta ----------
  String _mensajeEstado(EstadoCuenta e) => switch (e) {
        EstadoCuenta.inactiva =>
          'Tu cuenta está inactiva. Contacta al administrador para reactivarla.',
        EstadoCuenta.suspendida =>
          'Tu cuenta está suspendida. Contacta al administrador.',
        EstadoCuenta.activa => '',
      };

  Future<String?> register({
    required String nombre,
    required DateTime fechaNacimiento,
    required String email,
    String? telefono,
    required String pass,
    required Rol rol,
    required bool consentimientoSalud,
    required bool consentimientoCompartir,
  }) async {
    email = email.trim().toLowerCase();
    if (rol == Rol.admin) {
      return 'Este tipo de cuenta no se puede crear desde el registro.';
    }
    if (!consentimientoSalud) {
      return 'Necesitamos tu consentimiento para tratar tus datos de salud.';
    }
    final errPass = Seguridad.validarPassword(pass);
    if (errPass != null) return errPass;
    if (users.any((u) => u.email == email)) {
      return 'Ese correo ya está registrado';
    }

    final u = AppUser(
      nombre: nombre.trim(),
      email: email,
      telefono: (telefono ?? '').trim().isEmpty ? null : telefono!.trim(),
      fechaNacimiento: fechaNacimiento,
      rol: rol,
    );
    await _asignarPassword(u, pass);
    users.add(u);

    final ahora = DateTime.now();
    consentimientos.add(Consentimiento(
      id: _id(),
      usuarioEmail: email,
      tipo: TipoConsentimiento.tratamientoDatosSalud,
      version: kVersionConsentimiento,
      aceptadoEn: ahora,
    ));
    if (consentimientoCompartir) {
      consentimientos.add(Consentimiento(
        id: _id(),
        usuarioEmail: email,
        tipo: TipoConsentimiento.compartirConCuidadores,
        version: kVersionConsentimiento,
        aceptadoEn: ahora,
      ));
    }

    current = u;
    _log(AccionBitacora.registro,
        paciente: rol == Rol.paciente ? email : null,
        tipoObjeto: 'usuario',
        objetoId: email);
    _log(AccionBitacora.consentimientoOtorgado,
        paciente: rol == Rol.paciente ? email : null,
        detalle: TipoConsentimiento.tratamientoDatosSalud.label);
    if (consentimientoCompartir) {
      _log(AccionBitacora.consentimientoOtorgado,
          paciente: rol == Rol.paciente ? email : null,
          detalle: TipoConsentimiento.compartirConCuidadores.label);
    }
    _changed();
    return null;
  }

  Future<String?> login(String email, String pass) async {
    email = email.trim().toLowerCase();
    final registro = _intentos.putIfAbsent(email, () => _Intentos());
    final hasta = registro.bloqueadoHasta;
    if (hasta != null && DateTime.now().isBefore(hasta)) {
      return 'Demasiados intentos. Intenta de nuevo en unos minutos.';
    }

    AppUser? u;
    for (final x in users) {
      if (x.email == email) u = x;
    }

    // Se calcula el hash aunque el usuario no exista para no revelar qué
    // correos están registrados por el tiempo de respuesta.
    final sal = u?.passwordSalt.isNotEmpty == true
        ? u!.passwordSalt
        : Seguridad.nuevaSal();
    final iter = (u?.passwordIter ?? 0) > 0
        ? u!.passwordIter
        : Seguridad.iteraciones;
    final calculado = await Seguridad.hash(pass, sal, iter);
    final usuario = u;
    final ok = usuario != null &&
        usuario.passwordHash.isNotEmpty &&
        Seguridad.iguales(calculado, usuario.passwordHash);

    if (!ok) {
      registro.fallos++;
      if (registro.fallos >= _maxIntentos) {
        registro.fallos = 0;
        registro.bloqueadoHasta = DateTime.now().add(_bloqueo);
      }
      return 'Correo o contraseña incorrectos';
    }

    registro
      ..fallos = 0
      ..bloqueadoHasta = null;

    if (usuario.estado != EstadoCuenta.activa) {
      return _mensajeEstado(usuario.estado);
    }

    current = usuario;
    _log(AccionBitacora.inicioSesion,
        paciente: usuario.rol == Rol.paciente ? usuario.email : null);
    _changed();
    return null;
  }

  void logout() {
    if (current != null) {
      _log(AccionBitacora.cierreSesion,
          paciente: current!.rol == Rol.paciente ? current!.email : null);
    }
    current = null;
    _changed();
  }

  Future<String?> cambiarPassword(String actual, String nueva) async {
    final u = current;
    if (u == null) return 'No hay una sesión activa.';
    final calculado = await Seguridad.hash(actual, u.passwordSalt, u.passwordIter);
    if (!Seguridad.iguales(calculado, u.passwordHash)) {
      return 'La contraseña actual no es correcta';
    }
    final err = Seguridad.validarPassword(nueva);
    if (err != null) return err;
    await _asignarPassword(u, nueva);
    _log(AccionBitacora.cambioPassword,
        paciente: u.rol == Rol.paciente ? u.email : null);
    _changed();
    return null;
  }

  void actualizarPerfil({
    required String nombre,
    required DateTime fechaNacimiento,
    String? telefono,
  }) {
    final u = current;
    if (u == null) return;
    u.nombre = nombre.trim();
    u.fechaNacimiento = fechaNacimiento;
    u.fechaNacimientoEstimada = false;
    u.telefono = (telefono ?? '').trim().isEmpty ? null : telefono!.trim();
    _log(AccionBitacora.perfilActualizado,
        paciente: u.rol == Rol.paciente ? u.email : null);
    _changed();
  }

  /// Solo el administrador cambia el estado de una cuenta ajena.
  String? cambiarEstadoCuenta(AppUser objetivo, EstadoCuenta nuevo) {
    final u = current;
    if (u == null || u.rol != Rol.admin) return 'Acción no autorizada.';
    if (objetivo.email == u.email) return 'No puedes cambiar tu propia cuenta.';
    objetivo.estado = nuevo;
    _log(AccionBitacora.estadoCuentaCambiado,
        tipoObjeto: 'usuario',
        objetoId: objetivo.email,
        detalle: nuevo.label);
    _changed();
    return null;
  }

  // ---------- Consentimientos ----------
  bool get tieneConsentimientoSalud =>
      current != null &&
      tieneConsentimiento(
          current!.email, TipoConsentimiento.tratamientoDatosSalud);

  List<Consentimiento> get misConsentimientos {
    final u = current;
    if (u == null) return const [];
    final l = consentimientos.where((c) => c.usuarioEmail == u.email).toList();
    l.sort((a, b) => b.aceptadoEn.compareTo(a.aceptadoEn));
    return l;
  }

  void otorgarConsentimiento(TipoConsentimiento tipo) {
    final u = current;
    if (u == null || tieneConsentimiento(u.email, tipo)) return;
    consentimientos.add(Consentimiento(
      id: _id(),
      usuarioEmail: u.email,
      tipo: tipo,
      version: kVersionConsentimiento,
      aceptadoEn: DateTime.now(),
    ));
    _log(AccionBitacora.consentimientoOtorgado,
        paciente: u.rol == Rol.paciente ? u.email : null, detalle: tipo.label);
    _changed();
  }

  /// Retirar el consentimiento de compartir revoca todos los vínculos activos.
  void retirarConsentimientoCompartir() {
    final u = current;
    if (u == null) return;
    final c =
        _consentimientoVigente(u.email, TipoConsentimiento.compartirConCuidadores);
    if (c == null) return;
    c.revocadoEn = DateTime.now();
    for (final v in cuidadores) {
      if (v.pacienteEmail == u.email &&
          (v.estado == EstadoVinculo.activo ||
              v.estado == EstadoVinculo.pendiente)) {
        v.estado = EstadoVinculo.revocado;
        v.fechaRevocacion = DateTime.now();
      }
    }
    _log(AccionBitacora.consentimientoRetirado,
        paciente: u.email, detalle: TipoConsentimiento.compartirConCuidadores.label);
    _changed();
  }

  // ---------- Configuración general ----------
  ConfiguracionGeneral configDe(String email) =>
      _configs[email] ?? ConfiguracionGeneral();

  ConfiguracionGeneral get config =>
      current == null ? ConfiguracionGeneral() : configDe(current!.email);

  int umbralDe(Medicamento m) =>
      configDe(m.pacienteEmail).umbralExistenciasBajas;

  void guardarConfig(ConfiguracionGeneral nueva) {
    final u = current;
    if (u == null) return;
    _configs[u.email] = nueva;
    _log(AccionBitacora.configuracionModificada,
        paciente: u.rol == Rol.paciente ? u.email : null);
    _changed();
  }

  // ---------- Consultas ----------
  List<AppUser> get pacientes =>
      users.where((u) => u.rol == Rol.paciente).toList();

  /// Pacientes con vínculo activo hacia el cuidador actual.
  List<AppUser> get pacientesVinculados {
    final u = current;
    if (u == null || u.rol == Rol.admin) return const [];
    final emails = <String>{
      for (final c in cuidadores)
        if (c.cuidadorEmail == u.email &&
            c.estado == EstadoVinculo.activo &&
            tieneConsentimiento(
                c.pacienteEmail, TipoConsentimiento.compartirConCuidadores))
          c.pacienteEmail,
    };
    return users.where((x) => emails.contains(x.email)).toList();
  }

  /// Pacientes para los que el usuario actual puede crear medicamentos.
  List<AppUser> get pacientesEditables => pacientesVinculados
      .where((p) => tienePermiso(p.email, Permiso.editarMedicamentos))
      .toList();

  /// El paciente ve lo suyo; el cuidador solo lo autorizado; el administrador
  /// no ve datos clínicos.
  List<Medicamento> get visibleMeds {
    final u = current;
    if (u == null || u.rol == Rol.admin) return [];
    final l = meds
        .where((m) =>
            m.activo && tienePermiso(m.pacienteEmail, Permiso.consultarTomas))
        .toList();
    l.sort((a, b) => a.hora.compareTo(b.hora));
    return l;
  }

  /// Medicamentos cuyas existencias puede ver el usuario actual.
  List<Medicamento> get medsConExistencias => visibleMeds
      .where((m) => tienePermiso(m.pacienteEmail, Permiso.consultarExistencias))
      .toList();

  List<Medicamento> medsDe(String email) {
    if (!tienePermiso(email, Permiso.consultarTomas)) return [];
    final l = meds.where((m) => m.pacienteEmail == email && m.activo).toList();
    l.sort((a, b) => a.hora.compareTo(b.hora));
    return l;
  }

  List<Cuidador> get misCuidadores =>
      cuidadores.where((c) => c.pacienteEmail == current?.email).toList()
        ..sort((a, b) => b.fechaInicio.compareTo(a.fechaInicio));

  /// Invitaciones que el cuidador actual todavía no responde.
  List<Cuidador> get invitacionesPendientes => cuidadores
      .where((c) =>
          c.cuidadorEmail == current?.email &&
          c.estado == EstadoVinculo.pendiente)
      .toList();

  String nombreDe(String email) => usuarioPorEmail(email)?.nombre ?? email;

  bool tomadoHoy(Medicamento m) {
    final now = DateTime.now();
    return tomas.any((t) =>
        t.medId == m.id &&
        t.estado == EstadoToma.tomada &&
        mismoDia(t.fecha, now));
  }

  bool omitidoHoy(Medicamento m) {
    final now = DateTime.now();
    return tomas.any((t) =>
        t.medId == m.id &&
        t.estado == EstadoToma.omitida &&
        mismoDia(t.fecha, now));
  }

  /// Estado de hoy calculado; no se edita directamente.
  EstadoToma estadoHoy(Medicamento m) {
    if (tomadoHoy(m)) return EstadoToma.tomada;
    if (omitidoHoy(m)) return EstadoToma.omitida;
    final s = snoozeUntil[m.id];
    if (s != null && s.isAfter(DateTime.now())) return EstadoToma.pospuesta;
    return EstadoToma.pendiente;
  }

  /// Pendientes = ni tomadas ni omitidas hoy.
  int pendientesHoy(String email) => medsDe(email)
      .where((m) => !tomadoHoy(m) && !omitidoHoy(m))
      .length;

  int get tomasHoy => tomas
      .where((t) =>
          t.estado == EstadoToma.tomada && mismoDia(t.fecha, DateTime.now()))
      .length;

  EstadoExistencia estadoExistencia(Medicamento m) {
    final n = existenciaDe(m.id);
    if (n <= 0) return EstadoExistencia.agotado;
    if (n <= umbralDe(m)) return EstadoExistencia.bajo;
    return EstadoExistencia.normal;
  }

  ResumenPaciente resumenDe(String email) {
    final verTomas = tienePermiso(email, Permiso.consultarTomas);
    final verExist = tienePermiso(email, Permiso.consultarExistencias);
    final lista = meds.where((m) => m.pacienteEmail == email && m.activo);
    final hoy = DateTime.now();
    return ResumenPaciente(
      totalMedicamentos: verTomas ? lista.length : null,
      pendientesHoy: verTomas
          ? lista.where((m) => !tomadoHoy(m) && !omitidoHoy(m)).length
          : null,
      omitidasHoy: verTomas
          ? tomas
              .where((t) =>
                  t.pacienteEmail == email &&
                  t.estado == EstadoToma.omitida &&
                  mismoDia(t.fecha, hoy))
              .length
          : null,
      existenciasBajas: verExist
          ? lista
              .where((m) =>
                  existencias.containsKey(m.id) &&
                  estadoExistencia(m) != EstadoExistencia.normal)
              .length
          : null,
    );
  }

  /// Tomas del día que el usuario actual puede consultar.
  List<Toma> tomasDelDia(DateTime f) {
    final l = tomas
        .where((t) =>
            mismoDia(t.fecha, f) &&
            tienePermiso(t.pacienteEmail, Permiso.consultarTomas))
        .toList();
    l.sort((a, b) => a.fecha.compareTo(b.fecha));
    return l;
  }

  /// Número de tomas por día de los últimos [n] días (para la gráfica).
  List<int> conteoUltimosDias(int n) {
    final hoy = DateTime.now();
    return [
      for (var i = n - 1; i >= 0; i--)
        tomasDelDia(DateTime(hoy.year, hoy.month, hoy.day - i))
            .where((t) => t.estado == EstadoToma.tomada)
            .length,
    ];
  }

  /// Días consecutivos con al menos una toma registrada como tomada.
  /// Se calcula desde el historial; no se edita.
  int racha(String email) {
    if (!tienePermiso(email, Permiso.consultarTomas)) return 0;
    final dias = tomas
        .where((t) => t.pacienteEmail == email && t.estado == EstadoToma.tomada)
        .map((t) => DateTime(t.fecha.year, t.fecha.month, t.fecha.day))
        .toSet();
    final n0 = DateTime.now();
    var d = DateTime(n0.year, n0.month, n0.day);
    if (!dias.contains(d)) d = DateTime(d.year, d.month, d.day - 1);
    var n = 0;
    while (dias.contains(d)) {
      n++;
      d = DateTime(d.year, d.month, d.day - 1);
    }
    return n;
  }

  // ---------- Medicinas ----------
  void addMed(String nombre, String dosis, String hora, String info,
      String pacienteEmail,
      {int cantidadPorToma = 1}) {
    _exigir(pacienteEmail, Permiso.editarMedicamentos);
    final m = Medicamento(
      id: _id(),
      nombre: nombre.trim(),
      dosis: dosis.trim(),
      hora: hora,
      info: info.trim(),
      pacienteEmail: pacienteEmail,
      cantidadPorToma: cantidadPorToma < 1 ? 1 : cantidadPorToma,
      creadoPor: current!.email,
    );
    meds.add(m);
    _log(AccionBitacora.medicamentoCreado,
        paciente: pacienteEmail,
        tipoObjeto: 'medicamento',
        objetoId: m.id,
        detalle: m.nombre);
    _changed();
  }

  void updateMed(Medicamento m, String nombre, String dosis, String hora,
      String info) {
    _exigir(m.pacienteEmail, Permiso.editarMedicamentos);
    m.nombre = nombre.trim();
    m.dosis = dosis.trim();
    m.hora = hora;
    m.info = info.trim();
    m.actualizadoPor = current!.email;
    m.actualizadoEn = DateTime.now();
    // Cambiar la hora no duplica recordatorios: hay una sola hora por
    // medicamento y un posible aplazamiento anterior se descarta.
    snoozeUntil.remove(m.id);
    _log(AccionBitacora.medicamentoEditado,
        paciente: m.pacienteEmail,
        tipoObjeto: 'medicamento',
        objetoId: m.id,
        detalle: m.nombre);
    _changed();
  }

  void updateCantidadPorToma(Medicamento m, int cantidad) {
    _exigir(m.pacienteEmail, Permiso.editarMedicamentos);
    m.cantidadPorToma = cantidad < 1 ? 1 : cantidad;
    m.actualizadoPor = current!.email;
    m.actualizadoEn = DateTime.now();
    _changed();
  }

  /// Si el medicamento tiene tomas registradas se archiva en lugar de
  /// eliminarse. Devuelve `true` cuando fue archivado.
  bool deleteMed(Medicamento m) {
    _exigir(m.pacienteEmail, Permiso.editarMedicamentos);
    final tieneTomas = tomas.any((t) => t.medId == m.id);
    if (tieneTomas) {
      m.activo = false;
      m.actualizadoPor = current!.email;
      m.actualizadoEn = DateTime.now();
      snoozeUntil.remove(m.id);
      _log(AccionBitacora.medicamentoArchivado,
          paciente: m.pacienteEmail,
          tipoObjeto: 'medicamento',
          objetoId: m.id,
          detalle: m.nombre);
    } else {
      meds.removeWhere((e) => e.id == m.id);
      existencias.remove(m.id);
      snoozeUntil.remove(m.id);
      _log(AccionBitacora.medicamentoEliminado,
          paciente: m.pacienteEmail,
          tipoObjeto: 'medicamento',
          objetoId: m.id,
          detalle: m.nombre);
    }
    _changed();
    return tieneTomas;
  }

  DateTime _programadaHoy(Medicamento m) {
    final p = m.hora.split(':');
    final h = int.tryParse(p.first) ?? 0;
    final min = p.length > 1 ? (int.tryParse(p[1]) ?? 0) : 0;
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day, h, min);
  }

  /// Registra la toma de hoy una sola vez y devuelve la racha. Descuenta de
  /// la existencia las unidades definidas en `cantidadPorToma`. No sugiere
  /// dosis ni compensaciones.
  int marcarTomado(Medicamento m) {
    _exigir(m.pacienteEmail, Permiso.registrarTomas);
    if (tomadoHoy(m)) {
      snoozeUntil.remove(m.id);
      return racha(m.pacienteEmail);
    }

    // Una omisión previa de hoy pasa a ser una toma tardía registrada; se
    // conserva el registro de la omisión.
    final programada = _programadaHoy(m);
    final ahora = DateTime.now();
    final tardia = ahora.difference(programada).inMinutes > toleranciaTomaMin;

    tomas.add(Toma(
      id: _id(),
      medId: m.id,
      nombre: m.nombre,
      dosis: m.dosis,
      pacienteEmail: m.pacienteEmail,
      fecha: ahora,
      estado: EstadoToma.tomada,
      programadaPara: programada,
      registradaPor: current!.email,
      tardia: tardia,
    ));

    if (existencias.containsKey(m.id)) {
      final actual = existencias[m.id]!;
      existencias[m.id] =
          (actual - m.cantidadPorToma) < 0 ? 0 : actual - m.cantidadPorToma;
    }

    snoozeUntil.remove(m.id);
    _log(AccionBitacora.tomaRegistrada,
        paciente: m.pacienteEmail,
        tipoObjeto: 'medicamento',
        objetoId: m.id,
        detalle: tardia ? 'Registrada con retraso' : 'Registrada a tiempo');
    _changed();
    return racha(m.pacienteEmail);
  }

  /// Corrección: retira la toma de hoy. Requiere permiso y queda en bitácora.
  void desmarcar(Medicamento m) {
    _exigir(m.pacienteEmail, Permiso.registrarTomas);
    final now = DateTime.now();
    final quitar = tomas
        .where((t) =>
            t.medId == m.id &&
            t.estado == EstadoToma.tomada &&
            mismoDia(t.fecha, now))
        .toList();
    if (quitar.isEmpty) return;

    tomas.removeWhere((t) => quitar.any((q) => q.id == t.id));
    if (existencias.containsKey(m.id)) {
      existencias[m.id] =
          existencias[m.id]! + m.cantidadPorToma * quitar.length;
    }
    _log(AccionBitacora.tomaCorregida,
        paciente: m.pacienteEmail,
        tipoObjeto: 'medicamento',
        objetoId: m.id,
        detalle: 'Toma de hoy retirada del historial');
    _changed();
  }

  /// Marca la toma de hoy como omitida, con una nota opcional.
  String? marcarOmitido(Medicamento m, {String? nota}) {
    _exigir(m.pacienteEmail, Permiso.registrarTomas);
    if (tomadoHoy(m)) return 'Esta toma ya fue registrada como tomada.';
    if (omitidoHoy(m)) return 'Esta toma ya fue marcada como omitida.';
    tomas.add(Toma(
      id: _id(),
      medId: m.id,
      nombre: m.nombre,
      dosis: m.dosis,
      pacienteEmail: m.pacienteEmail,
      fecha: DateTime.now(),
      estado: EstadoToma.omitida,
      programadaPara: _programadaHoy(m),
      registradaPor: current!.email,
      nota: (nota ?? '').trim().isEmpty ? null : nota!.trim(),
    ));
    snoozeUntil.remove(m.id);
    _log(AccionBitacora.tomaOmitida,
        paciente: m.pacienteEmail, tipoObjeto: 'medicamento', objetoId: m.id);
    _changed();
    return null;
  }

  /// Pospone el recordatorio los minutos definidos en Configuración General.
  void posponer(Medicamento m) {
    _exigir(m.pacienteEmail, Permiso.registrarTomas);
    final minutos = configDe(m.pacienteEmail).minutosPosposicion;
    snoozeUntil[m.id] = DateTime.now().add(Duration(minutes: minutos));
    _log(AccionBitacora.tomaPospuesta,
        paciente: m.pacienteEmail,
        tipoObjeto: 'medicamento',
        objetoId: m.id,
        detalle: '$minutos minutos');
    _changed();
  }

  // ---------- Botiquín ----------
  int existenciaDe(String medId) => existencias[medId] ?? 0;

  /// Ajuste manual del inventario (por ejemplo, al surtir). El estado
  /// (normal, bajo, agotado) siempre se calcula con [estadoExistencia].
  String? setExistencia(String medId, int cantidad) {
    Medicamento? m;
    for (final x in meds) {
      if (x.id == medId) m = x;
    }
    if (m == null) return 'Medicamento no encontrado.';
    if (!tienePermiso(m.pacienteEmail, Permiso.editarMedicamentos)) {
      return 'No tienes permiso para modificar las existencias.';
    }
    final anterior = existencias[medId];
    existencias[medId] = cantidad < 0 ? 0 : cantidad;
    _log(AccionBitacora.existenciaAjustada,
        paciente: m.pacienteEmail,
        tipoObjeto: 'medicamento',
        objetoId: medId,
        detalle: '${anterior ?? 0} → ${existencias[medId]} unidades');
    _changed();
    return null;
  }

  // ---------- Vínculos de cuidado ----------
  /// Crea un vínculo. Con `cuidadorEmail` queda pendiente hasta que el
  /// cuidador lo acepte; sin él es solo un contacto y no otorga acceso.
  String? addCuidador(
    String nombre,
    String parentesco,
    String contacto, {
    String? cuidadorEmail,
    Set<Permiso> permisos = const {},
  }) {
    final u = current;
    if (u == null || u.rol != Rol.paciente) {
      return 'Solo un paciente puede invitar cuidadores.';
    }
    final correo = (cuidadorEmail ?? '').trim().toLowerCase();

    if (correo.isNotEmpty) {
      if (!tieneConsentimiento(
          u.email, TipoConsentimiento.compartirConCuidadores)) {
        return 'Primero otorga tu consentimiento para compartir información '
            'con cuidadores (Perfil y consentimientos).';
      }
      if (correo == u.email) return 'No puedes vincularte contigo mismo.';
      final destino = usuarioPorEmail(correo);
      if (destino == null || destino.rol != Rol.cuidador) {
        return 'No existe una cuenta de cuidador con ese correo.';
      }
      final duplicado = cuidadores.any((c) =>
          c.pacienteEmail == u.email &&
          c.cuidadorEmail == correo &&
          (c.estado == EstadoVinculo.activo ||
              c.estado == EstadoVinculo.pendiente));
      if (duplicado) return 'Ya existe un vínculo con esa persona.';
    }

    final c = Cuidador(
      id: _id(),
      nombre: nombre.trim(),
      parentesco: parentesco.trim(),
      contacto: contacto.trim(),
      pacienteEmail: u.email,
      cuidadorEmail: correo.isEmpty ? null : correo,
      estado: correo.isEmpty ? EstadoVinculo.activo : EstadoVinculo.pendiente,
      permisos: {...permisos},
    );
    cuidadores.add(c);
    _log(AccionBitacora.vinculoCreado,
        paciente: u.email,
        tipoObjeto: 'vinculo',
        objetoId: c.id,
        detalle: correo.isEmpty ? 'Solo contacto' : 'Invitación enviada');
    _changed();
    return null;
  }

  String? updateCuidador(
    Cuidador c,
    String nombre,
    String parentesco,
    String contacto, {
    Set<Permiso>? permisos,
  }) {
    if (current?.email != c.pacienteEmail) return 'Acción no autorizada.';
    c.nombre = nombre.trim();
    c.parentesco = parentesco.trim();
    c.contacto = contacto.trim();
    if (permisos != null && !setEquals(permisos, c.permisos)) {
      c.permisos = {...permisos};
      _log(AccionBitacora.permisosModificados,
          paciente: c.pacienteEmail, tipoObjeto: 'vinculo', objetoId: c.id);
    }
    _changed();
    return null;
  }

  /// Revoca el vínculo (conserva el registro con su fecha de revocación).
  void revocarCuidador(Cuidador c) {
    if (current?.email != c.pacienteEmail) return;
    if (c.estado == EstadoVinculo.revocado) return;
    c.estado = EstadoVinculo.revocado;
    c.fechaRevocacion = DateTime.now();
    _log(AccionBitacora.vinculoRevocado,
        paciente: c.pacienteEmail, tipoObjeto: 'vinculo', objetoId: c.id);
    _changed();
  }

  /// El cuidador acepta o rechaza una invitación dirigida a él.
  void responderInvitacion(Cuidador c, {required bool aceptar}) {
    if (current?.email != c.cuidadorEmail ||
        c.estado != EstadoVinculo.pendiente) {
      return;
    }
    c.estado = aceptar ? EstadoVinculo.activo : EstadoVinculo.rechazado;
    if (aceptar) c.fechaInicio = DateTime.now();
    _log(aceptar ? AccionBitacora.vinculoAceptado : AccionBitacora.vinculoRechazado,
        paciente: c.pacienteEmail, tipoObjeto: 'vinculo', objetoId: c.id);
    _changed();
  }

  // ---------- Datos personales ----------
  /// Copia legible de los datos de la persona usuaria (sin contraseña).
  String exportarDatos() {
    final u = current!;
    final ids = meds
        .where((m) => m.pacienteEmail == u.email)
        .map((m) => m.id)
        .toSet();
    final datos = {
      'exportadoEn': DateTime.now().toIso8601String(),
      'perfil': {
        'nombre': u.nombre,
        'email': u.email,
        'telefono': u.telefono,
        'fechaNacimiento': u.fechaNacimiento.toIso8601String(),
        'rol': u.rol.name,
        'estado': u.estado.name,
      },
      'medicamentos':
          meds.where((m) => m.pacienteEmail == u.email).map((m) => m.toJson()).toList(),
      'existencias': {
        for (final e in existencias.entries)
          if (ids.contains(e.key)) e.key: e.value,
      },
      'tomas':
          tomas.where((t) => t.pacienteEmail == u.email).map((t) => t.toJson()).toList(),
      'vinculos': cuidadores
          .where((c) => c.pacienteEmail == u.email || c.cuidadorEmail == u.email)
          .map((c) => c.toJson())
          .toList(),
      'consentimientos': consentimientos
          .where((c) => c.usuarioEmail == u.email)
          .map((c) => c.toJson())
          .toList(),
      'configuracion': configDe(u.email).toJson(),
      'bitacora': miBitacora.map((e) => e.toJson()).toList(),
    };
    _log(AccionBitacora.datosExportados,
        paciente: u.rol == Rol.paciente ? u.email : null);
    _changed();
    return const JsonEncoder.withIndent('  ').convert(datos);
  }

  /// Elimina la cuenta y sus datos tras confirmar la contraseña.
  Future<String?> eliminarCuenta(String pass) async {
    final u = current;
    if (u == null) return 'No hay una sesión activa.';
    final calculado = await Seguridad.hash(pass, u.passwordSalt, u.passwordIter);
    if (!Seguridad.iguales(calculado, u.passwordHash)) {
      return 'La contraseña no es correcta';
    }

    final email = u.email;
    final medIds =
        meds.where((m) => m.pacienteEmail == email).map((m) => m.id).toSet();

    meds.removeWhere((m) => m.pacienteEmail == email);
    tomas.removeWhere((t) => t.pacienteEmail == email);
    for (final id in medIds) {
      existencias.remove(id);
      snoozeUntil.remove(id);
    }
    cuidadores.removeWhere((c) => c.pacienteEmail == email);
    for (final c in cuidadores) {
      if (c.cuidadorEmail == email &&
          (c.estado == EstadoVinculo.activo ||
              c.estado == EstadoVinculo.pendiente)) {
        c.estado = EstadoVinculo.revocado;
        c.fechaRevocacion = DateTime.now();
      }
    }
    consentimientos.removeWhere((c) => c.usuarioEmail == email);
    _configs.remove(email);
    users.removeWhere((x) => x.email == email);

    // Se retiran las referencias personales de la bitácora y se vuelve a
    // sellar la cadena. El registro de la eliminación no guarda el correo.
    _bitacora = _bitacora
        .where((e) => e.paciente != email && e.actor != email)
        .toList();
    _log(AccionBitacora.cuentaEliminada, usarActor: false);
    _resellarBitacora();

    current = null;
    _changed();
    return null;
  }
}
