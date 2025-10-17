import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/pokemon_model.dart';
import '../queries/get_pokemon_details.dart';

class PokemonScreen extends StatelessWidget {
  PokemonScreen({super.key, this.pokemonName = 'ditto'});

  final String pokemonName;

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1);
  }

  String _formatTypes(List<String> types) {
    if (types.isEmpty) {
      return 'Desconocido';
    }

    return types
        .map((type) => type.isEmpty ? type : _capitalize(type))
        .join(', ');
  }

  Pokemon? _mapToPokemon(Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }

    var spriteUrl = '';
    final spriteEntries = data['pokemon_v2_pokemonsprites'] as List<dynamic>?;
    if (spriteEntries != null && spriteEntries.isNotEmpty) {
      final rawSprites = spriteEntries.first['sprites'];
      if (rawSprites is String && rawSprites.isNotEmpty) {
        try {
          final spritesMap = json.decode(rawSprites) as Map<String, dynamic>;
          spriteUrl = (spritesMap['front_default'] as String?) ?? '';
        } catch (_) {
          spriteUrl = '';
        }
      }
    }

    final types = (data['pokemon_v2_pokemontypes'] as List<dynamic>? ?? [])
        .map((typeEntry) {
          final type = typeEntry['pokemon_v2_type'] as Map<String, dynamic>?;
          final name = type?['name'];
          return name is String ? name : null;
        })
        .whereType<String>()
        .toList();

    return Pokemon(
      name: data['name'] as String? ?? '',
      height: data['height'] as int? ?? 0,
      weight: data['weight'] as int? ?? 0,
      types: types,
      spriteUrl: spriteUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon (GraphQL)'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(getPokemonDetailsQuery),
          variables: {'name': pokemonName},
        ),
        builder: (result, {fetchMore, refetch}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Ocurrió un error al cargar el Pokémon.\n${result.exception}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          final results =
              result.data?['pokemon_v2_pokemon'] as List<dynamic>? ?? const [];

          if (results.isEmpty) {
            return const Center(
              child: Text('No se encontró información del Pokémon.'),
            );
          }

          final pokemon =
              _mapToPokemon(results.first as Map<String, dynamic>?) ??
                  Pokemon(
                    name: '',
                    height: 0,
                    weight: 0,
                    types: const [],
                    spriteUrl: '',
                  );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    '🧬 Nombre: ${_capitalize(pokemon.name)}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 16),
                if (pokemon.spriteUrl.isNotEmpty)
                  Center(
                    child: Image.network(
                      pokemon.spriteUrl,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                if (pokemon.spriteUrl.isNotEmpty) const SizedBox(height: 24),
                Text(
                  '📏 Altura: ${pokemon.height}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '⚖️ Peso: ${pokemon.weight}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '🌈 Tipo: ${_formatTypes(pokemon.types)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
