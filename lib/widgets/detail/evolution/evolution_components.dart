import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../models/pokemon_model.dart';
import '../../../widgets/pokemon_artwork.dart';
import '../detail_constants.dart';

/// Helper class for species data
class Species {
  final int id;
  final String name;
  final int? parentId;
  final String imageUrl;

  const Species({
    required this.id,
    required this.name,
    this.parentId,
    this.imageUrl = '',
  });
}

/// Build species map from raw evolution data
Map<int, Species> speciesMapFromRaw(List<PokemonEvolutionNode> raw) {
  final map = <int, Species>{};
  for (final node in raw) {
    map[node.speciesId] = Species(
      id: node.speciesId,
      name: node.name,
      parentId: node.fromSpeciesId,
      imageUrl: node.imageUrl,
    );
  }
  return map;
}

/// Get the full pre-evolution chain including current pokemon
List<Species> preChain(int currentId, Map<int, Species> map) {
  final chain = <Species>[];
  int? cursor = currentId;
  while (cursor != null) {
    final node = map[cursor];
    if (node == null) break;
    chain.insert(0, node);
    cursor = node.parentId;
  }
  return chain;
}

/// Get all forward evolution chains from current pokemon
List<List<Species>> forwardChains(int currentId, Map<int, Species> map) {
  final result = <List<Species>>[];
  final firstLevel = map.values.where((n) => n.parentId == currentId).toList();
  
  for (final child in firstLevel) {
    final chain = <Species>[child];
    var cursor = child;
    while (true) {
      final kids = map.values.where((n) => n.parentId == cursor.id).toList();
      if (kids.length == 1) {
        cursor = kids.first;
        chain.add(cursor);
      } else {
        break;
      }
    }
    result.add(chain);
  }
  return result;
}

/// Constants for sprite URLs
const String officialArtworkBaseUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork';

/// Helper to get sprite URL
String spriteUrl(int id) {
  return '$officialArtworkBaseUrl/$id.png';
}

/// Section displaying Pokemon evolution chain
class EvolutionSection extends StatelessWidget {
  const EvolutionSection({
    super.key,
    required this.evolutionChain,
    required this.currentSpeciesId,
    required this.formatLabel,
  });

  final PokemonEvolutionChain? evolutionChain;
  final int? currentSpeciesId;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    final chain = evolutionChain;
    if (chain == null || chain.isEmpty) {
      return const Text('Sin información de evoluciones disponible.');
    }

    // Collect all nodes into a flat list
    final allNodes = <PokemonEvolutionNode>[];
    for (final group in chain.groups) {
      allNodes.addAll(group);
    }
    for (final path in chain.paths) {
      for (final node in path) {
        if (!allNodes.any((n) => n.speciesId == node.speciesId)) {
          allNodes.add(node);
        }
      }
    }

    if (allNodes.isEmpty) {
      return const Text('Sin información de evoluciones disponible.');
    }

    // Build species map
    final speciesMap = speciesMapFromRaw(allNodes);
    
    // Determine current pokemon ID
    final effectiveCurrentId = currentSpeciesId ?? 
        chain.currentSpeciesId ?? 
        allNodes.first.speciesId;

    // Verify current species exists in map
    if (!speciesMap.containsKey(effectiveCurrentId)) {
      return const Text('Error: No se pudo encontrar el Pokémon actual en la cadena evolutiva.');
    }

    final currentSpecies = speciesMap[effectiveCurrentId];
    if (currentSpecies == null) {
      return const Text('Error: No se pudo encontrar el Pokémon actual en la cadena evolutiva.');
    }

    // Build pre-evolution and forward evolution chains
    final preEvolutionChain = preChain(effectiveCurrentId, speciesMap);
    final forwardEvolutionChains = forwardChains(effectiveCurrentId, speciesMap);

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show complete chain including current pokemon
        if (preEvolutionChain.isNotEmpty) ...[
          Text(
            'Cadena evolutiva completa',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          LinearEvolutionChain(
            chain: preEvolutionChain,
            currentId: effectiveCurrentId,
            formatLabel: formatLabel,
          ),
          const SizedBox(height: 24),
        ],
        
        // Show forward evolutions
        if (forwardEvolutionChains.isNotEmpty) ...[
          Text(
            'Evoluciones posibles',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (forwardEvolutionChains.length == 1)
            LinearEvolutionChain(
              chain: [currentSpecies, ...forwardEvolutionChains.first],
              currentId: effectiveCurrentId,
              formatLabel: formatLabel,
            )
          else
            BranchedEvolutionDisplay(
              chains: forwardEvolutionChains,
              currentSpecies: currentSpecies,
              formatLabel: formatLabel,
            ),
        ] else ...[
          Text(
            'Este Pokémon no tiene evoluciones posteriores.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.72),
            ),
          ),
        ],
      ],
    );
  }
}

