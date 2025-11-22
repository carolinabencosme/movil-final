import 'package:flutter/material.dart';

/// Datos de un mapa de región Pokémon
///
/// Contiene información sobre el asset del mapa y sus dimensiones reales.
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
/// de cada PNG/SVG para evitar valores aproximados.
final Map<String, List<RegionMapData>> regionMapsByVersion = {
  'kanto': [
    const RegionMapData(
      region: 'kanto',
      assetPath: 'assets/maps/regions/kanto/kanto_rby.png',
      mapSize: Size(1024, 768),
      gameVersion: 'Red/Blue/Yellow',
    ),
    const RegionMapData(
      region: 'kanto',
      assetPath: 'assets/maps/regions/kanto/kanto_frlg.png',
      mapSize: Size(1024, 768),
      gameVersion: 'FireRed/LeafGreen',
    ),
    const RegionMapData(
      region: 'kanto',
      assetPath: 'assets/maps/regions/kanto/kanto_letsgo.png',
      mapSize: Size(1024, 768),
      gameVersion: "Let's Go Pikachu/Eevee",
    ),
    const RegionMapData(
      region: 'kanto',
      assetPath: 'assets/maps/regions/kanto/kanto_vector.svg',
      mapSize: Size(1000, 1000),
      gameVersion: 'Vector Map',
    ),
  ],
  'johto': [
    const RegionMapData(
      region: 'johto',
      assetPath: 'assets/maps/regions/johto/johto_gsc.png',
      mapSize: Size(1200, 900),
      gameVersion: 'Gold/Silver/Crystal',
    ),
    const RegionMapData(
      region: 'johto',
      assetPath: 'assets/maps/regions/johto/johto_hgss.png',
      mapSize: Size(1200, 900),
      gameVersion: 'HeartGold/SoulSilver',
    ),
    const RegionMapData(
      region: 'johto',
      assetPath: 'assets/maps/regions/johto/johto_vector.svg',
      mapSize: Size(1000, 1000),
      gameVersion: 'Vector Map',
    ),
  ],
  'hoenn': [
    const RegionMapData(
      region: 'hoenn',
      assetPath: 'assets/maps/regions/hoenn/hoenn_rse.png',
      mapSize: Size(1500, 1100),
      gameVersion: 'Ruby/Sapphire/Emerald',
    ),
    const RegionMapData(
      region: 'hoenn',
      assetPath: 'assets/maps/regions/hoenn/hoenn_oras.png',
      mapSize: Size(1500, 1100),
      gameVersion: 'Omega Ruby/Alpha Sapphire',
    ),
    const RegionMapData(
      region: 'hoenn',
      assetPath: 'assets/maps/regions/hoenn/hoenn_vector.svg',
      mapSize: Size(1000, 1000),
      gameVersion: 'Vector Map',
    ),
  ],
  'sinnoh': [
    const RegionMapData(
      region: 'sinnoh',
      assetPath: 'assets/maps/regions/sinnoh/sinnoh_dpp.png',
      mapSize: Size(1400, 1000),
      gameVersion: 'Diamond/Pearl/Platinum',
    ),
    const RegionMapData(
      region: 'sinnoh',
      assetPath: 'assets/maps/regions/sinnoh/sinnoh_bdsp.png',
      mapSize: Size(1400, 1000),
      gameVersion: 'Brilliant Diamond/Shining Pearl',
    ),
    const RegionMapData(
      region: 'sinnoh',
      assetPath: 'assets/maps/regions/sinnoh/sinnoh_vector.svg',
      mapSize: Size(1000, 1000),
      gameVersion: 'Vector Map',
    ),
  ],
  'unova': [
    const RegionMapData(
      region: 'unova',
      assetPath: 'assets/maps/regions/unova/unova_bw.png',
      mapSize: Size(1600, 1200),
      gameVersion: 'Black/White',
    ),
    const RegionMapData(
      region: 'unova',
      assetPath: 'assets/maps/regions/unova/unova_b2w2.png',
      mapSize: Size(1600, 1200),
      gameVersion: 'Black 2/White 2',
    ),
    const RegionMapData(
      region: 'unova',
      assetPath: 'assets/maps/regions/unova/unova_vector.svg',
      mapSize: Size(1000, 1000),
      gameVersion: 'Vector Map',
    ),
  ],
  'kalos': [
    const RegionMapData(
      region: 'kalos',
      assetPath: 'assets/maps/regions/kalos/kalos_xy.png',
      mapSize: Size(1800, 1400),
      gameVersion: 'X/Y',
    ),
    const RegionMapData(
      region: 'kalos',
      assetPath: 'assets/maps/regions/kalos/kalos_vector.svg',
      mapSize: Size(1000, 1000),
      gameVersion: 'Vector Map',
    ),
  ],
  'alola': [
    const RegionMapData(
      region: 'alola',
      assetPath: 'assets/maps/regions/alola/alola_sm.png',
      mapSize: Size(1600, 1200),
      gameVersion: 'Sun/Moon',
    ),
    const RegionMapData(
      region: 'alola',
      assetPath: 'assets/maps/regions/alola/alola_usum.png',
      mapSize: Size(1600, 1200),
      gameVersion: 'Ultra Sun/Ultra Moon',
    ),
    const RegionMapData(
      region: 'alola',
      assetPath: 'assets/maps/regions/alola/alola_vector.svg',
      mapSize: Size(1000, 1000),
      gameVersion: 'Vector Map',
    ),
  ],
  'galar': [
    const RegionMapData(
      region: 'galar',
      assetPath: 'assets/maps/regions/galar/galar_swsh.png',
      mapSize: Size(2000, 1500),
      gameVersion: 'Sword/Shield',
    ),
    const RegionMapData(
      region: 'galar',
      assetPath: 'assets/maps/regions/galar/galar_isle_of_armor.png',
      mapSize: Size(1500, 1200),
      gameVersion: 'The Isle of Armor',
    ),
    const RegionMapData(
      region: 'galar',
      assetPath: 'assets/maps/regions/galar/galar_crown_tundra.png',
      mapSize: Size(1500, 1200),
      gameVersion: 'The Crown Tundra',
    ),
    const RegionMapData(
      region: 'galar',
      assetPath: 'assets/maps/regions/galar/galar_vector.svg',
      mapSize: Size(1000, 1000),
      gameVersion: 'Vector Map',
    ),
  ],
  'paldea': [
    const RegionMapData(
      region: 'paldea',
      assetPath: 'assets/maps/regions/paldea/paldea_sv.png',
      mapSize: Size(2200, 1600),
      gameVersion: 'Scarlet/Violet',
    ),
    const RegionMapData(
      region: 'paldea',
      assetPath: 'assets/maps/regions/paldea/paldea_teal_mask.png',
      mapSize: Size(1800, 1400),
      gameVersion: 'The Teal Mask',
    ),
    const RegionMapData(
      region: 'paldea',
      assetPath: 'assets/maps/regions/paldea/paldea_indigo_disk.png',
      mapSize: Size(1800, 1400),
      gameVersion: 'The Indigo Disk',
    ),
    const RegionMapData(
      region: 'paldea',
      assetPath: 'assets/maps/regions/paldea/paldea_vector.svg',
      mapSize: Size(1000, 1000),
      gameVersion: 'Vector Map',
    ),
  ],
  'hisui': [
    const RegionMapData(
      region: 'hisui',
      assetPath: 'assets/maps/regions/hisui/hisui_legends.png',
      mapSize: Size(2000, 1500),
      gameVersion: 'Legends: Arceus',
    ),
    const RegionMapData(
      region: 'hisui',
      assetPath: 'assets/maps/regions/hisui/hisui_vector.svg',
      mapSize: Size(1000, 1000),
      gameVersion: 'Vector Map',
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
