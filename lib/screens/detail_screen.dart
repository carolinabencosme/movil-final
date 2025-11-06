import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/pokemon_model.dart';
import '../queries/get_pokemon_details.dart';
import '../theme/pokemon_type_colors.dart';
import '../widgets/detail/animations/particle_field.dart';
import '../widgets/detail/detail_constants.dart';
import '../widgets/detail/detail_helper_widgets.dart';
import '../widgets/detail/tabs/detail_tabs.dart';
import '../widgets/pokemon_artwork.dart';

/// Detail screen showing comprehensive Pokemon information
class DetailScreen extends StatelessWidget {
  /// Constructor que requiere al menos el ID o nombre del Pokémon
  DetailScreen({
    super.key,
    this.pokemonId,
    this.pokemonName,
    this.initialPokemon,
    this.heroTag,
  }) : assert(
          pokemonId != null || (pokemonName != null && pokemonName.isNotEmpty),
          'Either pokemonId or pokemonName must be provided.',
        );

  /// ID numérico del Pokémon (ej: 1 para Bulbasaur)
  final int? pokemonId;
  
  /// Nombre del Pokémon (ej: "pikachu")
  final String? pokemonName;
  
  /// Datos iniciales del Pokémon para mostrar mientras se carga la información completa
  final PokemonListItem? initialPokemon;
  
  /// Tag único para la animación Hero entre pantallas
  final String? heroTag;

  /// Capitaliza la primera letra de un texto
  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedHeroTag =
        heroTag ?? 'pokemon-artwork-${pokemonId ?? pokemonName ?? 'unknown'}';
    final previewName = initialPokemon != null
        ? _capitalize(initialPokemon!.name)
        : (pokemonName != null ? _capitalize(pokemonName!) : null);
    final previewImage = initialPokemon?.imageUrl ?? '';
    final where = pokemonId != null
        ? <String, dynamic>{'id': {'_eq': pokemonId}}
        : <String, dynamic>{'name': {'_eq': pokemonName!}};

    return Scaffold(
      appBar: AppBar(
        title: Text(previewName ?? 'Detalles del Pokémon'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(getPokemonDetailsQuery),
          fetchPolicy: FetchPolicy.cacheAndNetwork,
          errorPolicy: ErrorPolicy.all,
          variables: {
            'where': where,
            'languageIds': preferredLanguageIds,
          },
        ),
        builder: (result, {fetchMore, refetch}) {
          if (kDebugMode) {
            debugPrint('[Pokemon Detail] Query result - isLoading: ${result.isLoading}, hasException: ${result.hasException}');
            debugPrint('[Pokemon Detail] Available data keys: ${result.data?.keys.toList()}');
            if (result.hasException) {
              debugPrint('[Pokemon Detail] Exception details: ${result.exception}');
            }
          }
          
          final pokemonList = result.data?['pokemon_v2_pokemon'] as List<dynamic>?;
          final data = (pokemonList?.isNotEmpty ?? false)
              ? pokemonList?.first as Map<String, dynamic>?
              : null;

          if (result.isLoading && data == null) {
            return LoadingDetailView(
              heroTag: resolvedHeroTag,
              imageUrl: previewImage,
              name: previewName,
            );
          }

          if (result.hasException && data == null) {
            debugPrint(
              'Error al cargar el detalle del Pokémon: ${result.exception}',
            );
            return PokemonDetailErrorView(
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
                      PokemonDetailBody(
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

/// Main body widget for Pokemon detail screen
class PokemonDetailBody extends StatefulWidget {
  const PokemonDetailBody({
    super.key,
    required this.pokemon,
    required this.resolvedHeroTag,
    required this.capitalize,
  });

  /// Datos completos del Pokémon a mostrar
  final PokemonDetail pokemon;
  
  /// Tag para la animación Hero (único por Pokémon)
  final String resolvedHeroTag;
  
  /// Función para capitalizar textos
  final String Function(String) capitalize;

  @override
  State<PokemonDetailBody> createState() => _PokemonDetailBodyState();
}

class _PokemonDetailBodyState extends State<PokemonDetailBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Inicializa controladores para las 5 pestañas
    _tabController = TabController(length: 5, vsync: this);
    _pageController = PageController();
    
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

  /// Formatea la altura del Pokémon de decímetros a metros
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
    final color = pokemonTypeColors[type.toLowerCase()];
    return color ?? colorScheme.primary;
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
                      backgroundTextureSvg,
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
                    child: ParticleField(
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
                    shadows: [
                      Shadow(
                        color: typeColor.withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: PokemonArtwork(
                    heroTag: widget.resolvedHeroTag,
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
        tabs: detailTabConfigs
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

    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = 48.0 + mediaQuery.padding.bottom + mediaQuery.viewInsets.bottom;

    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundTint),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RepaintBoundary(
            child: _buildHeroHeader(
              context: context,
              theme: theme,
              pokemon: pokemon,
              typeColor: typeColor,
              onTypeColor: onTypeColor,
            ),
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
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: EdgeInsets.only(top: 24, bottom: bottomPadding),
                  child: PokemonInfoTab(
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
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: EdgeInsets.only(top: 24, bottom: bottomPadding),
                  child: PokemonStatsTab(
                    pokemon: pokemon,
                    formatLabel: _formatLabel,
                    sectionBackground: sectionBackground,
                    sectionBorder: sectionBorder,
                  ),
                ),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: EdgeInsets.only(top: 24, bottom: bottomPadding),
                  child: PokemonMatchupsTab(
                    pokemon: pokemon,
                    formatLabel: _formatLabel,
                    sectionBackground: sectionBackground,
                    sectionBorder: sectionBorder,
                  ),
                ),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: EdgeInsets.only(top: 24, bottom: bottomPadding),
                  child: PokemonEvolutionTab(
                    pokemon: pokemon,
                    formatLabel: _formatLabel,
                    sectionBackground: sectionBackground,
                    sectionBorder: sectionBorder,
                  ),
                ),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: EdgeInsets.only(top: 24, bottom: bottomPadding),
                  child: PokemonMovesTab(
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

/// Extension for context navigation
extension DetailScreenNavigationX on BuildContext {
  Future<T?> push<T>(String location) {
    if (location.startsWith('/pokedex/')) {
      final slug = location.substring('/pokedex/'.length);
      final speciesId = pendingEvolutionNavigation.remove(slug);
      return Navigator.of(this).push<T>(
        MaterialPageRoute<T>(
          builder: (_) => DetailScreen(
            pokemonId: speciesId,
            pokemonName: slug,
            heroTag: speciesId != null
                ? 'pokemon-artwork-$speciesId'
                : 'pokemon-artwork-$slug',
          ),
        ),
      );
    }
    return Navigator.of(this).pushNamed<T>(location);
  }
}
