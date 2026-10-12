import 'package:url_launcher/url_launcher.dart';
import '../models/carrito_item_model.dart';

class WhatsAppService {
  static const String _telefonoBoutique = "7721286219";

  static Future<bool> solicitarInformesProducto({
    required String nombreProducto,
    required double precio,
  }) async {
    final String mensaje =
        "¡Hola, Girls’ Boutique! ✨ Me interesa obtener más información sobre el producto: "
        "*$nombreProducto* con precio de *\$$precio*. ¿Tienen disponibilidad?";

    return await _abrirWhatsApp(mensaje);
  }

  // Enviar pedido del carrito a WhatsApp
  static Future<bool> enviarPedidoCarrito({
    required List<CarritoItemModel> items,
    required double total,
  }) async {
    StringBuffer buffer = StringBuffer();
    buffer.writeln(
      "¡Hola, Girls’ Boutique! ✨ Quisiera realizar un pedido con los siguientes productos:\n",
    );

    for (var item in items) {
      buffer.writeln(
        "• ${item.nombre} x${item.cantidad} - \$${item.subtotal.toStringAsFixed(2)}",
      );
    }

    buffer.writeln("\n*Total estimado: \$${total.toStringAsFixed(2)}*");
    buffer.writeln(
      "Quedo al pendiente para confirmar mi pedido y método de entrega. 💕",
    );

    return await _abrirWhatsApp(buffer.toString());
  }

  static Future<bool> _abrirWhatsApp(String mensaje) async {
    final Uri url = Uri.parse(
      "https://wa.me/$_telefonoBoutique?text=${Uri.encodeComponent(mensaje)}",
    );

    if (await canLaunchUrl(url)) {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      return false;
    }
  }
}
