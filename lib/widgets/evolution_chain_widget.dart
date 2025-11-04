import 'package:flutter/material.dart';
import '../models/evolution_chain_model.dart';
import 'pokemon_artwork.dart';

class EvolutionChainWidget extends StatelessWidget {
  const EvolutionChainWidget({
    super.key,
    required this.evolutionChain,
    required this.onPokemonTap,
  });

  final EvolutionChain evolutionChain;
  final void Function(int pokemonId) onPokemonTap;

  @override
  Widget build(BuildContext context) {
    if (evolutionChain.species.isEmpty) {
      return const Text('No hay información de evoluciones disponible.');
    }

    if (evolutionChain.species.length == 1) {
      return const Text('Este Pokémon no tiene evoluciones.');
    }

    if (evolutionChain.isBranched) {
      return _BranchedEvolutionWidget(
        evolutionChain: evolutionChain,
        onPokemonTap: onPokemonTap,
      );
    } else {
      return _LinearEvolutionWidget(
        evolutionChain: evolutionChain,
        onPokemonTap: onPokemonTap,
      );
    }
  }
}

class _LinearEvolutionWidget extends StatelessWidget {
  const _LinearEvolutionWidget({
    required this.evolutionChain,
    required this.onPokemonTap,
  });

  final EvolutionChain evolutionChain;
  final void Function(int pokemonId) onPokemonTap;

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  List<EvolutionSpecies> _buildLinearChain() {
    final chain = <EvolutionSpecies>[];
    final root = evolutionChain.root;
    if (root == null) return chain;

    chain.add(root);
    EvolutionSpecies? current = root;

    while (current != null) {
      final nextList = evolutionChain.getEvolutionsFrom(current.id);
      if (nextList.isEmpty) break;
      current = nextList.first;
      chain.add(current);
    }

    return chain;
  }

  @override
  Widget build(BuildContext context) {
    final chain = _buildLinearChain();
    if (chain.isEmpty) {
      return const Text('No se pudo construir la cadena de evolución.');
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < chain.length; i++) ...[
            _EvolutionCard(
              species: chain[i],
              onTap: () => onPokemonTap(chain[i].pokemonId),
              capitalize: _capitalize,
            ),
            if (i < chain.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _BranchedEvolutionWidget extends StatelessWidget {
  const _BranchedEvolutionWidget({
    required this.evolutionChain,
    required this.onPokemonTap,
  });

  final EvolutionChain evolutionChain;
  final void Function(int pokemonId) onPokemonTap;

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final root = evolutionChain.root;
    if (root == null) {
      return const Text('No se pudo encontrar el Pokémon raíz.');
    }

    final firstEvolutions = evolutionChain.getEvolutionsFrom(root.id);
    
    // If there are no branches at the first level, check the second level
    if (firstEvolutions.length <= 1 && firstEvolutions.isNotEmpty) {
      final secondEvolutions = evolutionChain.getEvolutionsFrom(firstEvolutions.first.id);
      if (secondEvolutions.length > 1) {
        // Branch at second level
        return _buildTwoLevelBranched(context, root, firstEvolutions.first, secondEvolutions);
      }
    }

    // Branch at first level (like Eevee)
    return _buildFirstLevelBranched(context, root, firstEvolutions);
  }

  Widget _buildFirstLevelBranched(
    BuildContext context,
    EvolutionSpecies root,
    List<EvolutionSpecies> evolutions,
  ) {
    return Column(
      children: [
        // Root Pokemon in the center
        _EvolutionCard(
          species: root,
          onTap: () => onPokemonTap(root.pokemonId),
          capitalize: _capitalize,
        ),
        const SizedBox(height: 20),
        Icon(
          Icons.keyboard_arrow_down,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
        const SizedBox(height: 20),
        // Evolutions in a grid below
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: evolutions.map((species) {
            return _EvolutionCard(
              species: species,
              onTap: () => onPokemonTap(species.pokemonId),
              capitalize: _capitalize,
              compact: true,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTwoLevelBranched(
    BuildContext context,
    EvolutionSpecies root,
    EvolutionSpecies middle,
    List<EvolutionSpecies> finalEvolutions,
  ) {
    return Column(
      children: [
        // Root Pokemon
        _EvolutionCard(
          species: root,
          onTap: () => onPokemonTap(root.pokemonId),
          capitalize: _capitalize,
        ),
        const SizedBox(height: 12),
        Icon(
          Icons.arrow_downward,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 12),
        // Middle evolution
        _EvolutionCard(
          species: middle,
          onTap: () => onPokemonTap(middle.pokemonId),
          capitalize: _capitalize,
        ),
        const SizedBox(height: 20),
        Icon(
          Icons.keyboard_arrow_down,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
        const SizedBox(height: 20),
        // Final evolutions in a grid
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: finalEvolutions.map((species) {
            return _EvolutionCard(
              species: species,
              onTap: () => onPokemonTap(species.pokemonId),
              capitalize: _capitalize,
              compact: true,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _EvolutionCard extends StatelessWidget {
  const _EvolutionCard({
    required this.species,
    required this.onTap,
    required this.capitalize,
    this.compact = false,
  });

  final EvolutionSpecies species;
  final VoidCallback onTap;
  final String Function(String) capitalize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = compact ? 100.0 : 120.0;
    final imageSize = compact ? 80.0 : 100.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: size,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PokemonArtwork(
              imageUrl: species.imageUrl,
              size: imageSize,
              borderRadius: 16,
              padding: const EdgeInsets.all(8),
            ),
            const SizedBox(height: 4),
            Text(
              capitalize(species.name),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (species.minLevel != null && !compact) ...[
              const SizedBox(height: 2),
              Text(
                'Nv. ${species.minLevel}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
