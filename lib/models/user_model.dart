class UserModel {
  final String uid;
  final String nombre;
  final String telefono;
  final String correo;
  final String rol;

  UserModel({
    required this.uid,
    required this.nombre,
    required this.telefono,
    required this.correo,
    required this.rol,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      nombre: map['nombre']?.toString() ?? '',
      telefono: map['telefono']?.toString() ?? '',
      correo: map['correo']?.toString() ?? '',
      rol: map['rol']?.toString().trim().toLowerCase() ?? 'cliente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre.trim(),
      'telefono': telefono.trim(),
      'correo': correo.trim(),
      'rol': rol.trim().toLowerCase(),
    };
  }
}
