import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:girls_boutique_app/models/reserva_model.dart';

class ReservaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear una nueva reserva y actualizar el stock en una transacción
  Future<void> crearReserva(ReservaModel reserva, int stockActual) async {
    final DocumentReference productoRef = _firestore
        .collection('productos')
        .doc(reserva.productoId);
    final DocumentReference reservaRef =
        _firestore.collection('reservas').doc();

    return _firestore.runTransaction((transaction) async {
      // Verificar disponibilidad antes de apartar
      final snapshot = await transaction.get(productoRef);
      if (!snapshot.exists) {
        throw Exception("El producto ya no existe.");
      }

      final data = snapshot.data() as Map<String, dynamic>?;
      final int stockEnBD = data?['stock'] ?? 0;

      if (stockEnBD <= 0) {
        throw Exception("El producto ya no tiene stock disponible.");
      }

      // Guardar el registro de la reserva
      transaction.set(reservaRef, reserva.toMap());

      // Descontar 1 del stock del producto
      final int nuevoStock = stockEnBD - 1;
      transaction.update(productoRef, {
        'stock': nuevoStock,
        'disponible':
            nuevoStock > 0, // Si llega a 0 se marca como no disponible
      });
    });
  }

  // Obtener las reservas asociadas a un cliente específico en tiempo real
  Stream<List<ReservaModel>> getReservasPorCliente(String clienteId) {
    return _firestore
        .collection('reservas')
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('fechaReserva', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ReservaModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Permitir al cliente cancelar su apartado
  Future<void> cancelarReserva(String reservaId, String productoId) async {
    final DocumentReference reservaRef = _firestore
        .collection('reservas')
        .doc(reservaId);
    final DocumentReference productoRef = _firestore
        .collection('productos')
        .doc(productoId);

    return _firestore.runTransaction((transaction) async {
      // Eliminar reserva
      transaction.delete(reservaRef);

      // Devolver +1 al stock del producto
      transaction.update(productoRef, {
        'stock': FieldValue.increment(1),
        'disponible': true,
      });
    });
  }

  // Obtener TODAS las reservas registradas (para el panel de administración)
  Stream<List<ReservaModel>> getTodasLasReservas() {
    return _firestore
        .collection('reservas')
        .orderBy('fechaReserva', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ReservaModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Cambiar el estado de una reserva
  Future<void> cambiarEstadoReserva(
    String reservaId,
    String nuevoEstado,
  ) async {
    await _firestore.collection('reservas').doc(reservaId).update({
      'estado': nuevoEstado,
    });
  }

  // Rechazar o rechazar con devolución de stock (cuando la admin rechaza)
  Future<void> rechazarReservaAdmin(String reservaId, String productoId) async {
    final DocumentReference reservaRef = _firestore
        .collection('reservas')
        .doc(reservaId);
    final DocumentReference productoRef = _firestore
        .collection('productos')
        .doc(productoId);

    return _firestore.runTransaction((transaction) async {
      // Marcar como Rechazado
      transaction.update(reservaRef, {'estado': 'Rechazado'});

      // Regresar la prenda al stock
      transaction.update(productoRef, {
        'stock': FieldValue.increment(1),
        'disponible': true,
      });
    });
  }
}
