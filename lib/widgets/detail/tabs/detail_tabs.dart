import 'package:flutter/material.dart';

import '../../../models/pokemon_model.dart';
import '../detail_constants.dart';
import '../detail_helper_widgets.dart';
import '../evolution/evolution_components.dart';
import '../info/info_components.dart';
import '../matchups/matchup_components.dart';
import '../moves/moves_components.dart';
import '../stats/stat_components.dart';

/// Info tab showing Pokemon types, basic data, characteristics, and abilities
class PokemonInfoTab extends StatefulWidget {
  const PokemonInfoTab({
    super.key,
    required this.pokemon,
    required this.formatLabel,
    required this.formatHeight,
    required this.formatWeight,
    required this.mainAbility,
    required this.abilitySubtitle,
    required this.sectionBackground,
    required this.sectionBorder,
  });

  final PokemonDetail pokemon;
  final String Function(String) formatLabel;
  final String Function(int) formatHeight;
  final String Function(int) formatWeight;
  final String? mainAbility;
  final String? abilitySubtitle;
  final Color sectionBackground;
  final Color sectionBorder;

  @override
  State<PokemonInfoTab> createState() => _PokemonInfoTabState();
}

class _PokemonInfoTabState extends State<PokemonInfoTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);
    final characteristics = widget.pokemon.characteristics;
    final padding = responsiveDetailTabPadding(context);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoSectionCard(
            title: 'Tipos',
            backgroundColor: widget.sectionBackground,
            borderColor: widget.sectionBorder,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: widget.pokemon.types.isNotEmpty
                ? TypeLayout(
                    types: widget.pokemon.types,
                    formatLabel: widget.formatLabel,
                  )
                : const Text('Sin información de tipos disponible.'),
          ),
          const SizedBox(height: 16),
          InfoSectionCard(
            title: 'Datos básicos',
            backgroundColor: widget.sectionBackground,
            borderColor: widget.sectionBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    final isWide = maxWidth >= 520;
                    const spacing = 12.0;
                    final cardWidth = isWide
                        ? (maxWidth - spacing) / 2
                        : maxWidth;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: InfoCard(
                            icon: Icons.height,
                            label: 'Altura',
                            value: widget.formatHeight(characteristics.height),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: InfoCard(
                            icon: Icons.monitor_weight_outlined,
                            label: 'Peso',
                            value: widget.formatWeight(characteristics.weight),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  color: widget.sectionBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: widget.sectionBorder.withOpacity(0.8)),
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
                                widget.mainAbility ?? 'Sin habilidad principal disponible.',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (widget.abilitySubtitle != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  widget.abilitySubtitle!,
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
          const SizedBox(height: 16),
          InfoSectionCard(
            title: 'Características',
            backgroundColor: widget.sectionBackground,
            borderColor: widget.sectionBorder,
            variant: InfoSectionCardVariant.angled,
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
            child: CharacteristicsSection(
              characteristics: characteristics,
              formatHeight: widget.formatHeight,
              formatWeight: widget.formatWeight,
            ),
          ),
          const SizedBox(height: 16),
          InfoSectionCard(
            title: 'Habilidades',
            backgroundColor: widget.sectionBackground,
            borderColor: widget.sectionBorder,
            variant: InfoSectionCardVariant.angled,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
            child: widget.pokemon.abilities.isNotEmpty
                ? AbilitiesCarousel(
                    abilities: widget.pokemon.abilities,
                    formatLabel: widget.formatLabel,
                  )
                : const Text('Sin información de habilidades disponible.'),
          ),
        ],
      ),
    );
  }
}

/// Stats tab showing Pokemon statistics
class PokemonStatsTab extends StatefulWidget {
  const PokemonStatsTab({
    super.key,
    required this.pokemon,
    required this.formatLabel,
    required this.sectionBackground,
    required this.sectionBorder,
  });

  final PokemonDetail pokemon;
  final String Function(String) formatLabel;
  final Color sectionBackground;
  final Color sectionBorder;

  @override
  State<PokemonStatsTab> createState() => _PokemonStatsTabState();
}

