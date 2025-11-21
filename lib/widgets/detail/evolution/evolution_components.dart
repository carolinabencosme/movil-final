import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pokedex/l10n/app_localizations.dart';
import 'package:pokedex/screens/detail_screen.dart';



import '../../../models/pokemon_model.dart';
import '../../../widgets/pokemon_artwork.dart';
import '../detail_constants.dart';

/// Clase auxiliar para almacenar datos de una especie Pokémon
/// 
/// Representa una especie en la cadena evolutiva con información básica
/// necesaria para renderizar las tarjetas de evolución.
class Species {
  /// ID único de la especie en la base de datos
  final int id;
  
  /// Nombre de la especie (ej: "bulbasaur", "charizard")
  final String name;
  
  /// ID de la especie padre (pre-evolución), null si es la forma base
  final int? parentId;
  
  /// URL de la imagen artwork oficial del Pokémon
  final String imageUrl;

  const Species({
    required this.id,
    required this.name,
    this.parentId,
    this.imageUrl = '',
  });
}

/// Construye un mapa de especies desde datos crudos de evolución
/// 
/// Convierte una lista de nodos de evolución en un mapa indexado por ID
/// para facilitar la navegación y búsqueda en la cadena evolutiva.
/// 
/// [raw]: Lista de nodos de evolución desde la API GraphQL
/// Retorna: Mapa donde la clave es el ID de especie y el valor es el objeto Species
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

/// Obtiene la cadena completa de pre-evoluciones incluyendo el Pokémon actual
/// 
/// Recorre hacia atrás desde el Pokémon actual hasta la forma base,
/// construyendo una lista ordenada de todas las formas previas.
/// 
/// [currentId]: ID del Pokémon actual
/// [map]: Mapa de especies indexado por ID
/// Retorna: Lista ordenada desde la forma base hasta el Pokémon actual
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

/// Obtiene todas las cadenas de evolución futuras desde el Pokémon actual
/// 
/// Construye las diferentes rutas evolutivas posibles desde el Pokémon actual.
/// Maneja ramificaciones (como Eevee con múltiples evoluciones) creando
/// una cadena separada para cada rama.
/// 
/// [currentId]: ID del Pokémon actual
/// [map]: Mapa de especies indexado por ID
/// Retorna: Lista de cadenas, donde cada cadena es una posible ruta evolutiva
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

/// URL base para las imágenes artwork oficiales de Pokémon desde PokeAPI
const String officialArtworkBaseUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork';

/// Genera la URL del sprite oficial para un Pokémon dado su ID
/// 
/// [id]: ID numérico del Pokémon (ej: 1 para Bulbasaur)
/// Retorna: URL completa de la imagen PNG del artwork oficial
String spriteUrl(int id) {
  return '$officialArtworkBaseUrl/$id.png';
}

/// Sección que muestra la cadena evolutiva del Pokémon
/// 
/// Presenta visualmente las evoluciones de un Pokémon, incluyendo:
/// - Cadena evolutiva completa (pre-evoluciones)
/// - Evoluciones posibles futuras
/// - Ramificaciones evolutivas (como Eevee)
class EvolutionSection extends StatelessWidget {
  const EvolutionSection({
    super.key,
    required this.evolutionChain,
    required this.currentSpeciesId,
    required this.formatLabel,
  });

  /// Cadena evolutiva completa del Pokémon con todos los nodos
  final PokemonEvolutionChain? evolutionChain;
  
  /// ID de la especie del Pokémon actual que se está visualizando
  final int? currentSpeciesId;
  
  /// Función para formatear etiquetas de texto (capitalización)
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

/// Visualización lineal de cadena evolutiva (horizontal con flechas)
/// 
/// Muestra una secuencia de evoluciones en línea horizontal con flechas
/// entre cada etapa, ideal para evoluciones simples sin ramificaciones.
class LinearEvolutionChain extends StatelessWidget {
  const LinearEvolutionChain({
    super.key,
    required this.chain,
    required this.currentId,
    required this.formatLabel,
  });

  /// Lista ordenada de especies en la cadena evolutiva
  final List<Species> chain;
  
  /// ID del Pokémon actual para resaltarlo visualmente
  final int currentId;
  
