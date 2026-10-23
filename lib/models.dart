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
  final int edad;
  final Rol rol;
  AppUser({
    required this.nombre,
    required this.edad,
    required this.email,
    required this.password,
    required this.rol,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'edad': edad,
        'email': email,
        'password': password,
        'rol': rol.name,
      };

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        nombre: j['nombre'],
        edad: j['edad'],
        email: j['email'],
        password: j['password'],
        rol: Rol.values.byName(j['rol']),
      );
}

class Medicamento {
  final String id, pacienteEmail;
  String nombre, dosis, hora, info; // hora en formato HH:mm
  Medicamento({
    required this.id,
    required this.nombre,
    required this.dosis,
    required this.hora,
    required this.info,
    required this.pacienteEmail,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'dosis': dosis,
        'hora': hora,
        'info': info,
        'pacienteEmail': pacienteEmail,
      };

  factory Medicamento.fromJson(Map<String, dynamic> j) => Medicamento(
        id: j['id'],
        nombre: j['nombre'],
        dosis: j['dosis'],
        hora: j['hora'],
        info: j['info'] ?? '',
        pacienteEmail: j['pacienteEmail'],
      );
}

class Cuidador {
  final String id, pacienteEmail;
  String nombre, parentesco, contacto;
  Cuidador({
    required this.id,
    required this.nombre,
    required this.parentesco,
    required this.contacto,
    required this.pacienteEmail,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'parentesco': parentesco,
        'contacto': contacto,
        'pacienteEmail': pacienteEmail,
      };

  factory Cuidador.fromJson(Map<String, dynamic> j) => Cuidador(
        id: j['id'],
        nombre: j['nombre'],
        parentesco: j['parentesco'],
        contacto: j['contacto'],
        pacienteEmail: j['pacienteEmail'],
      );
}

/// Registro de una toma confirmada (alimenta Historial y Racha).
class Toma {
  final String id, medId, nombre, dosis, pacienteEmail;
  final DateTime fecha;
  Toma({
    required this.id,
    required this.medId,
    required this.nombre,
    required this.dosis,
    required this.pacienteEmail,
    required this.fecha,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'medId': medId,
        'nombre': nombre,
        'dosis': dosis,
        'pacienteEmail': pacienteEmail,
        'fecha': fecha.toIso8601String(),
      };

  factory Toma.fromJson(Map<String, dynamic> j) => Toma(
        id: j['id'],
        medId: j['medId'],
        nombre: j['nombre'],
        dosis: j['dosis'],
        pacienteEmail: j['pacienteEmail'],
        fecha: DateTime.parse(j['fecha']),
      );
}
