class CarritoItemModel {
  final String productoId;
  final String nombre;
  final String imagenUrl;
  final double precio;
  int cantidad;

  CarritoItemModel({
    required this.productoId,
    required this.nombre,
    required this.imagenUrl,
    required this.precio,
    this.cantidad = 1,
  });

  // Subtotal del carrito
  double get subtotal => precio * cantidad;

  // Crear desde Map
  factory CarritoItemModel.fromMap(Map<String, dynamic> map) {
    return CarritoItemModel(
      productoId: map['productoId']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      imagenUrl: map['imagenUrl']?.toString() ?? '',
      precio: (map['precio'] as num?)?.toDouble() ?? 0.0,
      cantidad: (map['cantidad'] as num?)?.toInt() ?? 1,
    );
  }

  // Convertir
  Map<String, dynamic> toMap() {
    return {
      'productoId': productoId,
      'nombre': nombre,
      'imagenUrl': imagenUrl,
      'precio': precio,
      'cantidad': cantidad,
      'subtotal': subtotal,
    };
  }
}
