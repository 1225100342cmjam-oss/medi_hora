import 'dart:convert';

import 'package:crypto/crypto.dart';

// ---------------------------------------------------------------------------
// Valores controlados (enumeraciones)
// ---------------------------------------------------------------------------

/// Perfil principal de la cuenta. El acceso a los datos de otra persona NO
/// depende de este valor: lo determina un Vínculo de Cuidado autorizado.
enum Rol { admin, paciente, cuidador }

extension RolX on Rol {
  String get label => switch (this) {
        Rol.admin => 'Administrador',
        Rol.paciente => 'Paciente',
        Rol.cuidador => 'Cuidador',
      };
}

enum EstadoCuenta { activa, inactiva, suspendida }

extension EstadoCuentaX on EstadoCuenta {
  String get label => switch (this) {
        EstadoCuenta.activa => 'Activa',
        EstadoCuenta.inactiva => 'Inactiva',
        EstadoCuenta.suspendida => 'Suspendida',
      };
}

enum TipoConsentimiento { tratamientoDatosSalud, compartirConCuidadores }

extension TipoConsentimientoX on TipoConsentimiento {
  String get label => switch (this) {
        TipoConsentimiento.tratamientoDatosSalud =>
          'Tratamiento de datos de salud',
        TipoConsentimiento.compartirConCuidadores =>
          'Compartir información con cuidadores',
      };
}

enum EstadoVinculo { pendiente, activo, rechazado, revocado }

extension EstadoVinculoX on EstadoVinculo {
  String get label => switch (this) {
        EstadoVinculo.pendiente => 'Invitación pendiente',
        EstadoVinculo.activo => 'Activo',
        EstadoVinculo.rechazado => 'Rechazado',
        EstadoVinculo.revocado => 'Revocado',
      };
}

/// Permisos granulares de un Vínculo de Cuidado.
enum Permiso {
  consultarTomas,
  consultarExistencias,
  recibirAlertas,
  editarMedicamentos,
  registrarTomas,
}

extension PermisoX on Permiso {
  String get label => switch (this) {
        Permiso.consultarTomas => 'Consultar medicamentos y tomas',
        Permiso.consultarExistencias => 'Consultar existencias',
        Permiso.recibirAlertas => 'Recibir alertas',
        Permiso.editarMedicamentos => 'Editar medicamentos y existencias',
        Permiso.registrarTomas => 'Registrar tomas en nombre del paciente',
      };
}

enum EstadoToma { pendiente, tomada, omitida, pospuesta }

extension EstadoTomaX on EstadoToma {
  String get label => switch (this) {
        EstadoToma.pendiente => 'Pendiente',
        EstadoToma.tomada => 'Tomada',
        EstadoToma.omitida => 'Omitida',
        EstadoToma.pospuesta => 'Pospuesta',
      };
}

enum EstadoExistencia { normal, bajo, agotado }

extension EstadoExistenciaX on EstadoExistencia {
  String get label => switch (this) {
        EstadoExistencia.normal => 'Disponible',
        EstadoExistencia.bajo => 'Existencias bajas',
        EstadoExistencia.agotado => 'Agotado',
      };
}

enum CanalNotificacion { enApp, correo, sms }

extension CanalNotificacionX on CanalNotificacion {
  String get label => switch (this) {
        CanalNotificacion.enApp => 'En la aplicación',
        CanalNotificacion.correo => 'Correo electrónico',
        CanalNotificacion.sms => 'Mensaje de texto (SMS)',
      };
}

T _porNombre<T extends Enum>(List<T> valores, Object? nombre, T porDefecto) {
  for (final v in valores) {
    if (v.name == nombre) return v;
  }
  return porDefecto;
}

// ---------------------------------------------------------------------------
// Usuario
// ---------------------------------------------------------------------------

class AppUser {
  String nombre;
  final String email;
  String? telefono;
  DateTime fechaNacimiento;

  /// `true` cuando la fecha proviene de una edad antigua (migración) y debe
  /// ser corregida por la persona usuaria.
  bool fechaNacimientoEstimada;

