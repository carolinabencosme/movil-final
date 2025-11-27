/// Clase simple para coordenadas X/Y en el mapa de región
class MapCoordinates {
  const MapCoordinates(this.x, this.y);

  final double x;
  final double y;
}

/// Coordenadas normalizadas y en píxeles para ubicar un Pokémon en el mapa
class PokemonLocationCoordinates {
  const PokemonLocationCoordinates({
    required this.normalizedX,
    required this.normalizedY,
    this.rawX,
    this.rawY,
    this.mapSize,
  });

  /// Coordenada X normalizada (0-1)
  final double normalizedX;

  /// Coordenada Y normalizada (0-1)
  final double normalizedY;

  /// Coordenadas originales en píxeles si están disponibles
  final double? rawX;
  final double? rawY;

  /// Tamaño del mapa usado para calcular las coordenadas
  final Size? mapSize;

  /// Convierte las coordenadas normalizadas a píxeles dentro de [mapBoundsPx].
  ///
  /// Siempre mantiene el punto dentro del rectángulo recibido.
  Offset toPixels(Rect mapBoundsPx) {
    final clampedX = normalizedX.clamp(0.0, 1.0);
    final clampedY = normalizedY.clamp(0.0, 1.0);

    return Offset(
      mapBoundsPx.left + mapBoundsPx.width * clampedX,
      mapBoundsPx.top + mapBoundsPx.height * clampedY,
    );
  }
}

/// Modelo para un encuentro de Pokémon en una ubicación específica
class PokemonEncounter {
  const PokemonEncounter({
    required this.locationArea,
    required this.versionDetails,
    this.region,
    this.coordinates,
    this.pokemonId = 0,
    this.pokemonName = 'unknown',
    this.spriteUrl = '',
    this.pokemonTypes = const [],
  });

  /// Nombre del área de ubicación (ej: "route-1-area", "viridian-forest-area")
  final String locationArea;

  /// Detalles de versión donde aparece este encuentro
  final List<EncounterVersionDetail> versionDetails;

  /// Región inferida del área (ej: "kanto", "johto")
  final String? region;

  /// Coordenadas X/Y en el mapa de región si están disponibles
  final MapCoordinates? coordinates;

  /// ID del Pokémon al que pertenece el encuentro
  final int pokemonId;

  /// Nombre del Pokémon
  final String pokemonName;

  /// Sprite del Pokémon (oficial o mini)
  final String spriteUrl;

  /// Tipos del Pokémon
  final List<String> pokemonTypes;

  /// Factory para crear desde JSON de PokéAPI
  factory PokemonEncounter.fromJson(
    Map<String, dynamic> json, {
    EncounterPokemonInfo? pokemon,
    String? region,
    MapCoordinates? coordinates,
  }) {
    final locationArea = json['location_area'] as Map<String, dynamic>?;
    final locationAreaName = locationArea?['name'] as String? ?? 'unknown';

    final versionDetailsJson = json['version_details'] as List<dynamic>? ?? [];
    final versionDetails = versionDetailsJson
        .map((detail) => EncounterVersionDetail.fromJson(detail as Map<String, dynamic>))
        .toList();

    return PokemonEncounter(
      locationArea: locationAreaName,
      versionDetails: versionDetails,
      region: region,
      coordinates: coordinates,
      pokemonId: pokemon?.id ?? 0,
      pokemonName: pokemon?.name ?? 'unknown',
      spriteUrl: pokemon?.spriteUrl ?? '',
      pokemonTypes: pokemon?.types ?? const [],
    );
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

  /// Resumen plano de métodos de encuentro para mostrar en UI.
  List<EncounterMethodSummary> get methodSummaries {
    final List<EncounterMethodSummary> summaries = [];

    for (final versionDetail in versionDetails) {
      for (final detail in versionDetail.encounterDetails) {
        summaries.add(
          EncounterMethodSummary(
            version: versionDetail.displayVersion,
            method: detail.displayMethod,
            chance: detail.chance,
            levelRange: detail.levelRange,
          ),
        );
      }
    }

    summaries.sort((a, b) => b.chance.compareTo(a.chance));
    return summaries;
  }

  /// Crea una copia con modificaciones de campos opcionales.
  PokemonEncounter copyWith({
    String? locationArea,
    List<EncounterVersionDetail>? versionDetails,
    String? region,
    MapCoordinates? coordinates,
    int? pokemonId,
    String? pokemonName,
    String? spriteUrl,
    List<String>? pokemonTypes,
  }) {
    return PokemonEncounter(
      locationArea: locationArea ?? this.locationArea,
      versionDetails: versionDetails ?? this.versionDetails,
      region: region ?? this.region,
      coordinates: coordinates ?? this.coordinates,
      pokemonId: pokemonId ?? this.pokemonId,
      pokemonName: pokemonName ?? this.pokemonName,
      spriteUrl: spriteUrl ?? this.spriteUrl,
      pokemonTypes: pokemonTypes ?? this.pokemonTypes,
    );
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

/// Información básica del Pokémon asociada al encuentro
class EncounterPokemonInfo {
  const EncounterPokemonInfo({
    required this.id,
    required this.name,
    required this.spriteUrl,
    this.types = const [],
  });

  final int id;
  final String name;
  final String spriteUrl;
  final List<String> types;
}

/// DTO especializado para representar ubicaciones de un Pokémon
class PokemonLocationPoint {
  const PokemonLocationPoint({
    required this.pokemonId,
    required this.pokemonName,
    required this.spriteUrl,
    required this.locationArea,
    required this.region,
    required this.versions,
    this.coordinates,
  });

  /// Identificador del Pokémon
  final int pokemonId;

  /// Nombre del Pokémon
  final String pokemonName;

  /// Sprite del Pokémon (arte oficial o sprite base)
  final String spriteUrl;

  /// Nombre del área de encuentro
  final String locationArea;

  /// Región inferida para la ubicación
  final String? region;

  /// Versiones de juego donde aparece el encuentro
  final List<String> versions;

  /// Coordenadas normalizadas y opcionalmente en píxeles
  final PokemonLocationCoordinates? coordinates;

  /// Versión legible de la región
  String get displayRegion {
    if (region == null || region!.isEmpty) return 'Unknown Region';
    return region![0].toUpperCase() + region!.substring(1);
  }

  /// Nombre legible del área
  String get displayArea {
    return locationArea
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Coordenadas del marcador en píxeles dentro del mapa renderizado
  MapCoordinates? toPixelCoordinates(Rect mapBoundsPx) {
    final pixelOffset = coordinates?.toPixels(mapBoundsPx);
    if (pixelOffset == null) return null;
    return MapCoordinates(pixelOffset.dx, pixelOffset.dy);
  }
}

/// Resumen plano de un método de encuentro
class EncounterMethodSummary {
  const EncounterMethodSummary({
    required this.version,
    required this.method,
    required this.chance,
    required this.levelRange,
  });

  final String version;
  final String method;
  final int chance;
  final String levelRange;
}

/// Datos agrupados de ubicaciones por región
class LocationsByRegion {
  const LocationsByRegion({
    required this.region,
    required this.encounters,
    this.coordinates,
  });

  /// Nombre de la región
  final String region;

  /// Lista de encuentros en esta región
  final List<PokemonEncounter> encounters;

  /// Coordenadas X/Y del centro de la región en el mapa
  final MapCoordinates? coordinates;

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
import 'dart:ui';

