import 'package:flutter/foundation.dart';
import '../models/venta_model.dart';
import '../models/producto.dart';
import '../repositories/venta_repository.dart';

class VentaViewModel extends ChangeNotifier {
  final VentaRepository _ventaRepository;

  final List<DetalleVentaModel> _productosVentaActual = [];

  String _metodoPago = 'Efectivo';
  bool _cargando = false;
  String? _error;

  List<VentaModel> _historialVentas = [];

  VentaViewModel({VentaRepository? ventaRepository})
    : _ventaRepository = ventaRepository ?? VentaRepository();

  List<DetalleVentaModel> get productosVentaActual =>
      List.unmodifiable(_productosVentaActual);

  String get metodoPago => _metodoPago;

  bool get cargando => _cargando;

  String? get error => _error;

  List<VentaModel> get historialVentas => List.unmodifiable(_historialVentas);

  bool get ventaVacia => _productosVentaActual.isEmpty;

  int get cantidadTotalProductos {
    return _productosVentaActual.fold(0, (sum, item) => sum + item.cantidad);
  }

  double get totalVenta {
    return _productosVentaActual.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  void cambiarMetodoPago(String nuevoMetodo) {
    if (nuevoMetodo != 'Efectivo' && nuevoMetodo != 'Transferencia') {
      return;
    }

    _metodoPago = nuevoMetodo;
    notifyListeners();
  }

  bool agregarProductoAVenta(Producto producto, {int cantidad = 1}) {
    _error = null;

    if (cantidad <= 0) {
      _error = 'Cantidad inválida.';
      notifyListeners();
      return false;
    }

    if (!producto.activo || !producto.disponible || producto.stock <= 0) {
      _error = 'El producto no está disponible.';
      notifyListeners();
      return false;
    }

    final index = _productosVentaActual.indexWhere(
      (item) => item.productoId == producto.id,
    );

    if (index != -1) {
      final item = _productosVentaActual[index];

      final nuevaCantidad = item.cantidad + cantidad;

      if (nuevaCantidad > producto.stock) {
        _error = 'No hay suficiente stock de ${producto.nombre}.';
        notifyListeners();
        return false;
      }

      _productosVentaActual[index] = DetalleVentaModel(
        productoId: producto.id,
        nombreProducto: producto.nombre,
        cantidad: nuevaCantidad,
        precioUnitario: producto.precio,
      );
    } else {
      if (cantidad > producto.stock) {
        _error = 'No hay suficiente stock de ${producto.nombre}.';
        notifyListeners();
        return false;
      }

      _productosVentaActual.add(
        DetalleVentaModel(
          productoId: producto.id,
          nombreProducto: producto.nombre,
          cantidad: cantidad,
          precioUnitario: producto.precio,
        ),
      );
    }

    notifyListeners();
    return true;
  }

  bool incrementarCantidad(Producto producto) {
    final index = _productosVentaActual.indexWhere(
      (item) => item.productoId == producto.id,
    );

    if (index == -1) {
      return agregarProductoAVenta(producto);
    }

    final item = _productosVentaActual[index];

    final nuevaCantidad = item.cantidad + 1;

    if (nuevaCantidad > producto.stock) {
      _error = 'No hay más stock disponible.';
      notifyListeners();
      return false;
    }

    _productosVentaActual[index] = DetalleVentaModel(
      productoId: item.productoId,
      nombreProducto: item.nombreProducto,
      cantidad: nuevaCantidad,
      precioUnitario: item.precioUnitario,
    );

    notifyListeners();
    return true;
  }

  void disminuirCantidad(String productoId) {
    final index = _productosVentaActual.indexWhere(
      (item) => item.productoId == productoId,
    );

    if (index == -1) return;

    final item = _productosVentaActual[index];

    if (item.cantidad <= 1) {
      _productosVentaActual.removeAt(index);
    } else {
      _productosVentaActual[index] = DetalleVentaModel(
        productoId: item.productoId,
        nombreProducto: item.nombreProducto,
        cantidad: item.cantidad - 1,
        precioUnitario: item.precioUnitario,
      );
    }

    notifyListeners();
  }

  void quitarProductoDeVenta(String productoId) {
    _productosVentaActual.removeWhere((item) => item.productoId == productoId);

    notifyListeners();
  }

  void cancelarVenta() {
    _productosVentaActual.clear();
    _metodoPago = 'Efectivo';
    _error = null;

    notifyListeners();
  }

  Future<bool> confirmarVenta(String adminId) async {
    if (_productosVentaActual.isEmpty) {
      _error = 'Agrega productos a la venta.';
      notifyListeners();
      return false;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final nuevaVenta = VentaModel(
        idVenta: '',
        fecha: DateTime.now(),
        total: totalVenta,
        metodoPago: _metodoPago,
        usuarioId: adminId,
        productos: List.from(_productosVentaActual),
      );

      await _ventaRepository.registrarVenta(nuevaVenta);

      _productosVentaActual.clear();
      _metodoPago = 'Efectivo';

      return true;
    } catch (e) {
      _error = 'Error al confirmar venta: $e';

      debugPrint('Error al confirmar venta: $e');

      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void cargarHistorialVentas() {
    _ventaRepository.obtenerVentas().listen(
      (ventas) {
        _historialVentas = ventas;

        _historialVentas.sort((a, b) => b.fecha.compareTo(a.fecha));

        notifyListeners();
      },
      onError: (error) {
        _error = 'Error al cargar ventas: $error';

        notifyListeners();
      },
    );
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}
