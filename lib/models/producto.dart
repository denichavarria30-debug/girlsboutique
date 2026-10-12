import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String categoria;
  final String imagenUrl;
  final List<String> tallas;
  final int stock;
  final bool disponible;
  final bool activo;
  final bool promocion;
  final DateTime fechaRegistro;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    required this.imagenUrl,
    this.tallas = const [],
    required this.stock,
    required this.disponible,
    this.activo = true,
    this.promocion = false,
    required this.fechaRegistro,
  });

  // Convierte Producto a Map para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'categoria': categoria,
      'imagenUrl': imagenUrl,
      'tallas': tallas,
      'stock': stock,
      'disponible': disponible,
      'activo': activo,
      'promocion': promocion,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
    };
  }

  // Crea un Producto desde Firestore
  factory Producto.fromFirestore(Map<String, dynamic> map, String docId) {
    final fecha = map['fechaRegistro'];

    return Producto(
      id: docId,
      nombre: map['nombre']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
      precio: (map['precio'] as num?)?.toDouble() ?? 0.0,
      categoria: map['categoria']?.toString() ?? 'General',
      imagenUrl: map['imagenUrl']?.toString() ?? '',
      tallas: List<String>.from(map['tallas'] ?? []),
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      disponible: map['disponible'] as bool? ?? false,
      activo: map['activo'] as bool? ?? true,
      promocion: map['promocion'] as bool? ?? false,
      fechaRegistro: fecha is Timestamp ? fecha.toDate() : DateTime.now(),
    );
  }

  Producto copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    double? precio,
    String? categoria,
    String? imagenUrl,
    List<String>? tallas,
    int? stock,
    bool? disponible,
    bool? activo,
    bool? promocion,
    DateTime? fechaRegistro,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      categoria: categoria ?? this.categoria,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      tallas: tallas ?? this.tallas,
      stock: stock ?? this.stock,
      disponible: disponible ?? this.disponible,
      activo: activo ?? this.activo,
      promocion: promocion ?? this.promocion,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  Map<String, dynamic> toMap() => toFirestore();

  factory Producto.fromMap(Map<String, dynamic> map, String id) =>
      Producto.fromFirestore(map, id);
}