  final Rol rol;
  EstadoCuenta estado;
  final DateTime creadoEn;

  /// Hash PBKDF2 (base64) y sal. Nunca se guarda la contraseña.
  String passwordHash;
  String passwordSalt;
  int passwordIter;

  /// Solo se llena al leer datos de versiones anteriores; se convierte a hash
  /// durante la carga y no se serializa.
  String? legacyPassword;

  AppUser({
    required this.nombre,
    required this.email,
    required this.fechaNacimiento,
    required this.rol,
    this.telefono,
    this.fechaNacimientoEstimada = false,
    this.estado = EstadoCuenta.activa,
    DateTime? creadoEn,
    this.passwordHash = '',
    this.passwordSalt = '',
    this.passwordIter = 0,
    this.legacyPassword,
  }) : creadoEn = creadoEn ?? DateTime.now();

  /// La edad se calcula; no se almacena.
  int get edad {
    final h = DateTime.now();
    var e = h.year - fechaNacimiento.year;
    if (h.month < fechaNacimiento.month ||
        (h.month == fechaNacimiento.month && h.day < fechaNacimiento.day)) {
      e--;
    }
    return e < 0 ? 0 : e;
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
        'fechaNacimiento': fechaNacimiento.toIso8601String(),
        'fechaNacimientoEstimada': fechaNacimientoEstimada,
        'rol': rol.name,
        'estado': estado.name,
        'creadoEn': creadoEn.toIso8601String(),
        'passwordHash': passwordHash,
        'passwordSalt': passwordSalt,
        'passwordIter': passwordIter,
      };

  factory AppUser.fromJson(Map<String, dynamic> j) {
    final fn = j['fechaNacimiento'] as String?;
    final edadAntigua = (j['edad'] as num?)?.toInt() ?? 0;
    final ahora = DateTime.now();
    return AppUser(
      nombre: j['nombre'],
      email: j['email'],
      telefono: j['telefono'] as String?,
      fechaNacimiento:
          fn != null ? DateTime.parse(fn) : DateTime(ahora.year - edadAntigua, 7, 1),
      fechaNacimientoEstimada:
          fn == null ? true : (j['fechaNacimientoEstimada'] == true),
      rol: _porNombre(Rol.values, j['rol'], Rol.paciente),
      estado: _porNombre(EstadoCuenta.values, j['estado'], EstadoCuenta.activa),
      creadoEn:
          j['creadoEn'] != null ? DateTime.parse(j['creadoEn']) : ahora,
      passwordHash: (j['passwordHash'] as String?) ?? '',
      passwordSalt: (j['passwordSalt'] as String?) ?? '',
      passwordIter: (j['passwordIter'] as num?)?.toInt() ?? 0,
      legacyPassword: j['password'] as String?,
    );
  }
}

// ---------------------------------------------------------------------------
// Medicamento
// ---------------------------------------------------------------------------

class Medicamento {
  final String id, pacienteEmail;
  String nombre, dosis, hora, info; // hora en formato HH:mm

  /// Un medicamento con tomas registradas se archiva (activo = false) en
  /// lugar de eliminarse.
  bool activo;

  /// Unidades que se descuentan de la existencia por cada toma registrada.
  /// La define la persona usuaria; la app no infiere dosis.
  int cantidadPorToma;

  String? creadoPor, actualizadoPor;
  DateTime? actualizadoEn;

