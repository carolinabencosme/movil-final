import 'package:flutter/material.dart';

/// Datos de un mapa de región Pokémon
///
/// Contiene información sobre el asset del mapa y sus dimensiones reales.
/// Las imágenes son capturas oficiales de cada versión almacenadas en
/// `assets/maps/regions/**` y las dimensiones provienen directamente del
/// archivo PNG correspondiente.
class RegionMapData {
  const RegionMapData({
    required this.region,
    required this.assetPath,
    required this.mapSize,
    required this.gameVersion,
  });

  /// Nombre de la región (ej: "kanto", "johto")
  final String region;

  /// Ruta del asset del mapa
  final String assetPath;

  /// Tamaño real del mapa en píxeles (ancho, alto)
  final Size mapSize;

  /// Versión del juego (ej: "FireRed/LeafGreen", "HeartGold/SoulSilver")
  final String gameVersion;

  /// Obtiene el nombre formateado de la región
  String get displayName {
    return region[0].toUpperCase() + region.substring(1);
  }

  /// Determina si el asset es un archivo SVG
  bool get isSvg {
    return assetPath.toLowerCase().endsWith('.svg');
  }
}

/// Mapas de regiones Pokémon oficiales extraídos de los juegos
///
/// Organizado por región y versión de juego para soportar múltiples
/// generaciones y remakes. Las dimensiones corresponden a las capturas
/// que se incluyen en `assets/maps/regions/**` y se midieron directamente
/// de cada PNG para evitar valores aproximados.
final Map<String, List<RegionMapData>> regionMapsByVersion = {
  'kanto': [
    const RegionMapData(
      region: 'kanto',
      assetPath: 'assets/maps/regions/kanto/kanto_pokeearth.png',
      mapSize: Size(200, 618),
      gameVersion: 'Pokéarth',
    ),
  ],
  'johto': [
    const RegionMapData(
      region: 'johto',
      assetPath: 'assets/maps/regions/johto/johto_pokeearth.png',
      mapSize: Size(166, 144),
      gameVersion: 'Pokéarth',
    ),
  ],
  'hoenn': [
    const RegionMapData(
      region: 'hoenn',
      assetPath: 'assets/maps/regions/hoenn/hoenn_pokeearth.png',
      mapSize: Size(306, 221),
      gameVersion: 'Pokéarth',
    ),
  ],
  'sinnoh': [
    const RegionMapData(
      region: 'sinnoh',
      assetPath: 'assets/maps/regions/sinnoh/sinnoh_pokeearth.png',
      mapSize: Size(216, 168),
      gameVersion: 'Pokéarth',
    ),
  ],
  'unova': [
    const RegionMapData(
      region: 'unova',
      assetPath: 'assets/maps/regions/unova/unova_pokeearth.png',
      mapSize: Size(256, 168),
      gameVersion: 'Pokéarth',
    ),
  ],
  'kalos': [
    const RegionMapData(
      region: 'kalos',
      assetPath: 'assets/maps/regions/kalos/kalos_pokeearth.png',
      mapSize: Size(320, 210),
      gameVersion: 'Pokéarth',
    ),
  ],
  'alola': [
    const RegionMapData(
      region: 'alola',
      assetPath: 'assets/maps/regions/alola/alola_pokeearth.png',
      mapSize: Size(400, 240),
      gameVersion: 'Pokéarth',
    ),
  ],
  'galar': [
    const RegionMapData(
      region: 'galar',
      assetPath: 'assets/maps/regions/galar/galar_pokeearth.png',
      mapSize: Size(728, 1420),
      gameVersion: 'Pokéarth',
    ),
  ],
  'hisui': [
    const RegionMapData(
      region: 'hisui',
      assetPath: 'assets/maps/regions/hisui/hisui_pokeearth.png',
      mapSize: Size(640, 360),
      gameVersion: 'Pokéarth',
    ),
  ],
};

/// Backward compatibility: Mapa simple que retorna la primera versión de cada región
final Map<String, RegionMapData> regionMaps = {
  for (var entry in regionMapsByVersion.entries)
    entry.key: entry.value.first,
};

/// Obtiene los datos del mapa de una región (primera versión disponible)
///
/// Retorna null si la región no está mapeada.
RegionMapData? getRegionMapData(String regionName) {
  final normalized = regionName.toLowerCase().trim();
  return regionMaps[normalized];
}

/// Obtiene todas las versiones de mapas disponibles para una región
///
/// Retorna una lista vacía si la región no está mapeada.
List<RegionMapData> getRegionMapVersions(String regionName) {
  final normalized = regionName.toLowerCase().trim();
  return regionMapsByVersion[normalized] ?? [];
}

/// Obtiene un mapa específico por región y versión de juego
///
/// Retorna null si no se encuentra la combinación.
RegionMapData? getRegionMapByVersion(String regionName, String gameVersion) {
  final versions = getRegionMapVersions(regionName);
  final filtered = versions.where(
    (map) => map.gameVersion.toLowerCase() == gameVersion.toLowerCase(),
  );
  return filtered.isEmpty ? null : filtered.first;
}

/// Verifica si una región tiene datos de mapa disponibles
bool hasRegionMapData(String regionName) {
  return getRegionMapData(regionName) != null;
}

/// Obtiene todas las regiones con datos de mapa disponibles
List<String> getAvailableRegionMaps() {
  return regionMaps.keys.toList();
}

/// Obtiene el número total de versiones de mapas para una región
int getRegionMapVersionCount(String regionName) {
  return getRegionMapVersions(regionName).length;
}
