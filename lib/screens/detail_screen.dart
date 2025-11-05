import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui' show clampDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/pokemon_model.dart';
import '../queries/get_pokemon_details.dart';
import '../theme/pokemon_type_colors.dart';
import '../widgets/pokemon_artwork.dart';

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

const String _backgroundTextureSvg = '''
<svg width="400" height="400" viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <radialGradient id="halo" cx="0.5" cy="0.5" r="0.5">
      <stop offset="0%" stop-color="white" stop-opacity="0.32"/>
      <stop offset="100%" stop-color="white" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <g fill="none" stroke="white" stroke-width="12" stroke-linecap="round" stroke-opacity="0.18">
    <path d="M50 200h300"/>
    <path d="M200 50v300"/>
    <circle cx="200" cy="200" r="160"/>
    <circle cx="200" cy="200" r="110" stroke-opacity="0.12" stroke-width="10"/>
    <circle cx="200" cy="200" r="60" stroke-opacity="0.1" stroke-width="8"/>
  </g>
  <circle cx="200" cy="200" r="48" fill="url(#halo)"/>
</svg>
''';

class _DetailTabConfig {
  const _DetailTabConfig({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

const List<_DetailTabConfig> _detailTabConfigs = [
  _DetailTabConfig(icon: Icons.info_outline_rounded, label: 'Información'),
  _DetailTabConfig(icon: Icons.bar_chart_rounded, label: 'Estadísticas'),
  _DetailTabConfig(icon: Icons.auto_awesome_motion_rounded, label: 'Matchups'),
  _DetailTabConfig(icon: Icons.transform_rounded, label: 'Evoluciones'),
  _DetailTabConfig(icon: Icons.sports_martial_arts_rounded, label: 'Movimientos'),
];

// Constants for evolution display layout
const double _evolutionBranchMaxWidth = 220.0;
const double _evolutionBranchMinWidth = 150.0;
const int _evolutionBranchGridColumns = 3;
const double _evolutionBranchSpacing = 20.0;
const double _wideScreenBreakpoint = 600.0;

// Constants for evolution stage card sizing
const double _evolutionCardImageSizeNormal = 110.0;
const double _evolutionCardImageSizeCompact = 90.0;
const double _evolutionCardImageBorderRadiusNormal = 24.0;
const double _evolutionCardImageBorderRadiusCompact = 20.0;
const double _evolutionCardImagePaddingNormal = 12.0;
const double _evolutionCardImagePaddingCompact = 8.0;
const double _evolutionCardHorizontalPaddingNormal = 18.0;
const double _evolutionCardHorizontalPaddingCompact = 14.0;
const double _evolutionCardVerticalPaddingNormal = 16.0;
const double _evolutionCardVerticalPaddingCompact = 12.0;
const double _evolutionCardBorderRadiusNormal = 26.0;
const double _evolutionCardBorderRadiusCompact = 20.0;
const double _evolutionCardNameFontSizeCompact = 14.0;
const double _evolutionCardConditionFontSizeCompact = 12.0;
const double _evolutionCardConditionDetailFontSizeCompact = 11.0;

// Constants for compact evolution display (6+ branches)
const int _compactLayoutThreshold = 6;
const int _maxCompactColumns = 4;
const int _compactColumnDivisor = 2;
const double _compactBranchMaxWidth = 180.0;
const double _compactBranchMinWidth = 140.0;
const double _compactBranchSpacing = 12.0;

// Constants for horizontal evolution layout
const double _horizontalEvolutionCardMinWidth = 160.0;
const double _horizontalEvolutionCardMaxWidth = 220.0;
const double _horizontalEvolutionPadding = 100.0;
const double _horizontalArrowTranslationDistance = 4.0;
const int _horizontalEvolutionMaxStages = 3;

EdgeInsets _responsiveDetailTabPadding(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  final horizontalPadding = clampDouble(size.width * 0.06, 16, 32);
  return EdgeInsets.symmetric(horizontal: horizontalPadding)
      .copyWith(top: 24, bottom: 32);
}

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
          fetchPolicy: FetchPolicy.networkOnly,
          cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
          errorPolicy: ErrorPolicy.all, // Changed from ignore to all to see errors
          variables: {
            'id': pokemonId,
            'languageId': _defaultLanguageId,
          },
        ),
        builder: (result, {fetchMore, refetch}) {
          // Debug logging for Pokemon detail data fetching
          if (kDebugMode) {
            debugPrint('[Pokemon Detail] Query result - isLoading: ${result.isLoading}, hasException: ${result.hasException}');
            debugPrint('[Pokemon Detail] Available data keys: ${result.data?.keys.toList()}');
            if (result.hasException) {
              debugPrint('[Pokemon Detail] Exception details: ${result.exception}');
            }
          }
          
          // Extract the first pokemon from the list query result
          final pokemonList = result.data?['pokemon_v2_pokemon'] as List<dynamic>?;
          final data = (pokemonList?.isNotEmpty ?? false)
              ? pokemonList?.first as Map<String, dynamic>?
              : null;

          if (result.isLoading && data == null) {
            return _LoadingDetailView(
              heroTag: resolvedHeroTag,
              imageUrl: previewImage,
              name: previewName,
            );
          }

          if (result.hasException && data == null) {
            debugPrint(
              'Error al cargar el detalle del Pokémon: ${result.exception}',
            );
            return _PokemonDetailErrorView(
              onRetry: refetch,
            );
          }

          if (data == null) {
            if (kDebugMode) {
              debugPrint('[Pokemon Detail] No pokemon data found. Full result: ${result.data}');
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No se encontró información para este Pokémon.'),
                  const SizedBox(height: 16),
                  if (refetch != null)
                    ElevatedButton(
                      onPressed: () async {
                        await refetch();
                      },
                      child: const Text('Reintentar'),
                    ),
                ],
              ),
            );
          }

          if (result.hasException) {
            debugPrint(
              'Se recibieron datos parciales con errores: ${result.exception}',
            );
          }

          final typeEfficacies =
              result.data?['type_efficacy'] as List<dynamic>? ?? [];

          final pokemon = PokemonDetail.fromGraphQL(
            data,
            typeEfficacies: typeEfficacies,
          );