  /// Función para formatear etiquetas de texto
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

/// Visualización de evoluciones ramificadas (diseño circular/ramificado)
/// 
/// Muestra evoluciones con múltiples ramas (como Eevee) en un diseño vertical:
/// - Pokémon actual en la parte superior central
/// - Flecha hacia abajo
/// - Todas las posibles evoluciones en un Wrap horizontal
/// 
/// Cada rama puede tener múltiples etapas (ej: Eevee -> Umbreon -> [futura evolución])
class BranchedEvolutionDisplay extends StatelessWidget {
  const BranchedEvolutionDisplay({
    super.key,
    required this.chains,
    required this.currentSpecies,
    required this.formatLabel,
  });

  /// Lista de cadenas evolutivas posibles, cada una es una lista de Species
  final List<List<Species>> chains;
  
  /// Especie del Pokémon actual que se muestra en el centro
  final Species currentSpecies;
  
  /// Función para formatear etiquetas de texto
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

/// Tarjeta individual de evolución
/// 
/// Muestra un Pokémon en la cadena evolutiva con:
/// - Imagen del Pokémon
/// - Nombre
/// - Indicador visual si es el Pokémon actual
/// - Navegación táctil a otros Pokémon (si no es el actual)
/// 
/// IMPORTANTE: No usa Hero widget para evitar conflictos de tags duplicados
/// cuando múltiples evoluciones se muestran en la misma pantalla.
class EvolutionCard extends StatelessWidget {
  const EvolutionCard({
    super.key,
    required this.species,
    required this.isCurrent,
    required this.formatLabel,
  });

  /// Datos de la especie a mostrar
  final Species species;
  
  /// Si es true, este es el Pokémon que el usuario está viendo actualmente
  final bool isCurrent;
  
  /// Función para formatear etiquetas de texto
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
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
          // No se usa Hero aquí para evitar conflictos de tags duplicados
          // en la cadena evolutiva donde múltiples especies se muestran simultáneamente.
          // TRADE-OFF: Esto elimina la animación de transición suave al navegar entre
          // tarjetas de evolución, pero previene el error crítico de Hero tags duplicados.
          // TODO: Futura mejora - implementar Hero tags únicos basados en contexto
          // (ej: 'evolution-card-${species.id}-${context.hashCode}') para restaurar
          // las animaciones sin causar conflictos.
          Image.network(
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
      final formattedName = formatLabel(species.name);
      card = Semantics(
        button: true,
        label: l10n.pokedexCardSemanticLabel(formattedName),
        hint: l10n.pokedexCardSemanticHint(formattedName),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            pendingEvolutionNavigation[species.name] = species.id;
            context.push('/pokedex/${species.name}');
          },
          child: card,
        ),
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

/// Tarjeta de etapa evolutiva con animación
/// 
/// Widget animado que muestra una etapa en la cadena evolutiva con:
/// - Animaciones de entrada (escala y fade)
/// - Imagen del Pokémon
/// - Nombre y condiciones de evolución
/// - Indicador visual si es el Pokémon actual
/// - Navegación táctil a otros Pokémon
class EvolutionStageCard extends StatefulWidget {
  const EvolutionStageCard({
    super.key,
    required this.node,
    required this.isCurrent,
    required this.formatLabel,
    this.isCompact = false,
  });

  /// Nodo de evolución con datos de la especie y condiciones
  final PokemonEvolutionNode node;
  
  /// Si es true, este es el Pokémon que el usuario está viendo
  final bool isCurrent;
  
  /// Función para formatear etiquetas de texto
  final String Function(String) formatLabel;
  
  /// Si es true, usa un diseño más compacto
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
    final l10n = AppLocalizations.of(context)!;

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
            // No se usa heroTag para evitar conflictos de tags duplicados
            // en la cadena evolutiva donde múltiples especies pueden tener el mismo ID.
            // TRADE-OFF: Sin Hero animations al navegar, pero previene errores críticos.
            // TODO: Considerar usar heroTag único con contexto para restaurar animaciones.
            PokemonArtwork(
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
      final resolvedName = _resolveName(widget.node.slug);
      card = Semantics(
        button: true,
        label: l10n.pokedexCardSemanticLabel(resolvedName),
        hint: l10n.pokedexCardSemanticHint(resolvedName),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadiusValue),
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadiusValue),
            onTap: () {
              pendingEvolutionNavigation[widget.node.slug] =
                  widget.node.speciesId;
              context.push('/pokedex/${widget.node.slug}');
            },
            child: card,
          ),
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
