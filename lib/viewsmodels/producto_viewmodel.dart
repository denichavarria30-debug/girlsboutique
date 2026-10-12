import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/producto.dart';
import '../repositories/producto_repository.dart';

class ProductoViewModel extends ChangeNotifier {
  final ProductoRepository _productoRepository;

  List<Producto> _productos = [];
  List<Producto> _productosFiltrados = [];

  String _categoriaSeleccionada = 'Todos';
  String _busqueda = '';

  bool _cargando = false;
  String? _error;

  StreamSubscription<List<Producto>>? _productosSubscription;

  ProductoViewModel({ProductoRepository? productoRepository})
    : _productoRepository = productoRepository ?? ProductoRepository() {
    escucharProductos();
  }

  List<Producto> get productos {
    if (_busqueda.isEmpty && _categoriaSeleccionada == 'Todos') {
      return _productos;
    }

    return _productosFiltrados;
  }

  List<Producto> get productosOriginales => _productos;

  bool get cargando => _cargando;

  String? get error => _error;

  String get categoriaSeleccionada => _categoriaSeleccionada;

  String get busqueda => _busqueda;

  void escucharProductos() {
    _cargando = true;
    _error = null;
    notifyListeners();

    _productosSubscription?.cancel();

    _productosSubscription = _productoRepository.getProductos().listen(
      (listaProductos) {
        _productos = listaProductos;

        _aplicarFiltros();

        _cargando = false;
        _error = null;

        notifyListeners();
      },
      onError: (error) {
        _cargando = false;
        _error = _limpiarError(error);

        notifyListeners();
      },
    );
  }

  Future<bool> agregarProducto(Producto producto) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _productoRepository.agregarProducto(producto);

      _cargando = false;
      notifyListeners();

      return true;
    } catch (e) {
      _cargando = false;
      _error = _limpiarError(e);

      notifyListeners();

      return false;
    }
  }

  Future<bool> actualizarProducto(Producto producto) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _productoRepository.actualizarProducto(producto);

      _cargando = false;
      notifyListeners();

      return true;
    } catch (e) {
      _cargando = false;
      _error = _limpiarError(e);

      notifyListeners();

      return false;
    }
  }

  Future<bool> desactivarProducto(String id) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _productoRepository.desactivarProducto(id);

      _cargando = false;
      notifyListeners();

      return true;
    } catch (e) {
      _cargando = false;
      _error = _limpiarError(e);

      notifyListeners();

      return false;
    }
  }

  Future<bool> reactivarProducto(String id) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _productoRepository.reactivarProducto(id);

      _cargando = false;
      notifyListeners();

      return true;
    } catch (e) {
      _cargando = false;
      _error = _limpiarError(e);

      notifyListeners();

      return false;
    }
  }

  Future<bool> actualizarStock(String id, int nuevoStock) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _productoRepository.actualizarStock(id, nuevoStock);

      _cargando = false;
      notifyListeners();

      return true;
    } catch (e) {
      _cargando = false;
      _error = _limpiarError(e);

      notifyListeners();

      return false;
    }
  }

  void seleccionarCategoria(String categoria) {
    _categoriaSeleccionada = categoria;

    _aplicarFiltros();

    notifyListeners();
  }

  void buscarProducto(String query) {
    _busqueda = query.trim();

    _aplicarFiltros();

    notifyListeners();
  }

  void limpiarFiltros() {
    _categoriaSeleccionada = 'Todos';
    _busqueda = '';

    _aplicarFiltros();

    notifyListeners();
  }

  void _aplicarFiltros() {
    final busquedaLower = _busqueda.toLowerCase();

    _productosFiltrados =
        _productos.where((producto) {
          final coincideCategoria =
              _categoriaSeleccionada == 'Todos' ||
              producto.categoria == _categoriaSeleccionada;

          final coincideBusqueda =
              _busqueda.isEmpty ||
              producto.nombre.toLowerCase().contains(busquedaLower) ||
              producto.descripcion.toLowerCase().contains(busquedaLower);

          return coincideCategoria && coincideBusqueda;
        }).toList();
  }

  String obtenerEstadoStock(int stock) {
    if (stock <= 0) {
      return 'Agotado';
    }

    if (stock <= 3) {
      return 'Últimas piezas';
    }

    return 'Disponible';
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  String _limpiarError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  void dispose() {
    _productosSubscription?.cancel();
    super.dispose();
  }
}
