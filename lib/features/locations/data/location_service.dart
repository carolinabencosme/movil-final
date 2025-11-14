import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/pokemon_location.dart';
import 'region_coordinates.dart';

/// Servicio para obtener datos de ubicaciones desde PokéAPI
class LocationService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  /// Obtiene los encuentros de un Pokémon por ID
  ///
  /// Retorna una lista de [PokemonEncounter] con información sobre
  /// dónde se puede encontrar el Pokémon en los diferentes juegos.
  Future<List<PokemonEncounter>> fetchPokemonEncounters(int pokemonId) async {
    try {
      final url = Uri.parse('$_baseUrl/pokemon/$pokemonId/encounters');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        
        return data
            .map((json) => PokemonEncounter.fromJson(json as Map<String, dynamic>))
            .toList();
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
      if (region != null && hasRegionCoordinates(region)) {
        byRegion.putIfAbsent(region, () => []).add(encounter);
      }
    }

    // Convertir a lista de LocationsByRegion con coordenadas
    final List<LocationsByRegion> result = [];
    for (final entry in byRegion.entries) {
      final coordinates = getRegionCoordinates(entry.key);
      if (coordinates != null) {
        result.add(
          LocationsByRegion(
            region: entry.key,
            encounters: entry.value,
            coordinates: coordinates,
          ),
        );
      }
    }

    return result;
  }

  /// Obtiene encuentros agrupados por región para un Pokémon
  ///
  /// Método de conveniencia que combina fetchPokemonEncounters
  /// y groupEncountersByRegion en una sola llamada.
  Future<List<LocationsByRegion>> fetchLocationsByRegion(int pokemonId) async {
    final encounters = await fetchPokemonEncounters(pokemonId);
    return groupEncountersByRegion(encounters);
  }
}

/// Excepción personalizada para errores del servicio de ubicaciones
class LocationServiceException implements Exception {
  LocationServiceException(this.message);

  final String message;

  @override
  String toString() => 'LocationServiceException: $message';
}
