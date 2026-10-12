import 'package:url_launcher/url_launcher.dart';

class MapasService {
  static const double _latitud = 20.4850;
  static const double _longitud = -99.2150;
  static const String _nombreTienda = "Girls’ Boutique";

  // Abrir la ubicación de la boutique en Google Maps
  static Future<bool> abrirUbicacionTienda() async {
    final String query = Uri.encodeComponent(
      "$_nombreTienda, $_latitud,$_longitud",
    );
    final Uri googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$query",
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      return await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      );
    } else {
      return false;
    }
  }

  // Generar enlace web para compartir la ubicación
  static String obtenerEnlaceUbicacion() {
    return "https://maps.google.com/?q=$_latitud,$_longitud";
  }
}
