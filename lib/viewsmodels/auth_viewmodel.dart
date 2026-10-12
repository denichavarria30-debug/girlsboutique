import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  AuthViewModel({required this.authRepository}) {
    _checkCurrentUser();
  }

  UserModel? get user => _user;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isAdmin {
    final rol = _user?.rol.trim().toLowerCase() ?? '';

    return rol == 'admin' || rol == 'administrador' || rol == 'administradora';
  }

  Future<void> _checkCurrentUser() async {
    try {
      final firebaseUser = authRepository.currentUser;

      if (firebaseUser != null) {
        _user = await authRepository.getUserData(firebaseUser.uid);
      }
    } catch (e) {
      _errorMessage = 'Error al cargar la sesión.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String correo, String password) async {
    _setLoading(true);

    try {
      _user = await authRepository.loginUser(
        correo: correo.trim(),
        password: password,
      );

      _errorMessage = null;

      _setLoading(false);

      return true;
    } catch (e) {
      _errorMessage = 'Error al iniciar sesión. Verifica tus datos.';

      _setLoading(false);

      return false;
    }
  }

  Future<bool> register({
    required String nombre,
    required String telefono,
    required String correo,
    required String password,
  }) async {
    _setLoading(true);

    try {
      _user = await authRepository.registerUser(
        nombre: nombre.trim(),
        telefono: telefono.trim(),
        correo: correo.trim(),
        password: password,
      );

      _errorMessage = null;

      _setLoading(false);

      return true;
    } catch (e) {
      _errorMessage = 'Error al registrar: ${e.toString()}';

      _setLoading(false);

      return false;
    }
  }

  Future<void> logout() async {
    await authRepository.signOut();

    _user = null;
    _errorMessage = null;

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
