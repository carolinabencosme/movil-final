import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/pokemon_model.dart';
import '../queries/get_pokemon_details.dart';
import '../widgets/pokemon_artwork.dart';

const Map<String, Color> _pokemonTypeColors = {
  'normal': Color(0xFFA8A77A),
  'fire': Color(0xFFEE8130),
  'water': Color(0xFF6390F0),
  'electric': Color(0xFFF7D02C),
  'grass': Color(0xFF7AC74C),
  'ice': Color(0xFF96D9D6),
  'fighting': Color(0xFFC22E28),
  'poison': Color(0xFFA33EA1),
  'ground': Color(0xFFE2BF65),
  'flying': Color(0xFFA98FF3),
  'psychic': Color(0xFFF95587),
  'bug': Color(0xFFA6B91A),
  'rock': Color(0xFFB6A136),
  'ghost': Color(0xFF735797),
  'dragon': Color(0xFF6F35FC),
  'dark': Color(0xFF705746),
  'steel': Color(0xFFB7B7CE),
  'fairy': Color(0xFFD685AD),
};

const Map<String, String> _typeEmojis = {
  'normal': '⭐️',
  'fire': '🔥',
  'water': '💧',
  'electric': '⚡️',
  'grass': '🍃',
  'ice': '❄️',
  'fighting': '🥊',
  'poison': '☠️',
  'ground': '🌋',
  'flying': '🕊️',
  'psychic': '🔮',
  'bug': '🐛',
  'rock': '🪨',
  'ghost': '👻',
  'dragon': '🐲',
  'dark': '🌑',
  'steel': '⚙️',
  'fairy': '🧚',
};

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.pokemonId,
    this.initialPokemon,
    this.heroTag,
  });

  static const int _defaultLanguageId = 7;

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
          variables: {
            'id': pokemonId,
            'languageId': _defaultLanguageId,
          },
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

  String _formatHeight(int height) {
    if (height <= 0) return '—';
    final meters = height / 10.0;
    return '${_stripTrailingZeros(meters)} m';
  }

  String _formatWeight(int weight) {
    if (weight <= 0) return '—';
    final kilograms = weight / 10.0;
    return '${_stripTrailingZeros(kilograms)} kg';
  }

  String _stripTrailingZeros(double value) {
    final fixed = value.toStringAsFixed(value >= 10 ? 1 : 2);
    return fixed
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  String _formatLabel(String value) {
    if (value.isEmpty) {
      return value;
    }
    final sanitized = value.replaceAll('-', ' ');
    return widget.capitalize(sanitized);
  }

  Color _resolveTypeColor(String type, ColorScheme colorScheme) {
    final color = _pokemonTypeColors[type.toLowerCase()];
    return color ?? colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pokemon = widget.pokemon;
    final characteristics = pokemon.characteristics;
    final mainAbilityDetail =
        pokemon.abilities.isNotEmpty ? pokemon.abilities.first : null;
    final mainAbility =
        mainAbilityDetail != null ? _formatLabel(mainAbilityDetail.name) : null;
    final abilitySubtitle = mainAbilityDetail == null
        ? null
        : (mainAbilityDetail.isHidden ? 'Habilidad oculta' : 'Habilidad principal');

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
                        .map((type) {
                          final typeColor = _resolveTypeColor(type, theme.colorScheme);
                          return Chip(
                            label: Text(_formatLabel(type)),
                            backgroundColor: typeColor.withOpacity(0.18),
                            labelStyle: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(color: typeColor.withOpacity(0.45)),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        })
                        .toList(),
                  )
                : const Text('Sin información de tipos disponible.'),
          ),
          const SizedBox(height: 16),
          _InfoSectionCard(
            title: 'Debilidades',
            child: _WeaknessSection(
              matchups: pokemon.typeMatchups,
              formatLabel: _formatLabel,
            ),
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
                        value: _formatHeight(characteristics.height),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.monitor_weight_outlined,
                        label: 'Peso',
                        value: _formatWeight(characteristics.weight),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mainAbility ?? 'Sin habilidad principal disponible.',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (abilitySubtitle != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  abilitySubtitle,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withOpacity(0.75),
                                  ),
                                ),
                              ],
                            ],
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
                  title: 'Características',
                  child: _CharacteristicsSection(
                    characteristics: characteristics,
                    formatHeight: _formatHeight,
                    formatWeight: _formatWeight,
                  ),
                ),
                const SizedBox(height: 16),
                _InfoSectionCard(
                  title: 'Habilidades',
                  child: pokemon.abilities.isNotEmpty
                      ? Column(
                          children: pokemon.abilities
                              .map(
                                (ability) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: _AbilityTile(
                                    ability: ability,
                                    formatLabel: _formatLabel,
                                  ),
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
                                  label: _formatLabel(stat.name.replaceAll('-', ' ')),
                                  value: stat.baseStat,
                                ),
                              )
                              .toList(),
                        )
                      : const Text('Sin información de estadísticas disponible.'),
                ),
                const SizedBox(height: 16),
                _InfoSectionCard(
                  title: 'Resistencias e inmunidades',
                  child: _TypeMatchupSection(
                    matchups: pokemon.typeMatchups,
                    formatLabel: _formatLabel,
                  ),
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
    final colorScheme = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceVariant.withOpacity(0.4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.12)),
      ),
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

