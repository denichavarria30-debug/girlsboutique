import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewsmodels/auth_viewmodel.dart';

// Pantalla para que los clientes puedan crear su cuenta
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  // Controladores para guardar lo que escribe el usuario
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  final _correo = TextEditingController();
  final _password = TextEditingController();
  final _confirmarPassword = TextEditingController();

  // Variables para mostrar u ocultar las contraseñas
  bool _ocultarPassword = true;
  bool _ocultarConfirmacion = true;

  // Variables para mostrar los errores de cada campo
  String? _errorNombre;
  String? _errorTelefono;
  String? _errorCorreo;
  String? _errorPassword;
  String? _errorConfirmacion;

  @override
  void dispose() {
    // Libero los controladores cuando se cierra la pantalla
    _nombre.dispose();
    _telefono.dispose();
    _correo.dispose();
    _password.dispose();
    _confirmarPassword.dispose();
    super.dispose();
  }

  // Función para mostrar mensajes al usuario
  void _mostrarMensaje(String mensaje, {bool esError = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Aquí reviso que el correo tenga un formato correcto
  bool _correoValido(String correo) {
    final expresion = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return expresion.hasMatch(correo);
  }

  // Aquí reviso que la contraseña sea segura
  String? _validarPassword(String password) {
    if (password.isEmpty) {
      return 'Ingresa una contraseña';
    }

    if (password.length < 10) {
      return 'La contraseña debe tener mínimo 10 caracteres';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'La contraseña necesita una letra mayúscula';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'La contraseña necesita una letra minúscula';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'La contraseña necesita al menos un número';
    }

    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) {
      return 'La contraseña necesita un carácter especial';
    }

    return null;
  }

  // Aquí reviso todos los campos antes de registrar al usuario
  bool _validarCampos() {
    final nombre = _nombre.text.trim();
    final telefono = _telefono.text.trim();
    final correo = _correo.text.trim();
    final password = _password.text;
    final confirmacion = _confirmarPassword.text;

    String? errorNombre;
    String? errorTelefono;
    String? errorCorreo;
    String? errorPassword;
    String? errorConfirmacion;

    // Reviso el nombre
    if (nombre.isEmpty) {
      errorNombre = 'Ingresa tu nombre completo';
    } else if (nombre.length < 3) {
      errorNombre = 'El nombre es demasiado corto';
    }

    // Reviso que el teléfono tenga exactamente 10 números
    if (telefono.isEmpty) {
      errorTelefono = 'Ingresa tu teléfono';
    } else if (!RegExp(r'^\d{10}$').hasMatch(telefono)) {
      errorTelefono = 'El teléfono debe tener exactamente 10 dígitos';
    }

    // Reviso que el correo esté bien escrito
    if (correo.isEmpty) {
      errorCorreo = 'Ingresa tu correo electrónico';
    } else if (!_correoValido(correo)) {
      errorCorreo = 'El correo no es válido. Revisa que esté bien escrito';
    }

    // Reviso la seguridad de la contraseña
    errorPassword = _validarPassword(password);

    // Reviso que las contraseñas sean iguales
    if (confirmacion.isEmpty) {
      errorConfirmacion = 'Confirma tu contraseña';
    } else if (password != confirmacion) {
      errorConfirmacion = 'Las contraseñas no coinciden';
    }

    // Muestro los errores debajo de cada campo
    setState(() {
      _errorNombre = errorNombre;
      _errorTelefono = errorTelefono;
      _errorCorreo = errorCorreo;
      _errorPassword = errorPassword;
      _errorConfirmacion = errorConfirmacion;
    });

    // Si no hay errores, permito que se registre
    return errorNombre == null &&
        errorTelefono == null &&
        errorCorreo == null &&
        errorPassword == null &&
        errorConfirmacion == null;
  }

  // Aquí registro al usuario usando mi AuthViewModel
  Future<void> _registrarUsuario(AuthViewModel authVM) async {
    // Primero reviso que los datos estén correctos
    if (!_validarCampos()) {
      _mostrarMensaje('Revisa los campos marcados en rojo');
      return;
    }

    try {
      // Aquí envío los datos a Firebase
      final ok = await authVM.register(
        nombre: _nombre.text.trim(),
        telefono: _telefono.text.trim(),
        correo: _correo.text.trim(),
        password: _password.text,
      );

      if (!mounted) return;

      if (ok) {
        // Si todo sale bien, aviso que la cuenta fue creada
        _mostrarMensaje(
          '¡Registro exitoso! Tu cuenta fue creada correctamente.',
          esError: false,
        );

        // Regreso a la pantalla anterior
        Navigator.pop(context, true);
      } else {
        // Si Firebase rechaza el registro, muestro el error
        final mensaje = authVM.errorMessage;

        _mostrarMensaje(
          mensaje != null && mensaje.isNotEmpty
              ? mensaje
              : 'No se pudo crear la cuenta. Inténtalo nuevamente.',
        );
      }
    } catch (_) {
      if (!mounted) return;

      _mostrarMensaje(
        'Ocurrió un error al registrar tu cuenta. Inténtalo nuevamente.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      // Barra superior de la pantalla
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),

      // Permito deslizar la pantalla para ver todos los campos
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            const SizedBox(height: 12),

            // Logo de mi tienda
            Image.asset(
              'assets/images/logo.png',
              width: 140,
              height: 140,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 12),

            const Text(
              "¡Únete a Girls' Boutique!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Crea tu cuenta para comenzar a comprar',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 28),

            // Campo para escribir el nombre completo
            TextField(
              controller: _nombre,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {
                if (_errorNombre != null) {
                  setState(() {
                    _errorNombre = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: const Icon(Icons.person, color: Colors.pink),
                errorText: _errorNombre,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Campo para escribir el teléfono
            TextField(
              controller: _telefono,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: (_) {
                if (_errorTelefono != null) {
                  setState(() {
                    _errorTelefono = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Teléfono',
                hintText: 'Ingresa 10 dígitos',
                prefixIcon: const Icon(Icons.phone, color: Colors.pink),
                errorText: _errorTelefono,
                counterText: '',
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Campo para escribir el correo electrónico
            TextField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              onChanged: (_) {
                if (_errorCorreo != null) {
                  setState(() {
                    _errorCorreo = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                hintText: 'ejemplo@gmail.com',
                prefixIcon: const Icon(Icons.email, color: Colors.pink),
                errorText: _errorCorreo,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Campo para crear una contraseña segura
            TextField(
              controller: _password,
              obscureText: _ocultarPassword,
              enableSuggestions: false,
              autocorrect: false,
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

                // Botón para mostrar u ocultar la contraseña
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
              ),
            ),

            const SizedBox(height: 8),

            // Aquí explico los requisitos de la contraseña
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'La contraseña debe tener mínimo 10 caracteres, '
                'una mayúscula, una minúscula, un número '
                'y un carácter especial.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 16),

            // Campo para confirmar la contraseña
            TextField(
              controller: _confirmarPassword,
              obscureText: _ocultarConfirmacion,
              enableSuggestions: false,
              autocorrect: false,
              onChanged: (_) {
                if (_errorConfirmacion != null) {
                  setState(() {
                    _errorConfirmacion = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.pink),
                errorText: _errorConfirmacion,

                // Botón para mostrar u ocultar la confirmación
                suffixIcon: IconButton(
                  icon: Icon(
                    _ocultarConfirmacion
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _ocultarConfirmacion = !_ocultarConfirmacion;
                    });
                  },
                ),

                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 28),

            // Botón para registrar al usuario
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

                // Mientras se registra, desactivo el botón
                onPressed:
                    authVM.isLoading ? null : () => _registrarUsuario(authVM),

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
                          'Registrarme',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