/// Linear evolution chain display (horizontal with arrows)
class LinearEvolutionChain extends StatelessWidget {
  const LinearEvolutionChain({
    super.key,
    required this.chain,
    required this.currentId,
    required this.formatLabel,
  });

  final List<Species> chain;
  final int currentId;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < chain.length; i++) ...[
            EvolutionCard(
              species: chain[i],
              isCurrent: chain[i].id == currentId,
              formatLabel: formatLabel,
            ),
            if (i < chain.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward,
                  color: colorScheme.onSurface.withOpacity(0.6),
                  size: 32,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Branched evolution display (circular/ramified layout)
class BranchedEvolutionDisplay extends StatelessWidget {
  const BranchedEvolutionDisplay({
    super.key,
    required this.chains,
    required this.currentSpecies,
    required this.formatLabel,
  });

  final List<List<Species>> chains;
  final Species currentSpecies;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Show current pokemon at top center
        Center(
          child: EvolutionCard(
            species: currentSpecies,
            isCurrent: true,
            formatLabel: formatLabel,
          ),
        ),
        const SizedBox(height: 16),
        // Show arrow pointing down
        Center(
          child: Icon(
            Icons.arrow_downward,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        // Show all evolution branches in a wrap
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 24,
          children: [
            for (final chain in chains)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < chain.length; i++) ...[
                    EvolutionCard(
                      species: chain[i],
                      isCurrent: false,
                      formatLabel: formatLabel,
                    ),
                    if (i < chain.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Icon(
                          Icons.arrow_downward,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          size: 24,
                        ),
                      ),
                  ],
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// Individual evolution card
class EvolutionCard extends StatelessWidget {
  const EvolutionCard({
    super.key,
    required this.species,
    required this.isCurrent,
    required this.formatLabel,
  });

  final Species species;
  final bool isCurrent;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final borderColor = isCurrent
        ? colorScheme.primary
        : colorScheme.outline.withOpacity(0.35);
    final backgroundColor = isCurrent
        ? colorScheme.primaryContainer.withOpacity(0.7)
        : colorScheme.surface.withOpacity(0.96);
    final textColor = isCurrent
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    final imageUrl = species.imageUrl.isNotEmpty 
        ? species.imageUrl 
        : spriteUrl(species.id);

    Widget card = Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
            tag: 'pokemon-artwork-${species.id}',
            child: Image.network(
              imageUrl,
              height: 80,
              width: 80,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.image_not_supported,
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatLabel(species.name),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    // Make non-current cards tappable for navigation
    if (!isCurrent && species.name.isNotEmpty) {
      card = InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          pendingEvolutionNavigation[species.name] = species.id;
          Navigator.of(context).pushNamed('/pokedex/${species.name}');
        },
        child: card,
      );
    }

    return card;
  }
}

/// Row displaying evolution path nodes
class EvolutionPathRow extends StatelessWidget {
  const EvolutionPathRow({
    super.key,
    required this.nodes,
    required this.currentSpeciesId,
    required this.formatLabel,
  });

  final List<PokemonEvolutionNode> nodes;
  final int? currentSpeciesId;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final arrowColor = theme.colorScheme.onSurfaceVariant.withOpacity(0.65);
    final mediaWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var index = 0; index < nodes.length; index++) ...[
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: horizontalEvolutionCardMinWidth,
                  maxWidth: math.min(
                    horizontalEvolutionCardMaxWidth, 
                    math.max(horizontalEvolutionCardMinWidth, (mediaWidth - horizontalEvolutionPadding) / horizontalEvolutionMaxStages),
                  ),
                ),
                child: EvolutionStageCard(
                  node: nodes[index],
                  isCurrent: currentSpeciesId != null &&
                      currentSpeciesId == nodes[index].speciesId,
                  formatLabel: formatLabel,
                ),
              ),
              if (index < nodes.length - 1) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: AnimatedEvolutionArrowHorizontal(
                    color: arrowColor,
                    delay: Duration(milliseconds: 300 + (index * 200)),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Animated horizontal arrow widget
class AnimatedEvolutionArrowHorizontal extends StatefulWidget {
  const AnimatedEvolutionArrowHorizontal({
    super.key,
    required this.color,
    this.delay = Duration.zero,
  });

  final Color color;
  final Duration delay;

  @override
  State<AnimatedEvolutionArrowHorizontal> createState() =>
      _AnimatedEvolutionArrowHorizontalState();
}

class _AnimatedEvolutionArrowHorizontalState
    extends State<AnimatedEvolutionArrowHorizontal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _delayTimer = Timer(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value * horizontalArrowTranslationDistance, 0),
          child: Opacity(
            opacity: 0.4 + (_animation.value * 0.6),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: widget.color,
              size: 28,
            ),
          ),
        );
      },
    );
  }
}