  Medicamento({
    required this.id,
    required this.nombre,
    required this.dosis,
    required this.hora,
    required this.info,
    required this.pacienteEmail,
    this.activo = true,
    this.cantidadPorToma = 1,
    this.creadoPor,
    this.actualizadoPor,
    this.actualizadoEn,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'dosis': dosis,
        'hora': hora,
        'info': info,
        'pacienteEmail': pacienteEmail,
        'activo': activo,
        'cantidadPorToma': cantidadPorToma,
        'creadoPor': creadoPor,
        'actualizadoPor': actualizadoPor,
        'actualizadoEn': actualizadoEn?.toIso8601String(),
      };

  factory Medicamento.fromJson(Map<String, dynamic> j) => Medicamento(
        id: j['id'],
        nombre: j['nombre'],
        dosis: j['dosis'],
        hora: j['hora'],
        info: j['info'] ?? '',
        pacienteEmail: j['pacienteEmail'],
        activo: j['activo'] != false,
        cantidadPorToma: (j['cantidadPorToma'] as num?)?.toInt() ?? 1,
        creadoPor: (j['creadoPor'] as String?) ?? j['pacienteEmail'],
        actualizadoPor: j['actualizadoPor'] as String?,
        actualizadoEn: j['actualizadoEn'] != null
            ? DateTime.parse(j['actualizadoEn'])
            : null,
      );
}

// ---------------------------------------------------------------------------
// Vínculo de Cuidado
// ---------------------------------------------------------------------------

/// Vínculo de Cuidado entre un paciente y un cuidador.
///
/// `cuidadorEmail` apunta a una cuenta registrada. Los vínculos antiguos, que
/// eran solo un contacto (sin cuenta), tienen `cuidadorEmail == null` y no
/// otorgan acceso a ningún dato.
class Cuidador {
  final String id, pacienteEmail;
  String nombre, parentesco, contacto;
  String? cuidadorEmail;
  EstadoVinculo estado;
  Set<Permiso> permisos;
  DateTime fechaInicio;
  DateTime? fechaRevocacion;

  Cuidador({
    required this.id,
    required this.nombre,
    required this.parentesco,
    required this.contacto,
    required this.pacienteEmail,
    this.cuidadorEmail,
    this.estado = EstadoVinculo.activo,
    Set<Permiso>? permisos,
    DateTime? fechaInicio,
    this.fechaRevocacion,
  })  : permisos = permisos ?? <Permiso>{},
        fechaInicio = fechaInicio ?? DateTime.now();

  bool get soloContacto => cuidadorEmail == null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'parentesco': parentesco,
        'contacto': contacto,
        'pacienteEmail': pacienteEmail,
        'cuidadorEmail': cuidadorEmail,
        'estado': estado.name,
        'permisos': permisos.map((p) => p.name).toList(),
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaRevocacion': fechaRevocacion?.toIso8601String(),
      };

  factory Cuidador.fromJson(Map<String, dynamic> j) => Cuidador(
        id: j['id'],
        nombre: j['nombre'],
        parentesco: j['parentesco'],
        contacto: j['contacto'],
        pacienteEmail: j['pacienteEmail'],
        cuidadorEmail: j['cuidadorEmail'] as String?,
        estado: _porNombre(EstadoVinculo.values, j['estado'], EstadoVinculo.activo),
        permisos: {
          for (final n in (j['permisos'] as List? ?? const []))
            _porNombre(Permiso.values, n, Permiso.consultarTomas),
        },
        fechaInicio: j['fechaInicio'] != null
            ? DateTime.parse(j['fechaInicio'])
            : DateTime.now(),
        fechaRevocacion: j['fechaRevocacion'] != null
            ? DateTime.parse(j['fechaRevocacion'])
            : null,
      );
}

// ---------------------------------------------------------------------------
// Toma
// ---------------------------------------------------------------------------

/// Registro de una toma (alimenta Historial y Racha).
///
/// `fecha` es la fecha de registro; `programadaPara` es la hora que
/// correspondía según el medicamento.
class Toma {
  final String id, medId, nombre, dosis, pacienteEmail;
  final DateTime fecha;
  final EstadoToma estado;
  final DateTime? programadaPara;
  final String registradaPor;
  final bool tardia;
  final String? nota;

  Toma({
    required this.id,
    required this.medId,
    required this.nombre,
    required this.dosis,
    required this.pacienteEmail,
    required this.fecha,
    this.estado = EstadoToma.tomada,
    this.programadaPara,
    String? registradaPor,
    this.tardia = false,
    this.nota,
  }) : registradaPor = registradaPor ?? pacienteEmail;

