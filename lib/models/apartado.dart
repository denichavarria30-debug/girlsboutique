import 'package:cloud_firestore/cloud_firestore.dart';

class Apartado {
  final String id;
  final String usuarioId;

  final String productoId;
  final String nombreProducto;
  final String imagenUrl;

  final double precio;
  final int cantidad;

  final String talla;

  final DateTime fechaApartado;
  final DateTime fechaLimite;

  final double total;
  final double anticipo;
  final double saldoPendiente;

  final String estado;

  Apartado({
    required this.id,
    required this.usuarioId,
    required this.productoId,
    required this.nombreProducto,
    required this.imagenUrl,
    required this.precio,
    this.cantidad = 1,
    this.talla = '',
    required this.fechaApartado,
    required this.fechaLimite,
    required this.total,
    required this.anticipo,
    required this.saldoPendiente,
    this.estado = 'Pendiente',
  });

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'productoId': productoId,
      'nombreProducto': nombreProducto,
      'imagenUrl': imagenUrl,
      'precio': precio,
      'cantidad': cantidad,
      'talla': talla,
      'fechaApartado': Timestamp.fromDate(fechaApartado),
      'fechaLimite': Timestamp.fromDate(fechaLimite),
      'total': total,
      'anticipo': anticipo,
      'saldoPendiente': saldoPendiente,
      'estado': estado,
    };
  }

  factory Apartado.fromFirestore(Map<String, dynamic> map, String docId) {
    final fechaApartado = map['fechaApartado'];
    final fechaLimite = map['fechaLimite'];

    return Apartado(
      id: docId,

      usuarioId: map['usuarioId']?.toString() ?? '',

      productoId: map['productoId']?.toString() ?? '',

      nombreProducto:
          map['nombreProducto']?.toString() ??
          map['productoNombre']?.toString() ??
          'Producto',

      imagenUrl: map['imagenUrl']?.toString() ?? '',

      precio: (map['precio'] as num?)?.toDouble() ?? 0.0,

      cantidad: (map['cantidad'] as num?)?.toInt() ?? 1,

      talla: map['talla']?.toString() ?? '',

      fechaApartado:
          fechaApartado is Timestamp ? fechaApartado.toDate() : DateTime.now(),

      fechaLimite:
          fechaLimite is Timestamp
              ? fechaLimite.toDate()
              : DateTime.now().add(const Duration(days: 7)),

      total:
          (map['total'] as num?)?.toDouble() ??
          (map['precio'] as num?)?.toDouble() ??
          0.0,

      anticipo: (map['anticipo'] as num?)?.toDouble() ?? 0.0,

      saldoPendiente: (map['saldoPendiente'] as num?)?.toDouble() ?? 0.0,

      estado: _normalizarEstado(map['estado']?.toString() ?? 'Pendiente'),
    );
  }

  static String _normalizarEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmado':
        return 'Confirmado';

      case 'recogido':
        return 'Recogido';

      case 'cancelado':
        return 'Cancelado';

      case 'vencido':
        return 'Vencido';

      default:
        return 'Pendiente';
    }
  }

  Apartado copyWith({
    String? id,
    String? usuarioId,
    String? productoId,
    String? nombreProducto,
    String? imagenUrl,
    double? precio,
    int? cantidad,
    String? talla,
    DateTime? fechaApartado,
    DateTime? fechaLimite,
    double? total,
    double? anticipo,
    double? saldoPendiente,
    String? estado,
  }) {
    return Apartado(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      productoId: productoId ?? this.productoId,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      precio: precio ?? this.precio,
      cantidad: cantidad ?? this.cantidad,
      talla: talla ?? this.talla,
      fechaApartado: fechaApartado ?? this.fechaApartado,
      fechaLimite: fechaLimite ?? this.fechaLimite,
      total: total ?? this.total,
      anticipo: anticipo ?? this.anticipo,
      saldoPendiente: saldoPendiente ?? this.saldoPendiente,
      estado: estado ?? this.estado,
    );
  }
}
