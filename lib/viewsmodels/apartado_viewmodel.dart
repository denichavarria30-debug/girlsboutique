import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/apartado.dart';
import '../models/producto.dart';

class ApartadoViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _cargando = false;
  String? _error;

  bool get cargando => _cargando;
  String? get error => _error;

  Future<bool> crearApartado({
    required Producto producto,
    int cantidad = 1,
    String talla = '',
    double porcentajeAnticipo = 0.20,
  }) async {
    try {
      _cargando = true;
      _error = null;
      notifyListeners();

      final usuario = _auth.currentUser;

      if (usuario == null) {
        _error = 'Debes iniciar sesión para realizar un apartado.';
        return false;
      }

      if (cantidad <= 0) {
        _error = 'La cantidad no es válida.';
        return false;
      }

      if (producto.stock < cantidad) {
        _error = 'No hay suficiente stock.';
        return false;
      }

      if (!producto.activo || !producto.disponible) {
        _error = 'Este producto no está disponible.';
        return false;
      }

      final total = producto.precio * cantidad;
      final anticipo = total * porcentajeAnticipo;
      final saldo = total - anticipo;

      final ahora = DateTime.now();
      final fechaLimite = ahora.add(const Duration(days: 7));

      final doc = _db.collection('apartados').doc();

      final apartado = Apartado(
        id: doc.id,
        usuarioId: usuario.uid,
        productoId: producto.id,
        nombreProducto: producto.nombre,
        imagenUrl: producto.imagenUrl,
        precio: producto.precio,
        cantidad: cantidad,
        talla: talla,
        fechaApartado: ahora,
        fechaLimite: fechaLimite,
        total: total,
        anticipo: anticipo,
        saldoPendiente: saldo,
        estado: 'Pendiente',
      );

      await doc.set(apartado.toMap());

      return true;
    } catch (e) {
      _error = 'No se pudo guardar el apartado: $e';

      debugPrint(_error);

      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Stream<List<Apartado>> getMisApartados() {
    return _auth.authStateChanges().asyncExpand((usuario) {
      if (usuario == null) {
        return Stream.value(<Apartado>[]);
      }

      return _db
          .collection('apartados')
          .where('usuarioId', isEqualTo: usuario.uid)
          .snapshots()
          .map((snapshot) {
            final lista =
                snapshot.docs
                    .map((doc) => Apartado.fromFirestore(doc.data(), doc.id))
                    .toList();

            lista.sort((a, b) => b.fechaApartado.compareTo(a.fechaApartado));

            return lista;
          });
    });
  }

  Stream<List<Apartado>> getTodosApartados() {
    return _db.collection('apartados').snapshots().map((snapshot) {
      final lista =
          snapshot.docs
              .map((doc) => Apartado.fromFirestore(doc.data(), doc.id))
              .toList();

      lista.sort((a, b) => b.fechaApartado.compareTo(a.fechaApartado));

      return lista;
    });
  }

  Future<bool> cambiarEstado(String apartadoId, String nuevoEstado) async {
    try {
      _error = null;

      await _db.collection('apartados').doc(apartadoId).update({
        'estado': nuevoEstado,
      });

      notifyListeners();

      return true;
    } catch (e) {
      _error = 'No se pudo cambiar el estado: $e';

      notifyListeners();

      return false;
    }
  }

  Future<bool> confirmarApartado(String apartadoId) {
    return cambiarEstado(apartadoId, 'Confirmado');
  }

  Future<bool> marcarRecogido(String apartadoId) {
    return cambiarEstado(apartadoId, 'Recogido');
  }

  Future<bool> cancelarApartado(String apartadoId) {
    return cambiarEstado(apartadoId, 'Cancelado');
  }

  Future<bool> marcarVencido(String apartadoId) {
    return cambiarEstado(apartadoId, 'Vencido');
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}
