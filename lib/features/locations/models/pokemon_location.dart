/// Clase simple para coordenadas X/Y en el mapa de región
class MapCoordinates {
  const MapCoordinates(this.x, this.y);

  final double x;
  final double y;
}

/// Modelo para un encuentro de Pokémon en una ubicación específica
class PokemonEncounter {
  const PokemonEncounter({
    required this.locationArea,
    required this.versionDetails,
    this.region,
    this.coordinates,
  });

  /// Nombre del área de ubicación (ej: "route-1-area", "viridian-forest-area")
  final String locationArea;

  /// Detalles de versión donde aparece este encuentro
  final List<EncounterVersionDetail> versionDetails;

  /// Región inferida del área (ej: "kanto", "johto")
  final String? region;

  /// Coordenadas X/Y en el mapa de región si están disponibles
  final MapCoordinates? coordinates;

  /// Factory para crear desde JSON de PokéAPI
  factory PokemonEncounter.fromJson(Map<String, dynamic> json) {
    final locationArea = json['location_area'] as Map<String, dynamic>?;
    final locationAreaName = locationArea?['name'] as String? ?? 'unknown';

    final versionDetailsJson = json['version_details'] as List<dynamic>? ?? [];
    final versionDetails = versionDetailsJson
        .map((detail) => EncounterVersionDetail.fromJson(detail as Map<String, dynamic>))
        .toList();

    // Intentar inferir la región del nombre del área
    final region = _inferRegionFromLocationArea(locationAreaName);

    return PokemonEncounter(
      locationArea: locationAreaName,
      versionDetails: versionDetails,
      region: region,
    );
  }

  /// Infiere la región desde el nombre del área
  static String? _inferRegionFromLocationArea(String locationArea) {
    // Mapeo simple basado en rutas y ubicaciones conocidas
    if (locationArea.contains('route-') || locationArea.contains('viridian') ||
        locationArea.contains('pewter') || locationArea.contains('cerulean')) {
      final routeNum = _extractRouteNumber(locationArea);
      if (routeNum != null) {
        if (routeNum <= 28) return 'kanto';
        if (routeNum <= 48) return 'johto';
        if (routeNum <= 134) return 'hoenn';
        if (routeNum <= 230) return 'sinnoh';
      }
    }
    return null;
  }

  static int? _extractRouteNumber(String locationArea) {
    final match = RegExp(r'route-(\d+)').firstMatch(locationArea);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '');
    }
    return null;
  }

  /// Obtiene el nombre legible del área
  String get displayName {
    return locationArea
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Obtiene todas las versiones únicas donde aparece
  List<String> get allVersions {
    return versionDetails
        .map((detail) => detail.version)
        .toSet()
        .toList();
  }
}

/// Detalles de encuentro para una versión específica
class EncounterVersionDetail {
  const EncounterVersionDetail({
    required this.version,
    required this.maxChance,
    required this.encounterDetails,
  });

  /// Nombre de la versión del juego (ej: "red", "blue", "gold")
  final String version;

  /// Probabilidad máxima de encuentro
  final int maxChance;

  /// Detalles específicos del encuentro
  final List<EncounterDetail> encounterDetails;

  factory EncounterVersionDetail.fromJson(Map<String, dynamic> json) {
    final versionData = json['version'] as Map<String, dynamic>?;
    final version = versionData?['name'] as String? ?? 'unknown';
    final maxChance = json['max_chance'] as int? ?? 0;

    final encounterDetailsJson = json['encounter_details'] as List<dynamic>? ?? [];
    final encounterDetails = encounterDetailsJson
        .map((detail) => EncounterDetail.fromJson(detail as Map<String, dynamic>))
        .toList();

    return EncounterVersionDetail(
      version: version,
      maxChance: maxChance,
      encounterDetails: encounterDetails,
    );
  }

  /// Obtiene el nombre legible de la versión
  String get displayVersion {
    return version
        .split('-')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

/// Detalle específico de un encuentro
class EncounterDetail {
  const EncounterDetail({
    required this.chance,
    required this.method,
    this.minLevel,
    this.maxLevel,
  });

  /// Probabilidad de encuentro (0-100)
  final int chance;

  /// Método de encuentro (ej: "walk", "surf", "old-rod")
  final String method;

  /// Nivel mínimo del encuentro
  final int? minLevel;

  /// Nivel máximo del encuentro
  final int? maxLevel;

  factory EncounterDetail.fromJson(Map<String, dynamic> json) {
    final chance = json['chance'] as int? ?? 0;
    final methodData = json['method'] as Map<String, dynamic>?;
    final method = methodData?['name'] as String? ?? 'unknown';
    final minLevel = json['min_level'] as int?;
    final maxLevel = json['max_level'] as int?;

    return EncounterDetail(
      chance: chance,
      method: method,
      minLevel: minLevel,
      maxLevel: maxLevel,
    );
  }

  /// Obtiene el nombre legible del método
  String get displayMethod {
    return method
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Obtiene el rango de niveles como string
  String get levelRange {
    if (minLevel == null && maxLevel == null) return 'Unknown level';
    if (minLevel == maxLevel) return 'Lv. $minLevel';
    return 'Lv. ${minLevel ?? '?'}-${maxLevel ?? '?'}';
  }
}

/// Datos agrupados de ubicaciones por región
class LocationsByRegion {
  const LocationsByRegion({
    required this.region,
    required this.encounters,
    required this.coordinates,
  });

  /// Nombre de la región
  final String region;

  /// Lista de encuentros en esta región
  final List<PokemonEncounter> encounters;

  /// Coordenadas X/Y del centro de la región en el mapa
  final MapCoordinates coordinates;

  /// Obtiene todas las versiones únicas en esta región
  List<String> get allVersions {
    return encounters
        .expand((encounter) => encounter.allVersions)
        .toSet()
        .toList();
  }

  /// Cuenta total de áreas en esta región
  int get areaCount => encounters.length;
}
