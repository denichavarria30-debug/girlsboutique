import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriaModel {
  final String idCategoria;
  final String nombre;
  final String imagen;
  final bool activo;

  CategoriaModel({
    required this.idCategoria,
    required this.nombre,
    required this.imagen,
    this.activo = true,
  });

  // Convertir un DocumentSnapshot de Firestore a un objeto CategoriaModel
  factory CategoriaModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CategoriaModel(
      idCategoria: doc.id,
      nombre: data['nombre'] ?? '',
      imagen: data['imagen'] ?? '',
      activo: data['activo'] ?? true,
    );
  }

  // Convertir de Map (JSON) a CategoriaModel
  factory CategoriaModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoriaModel(
      idCategoria: id,
      nombre: map['nombre'] ?? '',
      imagen: map['imagen'] ?? '',
      activo: map['activo'] ?? true,
    );
  }

  // Convertir un objeto CategoriaModel a un Map para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {'nombre': nombre, 'imagen': imagen, 'activo': activo};
  }
}
