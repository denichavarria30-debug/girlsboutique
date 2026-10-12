import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/producto.dart';
import '../../viewsmodels/producto_viewmodel.dart';

class AgregarProductoScreen extends StatefulWidget {
  const AgregarProductoScreen({super.key});

  @override
  State<AgregarProductoScreen> createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();
  final _imagenUrlController = TextEditingController();

  // Categorías de Girls' Boutique
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

  String? _categoriaSeleccionada;

  // Tallas disponibles solamente para ropa
  final List<String> _tallasDisponibles = ['XS', 'S', 'M', 'L', 'XL', 'Única'];

  final List<String> _tallasSeleccionadas = [];

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _imagenUrlController.dispose();

    super.dispose();
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_categoriaSeleccionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona una categoría')));
      return;
    }

    // Las tallas solamente son obligatorias para ropa
    if (_categoriaSeleccionada == 'Ropa' && _tallasSeleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una talla para la ropa'),
        ),
      );
      return;
    }

    final double precio = double.tryParse(_precioController.text.trim()) ?? 0;

    final int stock = int.tryParse(_stockController.text.trim()) ?? 0;

    final nuevoProducto = Producto(
      id: '',
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      categoria: _categoriaSeleccionada!,
      precio: precio,
      stock: stock,
      tallas:
          _categoriaSeleccionada == 'Ropa'
              ? List<String>.from(_tallasSeleccionadas)
              : [],
      imagenUrl: _imagenUrlController.text.trim(),
      disponible: stock > 0,
      activo: true,
      promocion: false,
      fechaRegistro: DateTime.now(),
    );

    final productoVM = Provider.of<ProductoViewModel>(context, listen: false);

    final exito = await productoVM.agregarProducto(nuevoProducto);

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Producto registrado correctamente!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al guardar: '
            '${productoVM.error ?? "Ocurrió un error"}',
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
        title: const Text('Nuevo Producto'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

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
                  setState(() {
                    _categoriaSeleccionada = value;

                    if (value != 'Ropa') {
                      _tallasSeleccionadas.clear();
                    }
                  });
                },

                validator: (value) {
                  if (value == null) {
                    return 'Selecciona una categoría';
                  }

                  return null;
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
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa el precio';
                        }

                        final precio = double.tryParse(value.trim());

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
                        labelText: 'Stock inicial',

                        prefixIcon: const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.pink,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa el stock';
                        }

                        final stock = int.tryParse(value.trim());

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
                const Text(
                  'Tallas disponibles:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),

                const SizedBox(height: 8),

                Wrap(
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

                          labelStyle: TextStyle(
                            color: seleccionada ? Colors.pink : Colors.black,

                            fontWeight:
                                seleccionada
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),

                          onSelected: (bool selected) {
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

                const SizedBox(height: 15),
              ],

              TextFormField(
                controller: _imagenUrlController,

                decoration: InputDecoration(
                  labelText: 'URL de la imagen (opcional)',

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
                  labelText: 'Descripción del producto',

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

                  onPressed: productoVM.cargando ? null : _guardarProducto,

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
                          : const Icon(Icons.save_outlined),

                  label: Text(
                    productoVM.cargando ? 'Guardando...' : 'Guardar Producto',

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
