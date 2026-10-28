import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

bool mismoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Manejo de estado: Provider (ChangeNotifier) + persistencia local.
class AppState extends ChangeNotifier {
  List<AppUser> users = [];
  List<Medicamento> meds = [];
  List<Cuidador> cuidadores = [];
  List<Toma> tomas = [];
  /// Existencias del botiquín: id de medicamento -> cantidad disponible.
  Map<String, int> existencias = {};
  AppUser? current;

  /// Recordatorios pospuestos (solo en memoria).
  final Map<String, DateTime> snoozeUntil = {};

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  // ---------- Persistencia ----------
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    List<dynamic> l(String k) => jsonDecode(p.getString(k) ?? '[]') as List;
    users = l('users').map((e) => AppUser.fromJson(e)).toList();
    meds = l('meds').map((e) => Medicamento.fromJson(e)).toList();
    cuidadores = l('cuidadores').map((e) => Cuidador.fromJson(e)).toList();
    tomas = l('tomas').map((e) => Toma.fromJson(e)).toList();
    final ex = jsonDecode(p.getString('existencias') ?? '{}') as Map<String, dynamic>;
    existencias = ex.map((k, v) => MapEntry(k, (v as num).toInt()));
    final session = p.getString('session');
    for (final u in users) {
      if (u.email == session) current = u;
    }
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('users', jsonEncode(users.map((e) => e.toJson()).toList()));
    await p.setString('meds', jsonEncode(meds.map((e) => e.toJson()).toList()));
    await p.setString('cuidadores', jsonEncode(cuidadores.map((e) => e.toJson()).toList()));
    await p.setString('tomas', jsonEncode(tomas.map((e) => e.toJson()).toList()));
    await p.setString('existencias', jsonEncode(existencias));
    if (current == null) {
      await p.remove('session');
    } else {
      await p.setString('session', current!.email);
    }
  }

  void _changed() {
    _save();
    notifyListeners();
  }

  // ---------- Autenticación ----------
  String? register(String nombre, int edad, String email, String pass, Rol rol) {
    email = email.trim().toLowerCase();
    if (users.any((u) => u.email == email)) return 'Ese correo ya está registrado';
    final u = AppUser(nombre: nombre.trim(), edad: edad, email: email, password: pass, rol: rol);
    users.add(u);
    current = u;
    _changed();
    return null;
  }

  String? login(String email, String pass) {
    email = email.trim().toLowerCase();
    for (final u in users) {
      if (u.email == email && u.password == pass) {
        current = u;
        _changed();
        return null;
      }
    }
    return 'Correo o contraseña incorrectos';
  }

  void logout() {
    current = null;
    _changed();
  }

  // ---------- Consultas ----------
  List<AppUser> get pacientes => users.where((u) => u.rol == Rol.paciente).toList();

  bool get _soloPropio => current?.rol == Rol.paciente;

  /// El paciente ve solo lo suyo; cuidador y admin ven todo.
  List<Medicamento> get visibleMeds {
    final l = _soloPropio
        ? meds.where((m) => m.pacienteEmail == current!.email).toList()
        : [...meds];
    l.sort((a, b) => a.hora.compareTo(b.hora));
    return l;
  }

  List<Medicamento> medsDe(String email) {
    final l = meds.where((m) => m.pacienteEmail == email).toList();
    l.sort((a, b) => a.hora.compareTo(b.hora));
    return l;
  }

  List<Cuidador> get misCuidadores =>
      cuidadores.where((c) => c.pacienteEmail == current?.email).toList();

  String nombreDe(String email) {
    for (final u in users) {
      if (u.email == email) return u.nombre;
    }
    return email;
  }

  bool tomadoHoy(Medicamento m) {
    final now = DateTime.now();
    return tomas.any((t) => t.medId == m.id && mismoDia(t.fecha, now));
  }

  int pendientesHoy(String email) =>
      medsDe(email).where((m) => !tomadoHoy(m)).length;

  int get tomasHoy => tomas.where((t) => mismoDia(t.fecha, DateTime.now())).length;

  List<Toma> tomasDelDia(DateTime f) {
    final l = tomas
        .where((t) => mismoDia(t.fecha, f) && (!_soloPropio || t.pacienteEmail == current!.email))
        .toList();
    l.sort((a, b) => a.fecha.compareTo(b.fecha));
    return l;
  }

  /// Número de tomas por día de los últimos [n] días (para la gráfica).
  List<int> conteoUltimosDias(int n) {
    final hoy = DateTime.now();
    return [
      for (var i = n - 1; i >= 0; i--)
        tomasDelDia(DateTime(hoy.year, hoy.month, hoy.day - i)).length,
    ];
  }

  int racha(String email) {
    final dias = tomas
        .where((t) => t.pacienteEmail == email)
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
  void addMed(String nombre, String dosis, String hora, String info, String pacienteEmail) {
    meds.add(Medicamento(
      id: _id(),
      nombre: nombre.trim(),
      dosis: dosis.trim(),
      hora: hora,
      info: info.trim(),
      pacienteEmail: pacienteEmail,
    ));
    _changed();
  }

  void updateMed(Medicamento m, String nombre, String dosis, String hora, String info) {
    m.nombre = nombre.trim();
    m.dosis = dosis.trim();
    m.hora = hora;
    m.info = info.trim();
    _changed();
  }

  void deleteMed(Medicamento m) {
    meds.removeWhere((e) => e.id == m.id);
    existencias.remove(m.id);
    _changed();
  }

  /// Marca el medicamento como tomado una sola vez al día y devuelve la racha.
  /// Si ya existe una toma de hoy, no crea otro registro.
  int marcarTomado(Medicamento m) {
    if (tomadoHoy(m)) {
      snoozeUntil.remove(m.id);
      return racha(m.pacienteEmail);
    }

    tomas.add(Toma(
      id: _id(),
      medId: m.id,
      nombre: m.nombre,
      dosis: m.dosis,
      pacienteEmail: m.pacienteEmail,
      fecha: DateTime.now(),
    ));

    snoozeUntil.remove(m.id);
    _changed();

    return racha(m.pacienteEmail);
  }

  void desmarcar(Medicamento m) {
    final now = DateTime.now();
    tomas.removeWhere((t) => t.medId == m.id && mismoDia(t.fecha, now));
    _changed();
  }

  void posponer(Medicamento m) {
    snoozeUntil[m.id] = DateTime.now().add(const Duration(minutes: 10));
    notifyListeners();
  }

  // ---------- Botiquín ----------
  int existenciaDe(String medId) => existencias[medId] ?? 0;

  void setExistencia(String medId, int cantidad) {
    existencias[medId] = cantidad < 0 ? 0 : cantidad;
    _changed();
  }

  // ---------- Cuidadores ----------
  void addCuidador(String nombre, String parentesco, String contacto) {
    cuidadores.add(Cuidador(
      id: _id(),
      nombre: nombre.trim(),
      parentesco: parentesco.trim(),
      contacto: contacto.trim(),
      pacienteEmail: current!.email,
    ));
    _changed();
  }

  void updateCuidador(Cuidador c, String nombre, String parentesco, String contacto) {
    c.nombre = nombre.trim();
    c.parentesco = parentesco.trim();
    c.contacto = contacto.trim();
    _changed();
  }

  void deleteCuidador(Cuidador c) {
    cuidadores.removeWhere((e) => e.id == c.id);
    _changed();
  }
}
