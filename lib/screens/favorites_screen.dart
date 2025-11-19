import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../controllers/favorites_controller.dart';
import '../models/pokemon_model.dart';
import '../queries/get_pokemon_list.dart';
import '../widgets/pokemon_artwork.dart';
import 'detail_screen.dart';

/// Pantalla que muestra solo los Pokémon favoritos del usuario actual.
/// 
/// Esta pantalla consulta la lista completa de favoritos del usuario
/// y muestra sus detalles usando GraphQL.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    this.heroTag,
    this.accentColor,
  });

  final String? heroTag;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final favoritesController = FavoritesScope.maybeOf(context);
    
    if (favoritesController == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Favoritos'),
          backgroundColor: accentColor,
        ),
        body: const Center(
          child: Text('No se pudo cargar los favoritos'),
        ),
      );
    }

    return AnimatedBuilder(
      animation: favoritesController,
      builder: (context, _) {
        final favoriteIds = favoritesController.favoriteIds.toList()..sort();

        if (favoriteIds.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Favoritos'),
              backgroundColor: accentColor,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No tienes Pokémon favoritos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Marca tus Pokémon favoritos usando el ícono de corazón en la Pokédex',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Favoritos (${favoriteIds.length})'),
            backgroundColor: accentColor,
          ),
          body: Query(
            options: QueryOptions(
              document: gql('''
                query GetFavoritePokemons(\$ids: [Int!]!) {
                  pokemon_v2_pokemon(where: {id: {_in: \$ids}}, order_by: {id: asc}) {
                    id
                    name
                    height
                    weight
                    pokemon_v2_pokemontypes {
                      pokemon_v2_type {
                        name
                      }
                    }
                    pokemon_v2_pokemonstats {
                      base_stat
                      pokemon_v2_stat {
                        name
                      }
                    }
                  }
                }
              '''),
              variables: {'ids': favoriteIds},
              fetchPolicy: FetchPolicy.cacheAndNetwork,
            ),
            builder: (result, {fetchMore, refetch}) {
              if (result.isLoading && result.data == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (result.hasException && result.data == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Error al cargar favoritos'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => refetch?.call(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              final pokemonList = result.data?['pokemon_v2_pokemon'] as List<dynamic>?;
              if (pokemonList == null || pokemonList.isEmpty) {
                return const Center(
                  child: Text('No se pudieron cargar los Pokémon favoritos'),
                );
              }

              final pokemons = pokemonList
                  .map((data) => PokemonListItem.fromGraphQL(data as Map<String, dynamic>))
                  .toList();

              return RefreshIndicator(
                onRefresh: () async {
                  await refetch?.call();
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: pokemons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final pokemon = pokemons[index];
                    return _FavoritePokemonTile(
                      key: ValueKey('favorite-${pokemon.id}'),
                      pokemon: pokemon,
                      onRemoveFavorite: () {
                        favoritesController.toggleFavorite(pokemon.id);
                      },
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _FavoritePokemonTile extends StatelessWidget {
  const _FavoritePokemonTile({
    super.key,
    required this.pokemon,
    required this.onRemoveFavorite,
  });

  final PokemonListItem pokemon;
  final VoidCallback onRemoveFavorite;

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heroTag = 'pokemon-artwork-${pokemon.id}';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(
                pokemonId: pokemon.id,
                pokemonName: pokemon.name,
                initialPokemon: pokemon,
                heroTag: heroTag,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              PokemonArtwork(
                heroTag: heroTag,
                imageUrl: pokemon.imageUrl,
                size: 70,
                borderRadius: 16,
                padding: const EdgeInsets.all(8),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${pokemon.id.toString().padLeft(3, '0')}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _capitalize(pokemon.name),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (pokemon.types.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: pokemon.types
                            .map((type) => Chip(
                                  label: Text(
                                    type.toUpperCase(),
                                    style: theme.textTheme.labelSmall,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite),
                color: Colors.red,
                tooltip: 'Quitar de favoritos',
                onPressed: onRemoveFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
