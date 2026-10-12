import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/apartado.dart';
import '../../viewsmodels/apartado_viewmodel.dart';

class MisApartadosScreen extends StatelessWidget {
  const MisApartadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apartadoVM = Provider.of<ApartadoViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FA),

      body: StreamBuilder<List<Apartado>>(
        stream: apartadoVM.getMisApartados(),
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
                  'No se pudieron cargar tus apartados.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final apartados = snapshot.data ?? [];

          if (apartados.isEmpty) {
            return _pantallaVacia();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: apartados.length,
            itemBuilder: (context, index) {
              final apartado = apartados[index];

              return _apartadoCard(apartado);
            },
          );
        },
      ),
    );
  }

  Widget _pantallaVacia() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 85, color: Colors.pink.shade200),

            const SizedBox(height: 18),

            const Text(
              'Aún no tienes apartados',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Los productos que apartes aparecerán aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _apartadoCard(Apartado apartado) {
    final colorEstado = _colorEstado(apartado.estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      apartado.imagenUrl.isNotEmpty
                          ? Image.network(
                            apartado.imagenUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imagenDefault(),
                          )
                          : _imagenDefault(),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apartado.nombreProducto,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        '\$${apartado.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.pink,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorEstado.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          apartado.estado,
                          style: TextStyle(
                            color: colorEstado,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            const Divider(),

            const SizedBox(height: 8),

            _fila('Cantidad', '${apartado.cantidad}'),

            if (apartado.talla.isNotEmpty) ...[
              const SizedBox(height: 6),
              _fila('Talla', apartado.talla),
            ],

            const SizedBox(height: 6),

            _fila('Anticipo', '\$${apartado.anticipo.toStringAsFixed(2)}'),

            const SizedBox(height: 6),

            _fila(
              'Saldo pendiente',
              '\$${apartado.saldoPendiente.toStringAsFixed(2)}',
              importante: true,
            ),

            const SizedBox(height: 6),

            _fila(
              'Fecha del apartado',
              _formatearFecha(apartado.fechaApartado),
            ),

            const SizedBox(height: 6),

            _fila('Fecha límite', _formatearFecha(apartado.fechaLimite)),
          ],
        ),
      ),
    );
  }

  Widget _fila(String titulo, String valor, {bool importante = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(titulo, style: TextStyle(color: Colors.grey.shade700)),
        ),

        Text(
          valor,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: importante ? Colors.pink : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _imagenDefault() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.pink.shade50,
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: Colors.pink,
        size: 38,
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');

    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Confirmado':
        return Colors.blue;

      case 'Recogido':
        return Colors.green;

      case 'Cancelado':
        return Colors.red;

      case 'Vencido':
        return Colors.orange;

      default:
        return Colors.amber.shade800;
    }
  }
}
