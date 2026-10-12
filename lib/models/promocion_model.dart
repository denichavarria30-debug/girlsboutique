import 'package:cloud_firestore/cloud_firestore.dart';

class PromocionModel {
  final String idPromocion;
  final String titulo;
  final String descripcion;
  final String imagen;
  final double descuento;
  final DateTime fechaInicio;
  final DateTime fechaFinal;
  final bool activo;
  final List<String> productosParticipantes;

  PromocionModel({
    required this.idPromocion,
    required this.titulo,
    required this.descripcion,
    required this.imagen,
    required this.descuento,
    required this.fechaInicio,
    required this.fechaFinal,
    this.activo = true,
    this.productosParticipantes = const [],
  });

  // Convertir un DocumentSnapshot de Firestore a un objeto PromocionModel
  factory PromocionModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PromocionModel(
      idPromocion: doc.id,
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      imagen: data['imagen'] ?? '',
      descuento: (data['descuento'] ?? 0.0).toDouble(),
      fechaInicio:
          (data['fechaInicio'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaFinal:
          (data['fechaFinal'] as Timestamp?)?.toDate() ?? DateTime.now(),
      activo: data['activo'] ?? true,
      productosParticipantes: List<String>.from(
        data['productosParticipantes'] ?? [],
      ),
    );
  }

  // Convertir un objeto PromocionModel a Map para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'imagen': imagen,
      'descuento': descuento,
      'fechaInicio': Timestamp.fromDate(fechaInicio),
      'fechaFinal': Timestamp.fromDate(fechaFinal),
      'activo': activo,
      'productosParticipantes': productosParticipantes,
    };
  }
}
