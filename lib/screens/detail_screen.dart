import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../features/locations/screens/locations_tab.dart';
import '../features/share/services/card_capture_service.dart';
import '../features/share/widgets/pokemon_share_card.dart';
import '../providers/favorites_provider.dart';
import '../controllers/favorites_controller.dart';
import '../models/pokemon_model.dart';
import '../queries/get_pokemon_details.dart';
import '../theme/pokemon_type_colors.dart';
import '../widgets/detail/animations/particle_field.dart';
import '../widgets/detail/detail_constants.dart';
import '../widgets/detail/detail_helper_widgets.dart';
import '../widgets/detail/tabs/detail_tabs.dart';
import '../widgets/pokemon_artwork.dart';
import '../services/pokemon_cache_service.dart';

/// ===============================
/// DETAIL SCREEN (CONTENEDOR)
/// ===============================
/// Pantalla de detalles que muestra información completa de un Pokémon:
/// - Hero artwork + cabecera colapsable con Slivers
/// - Tabs con secciones (Info, Stats, Matchups, Evolución, Movimientos)
/// - Carga de datos con GraphQL: manejo de loading, error y datos parciales
/// - Pull-to-refresh (refetch)
class DetailScreen extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  bool _isOfflineMode = false;
  bool _offlineSnackShown = false;
  bool _hasConnection = true;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  PokemonCacheService get _pokemonCacheService => PokemonCacheService.instance;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final bool hasConnection =
          results.any((status) => status != ConnectivityResult.none);
      if (!mounted || hasConnection == _hasConnection) {
        return;
      }
      setState(() {
        _hasConnection = hasConnection;
      });
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _updateOfflineMode(!hasConnection),
      );
    });
  }

  Future<void> _initializeConnectivity() async {
    final List<ConnectivityResult> results =
        await _connectivity.checkConnectivity();
    if (!mounted) return;
    final bool hasConnection =
        results.any((status) => status != ConnectivityResult.none);
    if (hasConnection != _hasConnection) {
      setState(() {
        _hasConnection = hasConnection;
      });
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _updateOfflineMode(!hasConnection),
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  /// Muestra el diálogo para compartir la tarjeta del Pokémon
  void _showShareDialog(BuildContext context, PokemonDetail pokemon) {
    final theme = Theme.of(context);
    final typeColor = pokemon.types.isNotEmpty
        ? (pokemonTypeColors[pokemon.types.first.toLowerCase()] ??
            theme.colorScheme.primary)
        : theme.colorScheme.primary;

    showDialog(
      context: context,
      builder: (dialogContext) => _ShareCardDialog(
        pokemon: pokemon,
        themeColor: typeColor,
      ),
    );
  }

  void _updateOfflineMode(bool offline) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    if (offline) {
      if (!_isOfflineMode) {
        setState(() {
          _isOfflineMode = true;
        });
      }
      if (!_offlineSnackShown) {
        _showSnack(
          l10n.detailOfflineModeSnack,
        );
        _offlineSnackShown = true;
      }
    } else {
      if (_isOfflineMode) {
        setState(() {
          _isOfflineMode = false;
        });
      }
      if (_offlineSnackShown) {
        _showSnack(l10n.detailConnectionRestored);
        _offlineSnackShown = false;
      }
    }
  }

  void _showSnack(String message) {
    if (!mounted || message.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  PokemonListItem? _resolveOfflinePokemon(
    FavoritesController favoritesController,
  ) {
    if (widget.initialPokemon != null) {
      return favoritesController.applyFavoriteState(widget.initialPokemon!);
    }
    if (widget.pokemonId != null) {
      final int id = widget.pokemonId!;
      final PokemonListItem? cached =
          favoritesController.getCachedPokemon(id) ??
              _pokemonCacheService.getPokemon(id);
      if (cached != null) {
        return favoritesController.applyFavoriteState(cached);
      }
    } else if (widget.pokemonName != null) {
      final PokemonListItem? fromService =
          _pokemonCacheService.findByName(widget.pokemonName!);
      if (fromService != null) {
        return favoritesController.applyFavoriteState(fromService);
      }
    }
    return null;
  }

  Widget _buildOfflineBanner(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final Color backgroundColor =
        theme.colorScheme.surfaceVariant.withOpacity(0.9);
    final Color foregroundColor = theme.colorScheme.onSurfaceVariant;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: foregroundColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.detailOfflineBanner,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favoritesController = ref.watch(favoritesControllerProvider);

    final resolvedHeroTag = widget.heroTag ??
        'pokemon-artwork-${widget.pokemonId ?? widget.pokemonName ?? 'unknown'}';

    final previewName = widget.initialPokemon != null
        ? _capitalize(widget.initialPokemon!.name)
        : (widget.pokemonName != null
            ? _capitalize(widget.pokemonName!)
            : null);
    final previewImage = widget.initialPokemon?.imageUrl ?? '';

    final where = widget.pokemonId != null
        ? <String, dynamic>{'id': {'_eq': widget.pokemonId}}
        : <String, dynamic>{'name': {'_eq': widget.pokemonName!}};

    PokemonListItem? cachedInitial;
    if (widget.pokemonId != null) {
      cachedInitial = favoritesController.getCachedPokemon(widget.pokemonId!) ??
          _pokemonCacheService.getPokemon(widget.pokemonId!);
    } else if (widget.pokemonName != null) {
      cachedInitial = _pokemonCacheService.findByName(widget.pokemonName!);
      if (cachedInitial != null) {
        cachedInitial =
            favoritesController.applyFavoriteState(cachedInitial!);
      }
    }

    final PokemonListItem? initialFavorite = widget.initialPokemon != null
        ? favoritesController.applyFavoriteState(widget.initialPokemon!)
        : cachedInitial;

    final FetchPolicy fetchPolicy =
        _hasConnection ? FetchPolicy.cacheAndNetwork : FetchPolicy.cacheFirst;

    return Query(
      options: QueryOptions(
        document: gql(getPokemonDetailsQuery),
        fetchPolicy: fetchPolicy,
        errorPolicy: ErrorPolicy.all,
        variables: {
          'where': where,
          'languageIds': preferredLanguageIds,
        },
      ),
      builder: (result, {fetchMore, refetch}) {
        if (kDebugMode) {
          debugPrint(
            '[Pokemon Detail] Query result - isLoading: ${result.isLoading}, hasException: ${result.hasException}',
          );
          debugPrint(
            '[Pokemon Detail] Available data keys: ${result.data?.keys.toList()}',
          );
          if (result.hasException) {
            debugPrint('[Pokemon Detail] Exception details: ${result.exception}');
          }
        }

        final bool offlineError =
            !_hasConnection || result.exception?.linkException != null;
        if (offlineError || (!result.isLoading && !result.hasException)) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _updateOfflineMode(offlineError),
          );
        }

        final pokemonList =
            result.data?['pokemon_v2_pokemon'] as List<dynamic>?;
        final data = (pokemonList?.isNotEmpty ?? false)
            ? pokemonList?.first as Map<String, dynamic>?
            : null;

        final List<dynamic> typeEfficacies =
            result.data?['type_efficacy'] as List<dynamic>? ??
                const <dynamic>[];

        PokemonDetail? pokemonDetail;
        PokemonListItem? favoriteTarget = initialFavorite;

        if (data != null) {
          pokemonDetail = PokemonDetail.fromGraphQL(
            data,
            typeEfficacies: typeEfficacies,
          );

          favoriteTarget = PokemonListItem(
            id: pokemonDetail.id,
            name: pokemonDetail.name,
            imageUrl: pokemonDetail.imageUrl,
            types: List<String>.from(pokemonDetail.types),
            stats: List<PokemonStat>.from(pokemonDetail.stats),
            generationId: favoriteTarget?.generationId ??
                widget.initialPokemon?.generationId,
            generationName: favoriteTarget?.generationName ??
                widget.initialPokemon?.generationName,
            regionName: favoriteTarget?.regionName ??
                widget.initialPokemon?.regionName,
            shapeName: favoriteTarget?.shapeName ??
                widget.initialPokemon?.shapeName,
            height: pokemonDetail.characteristics.height,
            weight: pokemonDetail.characteristics.weight,
            isFavorite: favoritesController.isFavorite(pokemonDetail.id),
          );

          unawaited(_pokemonCacheService.cachePokemon(favoriteTarget));
          unawaited(favoritesController.cachePokemon(favoriteTarget));
        } else if (offlineError) {
          favoriteTarget = _resolveOfflinePokemon(favoritesController);
        }

        if (favoriteTarget != null) {
          favoriteTarget =
              favoritesController.applyFavoriteState(favoriteTarget);
        }

        final String appBarTitle = favoriteTarget != null
            ? _capitalize(favoriteTarget.name)
            : previewName ?? l10n.detailFallbackTitle;

        final PokemonListItem? offlinePokemon =
            offlineError ? favoriteTarget : null;

        Widget body;

        if (result.isLoading && data == null && offlinePokemon == null) {
          body = LoadingDetailView(
            heroTag: resolvedHeroTag,
            imageUrl: previewImage,
            name: favoriteTarget != null
                ? _capitalize(favoriteTarget.name)
                : previewName,
          );
        } else if (offlinePokemon != null && data == null) {
          body = _OfflineDetailView(
            heroTag: resolvedHeroTag,
            pokemon: offlinePokemon,
          );
        } else if (result.hasException && data == null) {
          debugPrint(
            'Error al cargar el detalle del Pokémon: ${result.exception}',
          );
          body = PokemonDetailErrorView(
            onRetry: refetch,
          );
        } else if (data == null) {
          if (kDebugMode) {
            debugPrint(
              '[Pokemon Detail] No pokemon data found. Full result: ${result.data}',
            );
          }
          body = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.detailNoDataFound),
                const SizedBox(height: 16),
                if (refetch != null)
                  ElevatedButton(
                    onPressed: () async {
                      await refetch();
                    },
                    child: Text(l10n.commonRetry),
                  ),
              ],
            ),
          );
        } else {
          if (result.hasException) {
            debugPrint(
              'Se recibieron datos parciales con errores: ${result.exception}',
            );
          }

          // Eficacias de tipo para calcular matchups (deb/resist/inmunidad)
          final typeEfficacies =
              result.data?['type_efficacy'] as List<dynamic>? ?? [];

          // Parse a modelo de dominio completo
          pokemonDetail = PokemonDetail.fromGraphQL(
            data,
            typeEfficacies: typeEfficacies,
          );

          body = RefreshIndicator(
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
                        pokemon: pokemonDetail!,
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
        }

        final ThemeData theme = Theme.of(context);
        final Widget finalBody = _isOfflineMode
            ? Column(
                children: [
                  _buildOfflineBanner(context, theme),
                  Expanded(child: body),
                ],
              )
            : body;

        return Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            actions: [
              if (favoriteTarget != null)
                _DetailFavoriteButton(pokemon: favoriteTarget),
            ],
          ),
          body: finalBody,
          floatingActionButton: pokemonDetail != null
              ? FloatingActionButton.extended(
                  onPressed: () => _showShareDialog(context, pokemonDetail!),
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir'),
                  tooltip: 'Compartir Pokémon Card',
                )
              : null,
        );
      },
    );
  }
}

