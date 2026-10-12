import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/producto.dart';
import '../../viewsmodels/producto_viewmodel.dart';

class EditarProductoScreen extends StatefulWidget {
  final Producto producto;

  const EditarProductoScreen({super.key, required this.producto});

  @override
  State<EditarProductoScreen> createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  late TextEditingController _imagenUrlController;

  final List<String> _categorias = [
    'Maquillaje',
    'Skincare',
    'Ropa',
    'Accesorios',
    'Bolsas',
    'Peluches',
    'Productos para cabello',
    'Novedades',
  ];

  final List<String> _tallasDisponibles = ['XS', 'S', 'M', 'L', 'XL', 'Única'];

  late String _categoriaSeleccionada;
  late List<String> _tallasSeleccionadas;

  @override
  void initState() {
    super.initState();

    _nombreController = TextEditingController(text: widget.producto.nombre);

    _descripcionController = TextEditingController(
      text: widget.producto.descripcion,
    );

    _precioController = TextEditingController(
      text: widget.producto.precio.toStringAsFixed(2),
    );

    _stockController = TextEditingController(
      text: widget.producto.stock.toString(),
    );

    _imagenUrlController = TextEditingController(
      text: widget.producto.imagenUrl,
    );

    _categoriaSeleccionada = widget.producto.categoria;

    _tallasSeleccionadas = List<String>.from(widget.producto.tallas);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _imagenUrlController.dispose();

    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_categoriaSeleccionada == 'Ropa' && _tallasSeleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una talla para la ropa'),
        ),
      );

      return;
    }

    final precio = double.tryParse(_precioController.text.trim()) ?? 0;

    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    final productoActualizado = widget.producto.copyWith(
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      precio: precio,
      categoria: _categoriaSeleccionada,
      stock: stock,
      tallas:
          _categoriaSeleccionada == 'Ropa'
              ? List<String>.from(_tallasSeleccionadas)
              : [],
      imagenUrl: _imagenUrlController.text.trim(),
      disponible: stock > 0,
    );

    final productoVM = Provider.of<ProductoViewModel>(context, listen: false);

    final exito = await productoVM.actualizarProducto(productoActualizado);

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            productoVM.error ?? 'No se pudo actualizar el producto',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productoVM = Provider.of<ProductoViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre del producto',
                  prefixIcon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.pink,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa un nombre';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: const Icon(
                    Icons.category_outlined,
                    color: Colors.pink,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    _categorias.map((categoria) {
                      return DropdownMenuItem<String>(
                        value: categoria,
                        child: Text(categoria),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _categoriaSeleccionada = value;

                    if (value != 'Ropa') {
                      _tallasSeleccionadas.clear();
                    }
                  });
                },
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precioController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Precio (\$)',
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: Colors.pink,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        final precio = double.tryParse(value ?? '');

                        if (precio == null || precio <= 0) {
                          return 'Precio inválido';
                        }

                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Stock',
                        prefixIcon: const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.pink,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        final stock = int.tryParse(value ?? '');

                        if (stock == null || stock < 0) {
                          return 'Stock inválido';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              if (_categoriaSeleccionada == 'Ropa') ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tallas disponibles:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _tallasDisponibles.map((talla) {
                          final seleccionada = _tallasSeleccionadas.contains(
                            talla,
                          );

                          return FilterChip(
                            label: Text(talla),
                            selected: seleccionada,
                            selectedColor: Colors.pink.shade100,
                            checkmarkColor: Colors.pink,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _tallasSeleccionadas.add(talla);
                                } else {
                                  _tallasSeleccionadas.remove(talla);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                ),

                const SizedBox(height: 15),
              ],

              TextFormField(
                controller: _imagenUrlController,
                decoration: InputDecoration(
                  labelText: 'URL de imagen',
                  prefixIcon: const Icon(
                    Icons.image_outlined,
                    color: Colors.pink,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(
                    Icons.description_outlined,
                    color: Colors.pink,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: productoVM.cargando ? null : _guardarCambios,
                  icon:
                      productoVM.cargando
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Icon(Icons.save),
                  label: Text(
                    productoVM.cargando ? 'Guardando...' : 'Guardar Cambios',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
