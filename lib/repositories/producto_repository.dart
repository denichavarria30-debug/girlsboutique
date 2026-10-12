import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:girls_boutique_app/models/producto.dart';

class ProductoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _productos =>
      _db.collection('productos');

  // Obtener todos los productos
  Stream<List<Producto>> getProductos() {
    return _productos
        .orderBy('fechaRegistro', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Producto.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  // Obtener productos activos
  Stream<List<Producto>> getProductosActivos() {
    return _productos.where('activo', isEqualTo: true).snapshots().map((
      snapshot,
    ) {
      final productos =
          snapshot.docs
              .map((doc) => Producto.fromFirestore(doc.data(), doc.id))
              .toList();

      productos.sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));

      return productos;
    });
  }

  // Obtener productos por categoría
  Stream<List<Producto>> getProductosPorCategoria(String categoria) {
    return _productos
        .where('categoria', isEqualTo: categoria)
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final productos =
              snapshot.docs
                  .map((doc) => Producto.fromFirestore(doc.data(), doc.id))
                  .toList();

          productos.sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));

          return productos;
        });
  }

  // Obtener producto por ID
  Future<Producto?> getProductoPorId(String id) async {
    final doc = await _productos.doc(id).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return Producto.fromFirestore(doc.data()!, doc.id);
  }

  // Agregar producto
  Future<String> agregarProducto(Producto producto) async {
    final doc = await _productos.add(producto.toFirestore());

    return doc.id;
  }

  // Actualizar producto
  Future<void> actualizarProducto(Producto producto) async {
    if (producto.id.isEmpty) {
      throw Exception('No se puede actualizar un producto sin ID.');
    }

    await _productos.doc(producto.id).update(producto.toFirestore());
  }

  // Desactivar producto
  Future<void> desactivarProducto(String id) async {
    if (id.isEmpty) {
      throw Exception('No se puede desactivar un producto sin ID.');
    }

    await _productos.doc(id).update({'activo': false});
  }

  Future<void> eliminarProducto(String id) async {
    await desactivarProducto(id);
  }

  // Reactivar producto
  Future<void> reactivarProducto(String id) async {
    if (id.isEmpty) {
      throw Exception('No se puede reactivar un producto sin ID.');
    }

    await _productos.doc(id).update({'activo': true});
  }

  // Actualizar stock
  Future<void> actualizarStock(String id, int nuevoStock) async {
    if (id.isEmpty) {
      throw Exception('No se puede actualizar el stock sin ID.');
    }

    if (nuevoStock < 0) {
      throw Exception('El stock no puede ser negativo.');
    }

    await _productos.doc(id).update({
      'stock': nuevoStock,
      'disponible': nuevoStock > 0,
    });
  }
}
