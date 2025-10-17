import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/pokemon_model.dart';
import '../queries/get_pokemon_details.dart';
import '../widgets/pokemon_artwork.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.pokemonId,
    this.initialPokemon,
    this.heroTag,
  });

  final int pokemonId;
  final PokemonListItem? initialPokemon;
  final String? heroTag;

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedHeroTag = heroTag ?? 'pokemon-image-$pokemonId';
    final previewName =
        initialPokemon != null ? _capitalize(initialPokemon!.name) : null;
    final previewImage = initialPokemon?.imageUrl ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(previewName ?? 'Detalles del Pokémon'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(getPokemonDetailsQuery),
          variables: {'id': pokemonId},
        ),
        builder: (result, {fetchMore, refetch}) {
          if (result.isLoading && result.data == null) {
            return _LoadingDetailView(
              heroTag: resolvedHeroTag,
              imageUrl: previewImage,
              name: previewName,
            );
          }

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
            child: _PokemonDetailBody(
              pokemon: pokemon,
              resolvedHeroTag: resolvedHeroTag,
              capitalize: _capitalize,
            ),
          );
        },
      ),
    );
  }
}

class _PokemonDetailBody extends StatefulWidget {
  const _PokemonDetailBody({
    required this.pokemon,
    required this.resolvedHeroTag,
    required this.capitalize,
  });

  final PokemonDetail pokemon;
  final String resolvedHeroTag;
  final String Function(String) capitalize;

  @override
  State<_PokemonDetailBody> createState() => _PokemonDetailBodyState();
}

class _PokemonDetailBodyState extends State<_PokemonDetailBody> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pokemon = widget.pokemon;
    final mainAbility =
        pokemon.abilities.isNotEmpty ? widget.capitalize(pokemon.abilities.first) : null;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  widget.capitalize(pokemon.name),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Hero(
                  tag: widget.resolvedHeroTag,
                  child: PokemonArtwork(
                    imageUrl: pokemon.imageUrl,
                    size: 220,
                    borderRadius: 36,
                    padding: const EdgeInsets.all(24),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _InfoSectionCard(
            title: 'Tipos',
            child: pokemon.types.isNotEmpty
                ? Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: pokemon.types
                        .map(
                          (type) => Chip(
                            label: Text(widget.capitalize(type)),
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            labelStyle: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  )
                : const Text('Sin información de tipos disponible.'),
          ),
          const SizedBox(height: 16),
          _InfoSectionCard(
            title: 'Datos básicos',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 16),
                Card(
                  color: theme.colorScheme.surfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            mainAbility ?? 'Sin habilidad principal disponible.',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: _toggleExpanded,
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              label: Text(_isExpanded ? 'Ver menos detalles' : 'Ver más detalles'),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState:
                _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _InfoSectionCard(
                  title: 'Habilidades',
                  child: pokemon.abilities.isNotEmpty
                      ? Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: pokemon.abilities
                              .map(
                                (ability) => Chip(
                                  label: Text(widget.capitalize(ability)),
                                  backgroundColor:
                                      theme.colorScheme.tertiaryContainer,
                                  labelStyle: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              )
                              .toList(),
                        )
                      : const Text('Sin información de habilidades disponible.'),
                ),
                const SizedBox(height: 16),
                _InfoSectionCard(
                  title: 'Estadísticas',
                  child: pokemon.stats.isNotEmpty
                      ? Column(
                          children: pokemon.stats
                              .map(
                                (stat) => _StatBar(
                                  label: widget.capitalize(
                                    stat.name.replaceAll('-', ' '),
                                  ),
                                  value: stat.baseStat,
                                ),
                              )
                              .toList(),
                        )
                      : const Text('Sin información de estadísticas disponible.'),
                ),
              ],
            ),
          ),
        ],
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

class _InfoSectionCard extends StatelessWidget {
  const _InfoSectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: title),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double normalized = (value / 200).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Text(
                value.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: normalized,
              minHeight: 8,
              color: theme.colorScheme.primary,
              backgroundColor:
                  theme.colorScheme.primary.withOpacity(0.18),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDetailView extends StatelessWidget {
  const _LoadingDetailView({
    required this.heroTag,
    required this.imageUrl,
    this.name,
  });

  final String heroTag;
  final String imageUrl;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: heroTag,
              child: PokemonArtwork(
                imageUrl: imageUrl,
                size: 180,
                borderRadius: 32,
                padding: const EdgeInsets.all(20),
              ),
            ),
            if (name != null) ...[
              const SizedBox(height: 16),
              Text(
                name!,
                style: theme.textTheme.titleLarge,
              ),
            ],
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: colorScheme.onPrimaryContainer),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.85),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
