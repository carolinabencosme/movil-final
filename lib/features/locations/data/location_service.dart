import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/pokemon_location.dart';
import 'region_coordinates.dart';

/// Servicio para obtener datos de ubicaciones desde PokéAPI
class LocationService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  /// Caché simple para regiones por URL de location_area
  final Map<String, String?> _locationAreaRegionCache = {};

  /// Obtiene los encuentros de un Pokémon por ID
  ///
  /// Retorna una lista de [PokemonEncounter] con información sobre
  /// dónde se puede encontrar el Pokémon en los diferentes juegos.
  Future<List<PokemonEncounter>> fetchPokemonEncounters(
    int pokemonId, {
    EncounterPokemonInfo? pokemon,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/pokemon/$pokemonId/encounters');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        
        final encounterFutures = data.map((json) async {
          final encounterJson = json as Map<String, dynamic>;

          final locationArea = encounterJson['location_area'] as Map<String, dynamic>?;
          final locationAreaUrl = locationArea?['url'] as String?;

          final region = await _getRegionForLocationArea(locationAreaUrl);
          final coordinates = region != null ? getRegionCoordinates(region) : null;

          return PokemonEncounter.fromJson(
            encounterJson,
            pokemon: pokemon,
            region: region,
            coordinates: coordinates,
          );
        }).toList();

        return Future.wait(encounterFutures);
      } else if (response.statusCode == 404) {
        // No se encontraron encuentros para este Pokémon
        return [];
      } else {
        throw LocationServiceException(
          'Error al obtener encuentros: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is LocationServiceException) rethrow;
      throw LocationServiceException('Error de red: $e');
    }
  }

  /// Agrupa encuentros por región y agrega coordenadas
  ///
  /// Toma una lista de encuentros y los organiza por región,
  /// agregando las coordenadas correspondientes cuando están disponibles.
  List<LocationsByRegion> groupEncountersByRegion(
    List<PokemonEncounter> encounters,
  ) {
    final Map<String, List<PokemonEncounter>> byRegion = {};

    // Agrupar encuentros por región
    for (final encounter in encounters) {
      final region = encounter.region;
      if (region != null) {
        byRegion.putIfAbsent(region, () => []).add(encounter);
      }
    }

    // Convertir a lista de LocationsByRegion con coordenadas
    return byRegion.entries.map((entry) {
      final coordinates = getRegionCoordinates(entry.key);

      return LocationsByRegion(
        region: entry.key,
        encounters: entry.value,
        coordinates: coordinates,
      );
    }).toList();
  }

  /// Obtiene encuentros agrupados por región para un Pokémon
  ///
  /// Método de conveniencia que combina fetchPokemonEncounters
  /// y groupEncountersByRegion en una sola llamada.
  Future<List<LocationsByRegion>> fetchLocationsByRegion(
    int pokemonId, {
    EncounterPokemonInfo? pokemon,
  }) async {
    final encounters = await fetchPokemonEncounters(pokemonId, pokemon: pokemon);
    return groupEncountersByRegion(encounters);
  }

  Future<String?> _getRegionForLocationArea(String? locationAreaUrl) async {
    if (locationAreaUrl == null || locationAreaUrl.isEmpty) return null;

    if (_locationAreaRegionCache.containsKey(locationAreaUrl)) {
      return _locationAreaRegionCache[locationAreaUrl];
    }

    try {
      final response = await http.get(Uri.parse(locationAreaUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final location = data['location'] as Map<String, dynamic>?;

        final region = (location?['region'] as Map<String, dynamic>?)?['name'] as String?;
        if (region != null) {
          _locationAreaRegionCache[locationAreaUrl] = region;
          return region;
        }

        final locationUrl = location?['url'] as String?;
        if (locationUrl != null) {
          final locationResponse = await http.get(Uri.parse(locationUrl));
          if (locationResponse.statusCode == 200) {
            final Map<String, dynamic> locationData =
                json.decode(locationResponse.body) as Map<String, dynamic>;
            final resolvedRegion =
                (locationData['region'] as Map<String, dynamic>?)?['name'] as String?;

            _locationAreaRegionCache[locationAreaUrl] = resolvedRegion;
            return resolvedRegion;
          }
        }
      }
    } catch (_) {}

    _locationAreaRegionCache[locationAreaUrl] = null;
    return null;
  }
}

/// Excepción personalizada para errores del servicio de ubicaciones
class LocationServiceException implements Exception {
  LocationServiceException(this.message);

  final String message;

  @override
  String toString() => 'LocationServiceException: $message';
}
