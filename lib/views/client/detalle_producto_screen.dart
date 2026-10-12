import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/producto.dart';
import '../../viewsmodels/apartado_viewmodel.dart';

class DetalleProductoScreen extends StatefulWidget {
  final Producto producto;

  const DetalleProductoScreen({super.key, required this.producto});

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  String? _tallaSeleccionada;

  @override
  void initState() {
    super.initState();

    if (widget.producto.tallas.isNotEmpty) {
      _tallaSeleccionada = widget.producto.tallas.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prod = widget.producto;

    return Scaffold(
      appBar: AppBar(
        title: Text(prod.nombre),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.pink.shade50,
                    child:
                        prod.imagenUrl.isNotEmpty
                            ? Image.network(
                              prod.imagenUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 80,
                                    color: Colors.pink,
                                  ),
                                );
                              },
                            )
                            : const Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: 100,
                                color: Colors.pink,
                              ),
                            ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                prod.nombre,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Text(
                              '\$${prod.precio.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Chip(
                          label: Text(prod.categoria),
                          backgroundColor: Colors.pink.shade50,
                          labelStyle: const TextStyle(color: Colors.pink),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          prod.descripcion.isEmpty
                              ? 'Sin descripción disponible.'
                              : prod.descripcion,
                          style: const TextStyle(color: Colors.black87),
                        ),

                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Icon(
                              prod.stock <= 0
                                  ? Icons.cancel
                                  : prod.stock <= 3
                                  ? Icons.warning_amber
                                  : Icons.check_circle,
                              color:
                                  prod.stock <= 0
                                      ? Colors.red
                                      : prod.stock <= 3
                                      ? Colors.orange
                                      : Colors.green,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              prod.stock <= 0
                                  ? 'Agotado'
                                  : prod.stock <= 3
                                  ? 'Últimas piezas (${prod.stock})'
                                  : 'Disponible (${prod.stock})',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    prod.stock <= 0
                                        ? Colors.red
                                        : prod.stock <= 3
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                            ),
                          ],
                        ),

                        if (prod.tallas.isNotEmpty) ...[
                          const SizedBox(height: 20),

                          const Text(
                            'Selecciona tu talla',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children:
                                prod.tallas.map((talla) {
                                  final seleccionada =
                                      _tallaSeleccionada == talla;

                                  return ChoiceChip(
                                    label: Text(talla),
                                    selected: seleccionada,
                                    selectedColor: Colors.pink,
                                    backgroundColor: Colors.pink.shade50,
                                    labelStyle: TextStyle(
                                      color:
                                          seleccionada
                                              ? Colors.white
                                              : Colors.pink,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    onSelected: (_) {
                                      setState(() {
                                        _tallaSeleccionada = talla;
                                      });
                                    },
                                  );
                                }).toList(),
                          ),
                        ],

                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.pink.shade50,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Información del apartado',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Total: \$${prod.precio.toStringAsFixed(2)}',
                              ),

                              Text(
                                'Anticipo 20%: \$${(prod.precio * 0.20).toStringAsFixed(2)}',
                              ),

                              Text(
                                'Saldo pendiente: \$${(prod.precio * 0.80).toStringAsFixed(2)}',
                              ),

                              const Text(
                                'Fecha límite: 7 días después del apartado',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: Consumer<ApartadoViewModel>(
                builder: (context, apartadoVM, child) {
                  return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    onPressed:
                        (prod.stock <= 0 || apartadoVM.cargando)
                            ? null
                            : () async {
                              final exito = await apartadoVM.crearApartado(
                                producto: prod,
                                cantidad: 1,
                                talla: _tallaSeleccionada ?? '',
                              );

                              if (!context.mounted) {
                                return;
                              }

                              if (exito) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text(
                                      '¡${prod.nombre} apartado con éxito!',
                                    ),
                                  ),
                                );

                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      apartadoVM.error ??
                                          'No se pudo realizar el apartado.',
                                    ),
                                  ),
                                );
                              }
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
                            : const Icon(Icons.bookmark_add),

                    label: Text(
                      prod.stock <= 0
                          ? 'Agotado'
                          : apartadoVM.cargando
                          ? 'Procesando...'
                          : 'Apartar Producto',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