  Map<String, dynamic> toJson() => {
        'id': id,
        'medId': medId,
        'nombre': nombre,
        'dosis': dosis,
        'pacienteEmail': pacienteEmail,
        'fecha': fecha.toIso8601String(),
        'estado': estado.name,
        'programadaPara': programadaPara?.toIso8601String(),
        'registradaPor': registradaPor,
        'tardia': tardia,
        'nota': nota,
      };

  factory Toma.fromJson(Map<String, dynamic> j) => Toma(
        id: j['id'],
        medId: j['medId'],
        nombre: j['nombre'],
        dosis: j['dosis'],
        pacienteEmail: j['pacienteEmail'],
        fecha: DateTime.parse(j['fecha']),
        estado: _porNombre(EstadoToma.values, j['estado'], EstadoToma.tomada),
        programadaPara: j['programadaPara'] != null
            ? DateTime.parse(j['programadaPara'])
            : null,
        registradaPor: j['registradaPor'] as String?,
        tardia: j['tardia'] == true,
        nota: j['nota'] as String?,
      );
}

// ---------------------------------------------------------------------------
// Consentimiento
// ---------------------------------------------------------------------------

const String kVersionConsentimiento = '1.0';

class Consentimiento {
  final String id, usuarioEmail, version;
  final TipoConsentimiento tipo;
  final DateTime aceptadoEn;
  DateTime? revocadoEn;

  Consentimiento({
    required this.id,
    required this.usuarioEmail,
    required this.tipo,
    required this.version,
    required this.aceptadoEn,
    this.revocadoEn,
  });

  bool get vigente => revocadoEn == null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'usuarioEmail': usuarioEmail,
        'tipo': tipo.name,
        'version': version,
        'aceptadoEn': aceptadoEn.toIso8601String(),
        'revocadoEn': revocadoEn?.toIso8601String(),
      };

  factory Consentimiento.fromJson(Map<String, dynamic> j) => Consentimiento(
        id: j['id'],
        usuarioEmail: j['usuarioEmail'],
        tipo: _porNombre(TipoConsentimiento.values, j['tipo'],
            TipoConsentimiento.tratamientoDatosSalud),
        version: j['version'] ?? kVersionConsentimiento,
        aceptadoEn: DateTime.parse(j['aceptadoEn']),
        revocadoEn:
            j['revocadoEn'] != null ? DateTime.parse(j['revocadoEn']) : null,
      );
}

// ---------------------------------------------------------------------------
// Configuración general (personal: Usuario 1 — 1 ConfiguracionGeneral)
// ---------------------------------------------------------------------------

const List<String> kZonasHorarias = [
  'Automática (zona del dispositivo)',
  'America/Mexico_City',
  'America/Monterrey',
  'America/Tijuana',
  'America/Cancun',
  'America/Hermosillo',
];

class ConfiguracionGeneral {
  int minutosPosposicion;
  int umbralExistenciasBajas;
  String zonaHoraria;
  Set<CanalNotificacion> canales;
  bool alertasTomasOmitidas;
  bool alertasExistenciasBajas;

  /// Las notificaciones no deben mostrar el nombre del medicamento en la
  /// pantalla bloqueada.
  bool ocultarMedicamentoEnBloqueo;

  ConfiguracionGeneral({
    this.minutosPosposicion = 10,
    this.umbralExistenciasBajas = 5,
    this.zonaHoraria = 'Automática (zona del dispositivo)',
    Set<CanalNotificacion>? canales,
    this.alertasTomasOmitidas = true,
    this.alertasExistenciasBajas = true,
    this.ocultarMedicamentoEnBloqueo = true,
  }) : canales = canales ?? {CanalNotificacion.enApp};

  Map<String, dynamic> toJson() => {
        'minutosPosposicion': minutosPosposicion,
        'umbralExistenciasBajas': umbralExistenciasBajas,
        'zonaHoraria': zonaHoraria,
        'canales': canales.map((c) => c.name).toList(),
        'alertasTomasOmitidas': alertasTomasOmitidas,
        'alertasExistenciasBajas': alertasExistenciasBajas,
        'ocultarMedicamentoEnBloqueo': ocultarMedicamentoEnBloqueo,
      };

