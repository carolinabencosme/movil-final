import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Service for fetching Pokemon data from the REST API
class PokemonRestApi {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  /// Fetch Pokemon detail by ID from REST API
  static Future<Map<String, dynamic>?> fetchPokemonDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/pokemon/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final pokemonData = json.decode(response.body) as Map<String, dynamic>;
        
        // Fetch species data for additional information
        final speciesUrl = pokemonData['species']?['url'] as String?;
        
        // Create futures for concurrent fetching
        final futures = <Future<dynamic>>[];
        
        // Add species fetch future
        if (speciesUrl != null) {
          futures.add(http.get(Uri.parse(speciesUrl)));
        } else {
          futures.add(Future.value(null));
        }
        
        // Add ability details fetch future
        futures.add(_fetchAbilityDetails(pokemonData));
        
        // Wait for all concurrent requests
        final results = await Future.wait(futures);
        
        // Process species data
        Map<String, dynamic>? speciesData;
        final speciesResponse = results[0];
        if (speciesResponse is http.Response && speciesResponse.statusCode == 200) {
          speciesData = json.decode(speciesResponse.body) as Map<String, dynamic>;
        }
        
        // Get ability details
        final abilityDetails = results[1] as Map<String, Map<String, dynamic>>;
        
        // Fetch evolution chain if available
        Map<String, dynamic>? evolutionData;
        if (speciesData != null) {
          final evolutionUrl = speciesData['evolution_chain']?['url'] as String?;
          if (evolutionUrl != null) {
            final evolutionResponse = await http.get(Uri.parse(evolutionUrl));
            if (evolutionResponse.statusCode == 200) {
              evolutionData = json.decode(evolutionResponse.body) as Map<String, dynamic>;
            }
          }
        }
        
