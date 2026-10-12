import 'package:flutter/material.dart';
import 'catalogo.dart';

class MenuClienteScreen extends StatefulWidget {
  const MenuClienteScreen({super.key});

  @override
  State<MenuClienteScreen> createState() => _MenuClienteScreenState();
}

class _MenuClienteScreenState extends State<MenuClienteScreen> {
  int _pestanaActual = 0;

  // Las 5 pantallas principales del cliente
  final List<Widget> _pantallas = const [
    Center(child: Text('Inicio / Promociones', style: TextStyle(fontSize: 18))),
    CatalogoScreen(),
    Center(child: Text('Mis Favoritos', style: TextStyle(fontSize: 18))),
    Center(child: Text('Mis Apartados', style: TextStyle(fontSize: 18))),
    Center(child: Text('Mi Perfil', style: TextStyle(fontSize: 18))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Girls’ Boutique'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.pink,
        elevation: 1,
      ),
      body: _pantallas[_pestanaActual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pestanaActual,
        onTap: (indice) {
          setState(() {
            _pestanaActual = indice;
          });
        },
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Apartados',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
