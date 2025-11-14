import 'package:latlong2/latlong.dart';

/// Coordenadas geográficas de las regiones Pokémon
///
/// Como la PokéAPI no proporciona coordenadas reales, usamos
/// coordenadas basadas en las inspiraciones reales de cada región:
/// - Kanto: Región de Kanto, Japón
/// - Johto: Región de Kansai, Japón
/// - Hoenn: Kyushu, Japón
/// - Sinnoh: Hokkaido, Japón
/// - Unova: Nueva York, EE.UU.
/// - Kalos: Francia
/// - Alola: Hawái, EE.UU.
/// - Galar: Reino Unido
/// - Paldea: Península Ibérica (España/Portugal)
const Map<String, LatLng> regionCoordinates = {
  'kanto': LatLng(35.4, 138.7),
  'johto': LatLng(36.2, 138.5),
  'hoenn': LatLng(34.7, 135.5),
  'sinnoh': LatLng(39.7, 140.0),
  'unova': LatLng(40.7, -74.0),
  'kalos': LatLng(46.2, 2.2),
  'alola': LatLng(20.8, -156.3),
  'galar': LatLng(53.0, -1.5),
  'paldea': LatLng(40.4, -3.7),
};

/// Obtiene las coordenadas de una región por su nombre
///
/// Retorna null si la región no está mapeada
LatLng? getRegionCoordinates(String regionName) {
  final normalized = regionName.toLowerCase().trim();
  return regionCoordinates[normalized];
}

/// Verifica si una región tiene coordenadas disponibles
bool hasRegionCoordinates(String regionName) {
  return getRegionCoordinates(regionName) != null;
}

/// Obtiene todas las regiones con coordenadas disponibles
List<String> getAvailableRegions() {
  return regionCoordinates.keys.toList();
}
