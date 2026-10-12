import 'package:flutter/foundation.dart';

import '../models/carrito_item_model.dart';
import '../models/producto.dart';

class CarritoViewModel extends ChangeNotifier {
  final List<CarritoItemModel> _items = [];

  List<CarritoItemModel> get items => List.unmodifiable(_items);

  bool get estaVacio => _items.isEmpty;

  int get cantidadTotalItems {
    return _items.fold(0, (total, item) => total + item.cantidad);
  }

  double get totalPagar {
    return _items.fold(0.0, (total, item) => total + item.subtotal);
  }

  bool agregarProducto(Producto producto, {int cantidad = 1}) {
    if (cantidad <= 0) {
      return false;
    }

    if (producto.stock <= 0 || !producto.disponible || !producto.activo) {
      return false;
    }

    final index = _items.indexWhere((item) => item.productoId == producto.id);

    if (index != -1) {
      final nuevaCantidad = _items[index].cantidad + cantidad;

      if (nuevaCantidad > producto.stock) {
        return false;
      }

      _items[index].cantidad = nuevaCantidad;
    } else {
      if (cantidad > producto.stock) {
        return false;
      }

      _items.add(
        CarritoItemModel(
          productoId: producto.id,
          nombre: producto.nombre,
          imagenUrl: producto.imagenUrl,
          precio: producto.precio,
          cantidad: cantidad,
        ),
      );
    }

    notifyListeners();
    return true;
  }

  bool incrementarCantidad(String productoId, int stockDisponible) {
    final index = _items.indexWhere((item) => item.productoId == productoId);

    if (index == -1) {
      return false;
    }

    if (_items[index].cantidad >= stockDisponible) {
      return false;
    }

    _items[index].cantidad++;

    notifyListeners();

    return true;
  }

  void decrementarCantidad(String productoId) {
    final index = _items.indexWhere((item) => item.productoId == productoId);

    if (index == -1) {
      return;
    }

    if (_items[index].cantidad > 1) {
      _items[index].cantidad--;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  bool cambiarCantidad(
    String productoId,
    int nuevaCantidad,
    int stockDisponible,
  ) {
    final index = _items.indexWhere((item) => item.productoId == productoId);

    if (index == -1) {
      return false;
    }

    if (nuevaCantidad <= 0) {
      _items.removeAt(index);

      notifyListeners();

      return true;
    }

    if (nuevaCantidad > stockDisponible) {
      return false;
    }

    _items[index].cantidad = nuevaCantidad;

    notifyListeners();

    return true;
  }

  void eliminarProducto(String productoId) {
    _items.removeWhere((item) => item.productoId == productoId);

    notifyListeners();
  }

  void vaciarCarrito() {
    _items.clear();

    notifyListeners();
  }

  bool contieneProducto(String productoId) {
    return _items.any((item) => item.productoId == productoId);
  }

  int cantidadDeProducto(String productoId) {
    final index = _items.indexWhere((item) => item.productoId == productoId);

    if (index == -1) {
      return 0;
    }

    return _items[index].cantidad;
  }
}
