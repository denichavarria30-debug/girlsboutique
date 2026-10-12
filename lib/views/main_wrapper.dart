import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:girls_boutique_app/views/admin/apartados_admin_screen.dart';
import 'package:girls_boutique_app/viewsmodels/auth_viewmodel.dart';
import 'package:girls_boutique_app/views/auth/login.dart';
import 'package:girls_boutique_app/views/home/home_screen.dart';
import 'package:girls_boutique_app/views/admin/catalogo_admin_screen.dart';
import 'package:girls_boutique_app/views/admin/punto_venta_screen.dart';
import 'package:girls_boutique_app/views/admin/historial_ventas_screen.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    if (authVM.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.pink)),
      );
    }

    if (authVM.user == null) {
      return const LoginScreen();
    }

    if (authVM.isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF7FA),

        appBar: AppBar(
          title: const Text(
            "Girls' Boutique",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pink.shade300, Colors.pink.shade500],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.storefront,
                        color: Colors.white,
                        size: 38,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        '¡Hola, ${authVM.user?.nombre ?? "Administradora"}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        'Panel de administración',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Administración',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                _AdminOptionCard(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Productos',
                  subtitle: 'Agregar, consultar y administrar productos',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CatalogoAdminScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _AdminOptionCard(
                  icon: Icons.point_of_sale,
                  title: 'Punto de venta',
                  subtitle: 'Registrar ventas del negocio',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PuntoVentaScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),
                _AdminOptionCard(
                  icon: Icons.receipt_long_outlined,
                  title: 'Historial de ventas',
                  subtitle: 'Consultar ventas registradas',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HistorialVentasScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _AdminOptionCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Inventario',
                  subtitle: 'Consultar existencias y productos',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CatalogoAdminScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _AdminOptionCard(
                  icon: Icons.bookmark_outline,
                  title: 'Apartados',
                  subtitle: 'Consultar y administrar productos reservados',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ApartadosAdminScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await authVM.logout();
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const MainNavigationScreen();
  }
}

class _AdminOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.pink, size: 28),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 17, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
