import '../models/pokemon_location.dart';

/// Coordenadas X/Y del centro de cada región Pokémon en el mapa
///
/// Las coordenadas son relativas a imágenes de 800x600 píxeles.
/// El centro del mapa está en (400, 300).
const Map<String, MapCoordinates> regionCoordinates = {
  'kanto': MapCoordinates(400, 300),
  'johto': MapCoordinates(400, 300),
  'hoenn': MapCoordinates(400, 300),
  'sinnoh': MapCoordinates(400, 300),
  'unova': MapCoordinates(400, 300),
  'kalos': MapCoordinates(400, 300),
  'alola': MapCoordinates(400, 300),
  'galar': MapCoordinates(400, 300),
  'paldea': MapCoordinates(400, 300),
};

/// Obtiene las coordenadas del centro de una región por su nombre
///
/// Retorna null si la región no está mapeada
MapCoordinates? getRegionCoordinates(String regionName) {
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