  factory ConfiguracionGeneral.fromJson(Map<String, dynamic> j) =>
      ConfiguracionGeneral(
        minutosPosposicion: (j['minutosPosposicion'] as num?)?.toInt() ?? 10,
        umbralExistenciasBajas:
            (j['umbralExistenciasBajas'] as num?)?.toInt() ?? 5,
        zonaHoraria:
            (j['zonaHoraria'] as String?) ?? 'Automática (zona del dispositivo)',
        canales: {
          for (final n in (j['canales'] as List? ?? const ['enApp']))
            _porNombre(CanalNotificacion.values, n, CanalNotificacion.enApp),
        },
        alertasTomasOmitidas: j['alertasTomasOmitidas'] != false,
        alertasExistenciasBajas: j['alertasExistenciasBajas'] != false,
        ocultarMedicamentoEnBloqueo: j['ocultarMedicamentoEnBloqueo'] != false,
      );
}

// ---------------------------------------------------------------------------
// Bitácora (solo se agrega; cada entrada encadena el hash de la anterior)
// ---------------------------------------------------------------------------

enum AccionBitacora {
  registro,
  inicioSesion,
  cierreSesion,
  cambioPassword,
  perfilActualizado,
  consentimientoOtorgado,
  consentimientoRetirado,
  medicamentoCreado,
  medicamentoEditado,
  medicamentoArchivado,
  medicamentoEliminado,
  existenciaAjustada,
  tomaRegistrada,
  tomaOmitida,
  tomaPospuesta,
  tomaCorregida,
  vinculoCreado,
  vinculoAceptado,
  vinculoRechazado,
  vinculoRevocado,
  permisosModificados,
  configuracionModificada,
  datosExportados,
  cuentaEliminada,
  estadoCuentaCambiado,
}

extension AccionBitacoraX on AccionBitacora {
  String get label => switch (this) {
        AccionBitacora.registro => 'Cuenta creada',
        AccionBitacora.inicioSesion => 'Inicio de sesión',
        AccionBitacora.cierreSesion => 'Cierre de sesión',
        AccionBitacora.cambioPassword => 'Cambio de contraseña',
        AccionBitacora.perfilActualizado => 'Perfil actualizado',
        AccionBitacora.consentimientoOtorgado => 'Consentimiento otorgado',
        AccionBitacora.consentimientoRetirado => 'Consentimiento retirado',
        AccionBitacora.medicamentoCreado => 'Medicamento creado',
        AccionBitacora.medicamentoEditado => 'Medicamento editado',
        AccionBitacora.medicamentoArchivado => 'Medicamento archivado',
        AccionBitacora.medicamentoEliminado => 'Medicamento eliminado',
        AccionBitacora.existenciaAjustada => 'Existencias ajustadas',
        AccionBitacora.tomaRegistrada => 'Toma registrada',
        AccionBitacora.tomaOmitida => 'Toma omitida',
        AccionBitacora.tomaPospuesta => 'Toma pospuesta',
        AccionBitacora.tomaCorregida => 'Toma corregida',
        AccionBitacora.vinculoCreado => 'Invitación a cuidador',
        AccionBitacora.vinculoAceptado => 'Vínculo aceptado',
        AccionBitacora.vinculoRechazado => 'Vínculo rechazado',
        AccionBitacora.vinculoRevocado => 'Vínculo revocado',
        AccionBitacora.permisosModificados => 'Permisos modificados',
        AccionBitacora.configuracionModificada => 'Configuración modificada',
        AccionBitacora.datosExportados => 'Datos exportados',
        AccionBitacora.cuentaEliminada => 'Cuenta eliminada',
        AccionBitacora.estadoCuentaCambiado => 'Estado de cuenta cambiado',
      };

