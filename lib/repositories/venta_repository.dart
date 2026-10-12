import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/venta_model.dart';

class VentaRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> registrarVenta(VentaModel venta) async {
    await _db.runTransaction((transaction) async {
      final List<DocumentReference<Map<String, dynamic>>> referencias = [];
      final List<DocumentSnapshot<Map<String, dynamic>>> snapshots = [];

      for (final item in venta.productos) {
        final referencia = _db.collection('productos').doc(item.productoId);

        final snapshot = await transaction.get(referencia);

        referencias.add(referencia);
        snapshots.add(snapshot);
      }

      for (int i = 0; i < venta.productos.length; i++) {
        final item = venta.productos[i];
        final snapshot = snapshots[i];

        if (!snapshot.exists) {
          throw Exception('El producto ${item.nombreProducto} ya no existe.');
        }

        final datos = snapshot.data();

        if (datos == null) {
          throw Exception(
            'No se pudo obtener la información de ${item.nombreProducto}.',
          );
        }

        final int stockActual = (datos['stock'] as num?)?.toInt() ?? 0;

        final bool activo = datos['activo'] as bool? ?? true;

        if (!activo) {
          throw Exception('${item.nombreProducto} está desactivado.');
        }

        if (stockActual < item.cantidad) {
          throw Exception(
            'Stock insuficiente para ${item.nombreProducto}. '
            'Disponibles: $stockActual.',
          );
        }
      }

      for (int i = 0; i < venta.productos.length; i++) {
        final item = venta.productos[i];
        final snapshot = snapshots[i];
        final referencia = referencias[i];

        final datos = snapshot.data()!;

        final int stockActual = (datos['stock'] as num?)?.toInt() ?? 0;

        final int nuevoStock = stockActual - item.cantidad;

        transaction.update(referencia, {
          'stock': nuevoStock,
          'disponible': nuevoStock > 0,
        });
      }

      final ventaRef = _db.collection('ventas').doc();

      transaction.set(ventaRef, venta.toMap());
    });
  }

  Stream<List<VentaModel>> obtenerVentas() {
    return _db
        .collection('ventas')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => VentaModel.fromDocument(doc)).toList(),
        );
  }

  Future<List<VentaModel>> obtenerVentasDelDia() async {
    final hoy = DateTime.now();

    final inicioDia = DateTime(hoy.year, hoy.month, hoy.day);

    final finDia = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59, 999);

    final query =
        await _db
            .collection('ventas')
            .where(
              'fecha',
              isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia),
            )
            .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(finDia))
            .get();

    return query.docs.map((doc) => VentaModel.fromDocument(doc)).toList();
  }
}