class _PokemonStatsTabState extends State<PokemonStatsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final padding = responsiveDetailTabPadding(context);

    return Padding(
      padding: padding,
      child: InfoSectionCard(
        title: 'Estadísticas',
        backgroundColor: widget.sectionBackground,
        borderColor: widget.sectionBorder,
        child: widget.pokemon.stats.isNotEmpty
            ? Column(
                children: widget.pokemon.stats
                    .map(
                      (stat) => StatBar(
                        label: widget.formatLabel(stat.name.replaceAll('-', ' ')),
                        value: stat.baseStat,
                      ),
                    )
                    .toList(),
              )
            : const Text('Sin información de estadísticas disponible.'),
      ),
    );
  }
}

/// Matchups tab showing Pokemon type weaknesses and resistances
class PokemonMatchupsTab extends StatefulWidget {
  const PokemonMatchupsTab({
    super.key,
    required this.pokemon,
    required this.formatLabel,
    required this.sectionBackground,
    required this.sectionBorder,
  });

  final PokemonDetail pokemon;
  final String Function(String) formatLabel;
  final Color sectionBackground;
  final Color sectionBorder;

  @override
  State<PokemonMatchupsTab> createState() => _PokemonMatchupsTabState();
}

class _PokemonMatchupsTabState extends State<PokemonMatchupsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final padding = responsiveDetailTabPadding(context);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoSectionCard(
            title: 'Debilidades',
            backgroundColor: widget.sectionBackground,
            borderColor: widget.sectionBorder,
            child: WeaknessSection(
              matchups: widget.pokemon.typeMatchups,
              formatLabel: widget.formatLabel,
            ),
          ),
          const SizedBox(height: 16),
          InfoSectionCard(
            title: 'Resistencias e inmunidades',
            backgroundColor: widget.sectionBackground,
            borderColor: widget.sectionBorder,
            child: TypeMatchupSection(
              matchups: widget.pokemon.typeMatchups,
              formatLabel: widget.formatLabel,
            ),
          ),
        ],
      ),
    );
  }
}

/// Evolution tab showing Pokemon evolution chain
class PokemonEvolutionTab extends StatefulWidget {
  const PokemonEvolutionTab({
    super.key,
    required this.pokemon,
    required this.formatLabel,
    required this.sectionBackground,
    required this.sectionBorder,
  });

  final PokemonDetail pokemon;
  final String Function(String) formatLabel;
  final Color sectionBackground;
  final Color sectionBorder;

  @override
  State<PokemonEvolutionTab> createState() => _PokemonEvolutionTabState();
}

class _PokemonEvolutionTabState extends State<PokemonEvolutionTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final padding = responsiveDetailTabPadding(context);

    return Padding(
      padding: padding,
      child: InfoSectionCard(
        title: 'Cadena evolutiva',
        backgroundColor: widget.sectionBackground,
        borderColor: widget.sectionBorder,
        child: EvolutionSection(
          evolutionChain: widget.pokemon.evolutionChain,
          currentSpeciesId: widget.pokemon.speciesId,
          formatLabel: widget.formatLabel,
        ),
      ),
    );
  }
}

/// Moves tab showing Pokemon moves
class PokemonMovesTab extends StatefulWidget {
  const PokemonMovesTab({
    super.key,
    required this.pokemon,
    required this.formatLabel,
    required this.sectionBackground,
    required this.sectionBorder,
  });

  final PokemonDetail pokemon;
  final String Function(String) formatLabel;
  final Color sectionBackground;
  final Color sectionBorder;

  @override
  State<PokemonMovesTab> createState() => _PokemonMovesTabState();
}

class _PokemonMovesTabState extends State<PokemonMovesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final padding = responsiveDetailTabPadding(context);

    return Padding(
      padding: padding,
      child: InfoSectionCard(
        title: 'Movimientos',
        backgroundColor: widget.sectionBackground,
        borderColor: widget.sectionBorder,
        child: MovesSection(
          moves: widget.pokemon.moves,
          formatLabel: widget.formatLabel,
        ),
      ),
    );
  }
}
