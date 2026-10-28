import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewsmodels/auth_viewmodel.dart';
import 'registro.dart';

// Esta es mi pantalla para iniciar sesión
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Aquí guardo lo que escribe el usuario
  final _correo = TextEditingController();
  final _password = TextEditingController();

  // Esto me permite mostrar u ocultar la contraseña
  bool _ocultarPassword = true;

  // Aquí guardo los mensajes cuando hay algún error
  String? _errorCorreo;
  String? _errorPassword;

  @override
  void dispose() {
    _correo.dispose();
    _password.dispose();
    super.dispose();
  }

  // Muestro un aviso cuando hay algún problema
  void _mostrarMensaje(String mensaje, {bool error = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: error ? Colors.red.shade400 : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Reviso que los datos estén completos y bien escritos
  bool _validarCampos() {
    final correo = _correo.text.trim();
    final password = _password.text.trim();

    setState(() {
      _errorCorreo = null;
      _errorPassword = null;

      // Si no escribe su correo, le muestro un aviso
      if (correo.isEmpty) {
        _errorCorreo = 'Ingresa tu correo electrónico';
      } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(correo)) {
        _errorCorreo = 'Ingresa un correo electrónico válido';
      }

      // Si no escribe su contraseña, también le aviso
      if (password.isEmpty) {
        _errorPassword = 'Ingresa tu contraseña';
      }
    });

    return _errorCorreo == null && _errorPassword == null;
  }

  // Aquí intento iniciar sesión con los datos del usuario
  Future<void> _iniciarSesion(AuthViewModel authVM) async {
    if (!_validarCampos()) {
      _mostrarMensaje('Revisa los campos marcados en rojo');
      return;
    }

    try {
      final ok = await authVM.login(_correo.text.trim(), _password.text.trim());

      if (!mounted) return;

      // Si no puede entrar, le muestro qué pasó
      if (!ok) {
        _mostrarMensaje(
          authVM.errorMessage?.isNotEmpty == true
              ? authVM.errorMessage!
              : 'No se pudo iniciar sesión. Verifica tus datos.',
        );
      }
    } catch (_) {
      if (!mounted) return;

      _mostrarMensaje(
        'Ocurrió un error al iniciar sesión. Inténtalo nuevamente.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      // Esta es la parte de arriba de mi pantalla
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            const SizedBox(height: 20),

            // Aquí agregué el logo de mi tienda
            Image.asset(
              'assets/images/logo.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),

            // Mensaje de bienvenida a mi tienda
            const Text(
              "Bienvenida a Girls' Boutique",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Ingresa a tu cuenta para continuar',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // Aquí el usuario escribe su correo
            TextField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,

              onChanged: (_) {
                if (_errorCorreo != null) {
                  setState(() {
                    _errorCorreo = null;
                  });
                }
              },

              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                hintText: 'ejemplo@correo.com',

                prefixIcon: const Icon(Icons.email, color: Colors.pink),

                errorText: _errorCorreo,

                border: const OutlineInputBorder(),

                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Aquí el usuario escribe su contraseña
            TextField(
              controller: _password,
              obscureText: _ocultarPassword,

              onChanged: (_) {
                if (_errorPassword != null) {
                  setState(() {
                    _errorPassword = null;
                  });
                }
              },

              decoration: InputDecoration(
                labelText: 'Contraseña',

                prefixIcon: const Icon(Icons.lock, color: Colors.pink),

                errorText: _errorPassword,

                // Este botón permite ver o esconder la contraseña
                suffixIcon: IconButton(
                  icon: Icon(
                    _ocultarPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),

                  onPressed: () {
                    setState(() {
                      _ocultarPassword = !_ocultarPassword;
                    });
                  },
                ),

                border: const OutlineInputBorder(),

                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Este es mi botón para ingresar
            SizedBox(
              width: double.infinity,
              height: 48,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  disabledBackgroundColor: Colors.pink.shade200,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                onPressed:
                    authVM.isLoading ? null : () => _iniciarSesion(authVM),

                // Mientras revisa los datos, aparece un circulito
                child:
                    authVM.isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,

                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Ingresar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 16),

            // Si el usuario no tiene cuenta, puede registrarse aquí
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegistroScreen()),
                );
              },

              child: const Text(
                '¿No tienes cuenta? Regístrate aquí',
                style: TextStyle(color: Colors.pink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
