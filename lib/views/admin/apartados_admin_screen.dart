import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/apartado.dart';
import '../../viewsmodels/apartado_viewmodel.dart';

// Conserva el mismo nombre de pantalla para no modificar las rutas existentes.
class ApartadosAdminScreen extends StatefulWidget {
  const ApartadosAdminScreen({super.key});

  @override
  State<ApartadosAdminScreen> createState() => _ApartadosAdminScreenState();
}

class _ApartadosAdminScreenState extends State<ApartadosAdminScreen> {
  final TextEditingController _busqueda = TextEditingController();
  final Map<String, Future<_DatosCliente>> _cacheClientes = {};

  late final Stream<List<Apartado>> _streamApartados;
  String _claveClientes = '';
  Future<Map<String, _DatosCliente>>? _futuroClientes;

  @override
  void initState() {
    super.initState();
    _streamApartados = context.read<ApartadoViewModel>().getTodosApartados();
    _busqueda.addListener(_actualizarBusqueda);
  }

  void _actualizarBusqueda() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _busqueda.removeListener(_actualizarBusqueda);
    _busqueda.dispose();
    super.dispose();
  }

  // Un apartado sin usuarioId se muestra por separado, sin mezclar clientes.
  String _claveApartado(Apartado apartado) {
    final uid = apartado.usuarioId.trim();
    return uid.isEmpty ? 'sin_usuario:${apartado.id}' : uid;
  }

  Future<_DatosCliente> _leerCliente(String uid) async {
    final referencia = uid.length > 6 ? uid.substring(0, 6) : uid;
    if (uid.startsWith('sin_usuario:')) {
      return _DatosCliente(nombre: 'Cliente sin identificar ($referencia)');
    }

    try {
      final documento =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(uid)
              .get();

      if (!documento.exists) {
        return _DatosCliente(nombre: 'Cliente sin nombre ($referencia)');
      }

      final datos = documento.data() ?? <String, dynamic>{};
      final nombre = (datos['nombre'] ?? '').toString().trim();

      return _DatosCliente(
        nombre: nombre.isEmpty ? 'Cliente sin nombre ($referencia)' : nombre,
        correo: (datos['correo'] ?? '').toString().trim(),
        telefono: (datos['telefono'] ?? '').toString().trim(),
      );
    } catch (error) {
      debugPrint('No se pudo leer el perfil $uid: $error');
      return _DatosCliente(
        nombre: 'Cliente sin nombre ($referencia)',
        errorLectura: true,
      );
    }
  }

  Future<Map<String, _DatosCliente>> _obtenerClientes(
    List<String> identificadores,
  ) {
    final ids = [...identificadores]..sort();
    final nuevaClave = ids.join('|');

    if (_futuroClientes == null || nuevaClave != _claveClientes) {
      _claveClientes = nuevaClave;
      _futuroClientes = Future.wait(
        ids.map((id) async {
          final cliente = await _cacheClientes.putIfAbsent(
            id,
            () => _leerCliente(id),
          );
          return MapEntry(id, cliente);
        }),
      ).then((entradas) => Map.fromEntries(entradas));
    }

    return _futuroClientes!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FA),
      appBar: AppBar(
        title: const Text(
          'Apartados',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Apartado>>(
        stream: _streamApartados,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _mensajeCentrado(
              Icons.error_outline,
              'No se pudieron cargar los apartados.\n${snapshot.error}',
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.pink),
            );
          }

          final apartados = snapshot.data!;
          if (apartados.isEmpty) {
            return _mensajeCentrado(
              Icons.bookmark_border,
              'No hay apartados.\nCuando un cliente aparte un producto aparecerá aquí.',
            );
          }

          final grupos = <String, List<Apartado>>{};
          for (final apartado in apartados) {
            grupos
                .putIfAbsent(_claveApartado(apartado), () => [])
                .add(apartado);
          }

          return FutureBuilder<Map<String, _DatosCliente>>(
            future: _obtenerClientes(grupos.keys.toList()),
            builder: (context, clientesSnapshot) {
              if (clientesSnapshot.hasError) {
                return _mensajeCentrado(
                  Icons.error_outline,
                  'No se pudieron consultar los nombres de los clientes.',
                );
              }
              if (!clientesSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.pink),
                );
              }

              final clientes = clientesSnapshot.data!;
              final texto = _busqueda.text.trim().toLowerCase();

              final idsVisibles =
                  grupos.keys.where((id) {
                    if (texto.isEmpty) return true;
                    final cliente = clientes[id]!;
                    return cliente.nombre.toLowerCase().contains(texto) ||
                        cliente.correo.toLowerCase().contains(texto) ||
                        cliente.telefono.contains(texto);
                  }).toList();

              idsVisibles.sort((a, b) {
                final orden = clientes[a]!.nombre.toLowerCase().compareTo(
                  clientes[b]!.nombre.toLowerCase(),
                );
                return orden != 0 ? orden : a.compareTo(b);
              });

              final hayErrorDePerfil = clientes.values.any(
                (cliente) => cliente.errorLectura,
              );

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${grupos.length} ${grupos.length == 1 ? 'cliente con apartados' : 'clientes con apartados'}',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _busqueda,
                          decoration: InputDecoration(
                            hintText: 'Buscar por nombre, correo o teléfono',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.pink,
                            ),
                            suffixIcon:
                                _busqueda.text.isNotEmpty
                                    ? IconButton(
                                      tooltip: 'Limpiar búsqueda',
                                      onPressed: _busqueda.clear,
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
                        if (hayErrorDePerfil) ...[
                          const SizedBox(height: 10),
                          const Text(
                            'Algunos nombres no se pudieron consultar. '
                            'Revisa los permisos de lectura de usuarios en Firestore.',
                            style: TextStyle(color: Colors.deepOrange),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        idsVisibles.isEmpty
                            ? _mensajeCentrado(
                              Icons.search_off,
                              'No se encontraron clientes.',
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
                              itemCount: idsVisibles.length,
                              itemBuilder: (context, index) {
                                final uid = idsVisibles[index];
                                return _tarjetaCliente(
                                  uid,
                                  clientes[uid]!,
                                  grupos[uid]!,
                                );
                              },
                            ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _tarjetaCliente(
    String uid,
    _DatosCliente cliente,
    List<Apartado> apartados,
  ) {
    final activos = apartados.where(_esActivo).length;
    final saldo = apartados
        .where(_esActivo)
        .fold<double>(0, (suma, apartado) => suma + apartado.saldoPendiente);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.pink.shade50,
          foregroundColor: Colors.pink,
          child: const Icon(Icons.person_outline),
        ),
        title: Text(
          cliente.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${apartados.length} ${apartados.length == 1 ? 'apartado' : 'apartados'} · $activos activos',
              ),
              const SizedBox(height: 4),
              Text(
                'Saldo por cobrar: \$${saldo.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.pink),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => _DetalleClienteScreen(
                    uid: uid,
                    cliente: cliente,
                    apartadosIniciales: List<Apartado>.of(apartados),
                  ),
            ),
          );
        },
      ),
    );
  }
}

