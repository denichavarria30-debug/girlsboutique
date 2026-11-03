import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/producto.dart';
import '../../viewsmodels/auth_viewmodel.dart';
import '../../viewsmodels/carrito_viewmodel.dart';
import '../../viewsmodels/producto_viewmodel.dart';
import '../auth/login.dart';
import '../auth/registro.dart';
import '../client/catalogo.dart';
import '../client/carrito.dart';
import '../client/mis_apartados.dart';

// Pantalla principal de mi aplicación Girls' Boutique.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Abro los enlaces de ubicación y WhatsApp.
  Future<void> _abrirUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('No se pudo abrir el enlace: $urlString');
    }
  }

  // Abro el catálogo completo o una categoría específica.
  void _abrirCatalogo({String categoria = 'Todos'}) {
    final productoVM = Provider.of<ProductoViewModel>(context, listen: false);

    // Limpio los filtros anteriores para mostrar los productos.
    productoVM.limpiarFiltros();

    // Aplico la categoría que seleccioné.
    if (categoria != 'Todos') {
      productoVM.seleccionarCategoria(categoria);
    }

    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final carritoVM = Provider.of<CarritoViewModel>(context);

    final isLoggedIn = authVM.user != null;

    // Mantengo las pantallas principales de mi aplicación.
    final List<Widget> pages = [
      _buildInicioScreen(authVM),
      const CatalogoScreen(),

      if (isLoggedIn) const MisApartadosScreen(),

      if (isLoggedIn) _buildPerfil(authVM),
    ];

    // Configuro las opciones del menú inferior.
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

    // Evito seleccionar una pantalla que ya no esté disponible.
    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAFC),

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
          // Muestro el carrito cuando el usuario inicia sesión.
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

                // Muestro la cantidad de productos agregados al carrito.
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

  // PANTALLA DE INICIO

  Widget _buildInicioScreen(AuthViewModel authVM) {
    final isLoggedIn = authVM.user != null;

    // Obtengo los productos registrados en mi aplicación.
    final productoVM = Provider.of<ProductoViewModel>(context);

    // Solo muestro productos activos, disponibles y con existencias.
    final productosDisponibles =
        productoVM.productosOriginales
            .where(
              (producto) =>
                  producto.activo && producto.disponible && producto.stock > 0,
            )
            .toList();

    // Selecciono los primeros seis productos para el carrusel.
    final productosCarrusel = productosDisponibles.take(6).toList();

    // Selecciono otros cuatro productos para las recomendaciones.
    final productosRecomendados = productosDisponibles.skip(6).take(4).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BIENVENIDA
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

                const SizedBox(height: 8),

                const Text(
                  'Maquillaje, skincare, ropa, accesorios, '
                  'bolsas y mucho más.',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),

                const SizedBox(height: 16),

                // Agrego un botón para explorar todos mis productos.
                ElevatedButton.icon(
                  onPressed: () {
                    _abrirCatalogo();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text(
                    'Explorar productos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // INICIO DE SESIÓN Y REGISTRO
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

          // CARRUSEL DE PRODUCTOS
          _tituloSeccion(
            titulo: 'Descubre nuestros productos 💗',
            subtitulo: 'Encuentra algo especial para ti',
            mostrarBoton: true,
          ),

          const SizedBox(height: 14),

          // Muestro un indicador mientras se cargan los productos.
          if (productoVM.cargando)
            const SizedBox(
              height: 240,
              child: Center(
                child: CircularProgressIndicator(color: Colors.pink),
              ),
            )
          // Muestro un mensaje si todavía no hay productos.
          else if (productosCarrusel.isEmpty)
            _mensajeSinProductos()
          // Muestro mis productos en un carrusel horizontal.
          else
            SizedBox(
              height: 265,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: productosCarrusel.length,
                itemBuilder: (context, index) {
                  final producto = productosCarrusel[index];

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _productoCarruselCard(producto),
                  );
                },
              ),
            ),

          const SizedBox(height: 26),

          // CATEGORÍAS
          const Text(
            'Compra por categoría 🎀',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          // Organizo las categorías de productos de mi boutique.
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

              _categoriaChip(Icons.pets, 'Peluches'),

              _categoriaChip(
                Icons.face_retouching_natural,
                'Productos para cabello',
              ),
            ],
          ),

          const SizedBox(height: 28),
          // PRODUCTOS RECOMENDADOS
          if (productosRecomendados.isNotEmpty) ...[
            _tituloSeccion(
              titulo: 'Más productos para ti ✨',
              subtitulo: 'Descubre más artículos de nuestra boutique',
              mostrarBoton: true,
            ),

            const SizedBox(height: 14),

            // Organizo los productos recomendados en dos columnas.
            LayoutBuilder(
              builder: (context, constraints) {
                final anchoTarjeta = (constraints.maxWidth - 12) / 2;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      productosRecomendados.map((producto) {
                        return SizedBox(
                          width: anchoTarjeta,
                          child: _productoRecomendadoCard(producto),
                        );
                      }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),
          ],

          // BOTÓN PARA VER EL CATÁLOGO
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _abrirCatalogo();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.grid_view),
              label: const Text(
                'Ver catálogo completo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ====================================================
          // UBICACIÓN Y WHATSAPP
          // ====================================================
          const Text(
            'Encuéntranos 💕',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

          const SizedBox(height: 25),

          // Agrego un mensaje de agradecimiento a mis clientes.
          Center(
            child: Text(
              'Gracias por apoyar a Girls\' Boutique 💗',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.pink.shade300,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 15),
        ],
      ),
    );
  }

  // ============================================================
  // TÍTULOS DE LAS SECCIONES
  // ============================================================

  Widget _tituloSeccion({
    required String titulo,
    required String subtitulo,
    bool mostrarBoton = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            if (mostrarBoton)
              TextButton(
                onPressed: () {
                  _abrirCatalogo();
                },
                child: const Text(
                  'Ver todo',
                  style: TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),

        Text(
          subtitulo,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // ============================================================
  // TARJETAS DEL CARRUSEL
  // ============================================================

  Widget _productoCarruselCard(Producto producto) {
    return SizedBox(
      width: 175,
      child: Card(
        color: Colors.white,
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        child: InkWell(
          onTap: () {
            // Abro el catálogo con la categoría del producto.
            _abrirCatalogo(categoria: producto.categoria);
          },

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 165,
                width: double.infinity,
                child: _imagenProducto(),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '\$${producto.precio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.pink,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      producto.categoria,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TARJETAS DE PRODUCTOS RECOMENDADOS
  // ============================================================

  Widget _productoRecomendadoCard(Producto producto) {
    return Card(
      color: Colors.white,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: InkWell(
        onTap: () {
          // Muestro los productos de la categoría seleccionada.
          _abrirCatalogo(categoria: producto.categoria);
        },

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 150,
              child: _imagenProducto(),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '\$${producto.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    producto.categoria,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DISEÑO SIN FOTOGRAFÍAS
  // ============================================================

  // Utilizo un ícono de bolsa para representar mis productos.
  // Así mantengo el mismo diseño sin cargar imágenes externas.
  Widget _imagenProducto() {
    return Container(
      width: double.infinity,
      color: Colors.pink.shade50,
      child: const Center(
        child: Icon(Icons.shopping_bag_outlined, color: Colors.pink, size: 48),
      ),
    );
  }

  // ============================================================
  // MENSAJE CUANDO NO HAY PRODUCTOS
  // ============================================================

  Widget _mensajeSinProductos() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
      ),

      child: const Column(
        children: [
          Icon(Icons.shopping_bag_outlined, size: 45, color: Colors.pink),

          SizedBox(height: 10),

          Text(
            'Próximamente tendremos más productos para ti.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.pink, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERFIL DEL USUARIO
  // ============================================================

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

              // Permito que el usuario cierre su sesión.
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

  // ============================================================
  // UBICACIÓN Y WHATSAPP
  // ============================================================

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
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
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

  // ============================================================
  // CATEGORÍAS INTERACTIVAS
  // ============================================================

  Widget _categoriaChip(IconData icon, String texto) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),

      // Abro el catálogo con la categoría que selecciono.
      onTap: () {
        _abrirCatalogo(categoria: texto);
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.pink.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.pink.shade100),
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
      ),
    );
  }
}
