import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  // Aquí guardo la información del usuario
  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  // Aquí reviso si ya terminó de cargar la sesión anterior
  bool _revisandoSesion = true;

  AuthViewModel({required this.authRepository}) {
    _checkCurrentUser();
  }

  UserModel? get user => _user;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;
  // Aquí puedo saber si todavía se está revisando la sesión
  bool get revisandoSesion => _revisandoSesion;

  // Aquí reviso si la persona que entró es administrador
  bool get isAdmin {
    final rol = _user?.rol.trim().toLowerCase() ?? '';

    return rol == 'admin' || rol == 'administrador' || rol == 'administradora';
  }

  // Aquí puse los mensajes en español para que sean más fáciles de entender
  String _mensajeEnEspanol(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        // Cuando el correo no está bien escrito
        case 'invalid-email':
          return 'El correo electrónico no es válido.';

        // Cuando no existe una cuenta con ese correo
        case 'user-not-found':
          return 'No encontramos una cuenta con ese correo.';

        // Cuando la contraseña está incorrecta
        case 'wrong-password':
          return 'La contraseña es incorrecta.';

        // Cuando los datos para entrar no son correctos
        case 'invalid-credential':
          return 'El correo o la contraseña son incorrectos.';

        // Cuando alguien intenta registrarse con un correo que ya existe
        case 'email-already-in-use':
          return 'Este correo electrónico ya está registrado.';

        // Cuando la contraseña no es  segura
        case 'weak-password':
          return 'La contraseña es muy débil. Intenta usar una más segura.';

        // Cuando no escriben una contraseña
        case 'missing-password':
          return 'Por favor, escribe una contraseña.';

        // Cuando la cuenta no está disponible
        case 'user-disabled':
          return 'Esta cuenta se encuentra deshabilitada.';

        // Cuando intentan entrar demasiadas veces
        case 'too-many-requests':
          return 'Has realizado demasiados intentos. Inténtalo más tarde.';

        // Cuando hay problemas con el internet
        case 'network-request-failed':
          return 'No hay conexión a internet. Revisa tu conexión.';

        // Cuando una opción no está disponible
        case 'operation-not-allowed':
          return 'Esta opción no está disponible por el momento.';

        // Si pasa algo diferente, también muestro un aviso en español
        default:
          return 'Ocurrió un problema. Inténtalo nuevamente.';
      }
    }

    // Si pasa otro error, muestro este mensaje
    return 'Ocurrió un error inesperado. Inténtalo nuevamente.';
  }

  // Aquí reviso si el usuario ya había iniciado sesión
  Future<void> _checkCurrentUser() async {
    try {
      final firebaseUser = authRepository.currentUser;

      if (firebaseUser != null) {
        _user = await authRepository.getUserData(firebaseUser.uid);
      }
    } catch (e) {
      // Si no puedo cargar la sesión, muestro un aviso
      _errorMessage = 'No se pudo cargar tu sesión.';
    } finally {
      // Aquí indico que ya terminé de revisar la sesión
      _revisandoSesion = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aquí reviso los datos que escribe el usuario para entrar
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
      // Si no puede entrar, le muestro un mensaje en español
      _errorMessage = _mensajeEnEspanol(e);

      _setLoading(false);

      return false;
    }
  }

  // Aquí guardo los datos cuando alguien crea una cuenta
  Future<bool> register({
    required String nombre,
    required String telefono,
    required String correo,
    required String password,
  }) async {
    _setLoading(true);

    try {
      // Primero registro al usuario y guardo sus datos en Firebase
      await authRepository.registerUser(
        nombre: nombre.trim(),
        telefono: telefono.trim(),
        correo: correo.trim(),
        password: password,
      );

      // Firebase inicia sesión automáticamente al crear una cuenta.
      // Por eso cierro esa sesión para que el cliente tenga que iniciar sesión.
      await authRepository.signOut();

      // Aquí limpio el usuario para regresar a la pantalla de login
      _user = null;
      _errorMessage = null;

      _setLoading(false);

      // Si todo salió bien, regreso true
      return true;
    } catch (e) {
      // Si ocurre un error, muestro el mensaje en español
      _errorMessage = _mensajeEnEspanol(e);

      _setLoading(false);

      return false;
    }
  }

  // Aquí cierro la sesión cuando el usuario quiere salir
  Future<void> logout() async {
    await authRepository.signOut();

    _user = null;
    _errorMessage = null;

    notifyListeners();
  }

  // Aquí reviso si la aplicación sigue cargando
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
