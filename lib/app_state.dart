import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// Manejo de estado: Provider (ChangeNotifier) + persistencia local.
class AppState extends ChangeNotifier {
  List<AppUser> users = [];
  List<Medicamento> meds = [];
  AppUser? current;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    users = (jsonDecode(p.getString('users') ?? '[]') as List)
        .map((e) => AppUser.fromJson(e))
        .toList();
    meds = (jsonDecode(p.getString('meds') ?? '[]') as List)
        .map((e) => Medicamento.fromJson(e))
        .toList();
    final session = p.getString('session');
    for (final u in users) {
      if (u.email == session) current = u;
    }
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('users', jsonEncode(users.map((e) => e.toJson()).toList()));
    await p.setString('meds', jsonEncode(meds.map((e) => e.toJson()).toList()));
    if (current == null) {
      await p.remove('session');
    } else {
      await p.setString('session', current!.email);
    }
  }

  // ---------- Autenticación ----------
  String? register(String nombre, String email, String pass, Rol rol) {
    email = email.trim().toLowerCase();
    if (users.any((u) => u.email == email)) return 'Ese correo ya está registrado';
    final u = AppUser(nombre: nombre.trim(), email: email, password: pass, rol: rol);
    users.add(u);
    current = u;
    _save();
    notifyListeners();
    return null;
  }

  String? login(String email, String pass) {
    email = email.trim().toLowerCase();
    for (final u in users) {
      if (u.email == email && u.password == pass) {
        current = u;
        _save();
        notifyListeners();
        return null;
      }
    }
    return 'Correo o contraseña incorrectos';
  }

  void logout() {
    current = null;
    _save();
    notifyListeners();
  }

  // ---------- Datos ----------
  List<AppUser> get pacientes => users.where((u) => u.rol == Rol.paciente).toList();

  /// El paciente solo ve lo suyo; admin y cuidador ven todo.
  List<Medicamento> get visibles {
    final l = current?.rol == Rol.paciente
        ? meds.where((m) => m.pacienteEmail == current!.email).toList()
        : [...meds];
    l.sort((a, b) => a.hora.compareTo(b.hora));
    return l;
  }

  List<Medicamento> get historial =>
      visibles.where((m) => m.tomado).toList()
        ..sort((a, b) => b.tomadoEn!.compareTo(a.tomadoEn!));

  String nombreDe(String email) =>
      users.firstWhere((u) => u.email == email,
          orElse: () => AppUser(nombre: email, email: email, password: '', rol: Rol.paciente)).nombre;

  void addMed(String nombre, String dosis, String hora, String pacienteEmail) {
    meds.add(Medicamento(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nombre: nombre.trim(),
      dosis: dosis.trim(),
      hora: hora,
      pacienteEmail: pacienteEmail,
    ));
    _save();
    notifyListeners();
  }

  void toggleTomado(Medicamento m) {
    m.tomado = !m.tomado;
    m.tomadoEn = m.tomado ? DateTime.now() : null;
    _save();
    notifyListeners();
  }

  void deleteMed(Medicamento m) {
    meds.removeWhere((e) => e.id == m.id);
    _save();
    notifyListeners();
  }
}
