import 'package:flutter/material.dart';
import 'package:girls_boutique_app/views/admin/editar_producto.dart';
import 'package:girls_boutique_app/models/producto.dart';
import 'package:girls_boutique_app/repositories/producto_repository.dart';
import 'package:girls_boutique_app/views/admin/agregar_producto.dart';

class CatalogoAdminScreen extends StatelessWidget {
  const CatalogoAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductoRepository productoRepository = ProductoRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<List<Producto>>(
        stream: productoRepository.getProductos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.pink),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error al cargar el catálogo:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final productos = snapshot.data ?? [];

          if (productos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No hay productos registrados.\n\n'
                  'Presiona "Nuevo Producto" para agregar uno.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];

              final tallasTexto =
                  producto.tallas.isEmpty
                      ? 'No aplica'
                      : producto.tallas.join(', ');

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // IMAGEN
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            producto.imagenUrl.isNotEmpty
                                ? Image.network(
                                  producto.imagenUrl,
                                  width: 65,
                                  height: 65,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => _imagenDefault(),
                                )
                                : _imagenDefault(),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              producto.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              producto.categoria,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Precio: \$${producto.precio.toStringAsFixed(2)}',
                            ),

                            Text('Stock: ${producto.stock}'),

                            Text('Tallas: $tallasTexto'),

                            const SizedBox(height: 5),

                            Row(
                              children: [
                                Icon(
                                  producto.activo
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  size: 17,
                                  color:
                                      producto.activo
                                          ? Colors.green
                                          : Colors.red,
                                ),

                                const SizedBox(width: 5),

                                Text(
                                  producto.activo ? 'Activo' : 'Inactivo',
                                  style: TextStyle(
                                    color:
                                        producto.activo
                                            ? Colors.green
                                            : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // MENÚ DE OPCIONES
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),

                        onSelected: (value) async {
                          // EDITAR
                          if (value == 'editar') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => EditarProductoScreen(
                                      producto: producto,
                                    ),
                              ),
                            );
                          }

                          // DESACTIVAR
                          if (value == 'desactivar') {
                            _confirmarDesactivar(
                              context,
                              productoRepository,
                              producto,
                            );
                          }

                          // REACTIVAR
                          if (value == 'reactivar') {
                            await _reactivarProducto(
                              context,
                              productoRepository,
                              producto,
                            );
                          }
                        },

                        itemBuilder:
                            (context) => [
                              // EDITAR
                              const PopupMenuItem(
                                value: 'editar',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Editar'),
                                  ],
                                ),
                              ),

                              // DESACTIVAR
                              if (producto.activo)
                                const PopupMenuItem(
                                  value: 'desactivar',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.visibility_off,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Desactivar'),
                                    ],
                                  ),
                                ),

                              // REACTIVAR
                              if (!producto.activo)
                                const PopupMenuItem(
                                  value: 'reactivar',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.visibility,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Reactivar'),
                                    ],
                                  ),
                                ),
                            ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AgregarProductoScreen()),
          );
        },

        icon: const Icon(Icons.add),

        label: const Text(
          'Nuevo Producto',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _imagenDefault() {
    return Container(
      width: 65,
      height: 65,
      color: Colors.pink.shade50,
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: Colors.pink,
        size: 34,
      ),
    );
  }

  void _confirmarDesactivar(
    BuildContext context,
    ProductoRepository repo,
    Producto producto,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Desactivar producto'),

          content: Text(
            '¿Deseas desactivar "${producto.nombre}"?\n\n'
            'Ya no aparecerá disponible para los clientes, '
            'pero conservará su información.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Cancelar'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),

              onPressed: () async {
                Navigator.pop(ctx);

                await repo.desactivarProducto(producto.id);

                if (!context.mounted) {
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Producto desactivado')),
                );
              },

              child: const Text('Desactivar'),
            ),
          ],
        );
      },
    );
  }

  // REACTIVAR PRODUCTO
  Future<void> _reactivarProducto(
    BuildContext context,
    ProductoRepository repo,
    Producto producto,
  ) async {
    await repo.reactivarProducto(producto.id);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Producto reactivado')));
  }
}
