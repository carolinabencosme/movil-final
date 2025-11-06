import 'dart:math' as math;
import 'dart:ui' show clampDouble;
import 'package:flutter/material.dart';

import '../../../models/pokemon_model.dart';
import '../../../theme/pokemon_type_colors.dart';
import '../detail_helper_widgets.dart';
import '../matchups/matchup_components.dart';
import '../stats/stat_components.dart';

/// Helper to resolve type color statically
Color _resolveStaticTypeColor(String type, ColorScheme scheme) {
  final color = pokemonTypeColors[type.toLowerCase()];
  return color ?? scheme.primary;
}

/// Layout widget for Pokemon types
class TypeLayout extends StatelessWidget {
  const TypeLayout({
    super.key,
    required this.types,
    required this.formatLabel,
  });

  final List<String> types;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (types.length <= 3) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: types.map((type) => _buildTypeChip(theme, type)).toList(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);

        if (types.length <= 6) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 3.4,
            ),
            itemCount: types.length,
            itemBuilder: (context, index) => Align(
              alignment: Alignment.center,
              child: _buildTypeChip(theme, types[index]),
            ),
          );
        }

        return CustomScrollView(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildTypeChip(theme, types[index]),
                childCount: types.length,
              ),
            ),
          ],
        );
      },
    );
  }

  int _calculateCrossAxisCount(double maxWidth) {
    final raw = (maxWidth / 180).floor();
    var count = raw < 2 ? 2 : raw;
    count = math.min(count, math.min(types.length, 4));
    return count;
  }

  Widget _buildTypeChip(ThemeData theme, String type) {
    final typeColor = _resolveStaticTypeColor(type, theme.colorScheme);
    return Chip(
      label: Text(formatLabel(type)),
      backgroundColor: typeColor.withOpacity(0.18),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: typeColor.withOpacity(0.45)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

/// Section displaying Pokemon characteristics
class CharacteristicsSection extends StatelessWidget {
  const CharacteristicsSection({
    super.key,
    required this.characteristics,
    required this.formatHeight,
    required this.formatWeight,
  });

  final PokemonCharacteristics characteristics;
  final String Function(int) formatHeight;
  final String Function(int) formatWeight;

  @override
  Widget build(BuildContext context) {
    final items = <CharacteristicData>[
      CharacteristicData(
        icon: Icons.height,
        label: 'Altura',
        value: formatHeight(characteristics.height),
      ),
      CharacteristicData(
        icon: Icons.monitor_weight_outlined,
        label: 'Peso',
        value: formatWeight(characteristics.weight),
      ),
      CharacteristicData(
        icon: Icons.category_outlined,
        label: 'Categoría',
        value: characteristics.category.isNotEmpty
            ? characteristics.category
            : 'Sin categoría',
      ),
      CharacteristicData(
        icon: Icons.catching_pokemon,
        label: 'Ratio de captura',
        value: characteristics.captureRate > 0
            ? characteristics.captureRate.toString()
            : '—',
      ),
      CharacteristicData(
        icon: Icons.star_border_rounded,
        label: 'Experiencia base',
        value: characteristics.baseExperience > 0
            ? characteristics.baseExperience.toString()
            : '—',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        const runSpacing = 14.0;
        const maxTileWidth = 220.0;

        final maxWidth = constraints.maxWidth;
        final rawColumns =
            ((maxWidth + spacing) / (maxTileWidth + spacing)).floor();
        final columns = math.max(1, math.min(items.length, rawColumns));
        final tileWidth = columns > 1
            ? (maxWidth - (columns - 1) * spacing) / columns
            : maxWidth;
        final effectiveTileWidth =
            columns > 1 ? math.min(tileWidth, maxTileWidth) : tileWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          alignment: columns == 1 ? WrapAlignment.center : WrapAlignment.start,
          children: [
            for (final item in items)
              SizedBox(
                width: effectiveTileWidth,
                child: CharacteristicTile(
                  icon: item.icon,
                  label: item.label,
                  value: item.value,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Section displaying Pokemon weaknesses (expandable)
class WeaknessSection extends StatefulWidget {
  const WeaknessSection({
    super.key,
    required this.matchups,
    required this.formatLabel,
  });

  final List<TypeMatchup> matchups;
  final String Function(String) formatLabel;

  @override
  State<WeaknessSection> createState() => _WeaknessSectionState();
}

class _WeaknessSectionState extends State<WeaknessSection> {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MatchupHexGrid(
                        matchups: weaknesses,
                        formatLabel: widget.formatLabel,
                        category: MatchupCategory.weakness,
                      ),
                      const SizedBox(height: 12),
                      const MatchupLegend(
                        entries: [
                          LegendEntry(
                            label: '4×',
                            description:
                                'Doble debilidad: el daño recibido se multiplica por cuatro.',
                            icon: Icons.local_fire_department,
                            colorRole: LegendColorRole.critical,
                          ),
                          LegendEntry(
                            label: '2×',
                            description:
                                'Debilidad clásica: ataques súper efectivos.',
                            icon: Icons.trending_up,
                            colorRole: LegendColorRole.warning,
                          ),
                          LegendEntry(
                            label: '1.5×',
                            description:
                                'Ventaja moderada: daño ligeramente incrementado.',
                            icon: Icons.bolt,
                            colorRole: LegendColorRole.emphasis,
                          ),
                        ],
                      ),
                    ],
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

/// Carousel widget for displaying Pokemon abilities
class AbilitiesCarousel extends StatefulWidget {
  const AbilitiesCarousel({
    super.key,
    required this.abilities,
    required this.formatLabel,
  });

  final List<PokemonAbilityDetail> abilities;
  final String Function(String) formatLabel;

  @override
  State<AbilitiesCarousel> createState() => _AbilitiesCarouselState();
}

class _AbilitiesCarouselState extends State<AbilitiesCarousel> {
  late PageController _pageController;
  double _currentViewportFraction = 0.88;
  double? _lastConstraintWidth;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _currentViewportFraction);
  }

  @override
  void didUpdateWidget(AbilitiesCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.abilities.length != widget.abilities.length) {
      _recreateController(_currentViewportFraction);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _recreateController(double newFraction) {
    if (_isUpdating) return;
    
    _isUpdating = true;
    _currentViewportFraction = newFraction;
    
    final oldController = _pageController;
    _pageController = PageController(viewportFraction: newFraction);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      oldController.dispose();
    });
  }

  void _updateViewportFractionIfNeeded(double newFraction, double constraintWidth) {
    if (_lastConstraintWidth != null && 
        (constraintWidth - _lastConstraintWidth!).abs() < 10) {
      return;
    }
    
    if ((_currentViewportFraction - newFraction).abs() > 0.01 && !_isUpdating) {
      _lastConstraintWidth = constraintWidth;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _recreateController(newFraction);
            _isUpdating = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.sizeOf(context);
        final isCompactWidth = constraints.maxWidth < 560;
        final viewportFraction = isCompactWidth ? 0.88 : 0.52;
        
        _updateViewportFractionIfNeeded(viewportFraction, constraints.maxWidth);

        final cardWidth = clampDouble(
          constraints.maxWidth * _currentViewportFraction,
          220,
          constraints.maxWidth,
        );
        final baseHeight = size.height * (isCompactWidth ? 0.28 : 0.32);
        final cardHeight = clampDouble(
          baseHeight,
          isCompactWidth ? 160 : 200,
          isCompactWidth ? 220 : 260,
        );

        return SizedBox(
          height: cardHeight,
          child: PageView.builder(
            controller: _pageController,
            padEnds: widget.abilities.length == 1,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.abilities.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompactWidth ? 8 : 10,
                ),
                child: AbilityTile(
                  ability: widget.abilities[index],
                  formatLabel: widget.formatLabel,
                  width: cardWidth,
                  height: cardHeight,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Tile displaying a single Pokemon ability
class AbilityTile extends StatelessWidget {
  const AbilityTile({
    super.key,
    required this.ability,
    required this.formatLabel,
    required this.width,
    required this.height,
  });

  final PokemonAbilityDetail ability;
  final String Function(String) formatLabel;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final subtitle = ability.isHidden ? 'Habilidad oculta' : 'Habilidad principal';

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withOpacity(0.9),
              colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_fix_high_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    formatLabel(ability.name),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ability.isHidden
                    ? colorScheme.secondaryContainer.withOpacity(0.9)
                    : colorScheme.tertiaryContainer.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                subtitle,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: ability.isHidden
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                ability.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.85),
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
