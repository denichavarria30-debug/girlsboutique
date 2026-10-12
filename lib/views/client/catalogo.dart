import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/negocio_config.dart';
import '../../models/producto.dart';
import '../../viewsmodels/producto_viewmodel.dart';
import '../../viewsmodels/carrito_viewmodel.dart';
import '../../viewsmodels/apartado_viewmodel.dart';

class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productoVM = Provider.of<ProductoViewModel>(context);
    final carritoVM = Provider.of<CarritoViewModel>(context);

    final categorias = [
      'Todos',
      'Maquillaje',
      'Skincare',
      'Ropa',
      'Accesorios',
      'Bolsas',
      'Peluches',
      'Productos para cabello',
      'Novedades',
    ];

    final productosActivos =
        productoVM.productos.where((producto) => producto.activo).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                onChanged: productoVM.buscarProducto,
                decoration: InputDecoration(
                  hintText: 'Buscar productos...',
                  prefixIcon: const Icon(Icons.search, color: Colors.pink),
                  filled: true,
                  fillColor: Colors.pink.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categorias.length,
                itemBuilder: (context, index) {
                  final categoria = categorias[index];

                  final seleccionada =
                      productoVM.categoriaSeleccionada == categoria;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(categoria),
                      selected: seleccionada,
                      selectedColor: Colors.pink,
                      backgroundColor: Colors.pink.shade50,
                      labelStyle: TextStyle(
                        color: seleccionada ? Colors.white : Colors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) {
                        productoVM.seleccionarCategoria(categoria);
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child:
                  productoVM.cargando
                      ? const Center(
                        child: CircularProgressIndicator(color: Colors.pink),
                      )
                      : productosActivos.isEmpty
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'No se encontraron productos disponibles.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      )
                      : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.55,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: productosActivos.length,
                        itemBuilder: (context, index) {
                          final producto = productosActivos[index];

                          return _productoCard(
                            context,
                            producto,
                            productoVM,
                            carritoVM,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productoCard(
    BuildContext context,
    Producto producto,
    ProductoViewModel productoVM,
    CarritoViewModel carritoVM,
  ) {
    final estadoStock = productoVM.obtenerEstadoStock(producto.stock);

    final disponible =
        producto.stock > 0 && producto.disponible && producto.activo;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          _mostrarDetalleProducto(context, producto, carritoVM);
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
                          errorBuilder: (_, __, ___) => _imagenDefault(),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    producto.categoria,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Icon(
                        producto.stock <= 0
                            ? Icons.cancel
                            : producto.stock <= 3
                            ? Icons.warning_amber
                            : Icons.check_circle,
                        size: 15,
                        color:
                            producto.stock <= 0
                                ? Colors.red
                                : producto.stock <= 3
                                ? Colors.orange
                                : Colors.green,
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          estadoStock,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color:
                                producto.stock <= 0
                                    ? Colors.red
                                    : producto.stock <= 3
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: disponible ? Colors.pink : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed:
                          disponible
                              ? () {
                                final ok = carritoVM.agregarProducto(producto);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        ok ? Colors.green : Colors.red,
                                    content: Text(
                                      ok
                                          ? '${producto.nombre} agregado al carrito'
                                          : 'No se pudo agregar al carrito',
                                    ),
                                  ),
                                );
                              }
                              : null,
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: const Text(
                        'Agregar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.pink,
                        side: const BorderSide(color: Colors.pink),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed:
                          disponible
                              ? () {
                                _mostrarModalApartado(context, producto);
                              }
                              : null,
                      icon: const Icon(Icons.bookmark_add_outlined, size: 17),
                      label: const Text(
                        'Apartar',
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
        child: Icon(Icons.shopping_bag_outlined, size: 50, color: Colors.pink),
      ),
    );
  }

  void _mostrarModalApartado(BuildContext context, Producto producto) {
    String? tallaSeleccionada;

    if (producto.tallas.isNotEmpty) {
      tallaSeleccionada = producto.tallas.first;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apartar ${producto.nombre}',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text('Precio: \$${producto.precio.toStringAsFixed(2)}'),

                    const SizedBox(height: 5),

                    Text(
                      'Anticipo (20%): '
                      '\$${(producto.precio * 0.20).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Saldo pendiente: '
                      '\$${(producto.precio * 0.80).toStringAsFixed(2)}',
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Fecha límite aproximada: 7 días',
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.pink.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Datos para transferencia',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text('Banco: ${NegocioConfig.banco}'),

                          const SizedBox(height: 5),

                          Text('Titular: ${NegocioConfig.titular}'),

                          const SizedBox(height: 5),

                          Text('Cuenta / CLABE: ${NegocioConfig.cuenta}'),

                          const SizedBox(height: 10),

                          const Text(
                            'Realiza el anticipo y después confirma el apartado. '
                            'Se abrirá WhatsApp para que envíes tu comprobante.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'El apartado permanecerá pendiente hasta que '
                            'Girls\' Boutique confirme el pago.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (producto.tallas.isNotEmpty) ...[
                      const SizedBox(height: 18),

                      const Text(
                        'Selecciona una talla:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            producto.tallas.map((talla) {
                              final seleccionada = tallaSeleccionada == talla;

                              return ChoiceChip(
                                label: Text(talla),
                                selected: seleccionada,
                                selectedColor: Colors.pink,
                                labelStyle: TextStyle(
                                  color:
                                      seleccionada
                                          ? Colors.white
                                          : Colors.black,
                                ),
                                onSelected: (selected) {
                                  if (!selected) {
                                    return;
                                  }

                                  setModalState(() {
                                    tallaSeleccionada = talla;
                                  });
                                },
                              );
                            }).toList(),
                      ),
                    ],

                    const SizedBox(height: 22),

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
                        onPressed: () async {
                          final apartadoVM = Provider.of<ApartadoViewModel>(
                            context,
                            listen: false,
                          );

                          final ok = await apartadoVM.crearApartado(
                            producto: producto,
                            cantidad: 1,
                            talla: tallaSeleccionada ?? '',
                          );

                          if (!context.mounted) {
                            return;
                          }

                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  apartadoVM.error ??
                                      'No se pudo realizar el apartado.',
                                ),
                              ),
                            );

                            return;
                          }

                          final anticipo = producto.precio * 0.20;

                          final saldo = producto.precio - anticipo;

                          final mensaje =
                              'Hola Girls\' Boutique 💕\n'
                              'Realicé el anticipo de mi apartado.\n\n'
                              'Producto: ${producto.nombre}\n'
                              'Cantidad: 1\n'
                              '${tallaSeleccionada != null && tallaSeleccionada!.isNotEmpty ? 'Talla: $tallaSeleccionada\n' : ''}'
                              'Total: \$${producto.precio.toStringAsFixed(2)}\n'
                              'Anticipo: \$${anticipo.toStringAsFixed(2)}\n'
                              'Saldo pendiente: \$${saldo.toStringAsFixed(2)}\n\n'
                              'Te envío mi comprobante para confirmar mi apartado. ✨';

                          final whatsappUrl = Uri.parse(
                            'https://wa.me/${NegocioConfig.whatsapp}'
                            '?text=${Uri.encodeComponent(mensaje)}',
                          );

                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                '¡${producto.nombre} apartado! '
                                'Envía tu comprobante por WhatsApp.',
                              ),
                            ),
                          );

                          final abierto = await launchUrl(
                            whatsappUrl,
                            mode: LaunchMode.externalApplication,
                          );

                          if (!abierto && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.orange,
                                content: Text(
                                  'El apartado sí se guardó, pero no se pudo '
                                  'abrir WhatsApp. Puedes enviar el comprobante '
                                  'manualmente.',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.bookmark_add),
                        label: const Text(
                          'Confirmar apartado y enviar comprobante',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarDetalleProducto(
    BuildContext context,
    Producto producto,
    CarritoViewModel carritoVM,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child:
                      producto.imagenUrl.isNotEmpty
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              producto.imagenUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imagenDefault(),
                            ),
                          )
                          : _imagenDefault(),
                ),

                const SizedBox(height: 18),

                Text(
                  producto.nombre,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  producto.categoria,
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 15),

                Text(
                  producto.descripcion.isEmpty
                      ? 'Sin descripción disponible.'
                      : producto.descripcion,
                  style: const TextStyle(fontSize: 15),
                ),

                const SizedBox(height: 18),

                Text(
                  '\$${producto.precio.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),

                const SizedBox(height: 6),

                Text('Stock disponible: ${producto.stock}'),

                if (producto.tallas.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('Tallas: ${producto.tallas.join(", ")}'),
                ],

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                    ),
                    onPressed:
                        producto.stock > 0
                            ? () {
                              final ok = carritoVM.agregarProducto(producto);

                              if (ok) {
                                Navigator.pop(ctx);
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor:
                                      ok ? Colors.green : Colors.red,
                                  content: Text(
                                    ok
                                        ? '${producto.nombre} agregado al carrito'
                                        : 'No se pudo agregar al carrito',
                                  ),
                                ),
                              );
                            }
                            : null,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: Text(
                      producto.stock > 0
                          ? 'Agregar al Carrito'
                          : 'Producto Agotado',
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.pink,
                      side: const BorderSide(color: Colors.pink),
                    ),
                    onPressed:
                        producto.stock > 0
                            ? () {
                              Navigator.pop(ctx);

                              _mostrarModalApartado(context, producto);
                            }
                            : null,
                    icon: const Icon(Icons.bookmark_add_outlined),
                    label: const Text('Apartar Producto'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