        // Combine all data
        return {
          'pokemon': pokemonData,
          'species': speciesData,
          'evolution': evolutionData,
          'abilities': abilityDetails,
        };
      } else {
        if (kDebugMode) {
          debugPrint('[REST API] Failed to fetch Pokemon $id: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[REST API] Error fetching Pokemon $id: $e');
      }
      return null;
    }
  }

  /// Fetch detailed ability information
  static Future<Map<String, Map<String, dynamic>>> _fetchAbilityDetails(
    Map<String, dynamic> pokemonData,
  ) async {
    final abilityDetails = <String, Map<String, dynamic>>{};
    final abilities = pokemonData['abilities'] as List<dynamic>?;
    
    if (abilities == null) return abilityDetails;
    
    for (final abilityEntry in abilities) {
      final ability = abilityEntry as Map<String, dynamic>?;
      final abilityInfo = ability?['ability'] as Map<String, dynamic>?;
      final abilityUrl = abilityInfo?['url'] as String?;
      final abilityName = abilityInfo?['name'] as String?;
      
      if (abilityUrl != null && abilityName != null) {
        try {
          final response = await http.get(Uri.parse(abilityUrl));
          if (response.statusCode == 200) {
            final detailData = json.decode(response.body) as Map<String, dynamic>;
            abilityDetails[abilityName] = detailData;
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[REST API] Error fetching ability $abilityName: $e');
          }
        }
      }
    }
    
    return abilityDetails;
  }

  /// Convert REST API data to GraphQL-like structure for compatibility
  static Map<String, dynamic>? convertToGraphQLStructure(
    Map<String, dynamic>? restData,
  ) {
    if (restData == null) return null;

    final pokemon = restData['pokemon'] as Map<String, dynamic>?;
    final species = restData['species'] as Map<String, dynamic>?;
    final evolution = restData['evolution'] as Map<String, dynamic>?;
    final abilityDetails = restData['abilities'] as Map<String, Map<String, dynamic>>? ?? {};

    if (pokemon == null) return null;

    // Extract sprites
    final sprites = pokemon['sprites'] as Map<String, dynamic>?;
    final spritesJson = sprites != null ? json.encode(sprites) : '{}';

    // Extract types
    final types = (pokemon['types'] as List<dynamic>?)
            ?.map((t) {
              final type = t as Map<String, dynamic>?;
              final slot = type?['slot'] as int?;
              final typeInfo = type?['type'] as Map<String, dynamic>?;
              final typeName = typeInfo?['name'] as String?;
              if (slot != null && typeName != null) {
                return {
                  'slot': slot,
                  'pokemon_v2_type': {
                    'id': 0,
                    'name': typeName,
                  },
                };
              }
              return null;
            })
            .whereType<Map<String, dynamic>>()
            .toList() ??
        [];

    // Extract stats
    final stats = (pokemon['stats'] as List<dynamic>?)
            ?.map((s) {
              final stat = s as Map<String, dynamic>?;
              final baseStat = stat?['base_stat'] as int?;
              final statInfo = stat?['stat'] as Map<String, dynamic>?;
              final statName = statInfo?['name'] as String?;
              if (baseStat != null && statName != null) {
                return {
                  'base_stat': baseStat,
                  'pokemon_v2_stat': {
                    'name': statName,
                  },
                };
              }
              return null;
            })
            .whereType<Map<String, dynamic>>()
            .toList() ??
        [];

    // Extract abilities with detailed information
    final abilities = (pokemon['abilities'] as List<dynamic>?)
            ?.map((a) {
              final ability = a as Map<String, dynamic>?;
              final isHidden = ability?['is_hidden'] as bool? ?? false;
              final slot = ability?['slot'] as int? ?? 0;
              final abilityInfo = ability?['ability'] as Map<String, dynamic>?;
              final abilityName = abilityInfo?['name'] as String?;
              
              if (abilityName != null) {
                // Get detailed ability information if available
                final detailData = abilityDetails[abilityName];
                String displayName = abilityName;
                String shortEffect = 'See ability details for more information.';
                String fullEffect = 'This ability provides special effects during battle.';
                
                if (detailData != null) {
                  // Extract English name
                  final names = detailData['names'] as List<dynamic>?;
                  if (names != null) {
                    for (final nameEntry in names) {
                      final entry = nameEntry as Map<String, dynamic>?;
                      final language = entry?['language'] as Map<String, dynamic>?;
                      if (language?['name'] == 'en') {
                        displayName = entry?['name'] as String? ?? abilityName;
                        break;
                      }
                    }
                  }
                  
                  // Extract English effect text
                  final effectEntries = detailData['effect_entries'] as List<dynamic>?;
                  if (effectEntries != null) {
                    for (final effectEntry in effectEntries) {
                      final entry = effectEntry as Map<String, dynamic>?;
                      final language = entry?['language'] as Map<String, dynamic>?;
                      if (language?['name'] == 'en') {
                        shortEffect = entry?['short_effect'] as String? ?? shortEffect;
                        fullEffect = entry?['effect'] as String? ?? fullEffect;
                        break;
                      }
                    }
                  }
                }
                
                return {
                  'is_hidden': isHidden,
                  'slot': slot,
                  'pokemon_v2_ability': {
                    'name': abilityName,
                    'pokemon_v2_abilitynames': [
                      {'name': displayName},
                    ],
                    'pokemon_v2_abilityeffecttexts': [
                      {
                        'short_effect': shortEffect,
                        'effect': fullEffect,
                      },
                    ],
                  },
                };
              }
              return null;
            })
            .whereType<Map<String, dynamic>>()
            .toList() ??
        [];

    // Extract moves
    final moves = (pokemon['moves'] as List<dynamic>?)
            ?.take(50) // Limit to first 50 moves to avoid overwhelming the UI
            .map((m) {
              final move = m as Map<String, dynamic>?;
              final moveInfo = move?['move'] as Map<String, dynamic>?;
              final moveName = moveInfo?['name'] as String?;
              
              final versionDetails = (move?['version_group_details'] as List<dynamic>?)?.isNotEmpty == true
                  ? (move?['version_group_details'] as List<dynamic>?)!.first as Map<String, dynamic>?
                  : null;
              final level = versionDetails?['level_learned_at'] as int?;
              final methodInfo = versionDetails?['move_learn_method'] as Map<String, dynamic>?;
              final method = methodInfo?['name'] as String? ?? 'unknown';
              final versionGroupInfo = versionDetails?['version_group'] as Map<String, dynamic>?;
              final versionGroup = versionGroupInfo?['name'] as String?;
              
              if (moveName != null) {
                return {
                  'level': level,
                  'pokemon_v2_movelearnmethod': {
                    'name': method,
                  },
                  'pokemon_v2_versiongroup': {
                    'id': 0,
                    'name': versionGroup ?? 'unknown',
                  },
                  'pokemon_v2_move': {
                    'id': 0,
                    'name': moveName,
                    'pokemon_v2_movenames': [
                      {'name': moveName},
                    ],
                    'pokemon_v2_type': {
                      'id': 0,
                      'name': 'normal',
                    },
                  },
                };
              }
              return null;
            })
            .whereType<Map<String, dynamic>>()
            .toList() ??
        [];

    // Extract species information
    final genus = _extractGenus(species);
    final captureRate = species?['capture_rate'] as int? ?? 0;
    final speciesId = species?['id'] as int?;

    // Build evolution chain
    final evolutionChainData = _buildEvolutionChain(evolution, speciesId);

    // Build the GraphQL-like structure
    return {
      'id': pokemon['id'] as int? ?? 0,
      'name': pokemon['name'] as String? ?? '',
      'height': pokemon['height'] as int? ?? 0,
      'weight': pokemon['weight'] as int? ?? 0,
      'base_experience': pokemon['base_experience'] as int? ?? 0,
      'pokemon_v2_pokemonsprites': [
        {'sprites': spritesJson},
      ],
      'pokemon_v2_pokemontypes': types,
      'pokemon_v2_pokemonstats': stats,
      'pokemon_v2_pokemonabilities': abilities,
      'pokemon_v2_pokemonmoves': moves,
      'species': {
        'id': speciesId,
        'name': species?['name'] as String? ?? '',
        'capture_rate': captureRate,
        'generation_id': 1,
        'pokemon_v2_pokemonspeciesnames': [
          {'genus': genus},
        ],
        'pokemon_v2_generation': {
          'id': 1,
          'name': 'generation-i',
        },
        'evolution_chain': evolutionChainData,
      },
    };
  }

  static String _extractGenus(Map<String, dynamic>? species) {
    if (species == null) return '';
    
    final genera = species['genera'] as List<dynamic>?;
    if (genera == null) return '';
    
    // Try to find English genus first
    for (final genusEntry in genera) {
      final entry = genusEntry as Map<String, dynamic>?;
      final language = entry?['language'] as Map<String, dynamic>?;
      final languageName = language?['name'] as String?;
      if (languageName == 'en') {
        return entry?['genus'] as String? ?? '';
      }
    }
    
    // Fallback to first genus
    if (genera.isNotEmpty) {
      final firstGenus = genera.first as Map<String, dynamic>?;
      return firstGenus?['genus'] as String? ?? '';
    }
    
    return '';
  }

  static Map<String, dynamic>? _buildEvolutionChain(
    Map<String, dynamic>? evolutionData,
    int? currentSpeciesId,
  ) {
    if (evolutionData == null) return null;

    final chain = evolutionData['chain'] as Map<String, dynamic>?;
    if (chain == null) return null;

    final speciesList = <Map<String, dynamic>>[];
    _extractEvolutionSpecies(chain, speciesList);

    return {
      'id': evolutionData['id'] as int? ?? 0,
      'species_list': speciesList,
    };
  }

  static void _extractEvolutionSpecies(
    Map<String, dynamic> chainNode,
    List<Map<String, dynamic>> speciesList,
  ) {
    final species = chainNode['species'] as Map<String, dynamic>?;
    if (species != null) {
      final speciesUrl = species['url'] as String?;
      final speciesId = _extractIdFromUrl(speciesUrl);
      final speciesName = species['name'] as String?;

      if (speciesId != null && speciesName != null) {
        speciesList.add({
          'id': speciesId,
          'name': speciesName,
          'order': speciesList.length,
          'evolves_from_species_id': null,
          'pokemon_v2_pokemonspeciesnames': [
            {'name': speciesName},
          ],
          'pokemon_v2_pokemonevolutions': [],
          'pokemon_v2_pokemons': [
            {
              'id': speciesId,
              'pokemon_v2_pokemonsprites': [
                {
                  'sprites': json.encode({
                    'other': {
                      'official-artwork': {
                        'front_default':
                            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$speciesId.png',
                      },
                    },
                  }),
                },
              ],
            },
          ],
        });
      }
    }

    final evolvesTo = chainNode['evolves_to'] as List<dynamic>?;
    if (evolvesTo != null) {
      for (final evolution in evolvesTo) {
        if (evolution is Map<String, dynamic>) {
          _extractEvolutionSpecies(evolution, speciesList);
        }
      }
    }
  }

  static int? _extractIdFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final parts = url.split('/');
    final idString = parts.reversed
        .firstWhere((part) => part.isNotEmpty && int.tryParse(part) != null, orElse: () => '');
    return int.tryParse(idString);
  }
}
