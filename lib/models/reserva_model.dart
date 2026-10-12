class ReservaModel {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final String productoId;
  final String productoNombre;
  final String talla;
  final double precio;
  final DateTime fechaReserva;
  final String estado;

  ReservaModel({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.productoId,
    required this.productoNombre,
    required this.talla,
    required this.precio,
    required this.fechaReserva,
    this.estado = 'Pendiente',
  });

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'productoId': productoId,
      'productoNombre': productoNombre,
      'talla': talla,
      'precio': precio,
      'fechaReserva': fechaReserva.toIso8601String(),
      'estado': estado,
    };
  }

  factory ReservaModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReservaModel(
      id: docId,
      clienteId: map['clienteId'] ?? '',
      clienteNombre: map['clienteNombre'] ?? '',
      productoId: map['productoId'] ?? '',
      productoNombre: map['productoNombre'] ?? '',
      talla: map['talla'] ?? '',
      precio: (map['precio'] as num?)?.toDouble() ?? 0.0,
      fechaReserva: DateTime.parse(map['fechaReserva']),
      estado: map['estado'] ?? 'Pendiente',
    );
  }
}
