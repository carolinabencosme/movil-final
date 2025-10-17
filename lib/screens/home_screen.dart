import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/pokemon_model.dart';
import '../queries/get_pokemon_list.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex GraphQL'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(getPokemonListQuery),
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
                  'Ocurrió un error al cargar los Pokémon.\n${result.exception}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          final rawPokemons =
              result.data?['pokemon_v2_pokemon'] as List<dynamic>? ?? [];
          final pokemons = rawPokemons
              .map((dynamic entry) =>
                  PokemonListItem.fromGraphQL(entry as Map<String, dynamic>))
              .toList();

          if (pokemons.isEmpty) {
            return const Center(
              child: Text('No se encontraron Pokémon.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await refetch?.call();
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: pokemons.length,
              itemBuilder: (context, index) {
                final pokemon = pokemons[index];
                return _PokemonCard(
                  pokemon: pokemon,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(pokemonId: pokemon.id),
                      ),
                    );
                  },
                  capitalize: _capitalize,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PokemonCard extends StatelessWidget {
  const _PokemonCard({
    required this.pokemon,
    required this.onTap,
    required this.capitalize,
  });

  final PokemonListItem pokemon;
  final VoidCallback onTap;
  final String Function(String value) capitalize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: pokemon.imageUrl.isNotEmpty
                    ? Image.network(
                        pokemon.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.catching_pokemon_outlined,
                          size: 48,
                          color: Colors.redAccent,
                        ),
                      )
                    : const Icon(
                        Icons.catching_pokemon_outlined,
                        size: 48,
                        color: Colors.redAccent,
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                '#${pokemon.id.toString().padLeft(3, '0')}',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                capitalize(pokemon.name),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
