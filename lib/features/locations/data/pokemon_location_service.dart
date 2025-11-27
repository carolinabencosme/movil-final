import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart' as http;

import '../models/pokemon_location.dart';
import 'region_map_data.dart';
import 'region_map_markers.dart';

/// Servicio especializado para ubicar Pokémon en mapas y regiones.
///
/// Consulta PokéAPI para combinar información de encuentros, regiones
/// y sprites con las coordenadas de los mapas locales. Todas las
/// coordenadas se normalizan al rango 0-1 para facilitar el escalado a
/// píxeles cuando se renderizan en la UI.
class PokemonLocationService {
  PokemonLocationService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  final http.Client _client;

  final Map<String, Map<String, dynamic>> _locationAreaCache = {};
  final Map<int, EncounterPokemonInfo> _pokemonCache = {};

  /// Obtiene las ubicaciones de un Pokémon con coordenadas listas para pintar en el mapa.
  Future<List<PokemonLocationPoint>> fetchPokemonLocations(int pokemonId) async {
    final pokemon = await _fetchPokemonSummary(pokemonId);
    final encounters = await _fetchEncounters(pokemonId);

    final List<PokemonLocationPoint> points = [];

    for (final encounter in encounters) {
      final locationArea = encounter['location_area'] as Map<String, dynamic>?;
      final locationAreaName = locationArea?['name'] as String?;
      final locationAreaUrl = locationArea?['url'] as String?;
      if (locationAreaName == null || locationAreaUrl == null) {
        continue;
      }

      final versions = _extractVersions(encounter);
      final region = await _resolveRegion(locationAreaUrl);
      final coordinates = await _resolveCoordinates(
        region: region,
        locationAreaName: locationAreaName,
        version: versions.isNotEmpty ? versions.first : null,
      );

      points.add(
        PokemonLocationPoint(
          pokemonId: pokemon.id,
          pokemonName: pokemon.name,
          spriteUrl: pokemon.spriteUrl,
          locationArea: locationAreaName,
          region: region,
          versions: versions,
          coordinates: coordinates,
        ),
      );
    }

    return points;
  }