class _CharacteristicsSection extends StatelessWidget {
  const _CharacteristicsSection({
    required this.characteristics,
    required this.formatHeight,
    required this.formatWeight,
  });

  final PokemonCharacteristics characteristics;
  final String Function(int) formatHeight;
  final String Function(int) formatWeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <_CharacteristicData>[
      _CharacteristicData(
        icon: Icons.height,
        label: 'Altura',
        value: formatHeight(characteristics.height),
      ),
      _CharacteristicData(
        icon: Icons.monitor_weight_outlined,
        label: 'Peso',
        value: formatWeight(characteristics.weight),
      ),
      _CharacteristicData(
        icon: Icons.category_outlined,
        label: 'Categoría',
        value: characteristics.category.isNotEmpty
            ? characteristics.category
            : 'Sin categoría',
      ),
      _CharacteristicData(
        icon: Icons.catching_pokemon,
        label: 'Ratio de captura',
        value: characteristics.captureRate > 0
            ? characteristics.captureRate.toString()
            : '—',
      ),
      _CharacteristicData(
        icon: Icons.star_border_rounded,
        label: 'Experiencia base',
        value: characteristics.baseExperience > 0
            ? characteristics.baseExperience.toString()
            : '—',
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => _CharacteristicTile(
              icon: item.icon,
              label: item.label,
              value: item.value,
            ),
          )
          .toList(),
    );
  }
}

class _WeaknessSection extends StatefulWidget {
  const _WeaknessSection({
    required this.matchups,
    required this.formatLabel,
  });

  final List<TypeMatchup> matchups;
  final String Function(String) formatLabel;

  @override
  State<_WeaknessSection> createState() => _WeaknessSectionState();
}

class _WeaknessSectionState extends State<_WeaknessSection> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weaknesses = widget.matchups
        .where((matchup) => matchup.multiplier > 1.0)
        .toList()
      ..sort((a, b) => b.multiplier.compareTo(a.multiplier));

    if (weaknesses.isEmpty) {
      return const Text('No hay información de debilidades disponible.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
          child: _isExpanded
              ? Padding(
                  key: const ValueKey(true),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _WeaknessChipGrid(
                    weaknesses: weaknesses,
                    formatLabel: widget.formatLabel,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey(false)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _toggleExpanded,
            icon: Icon(_isExpanded ? Icons.expand_less : Icons.visibility),
            label: Text(
              _isExpanded ? 'Ocultar debilidades' : 'Ver debilidades',
            ),
          ),
        ),
      ],
    );
  }
}

