enum Rol { admin, paciente, cuidador }

extension RolX on Rol {
  String get label => switch (this) {
        Rol.admin => 'Administrador',
        Rol.paciente => 'Paciente',
        Rol.cuidador => 'Cuidador',
      };
}

class AppUser {
  final String nombre, email, password;
  final Rol rol;
  AppUser({required this.nombre, required this.email, required this.password, required this.rol});

  Map<String, dynamic> toJson() =>
      {'nombre': nombre, 'email': email, 'password': password, 'rol': rol.name};

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        nombre: j['nombre'],
        email: j['email'],
        password: j['password'],
        rol: Rol.values.byName(j['rol']),
      );
}

class Medicamento {
  final String id, nombre, dosis, hora, pacienteEmail;
  bool tomado;
  DateTime? tomadoEn;

  Medicamento({
    required this.id,
    required this.nombre,
    required this.dosis,
    required this.hora,
    required this.pacienteEmail,
    this.tomado = false,
    this.tomadoEn,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'dosis': dosis,
        'hora': hora,
        'pacienteEmail': pacienteEmail,
        'tomado': tomado,
        'tomadoEn': tomadoEn?.toIso8601String(),
      };

  factory Medicamento.fromJson(Map<String, dynamic> j) => Medicamento(
        id: j['id'],
        nombre: j['nombre'],
        dosis: j['dosis'],
        hora: j['hora'],
        pacienteEmail: j['pacienteEmail'],
        tomado: j['tomado'] ?? false,
        tomadoEn: j['tomadoEn'] == null ? null : DateTime.parse(j['tomadoEn']),
      );
}
