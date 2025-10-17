import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/pokemon_model.dart';
import '../queries/get_pokemon_list.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PokemonListItem> _originalPokemons = [];
  List<PokemonListItem> _filteredPokemons = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  void _applyFilters() {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      _filteredPokemons = List<PokemonListItem>.from(_originalPokemons);
      return;
    }

    _filteredPokemons = _originalPokemons.where((pokemon) {
      final name = pokemon.name.toLowerCase();
      final id = pokemon.id.toString();
      return name.contains(query) || id.contains(query);
    }).toList();
  }

  void _updatePokemons(List<PokemonListItem> pokemons) {
    if (listEquals(_originalPokemons, pokemons)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _originalPokemons = List<PokemonListItem>.from(pokemons);
        _applyFilters();
      });
    });
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

          _updatePokemons(pokemons);

          if (pokemons.isEmpty) {
            return const Center(
              child: Text('No se encontraron Pokémon.'),
            );
          }

          final displayPokemons =
              _filteredPokemons.isEmpty && _searchQuery.isEmpty
                  ? pokemons
                  : _filteredPokemons;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por nombre o ID',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _searchQuery.isEmpty ? Icons.refresh : Icons.clear,
                      ),
                      onPressed: () {
                        if (_searchQuery.isEmpty) {
                          refetch?.call();
                        } else {
                          _searchController.clear();
                        }
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await refetch?.call();
                  },
                  child: displayPokemons.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 120),
                          children: const [
                            Center(
                              child: Text('No hay coincidencias con la búsqueda.'),
                            ),
                          ],
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: displayPokemons.length,
                          itemBuilder: (context, index) {
                            final pokemon = displayPokemons[index];
                            return _PokemonCard(
                              pokemon: pokemon,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailScreen(pokemonId: pokemon.id),
                                  ),
                                );
                              },
                              capitalize: _capitalize,
                            );
                          },
                        ),
                ),
              ),
            ],
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