class _WeaknessChipGrid extends StatelessWidget {
  const _WeaknessChipGrid({
    required this.weaknesses,
    required this.formatLabel,
  });

  final List<TypeMatchup> weaknesses;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: weaknesses
          .map(
            (matchup) => _WeaknessChip(
              matchup: matchup,
              formatLabel: formatLabel,
            ),
          )
          .toList(),
    );
  }
}

class _WeaknessChip extends StatelessWidget {
  const _WeaknessChip({
    required this.matchup,
    required this.formatLabel,
  });

  final TypeMatchup matchup;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final typeKey = matchup.type.toLowerCase();
    final typeColor = _pokemonTypeColors[typeKey] ?? colorScheme.primary;
    final emoji = _typeEmojis[typeKey];
    final background = Color.alphaBlend(
      typeColor.withOpacity(0.16),
      colorScheme.surface.withOpacity(0.95),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: typeColor.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            formatLabel(matchup.type),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatMultiplier(matchup.multiplier),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: typeColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacteristicTile extends StatelessWidget {
  const _CharacteristicTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: 165,
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.75),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AbilityTile extends StatelessWidget {
  const _AbilityTile({
    required this.ability,
    required this.formatLabel,
  });

  final PokemonAbilityDetail ability;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final subtitle = ability.isHidden ? 'Habilidad oculta' : 'Habilidad principal';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_fix_high_outlined,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formatLabel(ability.name),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary.withOpacity(0.75),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ability.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeMatchupSection extends StatelessWidget {
  const _TypeMatchupSection({
    required this.matchups,
    required this.formatLabel,
  });

  final List<TypeMatchup> matchups;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    final resistances = matchups
        .where((matchup) => matchup.multiplier > 0 && matchup.multiplier < 0.99)
        .toList()
      ..sort((a, b) => a.multiplier.compareTo(b.multiplier));
    final immunities = matchups
        .where((matchup) => matchup.multiplier <= 0.01)
        .toList();

    final hasContent = resistances.isNotEmpty || immunities.isNotEmpty;

    if (!hasContent) {
      return const Text('Sin información de resistencias o inmunidades disponible.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (resistances.isNotEmpty) ...[
          _MatchupGroup(
            title: 'Resistencias',
            matchups: resistances,
            formatLabel: formatLabel,
          ),
          if (immunities.isNotEmpty) const SizedBox(height: 12),
        ],
        if (immunities.isNotEmpty)
          _MatchupGroup(
            title: 'Inmunidades',
            matchups: immunities,
            formatLabel: formatLabel,
          ),
      ],
    );
  }
}

class _MatchupGroup extends StatelessWidget {
  const _MatchupGroup({
    required this.title,
    required this.matchups,
    required this.formatLabel,
  });

  final String title;
  final List<TypeMatchup> matchups;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: matchups
              .map(
                (matchup) => _TypeMatchupChip(
                  matchup: matchup,
                  formatLabel: formatLabel,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

String _formatMultiplier(double multiplier) {
  if (multiplier <= 0) {
    return '0×';
  }
  if ((multiplier - multiplier.round()).abs() < 0.01) {
    return '${multiplier.round()}×';
  }
  final text = multiplier
      .toStringAsFixed(2)
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');
  return '$text×';
}

class _TypeMatchupChip extends StatelessWidget {
  const _TypeMatchupChip({
    required this.matchup,
    required this.formatLabel,
  });

  final TypeMatchup matchup;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final typeColor =
        _pokemonTypeColors[matchup.type.toLowerCase()] ?? colorScheme.primary;
    final background = Color.alphaBlend(
      typeColor.withOpacity(0.16),
      colorScheme.surface.withOpacity(0.95),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: typeColor.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: typeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatLabel(matchup.type),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatMultiplier(matchup.multiplier),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: typeColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacteristicData {
  const _CharacteristicData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
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