  Future<EncounterPokemonInfo> _fetchPokemonSummary(int pokemonId) async {
    if (_pokemonCache.containsKey(pokemonId)) {
      return _pokemonCache[pokemonId]!;
    }

    final response = await _client.get(Uri.parse('$_baseUrl/pokemon/$pokemonId'));
    if (response.statusCode != 200) {
      throw LocationServiceException('No se pudo obtener el Pokémon $pokemonId');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final sprites = data['sprites'] as Map<String, dynamic>? ?? {};
    final other = sprites['other'] as Map<String, dynamic>?;
    final official = other?['official-artwork'] as Map<String, dynamic>?;

    final spriteUrl = official?['front_default'] as String? ??
        sprites['front_default'] as String? ??
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png';

    final name = data['name'] as String? ?? 'unknown';
    final types = (data['types'] as List<dynamic>? ?? [])
        .map((entry) => (entry as Map<String, dynamic>)['type'] as Map<String, dynamic>?)
        .whereType<Map<String, dynamic>>()
        .map((type) => type['name'] as String? ?? '')
        .where((type) => type.isNotEmpty)
        .toList();

    final info = EncounterPokemonInfo(
      id: pokemonId,
      name: name,
      spriteUrl: spriteUrl,
      types: types,
    );

    _pokemonCache[pokemonId] = info;
    return info;
  }

  Future<List<dynamic>> _fetchEncounters(int pokemonId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/pokemon/$pokemonId/encounters'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }

    if (response.statusCode == 404) {
      return const [];
    }

    throw LocationServiceException(
      'Error al obtener encuentros: ${response.statusCode}',
    );
  }

  Future<String?> _resolveRegion(String locationAreaUrl) async {
    try {
      final areaData = await _fetchLocationArea(locationAreaUrl);
      final location = areaData['location'] as Map<String, dynamic>?;

      final region = (location?['region'] as Map<String, dynamic>?)?['name'] as String?;
      if (region != null) return region;

      final locationUrl = location?['url'] as String?;
      if (locationUrl != null) {
        final locationResponse = await _client.get(Uri.parse(locationUrl));
        if (locationResponse.statusCode == 200) {
          final Map<String, dynamic> locationData =
              json.decode(locationResponse.body) as Map<String, dynamic>;
          return (locationData['region'] as Map<String, dynamic>?)?['name'] as String?;
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<PokemonLocationCoordinates?> _resolveCoordinates({
    required String? region,
    required String locationAreaName,
    required String? version,
  }) async {
    if (region == null) return null;
    final normalizedRegion = region.toLowerCase().trim();
    final normalizedArea = _normalizeAreaName(locationAreaName);
    final normalizedVersion = _normalizeVersion(version);

    final marker = _findMarker(
      region: normalizedRegion,
      area: normalizedArea,
      version: normalizedVersion,
    );

    final regionMap = _resolveMapDataForVersion(normalizedRegion, normalizedVersion);
    final baseSize = _markerBaseSizes[normalizedRegion];

    if (marker == null || regionMap == null || baseSize == null) {
      return null;
    }

    final scaleX = regionMap.mapSize.width / baseSize.width;
    final scaleY = regionMap.mapSize.height / baseSize.height;

    final scaledX = marker.x * scaleX;
    final scaledY = marker.y * scaleY;

    final normalizedX = (scaledX / regionMap.mapSize.width).clamp(0.0, 1.0);
    final normalizedY = (scaledY / regionMap.mapSize.height).clamp(0.0, 1.0);

    return PokemonLocationCoordinates(
      normalizedX: normalizedX,
      normalizedY: normalizedY,
      rawX: scaledX,
      rawY: scaledY,
      mapSize: regionMap.mapSize,
    );
  }

  Map<String, dynamic> _normalizeAttributes(Map<String, dynamic> data) {
    return data.map((key, value) {
      return MapEntry<String, dynamic>(key.toLowerCase().trim(), value);
    });
  }

  Future<Map<String, dynamic>> _fetchLocationArea(String url) async {
    if (_locationAreaCache.containsKey(url)) {
      return _locationAreaCache[url]!;
    }

    final response = await _client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw LocationServiceException(
        'No se pudo obtener location_area desde ${response.statusCode}',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final normalizedData = _normalizeAttributes(data);
    _locationAreaCache[url] = normalizedData;
    return normalizedData;
  }

  RegionMapData? _resolveMapDataForVersion(String region, String? gameVersion) {
    final versions = getRegionMapVersions(region);
    if (versions.isEmpty) return getRegionMapData(region);

    if (gameVersion != null && gameVersion.isNotEmpty) {
      for (final data in versions) {
        final normalized = _normalizeVersion(data.gameVersion);
        if (normalized == gameVersion ||
            normalized.contains(gameVersion) ||
            gameVersion.contains(normalized)) {
          return data;
        }
      }
    }

    return versions.first;
  }

  RegionMarker? _findMarker({
    required String region,
    required String area,
    required String? version,
  }) {
    final areaMarkers = regionMarkersByRegion[region]?[area];
    if (areaMarkers == null) return null;

    final normalizedVersion = version ?? '';
    return areaMarkers[normalizedVersion] ?? areaMarkers['default'];
  }

  List<String> _extractVersions(Map<String, dynamic> encounter) {
    final versionDetails = encounter['version_details'] as List<dynamic>? ?? [];
    return versionDetails
        .map((detail) => (detail as Map<String, dynamic>)['version'] as Map<String, dynamic>?)
        .whereType<Map<String, dynamic>>()
        .map((version) => version['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  String _normalizeAreaName(String value) {
    final normalized = value.toLowerCase().trim();
    if (normalized.endsWith('-area')) {
      return normalized.replaceFirst(RegExp(r'-area\$'), '');
    }
    return normalized;
  }

  String _normalizeVersion(String? value) {
    return (value ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}

/// Dimensiones base usadas para escalar los marcadores al tamaño real del mapa
const Map<String, Size> _markerBaseSizes = {
  'kanto': Size(1024, 768),
  'johto': Size(1200, 900),
  'hoenn': Size(1500, 1100),
  'sinnoh': Size(1400, 1000),
  'unova': Size(1600, 1200),
  'kalos': Size(1800, 1400),
  'alola': Size(1600, 1200),
  'galar': Size(2000, 1500),
  'hisui': Size(2000, 1500),
  'paldea': Size(2200, 1600),
};
