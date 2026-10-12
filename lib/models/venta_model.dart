import 'package:cloud_firestore/cloud_firestore.dart';

class DetalleVentaModel {
  final String productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;

  DetalleVentaModel({
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
  });

  double get subtotal => cantidad * precioUnitario;

  factory DetalleVentaModel.fromMap(Map<String, dynamic> map) {
    return DetalleVentaModel(
      productoId: map['productoId'] ?? '',
      nombreProducto: map['nombreProducto'] ?? '',
      cantidad: map['cantidad'] ?? 0,
      precioUnitario: (map['precioUnitario'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productoId': productoId,
      'nombreProducto': nombreProducto,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'subtotal': subtotal,
    };
  }
}

class VentaModel {
  final String idVenta;
  final DateTime fecha;
  final double total;
  final String metodoPago;
  final String usuarioId;
  final List<DetalleVentaModel> productos;

  VentaModel({
    required this.idVenta,
    required this.fecha,
    required this.total,
    required this.metodoPago,
    required this.usuarioId,
    required this.productos,
  });

  factory VentaModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    List<DetalleVentaModel> listaProductos = [];
    if (data['productos'] != null) {
      listaProductos =
          (data['productos'] as List)
              .map(
                (item) =>
                    DetalleVentaModel.fromMap(item as Map<String, dynamic>),
              )
              .toList();
    }

    return VentaModel(
      idVenta: doc.id,
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      total: (data['total'] ?? 0.0).toDouble(),
      metodoPago: data['metodoPago'] ?? 'Efectivo',
      usuarioId: data['usuarioId'] ?? '',
      productos: listaProductos,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fecha': Timestamp.fromDate(fecha),
      'total': total,
      'metodoPago': metodoPago,
      'usuarioId': usuarioId,
      'productos': productos.map((p) => p.toMap()).toList(),
    };
  }
}
