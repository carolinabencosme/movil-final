import 'package:flutter/material.dart';

import '../../../models/move_filters.dart';
import '../../../models/pokemon_model.dart';
import '../detail_constants.dart';
import '../detail_helper_widgets.dart';
import '../evolution/evolution_components.dart';
import '../info/info_components.dart';
import '../matchups/matchup_components.dart';
import '../moves/moves_components.dart';
import '../stats/stat_components.dart';
import 'moves_filter_sheet.dart';

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
  MoveFilters _filters = const MoveFilters();
  int _visibleMoves = 0;
  int _totalMoves = 0;
  bool _hasCounts = false;

  @override
  bool get wantKeepAlive => true;

  List<String> _availableMethods() {
    return widget.pokemon.moves
        .map((move) => move.method)
        .where((method) => method.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => widget.formatLabel(a).compareTo(widget.formatLabel(b)));
  }

  List<String> _availableVersionGroups() {
    return widget.pokemon.moves
        .where((move) => move.versionGroup != null && move.versionGroup!.isNotEmpty)
        .map((move) => move.versionGroup!)
        .toSet()
        .toList()
      ..sort((a, b) => _formatVersionGroup(a).compareTo(_formatVersionGroup(b)));
  }

  String _formatVersionGroup(String versionGroup) {
    if (versionGroup.isEmpty) {
      return 'Desconocido';
    }

    return versionGroup
        .split('-')
        .where((word) => word.isNotEmpty)
        .map(widget.formatLabel)
        .join(' ');
  }

  void _handleCountsChanged(int visible, int total) {
    if (_hasCounts && _visibleMoves == visible && _totalMoves == total) {
      return;
    }
    setState(() {
      _visibleMoves = visible;
      _totalMoves = total;
      _hasCounts = true;
    });
  }

  void _resetFilters() {
    if (_filters.isDefault) {
      return;
    }
    setState(() {
      _filters = const MoveFilters();
    });
  }

  Future<void> _openFilterSheet() async {
    final methods = _availableMethods();
    final versions = _availableVersionGroups();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return MovesFilterSheet(
          filters: _filters,
          availableMethods: methods,
          availableVersionGroups: versions,
          formatLabel: widget.formatLabel,
          formatVersionGroup: _formatVersionGroup,
          onApply: (filters) {
            setState(() {
              _filters = filters;
            });
            Navigator.of(sheetContext).pop();
          },
          onReset: _resetFilters,
        );
      },
    );
  }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _openFilterSheet,
                    icon: const Icon(Icons.filter_alt_outlined),
                    label: const Text('Filtros'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _filters.isDefault ? null : _resetFilters,
                    child: const Text('Reset filtros'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_hasCounts)
              Semantics(
                liveRegion: true,
                label: 'Contador de movimientos mostrados',
                child: Text(
                  'Mostrando $_visibleMoves de $_totalMoves movimientos',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            if (_hasCounts) const SizedBox(height: 12) else const SizedBox(height: 4),
            MovesSection(
              moves: widget.pokemon.moves,
              formatLabel: widget.formatLabel,
              filters: _filters,
              onCountsChanged: _handleCountsChanged,
            ),
          ],
        ),
      ),
    );
  }
}
