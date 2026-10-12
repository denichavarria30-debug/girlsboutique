import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/producto.dart';
import '../../viewsmodels/producto_viewmodel.dart';
import '../../viewsmodels/venta_viewmodel.dart';
import '../../viewsmodels/auth_viewmodel.dart';

class PuntoVentaScreen extends StatefulWidget {
  const PuntoVentaScreen({super.key});

  @override
  State<PuntoVentaScreen> createState() => _PuntoVentaScreenState();
}

class _PuntoVentaScreenState extends State<PuntoVentaScreen> {
  final TextEditingController _busquedaController = TextEditingController();

  String _busqueda = '';

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productoVM = Provider.of<ProductoViewModel>(context);
    final ventaVM = Provider.of<VentaViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    final productosDisponibles =
        productoVM.productos.where((producto) {
          final coincideBusqueda =
              producto.nombre.toLowerCase().contains(_busqueda.toLowerCase()) ||
              producto.categoria.toLowerCase().contains(
                _busqueda.toLowerCase(),
              );

          return producto.activo &&
              producto.disponible &&
              producto.stock > 0 &&
              coincideBusqueda;
        }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FA),

      appBar: AppBar(
        title: const Text(
          'Punto de Venta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _busquedaController,
              onChanged: (valor) {
                setState(() {
                  _busqueda = valor;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: const Icon(Icons.search, color: Colors.pink),
                suffixIcon:
                    _busqueda.isNotEmpty
                        ? IconButton(
                          onPressed: () {
                            _busquedaController.clear();

                            setState(() {
                              _busqueda = '';
                            });
                          },
                          icon: const Icon(Icons.close),
                        )
                        : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            flex: 5,
            child:
                productosDisponibles.isEmpty
                    ? const Center(
                      child: Text(
                        'No hay productos disponibles.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemCount: productosDisponibles.length,
                      itemBuilder: (context, index) {
                        final producto = productosDisponibles[index];

                        return _productoCard(context, producto, ventaVM);
                      },
                    ),
          ),

          const Divider(height: 1),

          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white,
              child:
                  ventaVM.productosVentaActual.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 55,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Agrega productos a la venta',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                      : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Venta actual',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${ventaVM.cantidadTotalProductos} producto(s)',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              itemCount: ventaVM.productosVentaActual.length,
                              itemBuilder: (context, index) {
                                final item =
                                    ventaVM.productosVentaActual[index];

                                Producto? producto;

                                try {
                                  producto = productoVM.productos.firstWhere(
                                    (p) => p.id == item.productoId,
                                  );
                                } catch (_) {
                                  producto = null;
                                }

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.nombreProducto,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                '\$${item.precioUnitario.toStringAsFixed(2)} c/u',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        IconButton(
                                          onPressed: () {
                                            ventaVM.disminuirCantidad(
                                              item.productoId,
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: Colors.pink,
                                          ),
                                        ),

                                        Text(
                                          '${item.cantidad}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),

                                        IconButton(
                                          onPressed:
                                              producto == null
                                                  ? null
                                                  : () {
                                                    final ok = ventaVM
                                                        .incrementarCantidad(
                                                          producto!,
                                                        );

                                                    if (!ok) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            ventaVM.error ??
                                                                'No se pudo aumentar la cantidad.',
                                                          ),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  },
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                            color: Colors.pink,
                                          ),
                                        ),

                                        SizedBox(
                                          width: 75,
                                          child: Text(
                                            '\$${item.subtotal.toStringAsFixed(2)}',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        IconButton(
                                          onPressed: () {
                                            ventaVM.quitarProductoDeVenta(
                                              item.productoId,
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: DropdownButtonFormField<String>(
                              value: ventaVM.metodoPago,
                              decoration: InputDecoration(
                                labelText: 'Método de pago',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Efectivo',
                                  child: Text('Efectivo'),
                                ),
                                DropdownMenuItem(
                                  value: 'Transferencia',
                                  child: Text('Transferencia'),
                                ),
                              ],
                              onChanged: (valor) {
                                if (valor != null) {
                                  ventaVM.cambiarMetodoPago(valor);
                                }
                              },
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '\$${ventaVM.totalVenta.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 25,
                                    color: Colors.pink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        ventaVM.cargando
                                            ? null
                                            : () {
                                              ventaVM.cancelarVenta();
                                            },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      'Cancelar',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        ventaVM.cargando
                                            ? null
                                            : () async {
                                              final adminId =
                                                  authVM.user?.uid ?? '';

                                              if (adminId.isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'No se encontró el usuario administrador.',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                                return;
                                              }

                                              final ok = await ventaVM
                                                  .confirmarVenta(adminId);

                                              if (!context.mounted) {
                                                return;
                                              }

                                              if (ok) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      '¡Venta registrada correctamente!',
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      ventaVM.error ??
                                                          'No se pudo registrar la venta.',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                    icon:
                                        ventaVM.cargando
                                            ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                            : const Icon(
                                              Icons.check_circle_outline,
                                            ),
                                    label: Text(
                                      ventaVM.cargando
                                          ? 'Guardando...'
                                          : 'Confirmar',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.pink,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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

  Widget _productoCard(
    BuildContext context,
    Producto producto,
    VentaViewModel ventaVM,
  ) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () {
          final ok = ventaVM.agregarProductoAVenta(producto);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ok
                    ? '${producto.nombre} agregado'
                    : ventaVM.error ?? 'No se pudo agregar.',
              ),
              backgroundColor: ok ? Colors.green : Colors.red,
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child:
                    producto.imagenUrl.isNotEmpty
                        ? Image.network(
                          producto.imagenUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return _imagenDefault();
                          },
                        )
                        : _imagenDefault(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    producto.categoria,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '\$${producto.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Stock: ${producto.stock}',
                    style: TextStyle(
                      color: producto.stock <= 3 ? Colors.orange : Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 7),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final ok = ventaVM.agregarProductoAVenta(producto);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? '${producto.nombre} agregado'
                                  : ventaVM.error ?? 'No se pudo agregar.',
                            ),
                            backgroundColor: ok ? Colors.green : Colors.red,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      icon: const Icon(Icons.add_shopping_cart, size: 17),
                      label: const Text(
                        'Agregar',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagenDefault() {
    return Container(
      color: Colors.pink.shade50,
      child: const Center(
        child: Icon(Icons.shopping_bag_outlined, size: 45, color: Colors.pink),
      ),
    );
  }
}