/// Evolution stage card with animation
class EvolutionStageCard extends StatefulWidget {
  const EvolutionStageCard({
    super.key,
    required this.node,
    required this.isCurrent,
    required this.formatLabel,
    this.isCompact = false,
  });

  final PokemonEvolutionNode node;
  final bool isCurrent;
  final String Function(String) formatLabel;
  final bool isCompact;

  @override
  State<EvolutionStageCard> createState() => _EvolutionStageCardState();
}

class _EvolutionStageCardState extends State<EvolutionStageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _delayTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  String _resolveName(String value) {
    if (value.isEmpty) {
      return 'Desconocido';
    }
    final lowercase = value.toLowerCase();
    if (value == lowercase) {
      return widget.formatLabel(value);
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final borderColor = widget.isCurrent
        ? colorScheme.primary
        : colorScheme.outline.withOpacity(0.35);
    final backgroundColor = widget.isCurrent
        ? colorScheme.primaryContainer.withOpacity(0.7)
        : colorScheme.surface.withOpacity(0.96);
    final textColor = widget.isCurrent
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;
    final subtitleColor = widget.isCurrent
        ? colorScheme.onPrimaryContainer.withOpacity(0.88)
        : colorScheme.onSurfaceVariant;

    final imageSize = widget.isCompact 
        ? evolutionCardImageSizeCompact 
        : evolutionCardImageSizeNormal;
    final horizontalPadding = widget.isCompact 
        ? evolutionCardHorizontalPaddingCompact 
        : evolutionCardHorizontalPaddingNormal;
    final verticalPadding = widget.isCompact 
        ? evolutionCardVerticalPaddingCompact 
        : evolutionCardVerticalPaddingNormal;
    final borderRadiusValue = widget.isCompact
        ? evolutionCardBorderRadiusCompact
        : evolutionCardBorderRadiusNormal;
    final isNavigable = !widget.isCurrent && widget.node.slug.isNotEmpty;

    Widget buildCard() {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadiusValue),
          border: Border.all(
            color: borderColor,
            width: widget.isCurrent ? 2 : 1,
          ),
          boxShadow: widget.isCurrent
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PokemonArtwork(
              heroTag: 'pokemon-artwork-${widget.node.speciesId}',
              imageUrl: widget.node.imageUrl,
              size: imageSize,
              borderRadius: widget.isCompact
                  ? evolutionCardImageBorderRadiusCompact
                  : evolutionCardImageBorderRadiusNormal,
              padding: EdgeInsets.all(widget.isCompact
                  ? evolutionCardImagePaddingCompact
                  : evolutionCardImagePaddingNormal),
              showShadow: false,
            ),
            SizedBox(height: widget.isCompact ? 8 : 12),
            Text(
              _resolveName(widget.node.name),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: textColor,
                fontSize:
                    widget.isCompact ? evolutionCardNameFontSizeCompact : null,
              ),
            ),
            SizedBox(height: widget.isCompact ? 6 : 8),
            if (widget.node.conditions.isEmpty)
              Text(
                'Sin requisitos adicionales.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: subtitleColor,
                  fontSize: widget.isCompact
                      ? evolutionCardConditionFontSizeCompact
                      : null,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.node.conditions
                    .map(
                      (condition) => Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: widget.isCompact ? 1 : 2,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: subtitleColor,
                                fontSize: widget.isCompact
                                    ? evolutionCardConditionDetailFontSizeCompact
                                    : null,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                condition,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: subtitleColor,
                                  fontSize: widget.isCompact
                                      ? evolutionCardConditionDetailFontSizeCompact
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      );
    }

    Widget card = buildCard();
    if (isNavigable) {
      card = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadiusValue),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadiusValue),
          onTap: () {
            pendingEvolutionNavigation[widget.node.slug] = widget.node.speciesId;
            Navigator.of(context).pushNamed('/pokedex/${widget.node.slug}');
          },
          child: card,
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: card,
      ),
    );
  }
}