          return RefreshIndicator(
            onRefresh: () async {
              await refetch?.call();
            },
            child: SafeArea(
              child: Builder(
                builder: (context) {
                  return Stack(
                    children: [
                      _PokemonDetailBody(
                        pokemon: pokemon,
                        resolvedHeroTag: resolvedHeroTag,
                        capitalize: _capitalize,
                      ),
                      if (result.isLoading)
                        const Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          child: LinearProgressIndicator(minHeight: 2),
                        ),
                    ],
                  );
                },
              ),
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

class _PokemonDetailBodyState extends State<_PokemonDetailBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _pageController = PageController();
    
    // Sync TabController with PageController
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
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
    return _resolveStaticTypeColor(type, colorScheme);
  }

  Widget _buildHeroHeader({
    required BuildContext context,
    required ThemeData theme,
    required PokemonDetail pokemon,
    required Color typeColor,
    required Color onTypeColor,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    const double collapsedHeight = kToolbarHeight + 72.0;
    final portraitHeight = math.max(
      collapsedHeight,
      math.min(360.0, size.height * 0.45),
    );
    final landscapeHeight = math.max(
      collapsedHeight,
      math.min(320.0, size.height * 0.6),
    );
    final headerHeight = isLandscape ? landscapeHeight : portraitHeight;
    final imageSize = math.min(
      210.0,
      math.min(size.width, headerHeight) * 0.55,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: SizedBox(
          height: headerHeight,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        typeColor,
                        Color.alphaBlend(
                          typeColor.withOpacity(0.45),
                          theme.colorScheme.surface,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.4),
                      radius: 1.05,
                      colors: [
                        typeColor.withOpacity(0.75),
                        typeColor.withOpacity(0.1),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.35,
                    child: SvgPicture.string(
                      _backgroundTextureSvg,
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        onTypeColor.withOpacity(0.25),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(
                      sigmaX: 18,
                      sigmaY: 18,
                    ),
                    child: Container(
                      color: typeColor.withOpacity(0.08),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.55,
                    child: _ParticleField(
                      color: onTypeColor.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                top: 24,
                child: Text(
                  widget.capitalize(pokemon.name),
                  style: theme.textTheme.headlineMedium?.copyWith(
                        color: onTypeColor,
                        fontWeight: FontWeight.w800,
                      ) ??
                      TextStyle(
                        color: onTypeColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 460;
                    final summaryMaxWidth = math.min(
                      260.0,
                      math.max(
                        0.0,
                        constraints.maxWidth - 48,
                      ),
                    );
                    final alignment =
                        isCompact ? Alignment.topCenter : Alignment.bottomRight;
                    final EdgeInsets padding = isCompact
                        ? const EdgeInsets.fromLTRB(24, 120, 24, 24)
                        : const EdgeInsets.fromLTRB(0, 0, 24, 24);

                    return Align(
                      alignment: alignment,
                      child: Padding(
                        padding: padding,
                        child: _buildFloatingSummaryCard(
                          theme,
                          theme.colorScheme,
                          pokemon,
                          summaryMaxWidth,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Hero(
                    tag: widget.resolvedHeroTag,
                    child: PokemonArtwork(
                      imageUrl: pokemon.imageUrl,
                      size: imageSize,
                      borderRadius: 36,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(
    ThemeData theme,
    Color typeColor,
    Color onTypeColor,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Color.alphaBlend(typeColor.withOpacity(0.08), theme.colorScheme.surface),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: typeColor.withOpacity(0.18), width: 1),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        indicator: BoxDecoration(
          color: typeColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        labelColor: theme.colorScheme.onSurface,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(6),
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        tabs: _detailTabConfigs
            .map(
              (config) => Tab(
                icon: Icon(config.icon, size: 20),
                text: config.label,
                height: 68,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildFloatingSummaryCard(
    ThemeData theme,
    ColorScheme colorScheme,
    PokemonDetail pokemon,
    double maxWidth,
  ) {
    final effectiveMaxWidth = maxWidth.isFinite && maxWidth > 0
        ? maxWidth
        : 220.0;
    final textTheme = theme.textTheme;
    final idText = '#${pokemon.id.toString().padLeft(4, '0')}';
    final heightText = _formatHeight(pokemon.characteristics.height);
    final weightText = _formatWeight(pokemon.characteristics.weight);
    final labelStyle = textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );

    Widget buildMetric(String label, String value) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      );
    }

    final typeChips = pokemon.types
        .map((type) {
          final typeColor = _resolveTypeColor(type, colorScheme);
          final textColor = ThemeData.estimateBrightnessForColor(typeColor) ==
                  Brightness.dark
              ? Colors.white
              : colorScheme.onSurface;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: typeColor.withOpacity(0.35)),
            ),
            child: Text(
              _formatLabel(type),
              style: textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          );
        })
        .toList();

    return Card(
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surface.withOpacity(0.82),
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                idText,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              if (typeChips.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: typeChips,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildMetric('Altura', heightText),
                  const SizedBox(width: 14),
                  buildMetric('Peso', weightText),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pokemon = widget.pokemon;
    final mainAbilityDetail =
        pokemon.abilities.isNotEmpty ? pokemon.abilities.first : null;
    final mainAbility =
        mainAbilityDetail != null ? _formatLabel(mainAbilityDetail.name) : null;
    final abilitySubtitle = mainAbilityDetail == null
        ? null
        : (mainAbilityDetail.isHidden ? 'Habilidad oculta' : 'Habilidad principal');

    final colorScheme = theme.colorScheme;
    final typeColor = pokemon.types.isNotEmpty
        ? _resolveTypeColor(pokemon.types.first, colorScheme)
        : colorScheme.primary;
    final onTypeColor =
        ThemeData.estimateBrightnessForColor(typeColor) == Brightness.dark
            ? Colors.white
            : Colors.black87;
    final backgroundTint =
        Color.alphaBlend(typeColor.withOpacity(0.04), colorScheme.surface);
    final sectionBackground =
        Color.alphaBlend(typeColor.withOpacity(0.08), colorScheme.surfaceVariant);
    final sectionBorder = typeColor.withOpacity(0.25);

    // Calculate bottom padding for safe area
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = 48.0 + mediaQuery.padding.bottom + mediaQuery.viewInsets.bottom;

    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundTint),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeroHeader(
            context: context,
            theme: theme,
            pokemon: pokemon,
            typeColor: typeColor,
            onTypeColor: onTypeColor,
          ),
          _buildTabBar(theme, typeColor, onTypeColor),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                if (_tabController.index != index) {
                  _tabController.animateTo(index);
                }
              },
              children: [
                // Información Tab
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: EdgeInsets.only(top: 24, bottom: bottomPadding),
                  child: _PokemonInfoTab(
                    pokemon: pokemon,
                    formatLabel: _formatLabel,
                    formatHeight: _formatHeight,
                    formatWeight: _formatWeight,
                    mainAbility: mainAbility,
                    abilitySubtitle: abilitySubtitle,
                    sectionBackground: sectionBackground,
                    sectionBorder: sectionBorder,
                  ),
                ),
                // Estadísticas Tab
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: EdgeInsets.only(top: 24, bottom: bottomPadding),
                  child: _PokemonStatsTab(
                    pokemon: pokemon,
                    formatLabel: _formatLabel,
                    sectionBackground: sectionBackground,
                    sectionBorder: sectionBorder,
                  ),
                ),
                // Matchups Tab
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: EdgeInsets.only(top: 24, bottom: bottomPadding),
                  child: _PokemonMatchupsTab(
                    pokemon: pokemon,
                    formatLabel: _formatLabel,
                    sectionBackground: sectionBackground,
                    sectionBorder: sectionBorder,
                  ),
                ),
                // Evoluciones Tab
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: EdgeInsets.only(top: 24, bottom: bottomPadding),
                  child: _PokemonEvolutionTab(
                    pokemon: pokemon,
                    formatLabel: _formatLabel,
                    sectionBackground: sectionBackground,
                    sectionBorder: sectionBorder,
                  ),
                ),
                // Movimientos Tab
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: EdgeInsets.only(top: 24, bottom: bottomPadding),
                  child: _PokemonMovesTab(
                    pokemon: pokemon,
                    formatLabel: _formatLabel,
                    sectionBackground: sectionBackground,
                    sectionBorder: sectionBorder,
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

class _ParticleField extends StatelessWidget {
  const _ParticleField({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlePainter(color),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final shortestSide = size.shortestSide;
    final baseRadius = shortestSide * 0.06;
    final blurPaint = Paint()
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8);

    final clusters = <Offset>[
      Offset(size.width * 0.2, size.height * 0.35),
      Offset(size.width * 0.8, size.height * 0.42),
      Offset(size.width * 0.65, size.height * 0.18),
      Offset(size.width * 0.35, size.height * 0.72),
      Offset(size.width * 0.55, size.height * 0.58),
    ];

    for (final offset in clusters) {
      final gradientPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            color,
            color.withOpacity(0),
          ],
        ).createShader(
          Rect.fromCircle(center: offset, radius: baseRadius * 1.8),
        );

      canvas.drawCircle(offset, baseRadius * 1.6, gradientPaint);
      blurPaint.color = color.withOpacity(0.35);
      canvas.drawCircle(offset, baseRadius, blurPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _PokemonInfoTab extends StatelessWidget {
  const _PokemonInfoTab({
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final characteristics = pokemon.characteristics;
    final padding = _responsiveDetailTabPadding(context);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoSectionCard(
            title: 'Tipos',
            backgroundColor: sectionBackground,
            borderColor: sectionBorder,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: pokemon.types.isNotEmpty
                ? _TypeLayout(
                    types: pokemon.types,
                    formatLabel: formatLabel,
                  )
                : const Text('Sin información de tipos disponible.'),
          ),
          const SizedBox(height: 16),
          _InfoSectionCard(
            title: 'Datos básicos',
            backgroundColor: sectionBackground,
            borderColor: sectionBorder,
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
                          child: _InfoCard(
                            icon: Icons.height,
                            label: 'Altura',
                            value: formatHeight(characteristics.height),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _InfoCard(
                            icon: Icons.monitor_weight_outlined,
                            label: 'Peso',
                            value: formatWeight(characteristics.weight),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  color: sectionBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: sectionBorder.withOpacity(0.8)),
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
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (abilitySubtitle != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  abilitySubtitle!,
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
          _InfoSectionCard(
            title: 'Características',
            backgroundColor: sectionBackground,
            borderColor: sectionBorder,
            variant: InfoSectionCardVariant.angled,
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
            child: _CharacteristicsSection(
              characteristics: characteristics,
              formatHeight: formatHeight,
              formatWeight: formatWeight,
            ),
          ),
          const SizedBox(height: 16),
          _InfoSectionCard(
            title: 'Habilidades',
            backgroundColor: sectionBackground,
            borderColor: sectionBorder,
            variant: InfoSectionCardVariant.angled,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
            child: pokemon.abilities.isNotEmpty
                ? _AbilitiesCarousel(
                    abilities: pokemon.abilities,
                    formatLabel: formatLabel,
                  )
                : const Text('Sin información de habilidades disponible.'),
          ),
        ],
      ),
    );
  }
}

class _PokemonStatsTab extends StatelessWidget {
  const _PokemonStatsTab({
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
  Widget build(BuildContext context) {
    final padding = _responsiveDetailTabPadding(context);

    return Padding(
      padding: padding,
      child: _InfoSectionCard(
        title: 'Estadísticas',
        backgroundColor: sectionBackground,
        borderColor: sectionBorder,
        child: pokemon.stats.isNotEmpty
            ? Column(
                children: pokemon.stats
                    .map(
                      (stat) => _StatBar(
                        label: formatLabel(stat.name.replaceAll('-', ' ')),
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

class _PokemonMatchupsTab extends StatelessWidget {
  const _PokemonMatchupsTab({
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
  Widget build(BuildContext context) {
    final padding = _responsiveDetailTabPadding(context);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoSectionCard(
            title: 'Debilidades',
            backgroundColor: sectionBackground,
            borderColor: sectionBorder,
            child: _WeaknessSection(
              matchups: pokemon.typeMatchups,
              formatLabel: formatLabel,
            ),
          ),
          const SizedBox(height: 16),
          _InfoSectionCard(
            title: 'Resistencias e inmunidades',
            backgroundColor: sectionBackground,
            borderColor: sectionBorder,
            child: _TypeMatchupSection(
              matchups: pokemon.typeMatchups,
              formatLabel: formatLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _PokemonFutureTab extends StatelessWidget {
  const _PokemonFutureTab({
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
  Widget build(BuildContext context) {
    final padding = _responsiveDetailTabPadding(context);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoSectionCard(
            title: 'Movimientos',
            backgroundColor: sectionBackground,
            borderColor: sectionBorder,
            child: _MovesSection(
              moves: pokemon.moves,
              formatLabel: formatLabel,
            ),
          ),
          const SizedBox(height: 16),
          _InfoSectionCard(
            title: 'Cadena evolutiva',
            backgroundColor: sectionBackground,
            borderColor: sectionBorder,
            child: _EvolutionSection(
              evolutionChain: pokemon.evolutionChain,
              currentSpeciesId: pokemon.speciesId,
              formatLabel: formatLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _PokemonEvolutionTab extends StatelessWidget {
  const _PokemonEvolutionTab({
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
  Widget build(BuildContext context) {
    final padding = _responsiveDetailTabPadding(context);

    return Padding(
      padding: padding,
      child: _InfoSectionCard(
        title: 'Cadena evolutiva',
        backgroundColor: sectionBackground,
        borderColor: sectionBorder,
        child: _EvolutionSection(
          evolutionChain: pokemon.evolutionChain,
          currentSpeciesId: pokemon.speciesId,
          formatLabel: formatLabel,
        ),
      ),
    );
  }
}

class _PokemonMovesTab extends StatelessWidget {
  const _PokemonMovesTab({
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
  Widget build(BuildContext context) {
    final padding = _responsiveDetailTabPadding(context);

    return Padding(
      padding: padding,
      child: _InfoSectionCard(
        title: 'Movimientos',
        backgroundColor: sectionBackground,
        borderColor: sectionBorder,
        child: _MovesSection(
          moves: pokemon.moves,
          formatLabel: formatLabel,
        ),
      ),
    );
  }
}

Color _resolveStaticTypeColor(String type, ColorScheme colorScheme) {
  final color = pokemonTypeColors[type.toLowerCase()];
  return color ?? colorScheme.primary;
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

enum InfoSectionCardVariant { rounded, angled }

class _InfoSectionCard extends StatelessWidget {
  const _InfoSectionCard({
    required this.title,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.variant = InfoSectionCardVariant.rounded,
    this.padding,
  });

  final String title;
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final InfoSectionCardVariant variant;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardColor = backgroundColor ?? colorScheme.surfaceVariant.withOpacity(0.4);
    final outlineColor = borderColor ?? colorScheme.outline.withOpacity(0.12);
    final effectivePadding = padding ?? const EdgeInsets.all(20);
    final content = Padding(
      padding: effectivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: title),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );

    switch (variant) {
      case InfoSectionCardVariant.rounded:
        return Card(
          margin: EdgeInsets.zero,
          color: cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: BorderSide(color: outlineColor),
          ),
          child: content,
        );
      case InfoSectionCardVariant.angled:
        return ClipPath(
          clipper: const _AngledCardClipper(),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cardColor,
              border: Border.all(color: outlineColor),
            ),
            child: content,
          ),
        );
    }
  }
}

class _AngledCardClipper extends CustomClipper<Path> {
  const _AngledCardClipper();

  @override
  Path getClip(Size size) {
    const double cut = 26;
    return Path()
      ..moveTo(0, cut)
      ..quadraticBezierTo(0, 0, cut, 0)
      ..lineTo(size.width - cut, 0)
      ..quadraticBezierTo(size.width, 0, size.width, cut)
      ..lineTo(size.width, size.height - cut)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - cut,
        size.height,
      )
      ..lineTo(cut, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - cut)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _TypeLayout extends StatelessWidget {
  const _TypeLayout({
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
                childAspectRatio: 1.0, // Puedes ajustar esto si es necesario
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
                child: _CharacteristicTile(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MatchupHexGrid(
                        matchups: weaknesses,
                        formatLabel: widget.formatLabel,
                        category: _MatchupCategory.weakness,
                      ),
                      const SizedBox(height: 12),
                      const _MatchupLegend(
                        entries: [
                          _LegendEntry(
                            label: '4×',
                            description:
                                'Doble debilidad: el daño recibido se multiplica por cuatro.',
                            icon: Icons.local_fire_department,
                            colorRole: _LegendColorRole.critical,
                          ),
                          _LegendEntry(
                            label: '2×',
                            description:
                                'Debilidad clásica: ataques súper efectivos.',
                            icon: Icons.trending_up,
                            colorRole: _LegendColorRole.warning,
                          ),
                          _LegendEntry(
                            label: '1.5×',
                            description:
                                'Ventaja moderada: daño ligeramente incrementado.',
                            icon: Icons.bolt,
                            colorRole: _LegendColorRole.emphasis,
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

class _MatchupHexGrid extends StatelessWidget {
  const _MatchupHexGrid({
    required this.matchups,
    required this.formatLabel,
    required this.category,
  });

  final List<TypeMatchup> matchups;
  final String Function(String) formatLabel;
  final _MatchupCategory category;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = math.max(2, math.min(4, (width / 150).floor()));

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
          ),
          itemCount: matchups.length,
          itemBuilder: (context, index) {
            final matchup = matchups[index];
            return _MatchupHexCell(
              matchup: matchup,
              formatLabel: formatLabel,
              category: category,
            );
          },
        );
      },
    );
  }
}

class _MovesSection extends StatefulWidget {
  const _MovesSection({
    required this.moves,
    required this.formatLabel,
  });

  final List<PokemonMove> moves;
  final String Function(String) formatLabel;

  @override
  State<_MovesSection> createState() => _MovesSectionState();
}

class _MovesSectionState extends State<_MovesSection> {
  String? _selectedMethod;
  bool _onlyWithLevel = false;

  String _resolveDisplayName(String value) {
    if (value.isEmpty) {
      return 'Movimiento desconocido';
    }
    final lowercase = value.toLowerCase();
    if (value == lowercase) {
      return widget.formatLabel(value);
    }
    return value;
  }

  String _formatMethod(String method) {
    if (method.toLowerCase() == 'unknown') {
      return 'Desconocido';
    }
    return widget.formatLabel(method);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.moves.isEmpty) {
      return const Text('Sin información de movimientos disponible.');
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final methods = widget.moves
        .map((move) => move.method)
        .where((method) => method.isNotEmpty)
        .toSet()
        .toList()
      ..sort(
        (a, b) => widget.formatLabel(a).compareTo(widget.formatLabel(b)),
      );

    final filteredMoves = widget.moves.where((move) {
      if (_selectedMethod != null && move.method != _selectedMethod) {
        return false;
      }
      if (_onlyWithLevel && !move.hasLevel) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final levelA = a.level ?? 999;
        final levelB = b.level ?? 999;
        final levelComparison = levelA.compareTo(levelB);
        if (levelComparison != 0) {
          return levelComparison;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Todos'),
              selected: _selectedMethod == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedMethod = null);
                }
              },
            ),
            ...methods.map(
              (method) => ChoiceChip(
                label: Text(_formatMethod(method)),
                selected: _selectedMethod == method,
                onSelected: (selected) {
                  setState(() {
                    _selectedMethod = selected ? method : null;
                  });
                },
              ),
            ),
            FilterChip(
              label: const Text('Solo movimientos con nivel'),
              selected: _onlyWithLevel,
              onSelected: (selected) {
                setState(() => _onlyWithLevel = selected);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (filteredMoves.isEmpty)
          const Text('No hay movimientos que coincidan con los filtros.')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredMoves.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final move = filteredMoves[index];
              final typeKey = move.type?.toLowerCase() ?? '';
              final typeColor =
                  pokemonTypeColors[typeKey] ?? colorScheme.primary;
              final emoji = _typeEmojis[typeKey];
              final typeLabel = move.type == null || move.type!.isEmpty
                  ? '—'
                  : widget.formatLabel(move.type!);
              final methodLabel = _formatMethod(move.method);
              final versionLabel = move.versionGroup == null ||
                      move.versionGroup!.isEmpty
                  ? null
                  : widget.formatLabel(move.versionGroup!);

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: typeColor.withOpacity(0.28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (emoji != null) ...[
                          Text(emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            _resolveDisplayName(move.name),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            typeLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _MoveInfoChip(
                          icon: Icons.school_outlined,
                          label: methodLabel,
                        ),
                        _MoveInfoChip(
                          icon: Icons.trending_up,
                          label: move.hasLevel
                              ? 'Nivel ${move.level}'
                              : 'Sin nivel definido',
                        ),
                        if (versionLabel != null)
                          _MoveInfoChip(
                            icon: Icons.videogame_asset_outlined,
                            label: versionLabel,
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _EvolutionSection extends StatelessWidget {
  const _EvolutionSection({
    required this.evolutionChain,
    required this.currentSpeciesId,
    required this.formatLabel,
  });

  final PokemonEvolutionChain? evolutionChain;
  final int? currentSpeciesId;
  final String Function(String) formatLabel;

  /// Determines if the evolution chain represents a branching evolution pattern
  /// (like Eevee that evolves into multiple different Pokemon).
  /// 
  /// Returns true if:
  /// - There are multiple evolution paths
  /// - All paths share the same root Pokemon (they branch from one common ancestor)
  static bool _isBranchingEvolution(PokemonEvolutionChain chain) {
    // Check if there are multiple evolution paths (branching like Eevee)
    if (chain.paths.length <= 1 || chain.paths.isEmpty) {
      return false;
    }
    
    // Check if paths share a common root (branching from one Pokemon)
    if (chain.paths.first.isEmpty) {
      return false;
    }
    
    try {
      final firstRoot = chain.paths.first.first.speciesId;
      final allShareRoot = chain.paths.every(
        (path) => path.isNotEmpty && path.first.speciesId == firstRoot,
      );
      return allShareRoot;
    } on StateError catch (e) {
      // Catch StateError if list is empty when accessing .first
      if (kDebugMode) {
        debugPrint('[Evolution] Error detecting branching evolution (StateError): $e');
      }
      return false;
    } on RangeError catch (e) {
      // Catch RangeError if accessing an invalid index
      if (kDebugMode) {
        debugPrint('[Evolution] Error detecting branching evolution (RangeError): $e');
      }
      return false;
    } catch (e) {
      // Catch any other unexpected errors
      if (kDebugMode) {
        debugPrint('[Evolution] Unexpected error detecting branching evolution: $e');
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chain = evolutionChain;
    if (chain == null || chain.isEmpty) {
      return const Text('Sin información de evoluciones disponible.');
    }

    // Check if this is a branching evolution (like Eevee)
    if (_isBranchingEvolution(chain)) {
      return _BranchingEvolutionTree(
        chain: chain,
        currentSpeciesId: currentSpeciesId,
        formatLabel: formatLabel,
      );
    }

    // For linear evolutions, show them as horizontal paths
    return Column(
      children: chain.paths
          .map(
            (path) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _EvolutionPathRow(
                nodes: path,
                currentSpeciesId: currentSpeciesId,
                formatLabel: formatLabel,
              ),
            ),
          )
          .toList(),
    );
  }
}

/// Displays evolution chains in a tree structure for branching evolutions.
/// 
/// This widget is used when a Pokemon has multiple possible evolution paths,
/// like Eevee. It shows the base Pokemon at the top and all possible evolution
/// branches below in a grid or column layout depending on screen width.
/// 
/// Example for Eevee:
/// ```
///        Eevee
///          ↓
///    ┌─────┼─────┐
///    ↓     ↓     ↓
/// Vaporeon Jolteon Flareon ...
/// ```
class _BranchingEvolutionTree extends StatelessWidget {
  const _BranchingEvolutionTree({
    required this.chain,
    required this.currentSpeciesId,
    required this.formatLabel,
  });

  final PokemonEvolutionChain chain;
  final int? currentSpeciesId;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    if (chain.paths.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Get the base Pokemon (root of all paths)
    final basePokemon = chain.paths.first.first;
    
    // Get all evolution branches (skip the base Pokemon)
    final branches = chain.paths
        .map((path) => path.skip(1).toList())
        .where((branch) => branch.isNotEmpty)
        .toList();

    return Column(
      children: [
        // Base Pokemon at the top/center
        _EvolutionStageCard(
          node: basePokemon,
          isCurrent: currentSpeciesId != null &&
              currentSpeciesId == basePokemon.speciesId,
          formatLabel: formatLabel,
        ),
        
        if (branches.isNotEmpty) ...[
          const SizedBox(height: 16),
          
          // Branching indicator with animation
          _AnimatedEvolutionArrow(
            color: colorScheme.onSurfaceVariant.withOpacity(0.65),
            delay: const Duration(milliseconds: 200),
          ),
          
          const SizedBox(height: 16),
          
          // Show branches in a radial/grid layout with better visual flow
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final isWide = maxWidth > _wideScreenBreakpoint;
              
              // For many branches (>6, like Eevee with 8), use a compact layout
              final branchCount = branches.length;
              final useCompactLayout = branchCount > _compactLayoutThreshold;
              
              if (isWide) {
                // For wide screens, show branches in a radial-like grid
                return Wrap(
                  spacing: useCompactLayout ? _compactBranchSpacing : 16,
                  runSpacing: useCompactLayout ? 16 : _evolutionBranchSpacing,
                  alignment: WrapAlignment.center,
                  children: branches.map((branch) {
                    // Calculate width per column dynamically based on branch count
                    final effectiveColumns = useCompactLayout 
                        ? math.min(_maxCompactColumns, (branchCount / _compactColumnDivisor).ceil())
                        : _evolutionBranchGridColumns;
                    final widthPerColumn = maxWidth / effectiveColumns;
                    final nonNegativeWidth = math.max(0.0, widthPerColumn - (useCompactLayout ? _compactBranchSpacing : _evolutionBranchSpacing));
                    final branchWidth = math.min(
                      useCompactLayout ? _compactBranchMaxWidth : _evolutionBranchMaxWidth,
                      math.max(useCompactLayout ? _compactBranchMinWidth : _evolutionBranchMinWidth, nonNegativeWidth),
                    );
                    return SizedBox(
                      width: branchWidth,
                      child: _EvolutionBranch(
                        nodes: branch,
                        currentSpeciesId: currentSpeciesId,
                        formatLabel: formatLabel,
                        isCompact: useCompactLayout,
                      ),
                    );
                  }).toList(),
                );
              } else {
                // For narrow screens, show branches in a scrollable column
                return Column(
                  children: branches.map((branch) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _EvolutionBranch(
                        nodes: branch,
                        currentSpeciesId: currentSpeciesId,
                        formatLabel: formatLabel,
                        isCompact: useCompactLayout,
                      ),
                    );
                  }).toList(),
                );
              }
            },
          ),
        ],
      ],
    );
  }
}

/// Displays a single evolution branch (path from one Pokemon to another).
/// 
/// Used within [_BranchingEvolutionTree] to show individual evolution paths.
/// Each branch can contain multiple stages of evolution.
class _EvolutionBranch extends StatelessWidget {
  const _EvolutionBranch({
    required this.nodes,
    required this.currentSpeciesId,
    required this.formatLabel,
    this.isCompact = false,
  });

  final List<PokemonEvolutionNode> nodes;
  final int? currentSpeciesId;
  final String Function(String) formatLabel;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final arrowColor = theme.colorScheme.onSurfaceVariant.withOpacity(0.65);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < nodes.length; index++) ...[
          _EvolutionStageCard(
            node: nodes[index],
            isCurrent: currentSpeciesId != null &&
                currentSpeciesId == nodes[index].speciesId,
            formatLabel: formatLabel,
            isCompact: isCompact,
          ),
          if (index < nodes.length - 1)
            Padding(
              padding: EdgeInsets.symmetric(vertical: isCompact ? 6 : 8),
              child: _AnimatedEvolutionArrow(
                color: arrowColor,
                delay: Duration(milliseconds: 300 + (index * 200)),
              ),
            ),
        ],
      ],
    );
  }
}

/// Animated arrow widget to show evolution flow direction
class _AnimatedEvolutionArrow extends StatefulWidget {
  const _AnimatedEvolutionArrow({
    required this.color,
    this.delay = Duration.zero,
  });

  final Color color;
  final Duration delay;

  @override
  State<_AnimatedEvolutionArrow> createState() => _AnimatedEvolutionArrowState();
}

class _AnimatedEvolutionArrowState extends State<_AnimatedEvolutionArrow>
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _animation.value * 4),
            child: Opacity(
              opacity: 0.4 + (_animation.value * 0.6),
              child: Icon(
                Icons.arrow_downward_rounded,
                color: widget.color,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EvolutionPathColumn extends StatelessWidget {
  const _EvolutionPathColumn({
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

    final mediaWidth = MediaQuery.of(context).size.width;
    final double rawMaxWidth = mediaWidth < 480 ? mediaWidth - 64 : 260;
    final double maxWidth = rawMaxWidth.clamp(180.0, 320.0).toDouble();
    final theme = Theme.of(context);
    final arrowColor =
        theme.colorScheme.onSurfaceVariant.withOpacity(0.65);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 180,
        maxWidth: maxWidth,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < nodes.length; index++) ...[
            _EvolutionStageCard(
              node: nodes[index],
              isCurrent: currentSpeciesId != null &&
                  currentSpeciesId == nodes[index].speciesId,
              formatLabel: formatLabel,
            ),
            if (index < nodes.length - 1)
              _AnimatedEvolutionArrow(
                color: arrowColor,
                delay: Duration(milliseconds: 300 + (index * 200)),
              ),
          ],
        ],
      ),
    );
  }
}

/// Displays a single evolution path horizontally (for linear evolutions).
/// 
/// This widget is used for Pokemon that evolve in a straight line,
/// showing the evolution stages from left to right with arrows between them.
/// 
/// Example for Charmander:
/// ```
/// Charmander → Charmeleon → Charizard
/// ```
class _EvolutionPathRow extends StatelessWidget {
  const _EvolutionPathRow({
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

    // Use SingleChildScrollView to allow horizontal scrolling for long chains
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
              // Each evolution stage card
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: _horizontalEvolutionCardMinWidth,
                  maxWidth: math.min(
                    _horizontalEvolutionCardMaxWidth, 
                    math.max(_horizontalEvolutionCardMinWidth, (mediaWidth - _horizontalEvolutionPadding) / _horizontalEvolutionMaxStages),
                  ),
                ),
                child: _EvolutionStageCard(
                  node: nodes[index],
                  isCurrent: currentSpeciesId != null &&
                      currentSpeciesId == nodes[index].speciesId,
                  formatLabel: formatLabel,
                ),
              ),
              // Arrow between stages
              if (index < nodes.length - 1) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _AnimatedEvolutionArrowHorizontal(
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

/// Animated horizontal arrow widget to show evolution flow direction (left to right)
class _AnimatedEvolutionArrowHorizontal extends StatefulWidget {
  const _AnimatedEvolutionArrowHorizontal({
    required this.color,
    this.delay = Duration.zero,
  });

  final Color color;
  final Duration delay;

  @override
  State<_AnimatedEvolutionArrowHorizontal> createState() =>
      _AnimatedEvolutionArrowHorizontalState();
}

class _AnimatedEvolutionArrowHorizontalState
    extends State<_AnimatedEvolutionArrowHorizontal>
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
          offset: Offset(_animation.value * _horizontalArrowTranslationDistance, 0),
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

class _EvolutionStageCard extends StatefulWidget {
  const _EvolutionStageCard({
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
  State<_EvolutionStageCard> createState() => _EvolutionStageCardState();
}

class _EvolutionStageCardState extends State<_EvolutionStageCard>
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

    // Start animation after a short delay for staggered effect
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

    // Adjust sizes based on compact mode
    final imageSize = widget.isCompact 
        ? _evolutionCardImageSizeCompact 
        : _evolutionCardImageSizeNormal;
    final horizontalPadding = widget.isCompact 
        ? _evolutionCardHorizontalPaddingCompact 
        : _evolutionCardHorizontalPaddingNormal;
    final verticalPadding = widget.isCompact 
        ? _evolutionCardVerticalPaddingCompact 
        : _evolutionCardVerticalPaddingNormal;
    final borderRadius = widget.isCompact 
        ? _evolutionCardBorderRadiusCompact 
        : _evolutionCardBorderRadiusNormal;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
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
                imageUrl: widget.node.imageUrl,
                size: imageSize,
                borderRadius: widget.isCompact 
                    ? _evolutionCardImageBorderRadiusCompact 
                    : _evolutionCardImageBorderRadiusNormal,
                padding: EdgeInsets.all(widget.isCompact 
                    ? _evolutionCardImagePaddingCompact 
                    : _evolutionCardImagePaddingNormal),
                showShadow: false,
              ),
              SizedBox(height: widget.isCompact ? 8 : 12),
              Text(
                _resolveName(widget.node.name),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  fontSize: widget.isCompact ? _evolutionCardNameFontSizeCompact : null,
                ),
              ),
              SizedBox(height: widget.isCompact ? 6 : 8),
              if (widget.node.conditions.isEmpty)
                Text(
                  'Sin requisitos adicionales.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: subtitleColor,
                    fontSize: widget.isCompact ? _evolutionCardConditionFontSizeCompact : null,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.node.conditions
                      .map(
                        (condition) => Padding(
                          padding: EdgeInsets.symmetric(vertical: widget.isCompact ? 1 : 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: subtitleColor,
                                  fontSize: widget.isCompact ? _evolutionCardConditionDetailFontSizeCompact : null,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  condition,
                                  style:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    color: subtitleColor,
                                    fontSize: widget.isCompact ? _evolutionCardConditionDetailFontSizeCompact : null,
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
        ),
      ),
    );
  }
}

class _MoveInfoChip extends StatelessWidget {
  const _MoveInfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
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
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            softWrap: true,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AbilitiesCarousel extends StatefulWidget {
  const _AbilitiesCarousel({
    required this.abilities,
    required this.formatLabel,
  });

  final List<PokemonAbilityDetail> abilities;
  final String Function(String) formatLabel;

  @override
  State<_AbilitiesCarousel> createState() => _AbilitiesCarouselState();
}

class _AbilitiesCarouselState extends State<_AbilitiesCarousel> {
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
  void didUpdateWidget(_AbilitiesCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.abilities.length != widget.abilities.length) {
      // Only recreate if the number of abilities changed
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
    // Only update if constraint width changed significantly AND viewport fraction is different
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
        
        // Check if update is needed based on constraint width
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
                child: _AbilityTile(
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

class _AbilityTile extends StatelessWidget {
  const _AbilityTile({
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
            category: _MatchupCategory.resistance,
          ),
          if (immunities.isNotEmpty) const SizedBox(height: 12),
        ],
        if (immunities.isNotEmpty)
          _MatchupGroup(
            title: 'Inmunidades',
            matchups: immunities,
            formatLabel: formatLabel,
            category: _MatchupCategory.immunity,
          ),
        const SizedBox(height: 16),
        const _MatchupLegend(
          entries: [
            _LegendEntry(
              label: '0×',
              description: 'Sin efecto: el Pokémon es inmune a este tipo.',
              icon: Icons.block,
              colorRole: _LegendColorRole.emphasis,
            ),
            _LegendEntry(
              label: '0.25×',
              description:
                  'Resistencia doble: el daño recibido se reduce a la cuarta parte.',
              icon: Icons.shield,
              colorRole: _LegendColorRole.success,
            ),
            _LegendEntry(
              label: '0.5×',
              description:
                  'Resistencia clásica: el daño recibido se reduce a la mitad.',
              icon: Icons.shield_outlined,
              colorRole: _LegendColorRole.warning,
            ),
          ],
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
    required this.category,
  });

  final String title;
  final List<TypeMatchup> matchups;
  final String Function(String) formatLabel;
  final _MatchupCategory category;

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
        _MatchupHexGrid(
          matchups: matchups,
          formatLabel: formatLabel,
          category: category,
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

class _LegendEntry {
  const _LegendEntry({
    required this.label,
    required this.description,
    required this.icon,
    required this.colorRole,
  });

  final String label;
  final String description;
  final IconData icon;
  final _LegendColorRole colorRole;
}

enum _LegendColorRole { critical, warning, emphasis, success }

class _MatchupLegend extends StatelessWidget {
  const _MatchupLegend({required this.entries});

  final List<_LegendEntry> entries;

  Color _resolveColor(ColorScheme scheme, _LegendColorRole role) {
    switch (role) {
      case _LegendColorRole.critical:
        return scheme.error;
      case _LegendColorRole.warning:
        return scheme.tertiary;
      case _LegendColorRole.emphasis:
        return scheme.primary;
      case _LegendColorRole.success:
        return scheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: entries
          .map(
            (entry) {
              final color = _resolveColor(scheme, entry.colorRole);
              final background = Color.alphaBlend(
                color.withOpacity(0.14),
                scheme.surface.withOpacity(0.92),
              );
              return Tooltip(
                message: entry.description,
                waitDuration: const Duration(milliseconds: 200),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(entry.icon, size: 16, color: color),
                      const SizedBox(width: 6),
                      Text(
                        entry.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
          .toList(),
    );
  }
}

enum _MatchupCategory { weakness, resistance, immunity }

class _MatchupHexCell extends StatelessWidget {
  const _MatchupHexCell({
    required this.matchup,
    required this.formatLabel,
    required this.category,
  });

  final TypeMatchup matchup;
  final String Function(String) formatLabel;
  final _MatchupCategory category;

  double _scaleForMultiplier(double multiplier) {
    switch (category) {
      case _MatchupCategory.weakness:
        final normalized = (multiplier - 1).clamp(0.0, 3.5);
        return 1 + normalized * 0.12;
      case _MatchupCategory.resistance:
        final normalized = (1 - multiplier).clamp(0.0, 1.0);
        return 1 + normalized * 0.12;
      case _MatchupCategory.immunity:
        return 1.18;
    }
  }

  IconData _iconForMultiplier(double multiplier) {
    switch (category) {
      case _MatchupCategory.weakness:
        return multiplier >= 4 ? Icons.local_fire_department : Icons.trending_up;
      case _MatchupCategory.resistance:
        return Icons.shield_outlined;
      case _MatchupCategory.immunity:
        return Icons.block;
    }
  }

  String _tooltipForMatchup(String label, double multiplier) {
    final formatted = _formatMultiplier(multiplier);
    switch (category) {
      case _MatchupCategory.weakness:
        return '$label recibe $formatted de daño: procura evitar este tipo.';
      case _MatchupCategory.resistance:
        return '$label causa $formatted de daño: es una buena cobertura defensiva.';
      case _MatchupCategory.immunity:
        return '$label no afecta a este Pokémon.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final typeKey = matchup.type.toLowerCase();
    final typeColor = pokemonTypeColors[typeKey] ?? scheme.primary;
    final emoji = _typeEmojis[typeKey];
    final label = formatLabel(matchup.type);
    final scale = _scaleForMultiplier(matchup.multiplier);
    final tooltip = _tooltipForMatchup(label, matchup.multiplier);

    final background = Color.alphaBlend(
      typeColor.withOpacity(0.14),
      scheme.surface.withOpacity(0.94),
    );

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 200),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: _HexagonContainer(
          color: typeColor,
          background: background,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (emoji != null) ...[
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              _MultiplierBadge(
                multiplier: matchup.multiplier,
                icon: _iconForMultiplier(matchup.multiplier),
                color: typeColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HexagonContainer extends StatelessWidget {
  const _HexagonContainer({
    required this.child,
    required this.color,
    required this.background,
  });

  final Widget child;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _HexagonClipper(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: color.withOpacity(0.55), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 14,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: child,
        ),
      ),
    );
  }
}

class _HexagonClipper extends CustomClipper<Path> {
  const _HexagonClipper();

  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final verticalInset = height * 0.25;

    return Path()
      ..moveTo(width / 2, 0)
      ..lineTo(width, verticalInset)
      ..lineTo(width, height - verticalInset)
      ..lineTo(width / 2, height)
      ..lineTo(0, height - verticalInset)
      ..lineTo(0, verticalInset)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _MultiplierBadge extends StatelessWidget {
  const _MultiplierBadge({
    required this.multiplier,
    required this.icon,
    required this.color,
  });

  final double multiplier;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final background = Color.alphaBlend(
      color.withOpacity(0.18),
      scheme.surface.withOpacity(0.92),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.withOpacity(0.9)),
          const SizedBox(width: 6),
          Text(
            _formatMultiplier(multiplier),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
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
          SizedBox(
            height: 28,
            child: Row(
              children: [
                for (var i = 0; i < 10; i++) ...[
                  Expanded(
                    child: _StatSegment(
                      fill: (normalized * 10) - i,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (i != 9) const SizedBox(width: 4),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatSegment extends StatelessWidget {
  const _StatSegment({required this.fill, required this.color});

  final double fill;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedFill = fill.clamp(0.0, 1.0);
    final brightness = theme.colorScheme.brightness == Brightness.dark
        ? Colors.white
        : theme.colorScheme.onPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FractionallySizedBox(
            widthFactor: clampedFill,
            alignment: Alignment.centerLeft,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.85),
                    color,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              opacity: clampedFill >= 0.95
                  ? 1
                  : clampedFill > 0.4
                      ? 0.7
                      : 0.25,
              child: Icon(
                Icons.catching_pokemon,
                size: 16,
                color: clampedFill > 0
                    ? brightness.withOpacity(0.9)
                    : color.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PokemonDetailErrorView extends StatelessWidget {
  const _PokemonDetailErrorView({this.onRetry});

  final Future<QueryResult<Object?>?> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final retry = onRetry;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'No se pudo obtener los datos del Pokémon.\nVerifica tu conexión o intenta de nuevo.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (retry != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () async {
                  try {
                    await retry();
                  } catch (error, stackTrace) {
                    debugPrint('Error al reintentar la carga: $error');
                    debugPrint('$stackTrace');
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
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
