import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repositories/producto_repository.dart';
import '../../viewsmodels/carrito_viewmodel.dart';
import '../../viewsmodels/apartado_viewmodel.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carritoVM = Provider.of<CarritoViewModel>(context);
    final apartadoVM = Provider.of<ApartadoViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          if (!carritoVM.estaVacio)
            IconButton(
              tooltip: 'Vaciar carrito',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () {
                _confirmarVaciarCarrito(context, carritoVM);
              },
            ),
        ],
      ),

      body:
          carritoVM.estaVacio
              ? _carritoVacio()
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: carritoVM.items.length,
                      itemBuilder: (context, index) {
                        final item = carritoVM.items[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child:
                                      item.imagenUrl.isNotEmpty
                                          ? Image.network(
                                            item.imagenUrl,
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (_, __, ___) =>
                                                    _imagenDefault(),
                                          )
                                          : _imagenDefault(),
                                ),

                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.nombre,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Text(
                                        '\$${item.precio.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.pink,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Text(
                                        'Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),

                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors.pink,
                                            ),
                                            onPressed: () {
                                              carritoVM.decrementarCantidad(
                                                item.productoId,
                                              );
                                            },
                                          ),

                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.pink.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${item.cantidad}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),

                                          IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                              color: Colors.pink,
                                            ),
                                            onPressed: () {
                                              final ok = carritoVM
                                                  .incrementarCantidad(
                                                    item.productoId,
                                                    999,
                                                  );

                                              if (!ok) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'No se puede aumentar la cantidad',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    carritoVM.eliminarProducto(item.productoId);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Productos:',
                                style: TextStyle(fontSize: 15),
                              ),
                              Text(
                                '${carritoVM.cantidadTotalItems}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${carritoVM.totalPagar.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.pink,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),

                              onPressed:
                                  apartadoVM.cargando
                                      ? null
                                      : () async {
                                        await _apartarCarrito(
                                          context,
                                          carritoVM,
                                          apartadoVM,
                                        );
                                      },

                              icon:
                                  apartadoVM.cargando
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Icon(Icons.bookmark_add_outlined),

                              label: Text(
                                apartadoVM.cargando
                                    ? 'Procesando...'
                                    : 'Apartar Productos',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Future<void> _apartarCarrito(
    BuildContext context,
    CarritoViewModel carritoVM,
    ApartadoViewModel apartadoVM,
  ) async {
    if (carritoVM.estaVacio) {
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar apartado'),
          content: Text(
            '¿Deseas apartar ${carritoVM.cantidadTotalItems} producto(s)?\n\n'
            'Total: \$${carritoVM.totalPagar.toStringAsFixed(2)}\n'
            'Anticipo estimado: \$${(carritoVM.totalPagar * 0.20).toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    final productoRepository = ProductoRepository();

    final items = List.of(carritoVM.items);

    int apartadosCreados = 0;

    for (final item in items) {
      try {
        // Obtenemos el producto REAL de Firebase.
        final producto = await productoRepository.getProductoPorId(
          item.productoId,
        );

        if (producto == null) {
          if (!context.mounted) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('No se encontró el producto ${item.nombre}.'),
            ),
          );

          return;
        }

        final ok = await apartadoVM.crearApartado(
          producto: producto,
          cantidad: item.cantidad,
          talla: '',
        );

        if (!ok) {
          if (!context.mounted) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                apartadoVM.error ?? 'No se pudo apartar ${item.nombre}.',
              ),
            ),
          );

          return;
        }

        apartadosCreados++;
      } catch (e) {
        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error al apartar ${item.nombre}: $e'),
          ),
        );

        return;
      }
    }

    if (!context.mounted) {
      return;
    }

    // Si todos se guardaron correctamente,
    // limpiamos el carrito.
    if (apartadosCreados == items.length) {
      carritoVM.vaciarCarrito();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('¡Productos apartados correctamente!'),
        ),
      );

      Navigator.pop(context);
    }
  }

  Widget _carritoVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 90,
              color: Colors.pink.shade200,
            ),

            const SizedBox(height: 20),

            const Text(
              'Tu carrito está vacío',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Agrega productos desde el catálogo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagenDefault() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.pink.shade50,
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: Colors.pink,
        size: 35,
      ),
    );
  }

  void _confirmarVaciarCarrito(
    BuildContext context,
    CarritoViewModel carritoVM,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Vaciar carrito'),
          content: const Text(
            '¿Deseas eliminar todos los productos del carrito?',
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
              onPressed: () {
                carritoVM.vaciarCarrito();

                Navigator.pop(ctx);
              },
              child: const Text('Vaciar'),
            ),
          ],
        );
      },
    );
  }
}
