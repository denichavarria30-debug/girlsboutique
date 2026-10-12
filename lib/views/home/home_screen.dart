import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../viewsmodels/auth_viewmodel.dart';
import '../../viewsmodels/carrito_viewmodel.dart';
import '../auth/login.dart';
import '../auth/registro.dart';
import '../client/catalogo.dart';
import '../client/carrito.dart';
import '../client/mis_apartados.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  Future<void> _abrirUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('No se pudo abrir el enlace: $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final carritoVM = Provider.of<CarritoViewModel>(context);

    final isLoggedIn = authVM.user != null;

    final List<Widget> pages = [
      _buildInicioScreen(authVM),
      const CatalogoScreen(),

      if (isLoggedIn) const MisApartadosScreen(),

      if (isLoggedIn) _buildPerfil(authVM),
    ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Inicio',
      ),

      const BottomNavigationBarItem(
        icon: Icon(Icons.grid_view_outlined),
        activeIcon: Icon(Icons.grid_view),
        label: 'Catálogo',
      ),

      if (isLoggedIn)
        const BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_border),
          activeIcon: Icon(Icons.bookmark),
          label: 'Apartados',
        ),

      if (isLoggedIn)
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
    ];

    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Girls' Boutique",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.pink,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,

        actions: [
          if (isLoggedIn)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  tooltip: 'Mi carrito',
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.pink,
                    size: 27,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CarritoScreen()),
                    );
                  },
                ),

                if (carritoVM.cantidadTotalItems > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${carritoVM.cantidadTotalItems}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),

      body:
          authVM.isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.pink),
              )
              : pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
    );
  }

  // INICIO
  Widget _buildInicioScreen(AuthViewModel authVM) {
    final isLoggedIn = authVM.user != null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink.shade300, Colors.pink.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn
                      ? '¡Hola, ${authVM.user?.nombre ?? "Cliente"}!'
                      : '¡Bienvenida a Girls\' Boutique!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Maquillaje, skincare, ropa, accesorios, bolsas y mucho más.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // BOTONES LOGIN y REGISTRO
          if (!isLoggedIn) ...[
            const Text(
              'Acceso',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Iniciar sesión'),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.pink,
                      side: const BorderSide(color: Colors.pink),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegistroScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Registrarse'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],

          const Text(
            'Encuéntranos',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _accionCard(
                  icon: Icons.location_on,
                  titulo: 'Ubicación',
                  color: Colors.red,
                  onTap: () {
                    _abrirUrl('https://maps.app.goo.gl/dFcvFLAnADFAqGRZ6');
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _accionCard(
                  icon: Icons.chat,
                  titulo: 'WhatsApp',
                  color: Colors.green,
                  onTap: () {
                    _abrirUrl('https://wa.me/7721286219');
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Categorías',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _categoriaChip(Icons.brush, 'Maquillaje'),
              _categoriaChip(Icons.spa, 'Skincare'),
              _categoriaChip(Icons.checkroom, 'Ropa'),
              _categoriaChip(Icons.shopping_bag, 'Bolsas'),
              _categoriaChip(Icons.auto_awesome, 'Accesorios'),
              _categoriaChip(Icons.card_giftcard, 'Novedades'),
            ],
          ),
        ],
      ),
    );
  }

  // PERFIL
  Widget _buildPerfil(AuthViewModel authVM) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 30),

          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.pink.shade100,
            child: const Icon(Icons.person, color: Colors.pink, size: 55),
          ),

          const SizedBox(height: 18),

          Text(
            authVM.user?.nombre ?? 'Usuario',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            authVM.user?.correo ?? '',
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 6),

          Text(
            authVM.user?.telefono ?? '',
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                await authVM.logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accionCard({
    required IconData icon,
    required String titulo,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),

            const SizedBox(height: 7),

            Text(
              titulo,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoriaChip(IconData icon, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.pink, size: 18),

          const SizedBox(width: 6),

          Text(
            texto,
            style: const TextStyle(
              color: Colors.pink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
