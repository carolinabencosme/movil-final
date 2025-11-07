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

/// ===============================
/// DETAIL SCREEN (CONTENEDOR)
/// ===============================
/// Pantalla de detalles que muestra información completa de un Pokémon:
/// - Hero artwork + cabecera colapsable con Slivers
/// - Tabs con secciones (Info, Stats, Matchups, Evolución, Movimientos)
/// - Carga de datos con GraphQL: manejo de loading, error y datos parciales
/// - Pull-to-refresh (refetch)
class DetailScreen extends StatelessWidget {
  /// Requiere `pokemonId` o `pokemonName`. Si llega `initialPokemon`, se usa como preview.
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

  /// ID del Pokémon (National Dex)
  final int? pokemonId;

  /// Nombre del Pokémon (slug en minúsculas)
  final String? pokemonName;

  /// Datos mínimos para render inmediato mientras llega el detalle completo
  final PokemonListItem? initialPokemon;

  /// Tag único para transición Hero del artwork
  final String? heroTag;

  /// Capitaliza primera letra (para títulos bonitos)
  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    // HeroTag estable incluso si entra por id o name
    final resolvedHeroTag =
        heroTag ?? 'pokemon-artwork-${pokemonId ?? pokemonName ?? 'unknown'}';

    // Nombre e imagen para el “skeleton/preview” antes del GraphQL completo
    final previewName = initialPokemon != null
        ? _capitalize(initialPokemon!.name)
        : (pokemonName != null ? _capitalize(pokemonName!) : null);
    final previewImage = initialPokemon?.imageUrl ?? '';

