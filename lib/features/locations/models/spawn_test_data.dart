import 'dart:convert';

/// Modelo para datos de prueba de spawn de Pokémon en mapas
class SpawnTestData {
  const SpawnTestData({
    required this.region,
    required this.mapSize,
    required this.spawns,
  });

  /// Región a la que pertenece este set de spawns
  final String region;

  /// Tamaño del mapa (dimensión en píxeles)
  final int mapSize;

  /// Lista de spawns de prueba
  final List<SpawnPoint> spawns;

  /// Crea un SpawnTestData desde JSON
  factory SpawnTestData.fromJson(Map<String, dynamic> json) {
    return SpawnTestData(
      region: json['region'] as String,
      mapSize: json['mapSize'] as int,
      spawns: (json['spawns'] as List<dynamic>)
          .map((spawn) => SpawnPoint.fromJson(spawn as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'mapSize': mapSize,
      'spawns': spawns.map((spawn) => spawn.toJson()).toList(),
    };
  }

  /// Parsea desde un string JSON
  static SpawnTestData fromJsonString(String jsonString) {
    return SpawnTestData.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }
}

/// Representa un punto de spawn individual
class SpawnPoint {
  const SpawnPoint({
    required this.pokemon,
    required this.x,
    required this.y,
    this.area,
  });

  /// Nombre del Pokémon
  final String pokemon;

  /// Coordenada X en el mapa
  final double x;

  /// Coordenada Y en el mapa
  final double y;

  /// Área opcional donde aparece
  final String? area;

  /// Crea un SpawnPoint desde JSON
  factory SpawnPoint.fromJson(Map<String, dynamic> json) {
    return SpawnPoint(
      pokemon: json['pokemon'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      area: json['area'] as String?,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'pokemon': pokemon,
      'x': x,
      'y': y,
      if (area != null) 'area': area,
    };
  }

  /// Nombre del Pokémon formateado
  String get displayName {
    if (pokemon.isEmpty) return '';
    if (pokemon.length == 1) return pokemon.toUpperCase();
    return pokemon[0].toUpperCase() + pokemon.substring(1);
  }
}