class _DatosCliente {
  final String nombre;
  final String correo;
  final String telefono;
  final bool errorLectura;

  const _DatosCliente({
    required this.nombre,
    this.correo = '',
    this.telefono = '',
    this.errorLectura = false,
  });
}

class _DetalleClienteScreen extends StatefulWidget {
  final String uid;
  final _DatosCliente cliente;
  final List<Apartado> apartadosIniciales;

  const _DetalleClienteScreen({
    required this.uid,
    required this.cliente,
    required this.apartadosIniciales,
  });

  @override
  State<_DetalleClienteScreen> createState() => _DetalleClienteScreenState();
}

class _DetalleClienteScreenState extends State<_DetalleClienteScreen> {
  late final Stream<List<Apartado>> _streamCliente;

  @override
  void initState() {
    super.initState();
    final coleccion = FirebaseFirestore.instance.collection('apartados');

    // Respaldo para apartados viejos sin un identificador de usuario.
    if (widget.uid.startsWith('sin_usuario:')) {
      final id = widget.uid.substring('sin_usuario:'.length);
      _streamCliente = coleccion.doc(id).snapshots().map((doc) {
        final datos = doc.data();
        if (datos == null) return <Apartado>[];
        return <Apartado>[Apartado.fromFirestore(datos, doc.id)];
      });
    } else {
      // Solo pide a Firestore los apartados de este cliente.
      _streamCliente = coleccion
          .where('usuarioId', isEqualTo: widget.uid)
          .snapshots()
          .map((snapshot) {
            final lista =
                snapshot.docs
                    .map((doc) => Apartado.fromFirestore(doc.data(), doc.id))
                    .toList();
            lista.sort((a, b) => b.fechaApartado.compareTo(a.fechaApartado));
            return lista;
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final apartadoVM = context.read<ApartadoViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FA),
      appBar: AppBar(
        title: Text(widget.cliente.nombre, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Apartado>>(
        stream: _streamCliente,
        // Evita quedarse en el indicador de carga al abrir esta pantalla.
        initialData: widget.apartadosIniciales,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _mensajeCentrado(
              Icons.error_outline,
              'Error al actualizar los apartados.\n${snapshot.error}',
            );
          }

          final apartados = snapshot.data ?? widget.apartadosIniciales;
          if (apartados.isEmpty) {
            return _mensajeCentrado(
              Icons.bookmark_border,
              'Este cliente ya no tiene apartados.',
            );
          }

          final activos = apartados.where(_esActivo).length;
          final saldo = apartados
              .where(_esActivo)
              .fold<double>(
                0,
                (suma, apartado) => suma + apartado.saldoPendiente,
              );

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: apartados.length + 1,
            itemBuilder: (context, index) {
              if (index > 0) {
                return _TarjetaApartado(
                  apartado: apartados[index - 1],
                  apartadoVM: apartadoVM,
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.cliente.nombre,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.cliente.correo.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(widget.cliente.correo),
                        ],
                        if (widget.cliente.telefono.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('Teléfono: ${widget.cliente.telefono}'),
                        ],
                        const Divider(height: 24),
                        Text(
                          'Apartados: ${apartados.length} · Activos: $activos',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Saldo por cobrar: \$${saldo.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.pink,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

bool _esActivo(Apartado apartado) =>
    apartado.estado == 'Pendiente' || apartado.estado == 'Confirmado';

Widget _mensajeCentrado(IconData icono, String mensaje) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 68, color: Colors.pink.shade200),
          const SizedBox(height: 14),
          Text(mensaje, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

// Mantiene las tarjetas de productos y los cuatro botones que ya tenías.
class _TarjetaApartado extends StatelessWidget {
  final Apartado apartado;
  final ApartadoViewModel apartadoVM;

  const _TarjetaApartado({required this.apartado, required this.apartadoVM});

  @override
  Widget build(BuildContext context) {
    final estadoColor = _colorEstado(apartado.estado);

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
                            width: 70,
                            height: 70,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text('Cantidad: ${apartado.cantidad}'),
                      if (apartado.talla.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text('Talla: ${apartado.talla}'),
                      ],
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: estadoColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          apartado.estado,
                          style: TextStyle(
                            color: estadoColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
            _fila('Precio', '\$${apartado.precio.toStringAsFixed(2)}'),
            const SizedBox(height: 6),
            _fila('Total', '\$${apartado.total.toStringAsFixed(2)}'),
            const SizedBox(height: 6),
            _fila('Anticipo', '\$${apartado.anticipo.toStringAsFixed(2)}'),
            const SizedBox(height: 6),
            _fila(
              'Saldo pendiente',
              '\$${apartado.saldoPendiente.toStringAsFixed(2)}',
              importante: true,
            ),
            const SizedBox(height: 10),
            _fila('Fecha', _formatearFecha(apartado.fechaApartado)),
            const SizedBox(height: 6),
            _fila('Fecha límite', _formatearFecha(apartado.fechaLimite)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (apartado.estado == 'Pendiente')
                  ElevatedButton.icon(
                    onPressed: () => _cambiarEstado(context, 'Confirmado'),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirmar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (_esActivo(apartado))
                  ElevatedButton.icon(
                    onPressed: () => _cambiarEstado(context, 'Recogido'),
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Recogido'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (_esActivo(apartado))
                  OutlinedButton.icon(
                    onPressed: () => _cambiarEstado(context, 'Cancelado'),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                if (_esActivo(apartado))
                  OutlinedButton.icon(
                    onPressed: () => _cambiarEstado(context, 'Vencido'),
                    icon: const Icon(Icons.schedule),
                    label: const Text('Vencido'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cambiarEstado(BuildContext context, String estado) async {
    bool ok;
    switch (estado) {
      case 'Confirmado':
        ok = await apartadoVM.confirmarApartado(apartado.id);
        break;
      case 'Recogido':
        ok = await apartadoVM.marcarRecogido(apartado.id);
        break;
      case 'Cancelado':
        ok = await apartadoVM.cancelarApartado(apartado.id);
        break;
      case 'Vencido':
        ok = await apartadoVM.marcarVencido(apartado.id);
        break;
      default:
        ok = await apartadoVM.cambiarEstado(apartado.id, estado);
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? Colors.green : Colors.red,
        content: Text(
          ok
              ? 'Estado actualizado a $estado'
              : (apartadoVM.error ?? 'No se pudo actualizar el apartado.'),
        ),
      ),
    );
  }

  Widget _fila(String titulo, String valor, {bool importante = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titulo,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: importante ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            color: importante ? Colors.pink : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
        size: 36,
      ),
    );
  }

  String _formatearFecha(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';

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