    // Filtro dinámico para GraphQL (por id o por name)
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
          fetchPolicy: FetchPolicy.cacheAndNetwork, // cache first -> network
          errorPolicy: ErrorPolicy.all, // permite datos parciales
          variables: {
            'where': where,
            'languageIds': preferredLanguageIds, // EN/ES típicamente [7,9]
          },
        ),
        builder: (result, {fetchMore, refetch}) {
          // Logs de depuración (solo en debug)
          if (kDebugMode) {
            debugPrint(
                '[Pokemon Detail] Query result - isLoading: ${result.isLoading}, hasException: ${result.hasException}');
            debugPrint(
                '[Pokemon Detail] Available data keys: ${result.data?.keys.toList()}');
            if (result.hasException) {
              debugPrint('[Pokemon Detail] Exception details: ${result.exception}');
            }
          }

          // Tomamos el primer Pokémon que cumpla el where
          final pokemonList = result.data?['pokemon_v2_pokemon'] as List<dynamic>?;
          final data = (pokemonList?.isNotEmpty ?? false)
              ? pokemonList?.first as Map<String, dynamic>?
              : null;

          // 1) Carga inicial sin cache → vista de loading personalizada
          if (result.isLoading && data == null) {
            return LoadingDetailView(
              heroTag: resolvedHeroTag,
              imageUrl: previewImage,
              name: previewName,
            );
          }

          // 2) Error sin datos → estado de error con retry
          if (result.hasException && data == null) {
            debugPrint(
              'Error al cargar el detalle del Pokémon: ${result.exception}',
            );
            return PokemonDetailErrorView(
              onRetry: refetch,
            );
          }

          // 3) Sin datos (no encontró) → mensaje + botón para reintentar
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

          // 4) Datos parciales con error → seguimos mostrando lo que hay
          if (result.hasException) {
            debugPrint(
              'Se recibieron datos parciales con errores: ${result.exception}',
            );
          }

          // Eficacias de tipo para calcular matchups (deb/resist/inmunidad)
          final typeEfficacies =
              result.data?['type_efficacy'] as List<dynamic>? ?? [];

          // Parse a modelo de dominio completo
          final pokemon = PokemonDetail.fromGraphQL(
            data,
            typeEfficacies: typeEfficacies,
          );

          // Pull-to-refresh que llama refetch()
          return RefreshIndicator(
            onRefresh: () async {
              await refetch?.call();
            },
            child: SafeArea(
              child: Builder(
                builder: (context) {
                  return Stack(
                    children: [
                      // Cuerpo con NestedScrollView + Slivers + TabBar/TabBarView
                      PokemonDetailBody(
                        pokemon: pokemon,
                        resolvedHeroTag: resolvedHeroTag,
                        capitalize: _capitalize,
                      ),
                      // Barra de progreso fina cuando llegan actualizaciones
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

/// ===============================
/// DETAIL BODY (LAYOUT + TABS)
/// ===============================
/// Orquesta:
/// - Cabecera hero colapsable (SliverPersistentHeader)
/// - TabBar "sticky" (SliverPersistentHeader pinned)
/// - TabBarView con 5 secciones
class PokemonDetailBody extends StatefulWidget {
  const PokemonDetailBody({
    super.key,
    required this.pokemon,
    required this.resolvedHeroTag,
    required this.capitalize,
  });

  /// Modelo completo del Pokémon (tipos, stats, habilidades, evolución, etc.)
  final PokemonDetail pokemon;

  /// Tag del Hero del artwork (debe matchear con la lista)
  final String resolvedHeroTag;

  /// Helper para capitalizar strings
  final String Function(String) capitalize;

  @override
  State<PokemonDetailBody> createState() => _PokemonDetailBodyState();
}

class _PokemonDetailBodyState extends State<PokemonDetailBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 5 pestañas: Info, Stats, Matchups, Evolución, Movimientos
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// ============ Helpers de formato ============

  /// Decímetros → metros con formato amigable
  String _formatHeight(int height) {
    if (height <= 0) return '—';
    final meters = height / 10.0;
    return '${_stripTrailingZeros(meters)} m';
  }

  /// Hectogramos → kilogramos con formato amigable
  String _formatWeight(int weight) {
    if (weight <= 0) return '—';
    final kilograms = weight / 10.0;
    return '${_stripTrailingZeros(kilograms)} kg';
  }

  /// Evita “2.00” → “2” y “10.50” → “10.5”
  String _stripTrailingZeros(double value) {
    final fixed = value.toStringAsFixed(value >= 10 ? 1 : 2);
    return fixed
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// “special-attack” → “Special attack”
  String _formatLabel(String value) {
    if (value.isEmpty) {
      return value;
    }
    final sanitized = value.replaceAll('-', ' ');
    return widget.capitalize(sanitized);
  }

  /// Colores por tipo (fallback al primary si no existe mapping)
  Color _resolveTypeColor(String type, ColorScheme colorScheme) {
    final color = pokemonTypeColors[type.toLowerCase()];
    return color ?? colorScheme.primary;
  }

  /// Construye SliverPersistentHeader con cabecera hero colapsable
  SliverPersistentHeader _buildHeroHeader({
    required BuildContext context,
    required ThemeData theme,
    required PokemonDetail pokemon,
    required Color typeColor,
    required Color onTypeColor,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // Alturas mínima y máxima (ajustadas a orientación y alto de pantalla)
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

    return SliverPersistentHeader(
      pinned: false, // no queda fija; se desplaza con el scroll
      delegate: _HeroHeaderDelegate(
        pokemon: pokemon,
        theme: theme,
        typeColor: typeColor,
        onTypeColor: onTypeColor,
        heroTag: widget.resolvedHeroTag,
        expandedHeight: headerHeight,
        collapsedHeight: collapsedHeight,
        capitalize: widget.capitalize,
      ),
    );
  }

  /// SliverPersistentHeader con TabBar “sticky” (pinned)
  SliverPersistentHeader _buildTabBar(
      ThemeData theme,
      Color typeColor,
      ) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarHeaderDelegate(
        tabController: _tabController,
        theme: theme,
        typeColor: typeColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pokemon = widget.pokemon;

    // Habilidad “principal” para mostrar en el bloque de info
    final mainAbilityDetail =
    pokemon.abilities.isNotEmpty ? pokemon.abilities.first : null;
    final mainAbility =
    mainAbilityDetail != null ? _formatLabel(mainAbilityDetail.name) : null;
    final abilitySubtitle = mainAbilityDetail == null
        ? null
        : (mainAbilityDetail.isHidden ? 'Habilidad oculta' : 'Habilidad principal');

    // Paleta reactiva según el primer tipo del Pokémon
    final colorScheme = theme.colorScheme;
    final typeColor = pokemon.types.isNotEmpty
        ? _resolveTypeColor(pokemon.types.first, colorScheme)
        : colorScheme.primary;
    final onTypeColor =
    ThemeData.estimateBrightnessForColor(typeColor) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    // Colores de fondo secciones (tintes del color de tipo)
    final backgroundTint =
    Color.alphaBlend(typeColor.withOpacity(0.04), colorScheme.surface);
    final sectionBackground =
    Color.alphaBlend(typeColor.withOpacity(0.08), colorScheme.surfaceVariant);
    final sectionBorder = typeColor.withOpacity(0.25);

    // Padding inferior para evitar solapamiento con gestos/teclado
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = 48.0 + mediaQuery.padding.bottom + mediaQuery.viewInsets.bottom;

    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundTint),
      child: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          final overlapHandle =
          NestedScrollView.sliverOverlapAbsorberHandleFor(context);
          return [
            // Absorbe el solapamiento entre header y body dentro del NestedScroll
            SliverOverlapAbsorber(
              handle: overlapHandle,
              sliver: _buildHeroHeader(
                context: context,
                theme: theme,
                pokemon: pokemon,
                typeColor: typeColor,
                onTypeColor: onTypeColor,
              ),
            ),
            _buildTabBar(theme, typeColor),
          ];
        },
        // Contenido de cada tab
        body: TabBarView(
          controller: _tabController,
          physics: const BouncingScrollPhysics(),
          children: [
            _DetailTabScrollView(
              storageKey: const PageStorageKey('info-tab'),
              topPadding: 24,
              bottomPadding: bottomPadding,
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
            _DetailTabScrollView(
              storageKey: const PageStorageKey('stats-tab'),
              topPadding: 24,
              bottomPadding: bottomPadding,
              child: PokemonStatsTab(
                pokemon: pokemon,
                formatLabel: _formatLabel,
                sectionBackground: sectionBackground,
                sectionBorder: sectionBorder,
              ),
            ),
            _DetailTabScrollView(
              storageKey: const PageStorageKey('matchups-tab'),
              topPadding: 24,
              bottomPadding: bottomPadding,
              child: PokemonMatchupsTab(
                pokemon: pokemon,
                formatLabel: _formatLabel,
                sectionBackground: sectionBackground,
                sectionBorder: sectionBorder,
              ),
            ),
            _DetailTabScrollView(
              storageKey: const PageStorageKey('evolution-tab'),
              topPadding: 24,
              bottomPadding: bottomPadding,
              child: PokemonEvolutionTab(
                pokemon: pokemon,
                formatLabel: _formatLabel,
                sectionBackground: sectionBackground,
                sectionBorder: sectionBorder,
              ),
            ),
            _DetailTabScrollView(
              storageKey: const PageStorageKey('moves-tab'),
              topPadding: 24,
              bottomPadding: bottomPadding,
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
    );
  }
}

/// ===============================
/// CABECERA HERO (SLIVER DELEGATE)
/// ===============================
/// Dibuja el header colapsable con:
/// - Gradientes de fondo + textura SVG + blur + partículas
/// - Título animado
/// - Hero del artwork (PokemonArtwork)
class _HeroHeaderDelegate extends SliverPersistentHeaderDelegate {
  _HeroHeaderDelegate({
    required this.pokemon,
    required this.theme,
    required this.typeColor,
    required this.onTypeColor,
    required this.heroTag,
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.capitalize,
  });

  final PokemonDetail pokemon;
  final ThemeData theme;
  final Color typeColor;
  final Color onTypeColor;
  final String heroTag;
  final double expandedHeight;
  final double collapsedHeight;
  final String Function(String) capitalize;

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    // Progreso de colapso [0..1]
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    // Al colapsar: baja opacidad de fondos/partículas/título e imagen escala
    final backgroundOpacity = 1 - (0.25 * progress);
    final particleOpacity = 0.55 * (1 - (0.5 * progress));
    final titleOpacity = 1 - (0.35 * progress);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12 - (8 * progress), 16, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Tamaño base del artwork relativo al espacio disponible
          final imageBaseSize = math.min(
            210.0,
            math.min(constraints.maxWidth, maxExtent) * 0.55,
          );
          final imageScale = 1 - (0.25 * progress);
          final imageSize = imageBaseSize * imageScale;

          return ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // Fondo gradiente vertical (tipo → surface)
                Positioned.fill(
                  child: Opacity(
                    opacity: backgroundOpacity,
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
                ),
                // Radial highlight para dar profundidad
                Positioned.fill(
                  child: Opacity(
                    opacity: backgroundOpacity,
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
                ),
                // Textura SVG tenue (decorativo)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.35 * (1 - (0.5 * progress)),
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
                // Blur suave para efecto “vidrioso”
                Positioned.fill(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaX: 18,
                        sigmaY: 18,
                      ),
                      child: Container(
                        color: typeColor.withOpacity(0.08 * (1 - (0.4 * progress))),
                      ),
                    ),
                  ),
                ),
                // Partículas sutiles encima
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: particleOpacity,
                      child: ParticleField(
                        color: onTypeColor.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
                // Título centrado que se desvanece al colapsar
                Positioned(
                  left: 24,
                  right: 24,
                  top: 24 - (12 * progress),
                  child: Opacity(
                    opacity: titleOpacity,
                    child: Text(
                      capitalize(pokemon.name),
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
                ),
                // Hero del artwork: escalado según el colapso
                Positioned(
                  bottom: 20 - (12 * progress),
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Transform.scale(
                      scale: imageScale,
                      child: PokemonArtwork(
                        heroTag: heroTag,
                        imageUrl: pokemon.imageUrl,
                        size: imageSize,
                        borderRadius: 36,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16 - (6 * progress),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HeroHeaderDelegate oldDelegate) {
    // Rebuild si cambian inputs críticos (evita repaints innecesarios)
    return oldDelegate.pokemon != pokemon ||
        oldDelegate.theme != theme ||
        oldDelegate.typeColor != typeColor ||
        oldDelegate.onTypeColor != onTypeColor ||
        oldDelegate.heroTag != heroTag ||
        oldDelegate.expandedHeight != expandedHeight ||
        oldDelegate.collapsedHeight != collapsedHeight;
  }
}

/// ===============================
/// TABBAR HEADER (SLIVER DELEGATE)
/// ===============================
/// Cabecera “pinned” con TabBar estilizada que flota sobre el contenido.
class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TabBarHeaderDelegate({
    required this.tabController,
    required this.theme,
    required this.typeColor,
  });

  final TabController tabController;
  final ThemeData theme;
  final Color typeColor;

  static const double _tabHeight = 68;
  static const double _tabPadding = 12; // TabBar padding top+bottom

  @override
  double get minExtent => _tabHeight + _tabPadding + 8;

  @override
  double get maxExtent => _tabHeight + _tabPadding + 16;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final topMargin = 16 - (8 * progress);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, topMargin, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            typeColor.withOpacity(0.08),
            theme.colorScheme.surface,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: typeColor.withOpacity(0.18), width: 1),
          boxShadow: overlapsContent
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: TabBar(
          controller: tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          indicator: BoxDecoration(
            color: typeColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          labelColor: theme.colorScheme.onSurface,
          unselectedLabelColor:
          theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
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
          // Usa la configuración compartida de tabs (icono + etiqueta)
          tabs: detailTabConfigs
              .map(
                (config) => Tab(
              icon: Icon(config.icon, size: 20),
              text: config.label,
              height: _tabHeight,
            ),
          )
              .toList(),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarHeaderDelegate oldDelegate) {
    return oldDelegate.tabController != tabController ||
        oldDelegate.theme != theme ||
        oldDelegate.typeColor != typeColor;
  }
}

/// ===============================
/// CONTENEDOR SCROLL POR TAB
/// ===============================
/// Envuelve cada contenido de Tab en un CustomScrollView que
/// inyecta el solapamiento correcto con el header del NestedScrollView.
class _DetailTabScrollView extends StatelessWidget {
  const _DetailTabScrollView({
    required this.child,
    required this.topPadding,
    required this.bottomPadding,
    this.storageKey,
  });

  final Widget child;
  final double topPadding;
  final double bottomPadding;

  /// PageStorageKey para mantener el scroll por pestaña
  final PageStorageKey<String>? storageKey;

  @override
  Widget build(BuildContext context) {
    final overlapHandle =
    NestedScrollView.sliverOverlapAbsorberHandleFor(context);
    return CustomScrollView(
      key: storageKey,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Inserta el espacio ocupado por el header para que el contenido no quede tapado
        SliverOverlapInjector(handle: overlapHandle),
        SliverPadding(
          padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
          sliver: SliverToBoxAdapter(child: child),
        ),
      ],
    );
  }
}

/// ===============================
/// EXTENSION DE NAVEGACIÓN
/// ===============================
/// Permite navegar a detalles usando rutas tipo `/pokedex/<slug>`.
/// Si existe un `pendingEvolutionNavigation[slug]`, lo usa como `pokemonId`
/// para construir el DetailScreen (mejorando la navegación desde la evolución).
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