  String get categoria => switch (this) {
        AccionBitacora.registro ||
        AccionBitacora.inicioSesion ||
        AccionBitacora.cierreSesion ||
        AccionBitacora.cambioPassword ||
        AccionBitacora.perfilActualizado ||
        AccionBitacora.estadoCuentaCambiado ||
        AccionBitacora.configuracionModificada =>
          'Cuenta',
        AccionBitacora.medicamentoCreado ||
        AccionBitacora.medicamentoEditado ||
        AccionBitacora.medicamentoArchivado ||
        AccionBitacora.medicamentoEliminado ||
        AccionBitacora.existenciaAjustada =>
          'Medicamentos',
        AccionBitacora.tomaRegistrada ||
        AccionBitacora.tomaOmitida ||
        AccionBitacora.tomaPospuesta ||
        AccionBitacora.tomaCorregida =>
          'Tomas',
        AccionBitacora.vinculoCreado ||
        AccionBitacora.vinculoAceptado ||
        AccionBitacora.vinculoRechazado ||
        AccionBitacora.vinculoRevocado ||
        AccionBitacora.permisosModificados =>
          'Cuidadores',
        AccionBitacora.consentimientoOtorgado ||
        AccionBitacora.consentimientoRetirado ||
        AccionBitacora.datosExportados ||
        AccionBitacora.cuentaEliminada =>
          'Privacidad y datos',
      };
}

const List<String> kCategoriasBitacora = [
  'Cuenta',
  'Medicamentos',
  'Tomas',
  'Cuidadores',
  'Privacidad y datos',
];

class EntradaBitacora {
  final String id;
  final DateTime fecha;

  /// Quién realizó la acción (correo) o `null` si el sistema la ejecutó.
  final String? actor;

  /// Paciente cuyos datos fueron afectados, si aplica.
  final String? paciente;
  final AccionBitacora accion;
  final String? tipoObjeto, objetoId, detalle;
  final String hashPrevio;
  final String hash;

  EntradaBitacora({
    required this.id,
    required this.fecha,
    required this.accion,
    required this.hashPrevio,
    this.actor,
    this.paciente,
    this.tipoObjeto,
    this.objetoId,
    this.detalle,
    String? hash,
  }) : hash = hash ?? '' {
    // `hash` se completa con [sellar] cuando no se recibe.
  }

  String _contenido() => [
        hashPrevio,
        id,
        fecha.toIso8601String(),
        actor ?? '',
        paciente ?? '',
        accion.name,
        tipoObjeto ?? '',
        objetoId ?? '',
        detalle ?? '',
      ].join('|');

  String calcularHash() =>
      sha256.convert(utf8.encode(_contenido())).toString();

  /// Devuelve una copia con el hash calculado.
  EntradaBitacora sellar(String hashPrevioNuevo) => EntradaBitacora(
        id: id,
        fecha: fecha,
        actor: actor,
        paciente: paciente,
        accion: accion,
        tipoObjeto: tipoObjeto,
        objetoId: objetoId,
        detalle: detalle,
        hashPrevio: hashPrevioNuevo,
      )._conHash();

  EntradaBitacora _conHash() => EntradaBitacora(
        id: id,
        fecha: fecha,
        actor: actor,
        paciente: paciente,
        accion: accion,
        tipoObjeto: tipoObjeto,
        objetoId: objetoId,
        detalle: detalle,
        hashPrevio: hashPrevio,
        hash: calcularHash(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fecha': fecha.toIso8601String(),
        'actor': actor,
        'paciente': paciente,
        'accion': accion.name,
        'tipoObjeto': tipoObjeto,
        'objetoId': objetoId,
        'detalle': detalle,
        'hashPrevio': hashPrevio,
        'hash': hash,
      };

  factory EntradaBitacora.fromJson(Map<String, dynamic> j) => EntradaBitacora(
        id: j['id'],
        fecha: DateTime.parse(j['fecha']),
        actor: j['actor'] as String?,
        paciente: j['paciente'] as String?,
        accion: _porNombre(
            AccionBitacora.values, j['accion'], AccionBitacora.inicioSesion),
        tipoObjeto: j['tipoObjeto'] as String?,
        objetoId: j['objetoId'] as String?,
        detalle: j['detalle'] as String?,
        hashPrevio: (j['hashPrevio'] as String?) ?? '',
        hash: (j['hash'] as String?) ?? '',
      );
}
