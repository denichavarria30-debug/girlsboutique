import 'package:flutter/foundation.dart';
import '../models/reserva_model.dart';
import '../repositories/reserva_repository.dart';

class ReservaViewModel extends ChangeNotifier {
  final ReservaRepository _reservaRepository;

  List<ReservaModel> _misApartados = [];
  bool _cargando = false;

  ReservaViewModel({ReservaRepository? reservaRepository})
    : _reservaRepository = reservaRepository ?? ReservaRepository();

  List<ReservaModel> get misApartados => _misApartados;
  bool get cargando => _cargando;

  // Cargar los apartados de un cliente específico en tiempo real
  void cargarApartadosCliente(String clienteId) {
    _cargando = true;
    notifyListeners();

    _reservaRepository
        .getReservasPorCliente(clienteId)
        .listen(
          (lista) {
            _misApartados = lista;
            _cargando = false;
            notifyListeners();
          },
          onError: (e) {
            _cargando = false;
            notifyListeners();
            debugPrint("Error al cargar apartados: $e");
          },
        );
  }

  // Crear un nuevo apartado
  Future<bool> crearApartado(ReservaModel reserva, int stockActual) async {
    try {
      _cargando = true;
      notifyListeners();
      await _reservaRepository.crearReserva(reserva, stockActual);
      _cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _cargando = false;
      notifyListeners();
      debugPrint("Error al crear apartado: $e");
      return false;
    }
  }

  // Cancelar un apartado devolviendo el stock del producto
  Future<bool> cancelarApartado(String reservaId, String productoId) async {
    try {
      _cargando = true;
      notifyListeners();
      await _reservaRepository.cancelarReserva(reservaId, productoId);
      _cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _cargando = false;
      notifyListeners();
      debugPrint("Error al cancelar apartado: $e");
      return false;
    }
  }

  // Calcular saldo pendiente
  double calcularSaldoPendiente(double total, double anticipo) {
    return total - anticipo;
  }
}
