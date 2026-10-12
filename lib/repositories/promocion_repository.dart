import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promocion_model.dart';

class PromocionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crear o guardar una nueva promoción
  Future<void> crearPromocion(PromocionModel promocion) async {
    await _db.collection('promociones').add(promocion.toMap());
  }

  // Actualizar una promoción existente
  Future<void> actualizarPromocion(
    String idPromocion,
    Map<String, dynamic> datos,
  ) async {
    await _db.collection('promociones').doc(idPromocion).update(datos);
  }

  // Eliminar o desactivar una promoción
  Future<void> eliminarPromocion(String idPromocion) async {
    await _db.collection('promociones').doc(idPromocion).delete();
  }

  // Obtener todas las promociones activas en tiempo real
  Stream<List<PromocionModel>> obtenerPromocionesActivas() {
    return _db
        .collection('promociones')
        .where('activo', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PromocionModel.fromDocument(doc))
                  .where((promo) => promo.fechaFinal.isAfter(DateTime.now()))
                  .toList(),
        );
  }

  // Obtener todas las promociones
  Stream<List<PromocionModel>> obtenerTodasLasPromociones() {
    return _db
        .collection('promociones')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PromocionModel.fromDocument(doc))
                  .toList(),
        );
  }
}
