import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/pokemon_model.dart';
import '../queries/get_pokemon_details.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.pokemonId});

  final int pokemonId;

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
        title: const Text('Detalles del Pokémon'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(getPokemonDetailsQuery),
          variables: {'id': pokemonId},
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
                  'Ocurrió un error al cargar el detalle.\n${result.exception}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          final data =
              result.data?['pokemon_v2_pokemon_by_pk'] as Map<String, dynamic>?;

          if (data == null) {
            return const Center(
              child: Text('No se encontró información para este Pokémon.'),
            );
          }

          final pokemon = PokemonDetail.fromGraphQL(data);

          return RefreshIndicator(
            onRefresh: () async {
              await refetch?.call();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      _capitalize(pokemon.name),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: pokemon.imageUrl.isNotEmpty
                        ? Image.network(
                            pokemon.imageUrl,
                            height: 200,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.catching_pokemon_outlined,
                              size: 80,
                              color: Colors.redAccent,
                            ),
                          )
                        : const Icon(
                            Icons.catching_pokemon_outlined,
                            size: 80,
                            color: Colors.redAccent,
                          ),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Tipos'),
                  const SizedBox(height: 8),
                  if (pokemon.types.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: pokemon.types
                          .map((type) => Chip(label: Text(_capitalize(type))))
                          .toList(),
                    )
                  else
                    const Text('Sin información de tipos disponible.'),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Habilidades'),
                  const SizedBox(height: 8),
                  if (pokemon.abilities.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: pokemon.abilities
                          .map((ability) => Chip(
                                label: Text(_capitalize(ability)),
                              ))
                          .toList(),
                    )
                  else
                    const Text('Sin información de habilidades disponible.'),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Estadísticas'),
                  const SizedBox(height: 8),
                  if (pokemon.stats.isNotEmpty)
                    Column(
                      children: pokemon.stats
                          .map(
                            (stat) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _capitalize(stat.name.replaceAll('-', ' ')),
                                      style:
                                          Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    stat.baseStat.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    )
                  else
                    const Text('Sin información de estadísticas disponible.'),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Medidas'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.height,
                          label: 'Altura',
                          value: '${pokemon.height}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.monitor_weight_outlined,
                          label: 'Peso',
                          value: '${pokemon.weight}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
