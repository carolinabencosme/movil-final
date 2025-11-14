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
}

/// Mapas de regiones Pokémon oficiales extraídos de los juegos
///
/// Usa sprites rippeados de Spriter's Resource en formato PNG/JPG.
/// Los tamaños son aproximados y deben ajustarse según las imágenes reales.
final Map<String, RegionMapData> regionMaps = {
  'kanto': const RegionMapData(
    region: 'kanto',
    assetPath: 'assets/maps/regions/kanto_frlg.png',
    mapSize: Size(1024, 768),
    gameVersion: 'FireRed/LeafGreen',
  ),
  'johto': const RegionMapData(
    region: 'johto',
    assetPath: 'assets/maps/regions/johto_hgss.png',
    mapSize: Size(1200, 900),
    gameVersion: 'HeartGold/SoulSilver',
  ),
  'hoenn': const RegionMapData(
    region: 'hoenn',
    assetPath: 'assets/maps/regions/hoenn_emerald.png',
    mapSize: Size(1500, 1100),
    gameVersion: 'Emerald',
  ),
  'sinnoh': const RegionMapData(
    region: 'sinnoh',
    assetPath: 'assets/maps/regions/sinnoh_platinum.png',
    mapSize: Size(1400, 1000),
    gameVersion: 'Platinum',
  ),
  'unova': const RegionMapData(
    region: 'unova',
    assetPath: 'assets/maps/regions/unova_bw.png',
    mapSize: Size(1600, 1200),
    gameVersion: 'Black/White',
  ),
  'kalos': const RegionMapData(
    region: 'kalos',
    assetPath: 'assets/maps/regions/kalos_xy.png',
    mapSize: Size(1800, 1400),
    gameVersion: 'X/Y',
  ),
  'alola': const RegionMapData(
    region: 'alola',
    assetPath: 'assets/maps/regions/alola_sm.png',
    mapSize: Size(1600, 1200),
    gameVersion: 'Sun/Moon',
  ),
  'galar': const RegionMapData(
    region: 'galar',
    assetPath: 'assets/maps/regions/galar_swsh.png',
    mapSize: Size(2000, 1500),
    gameVersion: 'Sword/Shield',
  ),
  'paldea': const RegionMapData(
    region: 'paldea',
    assetPath: 'assets/maps/regions/paldea_sv.png',
    mapSize: Size(2200, 1600),
    gameVersion: 'Scarlet/Violet',
  ),
};

/// Obtiene los datos del mapa de una región
///
/// Retorna null si la región no está mapeada.
RegionMapData? getRegionMapData(String regionName) {
  final normalized = regionName.toLowerCase().trim();
  return regionMaps[normalized];
}

/// Verifica si una región tiene datos de mapa disponibles
bool hasRegionMapData(String regionName) {
  return getRegionMapData(regionName) != null;
}

/// Obtiene todas las regiones con datos de mapa disponibles
List<String> getAvailableRegionMaps() {
  return regionMaps.keys.toList();
}
