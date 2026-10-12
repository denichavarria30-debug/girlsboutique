import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:girls_boutique_app/repositories/auth_repository.dart';
import 'package:girls_boutique_app/viewsmodels/auth_viewmodel.dart';
import 'package:girls_boutique_app/viewsmodels/reserva_viewmodel.dart';
import 'package:girls_boutique_app/viewsmodels/producto_viewmodel.dart';
import 'package:girls_boutique_app/viewsmodels/apartado_viewmodel.dart';
import 'package:girls_boutique_app/viewsmodels/carrito_viewmodel.dart';
import 'package:girls_boutique_app/viewsmodels/venta_viewmodel.dart';
import 'package:girls_boutique_app/views/main_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCfoChUEpWkqFLV3as7nwxslOA4KSaXHFQ",
        appId: "1:994437868322:android:a9f70251f980cf3c9f937b",
        messagingSenderId: "994437868322",
        projectId: "girls-boutique-app-2026",
        authDomain: "girls-boutique-app-2026.firebaseapp.com",
        storageBucket: "girls-boutique-app-2026.firebasestorage.app",
      ),
    );
  } catch (e) {
    debugPrint("Error al inicializar Firebase: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository: AuthRepository()),
        ),

        ChangeNotifierProvider(create: (_) => ReservaViewModel()),

        ChangeNotifierProvider(create: (_) => ProductoViewModel()),

        ChangeNotifierProvider(create: (_) => ApartadoViewModel()),

        ChangeNotifierProvider(create: (_) => CarritoViewModel()),

        ChangeNotifierProvider(create: (_) => VentaViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Girls' Boutique",

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.pink,

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          primary: Colors.pink,
        ),

        scaffoldBackgroundColor: Colors.white,
      ),

      home: const MainWrapper(),
    );
  }
}
