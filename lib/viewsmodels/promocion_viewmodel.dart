import 'package:flutter/foundation.dart';
import '../models/promocion_model.dart';
import '../repositories/promocion_repository.dart';

class PromocionViewModel extends ChangeNotifier {
  final PromocionRepository _promocionRepository;

  List<PromocionModel> _promocionesActivas = [];
  List<PromocionModel> _todasLasPromociones = [];
  bool _cargando = false;

  PromocionViewModel({PromocionRepository? promocionRepository})
    : _promocionRepository = promocionRepository ?? PromocionRepository() {
    escucharPromociones();
  }

  List<PromocionModel> get promocionesActivas => _promocionesActivas;
  List<PromocionModel> get todasLasPromociones => _todasLasPromociones;
  bool get cargando => _cargando;

  // promociones en tiempo real
  void escucharPromociones() {
    _cargando = true;
    notifyListeners();

    _promocionRepository.obtenerPromocionesActivas().listen((activas) {
      _promocionesActivas = activas;
      _cargando = false;
      notifyListeners();
    });

    _promocionRepository.obtenerTodasLasPromociones().listen((todas) {
      _todasLasPromociones = todas;
      notifyListeners();
    });
  }

  // Crear una nueva promoción desde el panel admin
  Future<bool> crearPromocion(PromocionModel promocion) async {
    try {
      _cargando = true;
      notifyListeners();
      await _promocionRepository.crearPromocion(promocion);
      _cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _cargando = false;
      notifyListeners();
      debugPrint("Error al crear promoción: $e");
      return false;
    }
  }

  // Desactivar o eliminar una promoción
  Future<void> eliminarPromocion(String idPromocion) async {
    try {
      await _promocionRepository.eliminarPromocion(idPromocion);
    } catch (e) {
      debugPrint("Error al eliminar promoción: $e");
    }
  }
}
