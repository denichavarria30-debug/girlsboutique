import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/apartado.dart';

class ApartadoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Registrar un apartado y reducir el stock del producto
  Future<void> crearApartado(Apartado apartado) async {
    final batch = _db.batch();

    //Guardar apartados
    final nuevoApartadoRef = _db.collection('apartados').doc();
    batch.set(nuevoApartadoRef, apartado.toMap());

    //Descontar 1 del stock del producto
    final productoRef = _db.collection('productos').doc(apartado.productoId);
    batch.update(productoRef, {'stock': FieldValue.increment(-1)});

    await batch.commit();
  }

  // Obtener los apartados de un usuario específico en tiempo real
  Stream<List<Apartado>> getApartadosUsuario(String usuarioId) {
    return _db
        .collection('apartados')
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Apartado.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }
}