class _OfflineDetailView extends StatelessWidget {
  const _OfflineDetailView({
    required this.heroTag,
    required this.pokemon,
  });

  final String heroTag;
  final PokemonListItem pokemon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final String displayName =
        pokemon.name.isEmpty ? 'Pokémon #${pokemon.id}' : pokemon.name;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PokemonArtwork(
            heroTag: heroTag,
            imageUrl: pokemon.imageUrl,
            size: 160,
            padding: const EdgeInsets.all(12),
            borderRadius: 32,
          ),
          const SizedBox(height: 16),
          Text(
            displayName.toUpperCase(),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: pokemon.types
                .map(
                  (type) => Chip(
                    label: Text(type.toUpperCase()),
                    backgroundColor:
                        theme.colorScheme.secondaryContainer.withOpacity(0.6),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.detailOfflineShortMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.detailOfflineLongMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _DetailFavoriteButton extends ConsumerWidget {
  const _DetailFavoriteButton({required this.pokemon});

  final PokemonListItem pokemon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final favoritesController = ref.watch(favoritesControllerProvider);
    final PokemonListItem resolvedPokemon =
        favoritesController.applyFavoriteState(pokemon);

    return IconButton(
      icon: Icon(
        resolvedPokemon.isFavorite ? Icons.favorite : Icons.favorite_border,
      ),
      color: resolvedPokemon.isFavorite ? Colors.redAccent : null,
      tooltip: resolvedPokemon.isFavorite
          ? l10n.detailFavoriteRemoveTooltip
          : l10n.detailFavoriteAddTooltip,
      onPressed: () async {
        await favoritesController.toggleFavorite(resolvedPokemon);
      },
    );
  }
}

/// ===============================
/// POKEMON DATA HELPER
/// ===============================
/// Helper class to hold current Pokemon data (base or selected form)
class _PokemonData {
  const _PokemonData({
    required this.imageUrl,
    this.shinyImageUrl,
    required this.types,
    required this.stats,
    required this.abilities,
    required this.moves,
    required this.height,
    required this.weight,
  });

  final String imageUrl;
  final String? shinyImageUrl;
  final List<String> types;
  final List<PokemonStat> stats;
  final List<PokemonAbilityDetail> abilities;
  final List<PokemonMove> moves;
  final int height;
  final int weight;

  bool get hasShinySprite => 
      shinyImageUrl != null && shinyImageUrl!.isNotEmpty;

  String getSpriteUrl({bool isShiny = false}) {
    if (isShiny && shinyImageUrl != null && shinyImageUrl!.isNotEmpty) {
      return shinyImageUrl!;
    }
    return imageUrl;
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
  late final ScrollController _primaryScrollController;
  
  // State for shiny toggle
  bool _isShiny = false;
  
  // State for selected form (index in forms list)
  int _selectedFormIndex = 0;

  static const int _locationsTabIndex = 5;

  @override
  void initState() {
    super.initState();
    // 6 pestañas: Info, Stats, Matchups, Evolución, Movimientos, Ubicaciones
    _tabController = TabController(length: 6, vsync: this);
    _primaryScrollController = ScrollController();
  }
  
  /// Toggles between normal and shiny sprite
  void _toggleShiny() {
    final currentPokemon = _getCurrentPokemonData();
    if (currentPokemon.hasShinySprite) {
      setState(() {
        _isShiny = !_isShiny;
      });
    }
  }
  
  /// Changes the selected form
  void _selectForm(int index) {
    if (widget.pokemon.forms != null && 
        index >= 0 && 
        index < widget.pokemon.forms!.length) {
      setState(() {
        _selectedFormIndex = index;
        // Reset shiny cuando cambia la forma si la nueva forma no tiene shiny
        if (_isShiny && !_getCurrentPokemonData().hasShinySprite) {
          _isShiny = false;
        }
      });
    }
  }
  
  /// Gets the current Pokemon data (base form or selected form)
  _PokemonData _getCurrentPokemonData() {
    if (widget.pokemon.forms != null && 
        widget.pokemon.forms!.isNotEmpty &&
        _selectedFormIndex < widget.pokemon.forms!.length) {
      final form = widget.pokemon.forms![_selectedFormIndex];
      return _PokemonData(
        imageUrl: form.imageUrl,
        shinyImageUrl: form.shinyImageUrl,
        types: form.types,
        stats: form.stats,
        abilities: form.abilities,
        moves: form.moves,
        height: form.height,
        weight: form.weight,
      );
    }
    
    // Base form data (from PokemonDetail)
    return _PokemonData(
      imageUrl: widget.pokemon.imageUrl,
      shinyImageUrl: widget.pokemon.shinyImageUrl,
      types: widget.pokemon.types,
      stats: widget.pokemon.stats,
      abilities: widget.pokemon.abilities,
      moves: widget.pokemon.moves,
      height: widget.pokemon.characteristics.height,
      weight: widget.pokemon.characteristics.weight,
    );
  }
  
  /// Creates a modified PokemonDetail with current form data
  PokemonDetail _getCurrentPokemon() {
    final currentData = _getCurrentPokemonData();
    
    // If no forms or we are in base form, return the original pokemon
    if (widget.pokemon.forms == null || 
        widget.pokemon.forms!.isEmpty ||
        _selectedFormIndex >= widget.pokemon.forms!.length ||
        _selectedFormIndex == 0) {
      return widget.pokemon;
    }
    
    // Create a copy of the pokemon with selected form data
    return PokemonDetail(
      id: widget.pokemon.id,
      name: widget.pokemon.name,
      imageUrl: currentData.imageUrl,
      types: currentData.types,
      abilities: currentData.abilities,
      stats: currentData.stats,
      characteristics: PokemonCharacteristics(
        height: currentData.height,
        weight: currentData.weight,
        baseExperience: widget.pokemon.characteristics.baseExperience,
        captureRate: widget.pokemon.characteristics.captureRate,
        category: widget.pokemon.characteristics.category,
        eggGroups: widget.pokemon.characteristics.eggGroups,
      ),
      typeMatchups: widget.pokemon.typeMatchups,
      moves: currentData.moves,
      evolutionChain: widget.pokemon.evolutionChain,
      speciesId: widget.pokemon.speciesId,
      shinyImageUrl: currentData.shinyImageUrl,
      spriteData: widget.pokemon.spriteData,
      forms: widget.pokemon.forms,
    );
  }

  @override
  void dispose() {
    _primaryScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleViewMapTap() async {
    if (_tabController.index != _locationsTabIndex) {
      _tabController.animateTo(_locationsTabIndex);
    }

    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    if (_primaryScrollController.hasClients) {
      await _primaryScrollController.animateTo(
        _primaryScrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
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
    required _PokemonData currentData,
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
        currentData: currentData,
        theme: theme,
        typeColor: typeColor,
        onTypeColor: onTypeColor,
        heroTag: widget.resolvedHeroTag,
        expandedHeight: headerHeight,
        collapsedHeight: collapsedHeight,
        capitalize: widget.capitalize,
        isShiny: _isShiny,
        onShinyToggle: _toggleShiny,
        forms: pokemon.forms,
        selectedFormIndex: _selectedFormIndex,
        onFormSelected: _selectForm,
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final pokemon = widget.pokemon;
    
    // Get current data (base form or selected form)
    final currentData = _getCurrentPokemonData();

    final currentPokemon = _getCurrentPokemon();
    // Habilidad “principal” para mostrar en el bloque de info
    final mainAbilityDetail =
    currentData.abilities.isNotEmpty ? currentData.abilities.first : null;
    final mainAbility =
    mainAbilityDetail != null ? _formatLabel(mainAbilityDetail.name) : null;
    final abilitySubtitle = mainAbilityDetail == null
        ? null
        : (mainAbilityDetail.isHidden
            ? l10n.detailHiddenAbilityLabel
            : l10n.detailMainAbilityLabel);

    // Reactive palette based on Pokemon primary type
    final colorScheme = theme.colorScheme;
    final typeColor = currentData.types.isNotEmpty
        ? _resolveTypeColor(currentData.types.first, colorScheme)
        : colorScheme.primary;
    final onTypeColor =
    ThemeData.estimateBrightnessForColor(typeColor) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    // Section background colors (type color tints)
    final backgroundTint =
    Color.alphaBlend(typeColor.withOpacity(0.04), colorScheme.surface);
    final sectionBackground =
    Color.alphaBlend(typeColor.withOpacity(0.08), colorScheme.surfaceVariant);
    final sectionBorder = typeColor.withOpacity(0.25);

    // Padding inferior para evitar solapamiento con gestos/teclado
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = 48.0 + mediaQuery.padding.bottom + mediaQuery.viewInsets.bottom;
    final scrollBehavior =
        ScrollConfiguration.of(context).copyWith(scrollbars: false);

    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundTint),
      child: PrimaryScrollController(
        controller: _primaryScrollController,
        child: ScrollConfiguration(
          behavior: scrollBehavior,
          child: NestedScrollView(
            controller: _primaryScrollController,
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
                currentData: currentData,
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
                onViewMap: _handleViewMapTap,
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
            _DetailTabScrollView(
              storageKey: const PageStorageKey('locations-tab'),
              topPadding: 24,
              bottomPadding: bottomPadding,
              child: PokemonLocationsTab(
                pokemon: pokemon,
                sectionBackground: sectionBackground,
                sectionBorder: sectionBorder,
              ),
            ),
          ],
        ),
      ),
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
    required this.currentData,
    required this.theme,
    required this.typeColor,
    required this.onTypeColor,
    required this.heroTag,
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.capitalize,
    required this.isShiny,
    required this.onShinyToggle,
    this.forms,
    required this.selectedFormIndex,
    required this.onFormSelected,
  });

  final PokemonDetail pokemon;
  final _PokemonData currentData;
  final ThemeData theme;
  final Color typeColor;
  final Color onTypeColor;
  final String heroTag;
  final double expandedHeight;
  final double collapsedHeight;
  final String Function(String) capitalize;
  final bool isShiny;
  final VoidCallback onShinyToggle;
  final List<PokemonForm>? forms;
  final int selectedFormIndex;
  final void Function(int) onFormSelected;

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
                        imageUrl: currentData.getSpriteUrl(isShiny: isShiny),
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
                // Forms selector (only if there are alternative forms)
                if (forms != null && forms!.length > 1)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Opacity(
                      opacity: (1 - (0.4 * progress)).clamp(0.0, 1.0),
                      child: Material(
                        color: Colors.transparent,
                        child: _FormsDropdown(
                          forms: forms!,
                          selectedIndex: selectedFormIndex,
                          onFormSelected: onFormSelected,
                          backgroundColor: onTypeColor.withOpacity(0.15),
                          borderColor: onTypeColor.withOpacity(0.3),
                          textColor: onTypeColor,
                          theme: theme,
                        ),
                      ),
                    ),
                  ),
                // Shiny toggle button (only if shiny sprite is available)
                if (currentData.hasShinySprite)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Opacity(
                      opacity: (1 - (0.4 * progress)).clamp(0.0, 1.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onShinyToggle,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: onTypeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: onTypeColor.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isShiny ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                                  color: isShiny 
                                      ? const Color(0xFFFFD700) // Gold for shiny
                                      : onTypeColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isShiny ? 'Shiny' : 'Normal',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: onTypeColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
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
    // Rebuild if critical inputs change (avoids unnecessary repaints)
    return oldDelegate.pokemon != pokemon ||
        oldDelegate.currentData != currentData ||
        oldDelegate.theme != theme ||
        oldDelegate.typeColor != typeColor ||
        oldDelegate.onTypeColor != onTypeColor ||
        oldDelegate.heroTag != heroTag ||
        oldDelegate.expandedHeight != expandedHeight ||
        oldDelegate.collapsedHeight != collapsedHeight ||
        oldDelegate.isShiny != isShiny ||
        oldDelegate.selectedFormIndex != selectedFormIndex;
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
    final tabConfigs = buildDetailTabConfigs(AppLocalizations.of(context)!);

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
          tabs: tabConfigs
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
/// FORMS DROPDOWN SELECTOR
/// ===============================
/// Widget for selecting different Pokemon forms (Alolan, Galarian, Mega, etc.)
class _FormsDropdown extends StatelessWidget {
  const _FormsDropdown({
    required this.forms,
    required this.selectedIndex,
    required this.onFormSelected,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.theme,
  });

  final List<PokemonForm> forms;
  final int selectedIndex;
  final void Function(int) onFormSelected;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    // Bounds check to prevent index out of range
    final safeIndex = selectedIndex.clamp(0, forms.length - 1);
    final selectedForm = forms[safeIndex];
    
    return PopupMenuButton<int>(
      initialValue: selectedIndex,
      onSelected: onFormSelected,
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      itemBuilder: (context) => forms.asMap().entries.map((entry) {
        final index = entry.key;
        final form = entry.value;
        final isSelected = index == selectedIndex;
        
        return PopupMenuItem<int>(
          value: index,
          child: Row(
            children: [
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: theme.colorScheme.primary,
                )
              else
                const SizedBox(width: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  form.displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (form.isMega)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.electric_bolt,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_mosaic,
              color: textColor,
              size: 18,
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                selectedForm.displayName,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: textColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteToggleAction extends StatelessWidget {
  const _FavoriteToggleAction({
    required this.pokemonId,
    required this.favoritesController,
  });

  final int pokemonId;
  final FavoritesController favoritesController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: favoritesController,
      builder: (context, _) {
        final isFavorite = favoritesController.isFavorite(pokemonId);
        final cachedPokemon = favoritesController.getCachedPokemon(pokemonId);
        return IconButton(
          tooltip: isFavorite
              ? 'Quitar de favoritos'
              : 'Marcar como favorito',
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? theme.colorScheme.error : null,
          ),
          onPressed: cachedPokemon != null
              ? () {
                  favoritesController.toggleFavorite(cachedPokemon);
                }
              : null,
        );
      },
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
      final favoritesController =
          ProviderScope.containerOf(this, listen: false)
              .read(favoritesControllerProvider);
      PokemonListItem? cachedPokemon;
      if (speciesId != null) {
        cachedPokemon = favoritesController.getCachedPokemon(speciesId);
      }
      if (cachedPokemon == null) {
        for (final PokemonListItem pokemon in favoritesController.favorites) {
          if (pokemon.name == slug) {
            cachedPokemon = pokemon;
            break;
          }
        }
      }
      if (cachedPokemon != null) {
        cachedPokemon =
            favoritesController.applyFavoriteState(cachedPokemon);
      }
      return Navigator.of(this).push<T>(
        MaterialPageRoute<T>(
          builder: (_) => DetailScreen(
            pokemonId: speciesId,
            pokemonName: slug,
            initialPokemon: cachedPokemon,
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

/// ===============================
/// SHARE CARD DIALOG
/// ===============================
/// Diálogo que muestra la tarjeta del Pokémon y permite compartirla.
class _ShareCardDialog extends StatefulWidget {
  const _ShareCardDialog({
    required this.pokemon,
    required this.themeColor,
  });

  final PokemonDetail pokemon;
  final Color themeColor;

  @override
  State<_ShareCardDialog> createState() => _ShareCardDialogState();
}

class _ShareCardDialogState extends State<_ShareCardDialog> {
  final GlobalKey _cardKey = GlobalKey();
  final CardCaptureService _captureService = CardCaptureService();
  bool _isSharing = false;
  bool _isPreloadingImage = false;

  Future<void> _shareCard() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
      _isPreloadingImage = true;
    });

    try {
      await WidgetsBinding.instance.endOfFrame;

      var precacheSuccessful = true;
      try {
        await precacheImage(
          NetworkImage(widget.pokemon.imageUrl),
          context,
        );
      } catch (e) {
        precacheSuccessful = false;
        debugPrint('[ShareCardDialog] Error al precargar imagen: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo preparar la imagen para compartir.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }

      if (!precacheSuccessful || !mounted) {
        return;
      }

      if (mounted) {
        setState(() {
          _isPreloadingImage = false;
        });
      }

      final success = await _captureService.captureAndShare(
        _cardKey,
        filename: 'pokemon_${widget.pokemon.id}_card.png',
        text: 'Check out ${widget.pokemon.name.toUpperCase()} #${widget.pokemon.id}!',
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Tarjeta compartida exitosamente!'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo compartir la tarjeta. Intenta de nuevo.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[ShareCardDialog] Error al compartir: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
          _isPreloadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Compartir Pokémon Card',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Preview de la tarjeta (escala pequeña)
            Container(
              height: 300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    RepaintBoundary(
                      key: _cardKey,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: PokemonShareCard(
                          pokemon: widget.pokemon,
                          themeColor: widget.themeColor,
                        ),
                      ),
                    ),
                    if (_isPreloadingImage)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.25),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Preparando la imagen...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Botones
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSharing
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSharing ? null : _shareCard,
                      icon: _isSharing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.share),
                      label: Text(_isSharing ? 'Compartiendo...' : 'Compartir'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
