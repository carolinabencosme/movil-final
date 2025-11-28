import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/l10n/app_localizations.dart';
import 'package:graphql/client.dart' show LinkException;
import 'package:graphql_flutter/graphql_flutter.dart';

import '../controllers/favorites_controller.dart';
import '../providers/favorites_provider.dart';
import '../models/pokemon_model.dart';
import '../queries/get_pokemon_list.dart';
import '../queries/get_pokemon_types.dart';
import '../theme/pokemon_type_colors.dart';
import '../services/connectivity_service.dart';
import '../widgets/pokemon_artwork.dart';
import 'detail_screen.dart';
import '../services/pokemon_cache_service.dart';

part 'favorites_screen.dart';

/// Opciones de ordenamiento para la lista de Pokémon
/// Permite ordenar por número, nombre, altura o peso
/// Opciones de ordenamiento para la lista de Pokémon
/// Permite ordenar por número, nombre, altura o peso
enum PokemonSortOption { id, name, height, weight }

/// Extensión para PokemonSortOption que proporciona etiquetas y campos de GraphQL
extension PokemonSortOptionX on PokemonSortOption {
  /// Etiqueta localizada para mostrar al usuario
  String label(AppLocalizations l10n) {
    switch (this) {
      case PokemonSortOption.id:
        return l10n.pokedexSortNumberLabel;
      case PokemonSortOption.name:
        return l10n.pokedexSortNameLabel;
      case PokemonSortOption.height:
        return l10n.pokedexSortHeightLabel;
      case PokemonSortOption.weight:
        return l10n.pokedexSortWeightLabel;
    }
  }

  /// Campo de GraphQL correspondiente para la query
  String get graphqlField {
    switch (this) {
      case PokemonSortOption.id:
        return 'id';
      case PokemonSortOption.name:
        return 'name';
      case PokemonSortOption.height:
        return 'height';
      case PokemonSortOption.weight:
        return 'weight';
    }
  }
}

/// Opción de ordenamiento por defecto: por número de Pokédex
const PokemonSortOption kDefaultSortOption = PokemonSortOption.id;

/// Dirección de ordenamiento por defecto: ascendente
const bool kDefaultSortAscending = true;

/// Pantalla principal de la Pokédex
/// 
/// Muestra una lista paginada de Pokémon con capacidades de:
/// - Búsqueda por nombre o número
/// - Filtrado por tipo, generación, región y forma
/// - Ordenamiento por diferentes criterios
/// - Carga perezosa (lazy loading) al hacer scroll
/// 
/// La implementación usa paginación para no cargar todos los 1300+ Pokémon a la vez,
/// mejorando significativamente el rendimiento y la experiencia del usuario.
class PokedexScreen extends StatefulWidget {
  const PokedexScreen({
    super.key,
    this.heroTag,
    this.accentColor,
    this.title = 'Pokédex',
  });

  /// Tag opcional para la animación Hero del título
  final String? heroTag;
  
  /// Color de acento opcional para la AppBar
  final Color? accentColor;
  
  /// Título de la pantalla
  final String title;

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

/// Estado de la pantalla Pokédex
/// 
/// Gestiona la lógica de:
/// - Paginación: carga incremental de Pokémon (30 a la vez)
/// - Búsqueda: con debounce de 350ms para optimizar las queries
/// - Filtros: tipos, generaciones, regiones y formas
/// - Ordenamiento: por diferentes criterios y direcciones
class _PokedexScreenState extends State<PokedexScreen> {
  /// Tamaño de cada página de resultados
  /// Se cargan 30 Pokémon a la vez para balance entre rendimiento y UX
  /// Tamaño de cada página de resultados
  /// Se cargan 30 Pokémon a la vez para balance entre rendimiento y UX
  static const int _pageSize = 30;
  
  /// Controlador para detectar cuándo el usuario llega al final de la lista
  final ScrollController _scrollController = ScrollController();
  
  /// Controlador para el campo de búsqueda
  final TextEditingController _searchController = TextEditingController();
  
  /// Filtros activos seleccionados por el usuario
  final Set<String> _selectedTypes = <String>{};
  final Set<String> _selectedGenerations = <String>{};
  final Set<String> _selectedRegions = <String>{};
  final Set<String> _selectedShapes = <String>{};

  /// Opción de ordenamiento actual
  PokemonSortOption _sortOption = kDefaultSortOption;
  
  /// Dirección de ordenamiento (ascendente/descendente)
  bool _isSortAscending = kDefaultSortAscending;

  /// Timer para el debounce de la búsqueda (evita queries excesivas)
  Timer? _debounce;
  
  /// Lista de Pokémon actualmente mostrados
  List<PokemonListItem> _pokemons = <PokemonListItem>[];

  FavoritesController? _favoritesController;
  
  /// Opciones disponibles para los filtros
  List<String> _availableTypes = <String>[];
  List<String> _availableGenerations = <String>[];
  List<String> _availableRegions = <String>[];
  List<String> _availableShapes = <String>[];

  /// Estados de carga y paginación
  bool _isFetching = false;           // Indica si hay una petición en curso
  bool _isInitialLoading = true;       // Indica la primera carga
  bool _hasMore = true;                // Indica si hay más resultados para cargar
  bool _filtersLoading = false;        // Indica si se están cargando los filtros
  bool _didInit = false;               // Indica si ya se inicializó
  bool _isOfflineMode = false;         // Indica si los datos provienen de caché local
  bool _offlineSnackShown = false;     // Controla los avisos de modo offline
  StreamSubscription<bool>? _connectivitySubscription;
  final ConnectivityService _connectivityService = ConnectivityService.instance;

  /// Métricas y estado de la UI
  int _totalCount = 0;                 // Total de Pokémon que coinciden con filtros
  int _activeFiltersCount = 0;         // Número de filtros activos
  String _searchTerm = '';             // Término de búsqueda actual (sin debounce)
  String _debouncedSearch = '';        // Término de búsqueda aplicado (con debounce)
  String _errorMessage = '';           // Mensaje de error si algo falla

  /// Verifica si el ordenamiento actual es el predeterminado
  bool get _isDefaultSort =>
      _sortOption == kDefaultSortOption && _isSortAscending == kDefaultSortAscending;

  PokemonCacheService get _pokemonCacheService => PokemonCacheService.instance;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _connectivitySubscription =
        _connectivityService.isOfflineStream.listen((bool isOffline) {
          if (!mounted) return;

          if (isOffline) {
            _updateOfflineMode(true, showMessage: true);
          } else {
            _updateOfflineMode(false);
            _resetAndFetch();
          }
        });

    if (_connectivityService.isOffline) {
      _updateOfflineMode(true, showMessage: true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final FavoritesController? favoritesController =
        FavoritesScope.maybeOf(context);
    if (!identical(_favoritesController, favoritesController)) {
      _favoritesController?.removeListener(_onFavoritesChanged);
      _favoritesController = favoritesController;
      _favoritesController?.addListener(_onFavoritesChanged);
      if (favoritesController != null && _pokemons.isNotEmpty) {
        setState(() {
          _pokemons =
              favoritesController.applyFavoriteStateToList(_pokemons);
        });
      }
    }
    if (_didInit) return;
    _didInit = true;
    _fetchFilters();
    _fetchPokemons(reset: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _connectivitySubscription?.cancel();
    _favoritesController?.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  /// Callback para detectar cuando el usuario hace scroll cerca del final
  /// Cuando quedan menos de 200 píxeles hasta el final, carga más Pokémon
  void _onScroll() {
    if (!_hasMore || _isFetching) {
      return;
    }
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchPokemons();
    }
  }

  void _onFavoritesChanged() {
    if (!mounted) {
      return;
    }

    final FavoritesController? favoritesController = _favoritesController;
    if (favoritesController == null) {
      return;
    }

    setState(() {
      _pokemons =
          favoritesController.applyFavoriteStateToList(_pokemons);
    });
  }

  /// Maneja cambios en el campo de búsqueda con debounce
  /// Espera 350ms después del último cambio antes de ejecutar la búsqueda
  /// Esto evita hacer queries en cada pulsación de tecla
  void _onSearchChanged(String value) {
    setState(() => _searchTerm = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _debouncedSearch = value.trim();
      _resetAndFetch();
    });
  }

  /// Aplica los filtros seleccionados y recarga la lista
  /// Solo hace la recarga si realmente hubo cambios en los filtros
  void _applyFilters({
    Set<String>? types,
    Set<String>? generations,
    Set<String>? regions,
    Set<String>? shapes,
    PokemonSortOption? sortOption,
    bool? isSortAscending,
  }) {
    var hasChanges = false;

    setState(() {
      if (types != null && !setEquals(types, _selectedTypes)) {
        _selectedTypes
          ..clear()
          ..addAll(types);
        hasChanges = true;
      }
      if (generations != null &&
          !setEquals(generations, _selectedGenerations)) {
        _selectedGenerations
          ..clear()
          ..addAll(generations);
        hasChanges = true;
      }
      if (regions != null && !setEquals(regions, _selectedRegions)) {
        _selectedRegions
          ..clear()
          ..addAll(regions);
        hasChanges = true;
      }
      if (shapes != null && !setEquals(shapes, _selectedShapes)) {
        _selectedShapes
          ..clear()
          ..addAll(shapes);
        hasChanges = true;
      }
      if (sortOption != null && isSortAscending != null) {
        final shouldUpdateSort =
            sortOption != _sortOption || isSortAscending != _isSortAscending;
        if (shouldUpdateSort) {
          _sortOption = sortOption;
          _isSortAscending = isSortAscending;
          hasChanges = true;
        }
      }
    });

    if (hasChanges) {
      _resetAndFetch();
    }
  }

  /// Calcula cuántos filtros están actualmente activos
  /// Incluye búsqueda, tipos, generaciones, regiones, formas y ordenamiento
  int _calculateActiveFiltersCount() {
    final searchCount = _debouncedSearch.trim().isEmpty ? 0 : 1;
    final sortCount = _isDefaultSort ? 0 : 1;
    return _selectedTypes.length +
        _selectedGenerations.length +
        _selectedRegions.length +
        _selectedShapes.length +
        searchCount +
        sortCount;
  }

  /// Reinicia el estado de paginación y recarga desde el inicio
  void _resetAndFetch() {
    setState(() {
      _hasMore = true;
      _totalCount = 0;
      _errorMessage = '';
      _activeFiltersCount = _calculateActiveFiltersCount();
    });
    _fetchPokemons(reset: true);
  }

  /// Elimina un filtro de tipo y recarga la lista
  void _removeTypeFilter(String type) {
    if (!_selectedTypes.contains(type)) return;
    setState(() {
      _selectedTypes.remove(type);
    });
    _resetAndFetch();
  }

  void _removeGenerationFilter(String generation) {
    if (!_selectedGenerations.contains(generation)) return;
    setState(() {
      _selectedGenerations.remove(generation);
    });
    _resetAndFetch();
  }

  void _removeRegionFilter(String region) {
    if (!_selectedRegions.contains(region)) return;
    setState(() {
      _selectedRegions.remove(region);
    });
    _resetAndFetch();
  }

  void _removeShapeFilter(String shape) {
    if (!_selectedShapes.contains(shape)) return;
    setState(() {
      _selectedShapes.remove(shape);
    });
    _resetAndFetch();
  }

  void _resetSortSelection() {
    if (_isDefaultSort) return;
    setState(() {
      _sortOption = kDefaultSortOption;
      _isSortAscending = kDefaultSortAscending;
    });
    _resetAndFetch();
  }

  void _clearSearchFilter() {
    if (_debouncedSearch.trim().isEmpty && _searchTerm.trim().isEmpty) {
      return;
    }
    _debounce?.cancel();
    setState(() {
      _searchController.clear();
      _searchTerm = '';
      _debouncedSearch = '';
    });
    _resetAndFetch();
  }

  Future<void> _fetchFilters() async {
    setState(() => _filtersLoading = true);
    final client = GraphQLProvider.of(context).value;
    try {
      final result = await client.query(
        QueryOptions(
          document: gql(getPokemonTypesQuery),
          fetchPolicy: FetchPolicy.cacheFirst,
        ),
      );
      if (!mounted) return;
      if (result.hasException) {
        setState(() => _filtersLoading = false);
        return;
      }
      final types = (result.data?['pokemon_v2_type'] as List<dynamic>? ?? [])
          .map((dynamic entry) => (entry as Map<String, dynamic>)['name'])
          .whereType<String>()
          .toList();
      final generations =
          (result.data?['pokemon_v2_generation'] as List<dynamic>? ?? [])
              .map((dynamic entry) =>
                  (entry as Map<String, dynamic>)['name'] as String?)
              .whereType<String>()
              .toList();
      final regions =
          (result.data?['pokemon_v2_region'] as List<dynamic>? ?? [])
              .map((dynamic entry) =>
                  (entry as Map<String, dynamic>)['name'] as String?)
              .whereType<String>()
              .toList();
      final shapes =
          (result.data?['pokemon_v2_pokemonshape'] as List<dynamic>? ?? [])
              .map((dynamic entry) =>
                  (entry as Map<String, dynamic>)['name'] as String?)
              .whereType<String>()
              .toList();
      setState(() {
        _availableTypes = types;
        _availableGenerations = generations;
        _availableRegions = regions;
        _availableShapes = shapes;
        _filtersLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _filtersLoading = false);
    }
  }

  /// Obtiene la lista de Pokémon desde el servidor GraphQL
  /// 
  /// Esta es la función clave para la paginación. Controla:
  /// - Cuándo cargar (evita cargas duplicadas)
  /// - Cuántos cargar (30 por página)
  /// - Desde dónde cargar (offset basado en lista actual)
  /// - Qué filtros aplicar
  ///
  /// [reset]: Si es true, reinicia la lista desde el inicio
  Future<void> _fetchPokemons({bool reset = false}) async {
    if (_isFetching || (!_hasMore && !reset)) {
      return;
    }

    // Calcula el offset: 0 si es reset, sino la cantidad actual
    final offset = reset ? 0 : _pokemons.length;
    setState(() {
      _isFetching = true;
      if (_pokemons.isEmpty) {
        _isInitialLoading = true;
      }
    });

    final bool isOffline = _connectivityService.isOffline;
    final searchValue = _debouncedSearch.toLowerCase();
    final numericId = int.tryParse(_debouncedSearch);

    // Determina qué filtros aplicar en la query
    final includeIdFilter = numericId != null && _debouncedSearch.isNotEmpty;
    final includeTypeFilter = _selectedTypes.isNotEmpty;
    final includeGenerationFilter = _selectedGenerations.isNotEmpty;
    final includeRegionFilter = _selectedRegions.isNotEmpty;
    final includeShapeFilter = _selectedShapes.isNotEmpty;

    // No paginar cuando se busca por ID (solo devuelve un resultado)
    final shouldPaginate = !includeIdFilter;

    if (isOffline) {
      final bool handledOffline = await _loadPokemonsFromCache(
        reset: reset,
        offset: offset,
        shouldPaginateOverride: shouldPaginate,
        showOfflineMessage: true,
      );

      if (!handledOffline && mounted) {
        setState(() {
          _isFetching = false;
          _isInitialLoading = false;
        });
      }
      return;
    }

    final client = GraphQLProvider.of(context).value;

    final document = gql(
      buildPokemonListQuery(
        includeIdFilter: includeIdFilter,
        includeTypeFilter: includeTypeFilter,
        includeGenerationFilter: includeGenerationFilter,
        includeRegionFilter: includeRegionFilter,
        includeShapeFilter: includeShapeFilter,
        includePagination: shouldPaginate,
        orderField: _sortOption.graphqlField,
        isOrderAscending: _isSortAscending,
      ),
    );

    final variables = <String, dynamic>{
      'search': searchValue.isEmpty ? '%' : '%$searchValue%',
    };

    if (shouldPaginate) {
      variables['limit'] = _pageSize;
      variables['offset'] = offset;
    }

    if (includeIdFilter && numericId != null) {
      variables['id'] = numericId;
    }
    if (includeTypeFilter) {
      variables['typeNames'] = _selectedTypes.toList();
    }
    if (includeGenerationFilter) {
      variables['generationNames'] = _selectedGenerations.toList();
    }
    if (includeRegionFilter) {
      variables['regionNames'] = _selectedRegions.toList();
    }
    if (includeShapeFilter) {
      variables['shapeNames'] = _selectedShapes.toList();
    }

    try {
      final result = await client.query(
        QueryOptions(
          document: document,
          variables: variables,
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (!mounted) return;

      final operationException = result.exception;
      if (result.hasException && operationException != null) {
        final bool offlineHandled = operationException.linkException != null &&
            await _loadPokemonsFromCache(
              reset: reset,
              offset: offset,
              shouldPaginateOverride: shouldPaginate,
              showOfflineMessage: true,
            );
        if (offlineHandled) {
          return;
        }
        _handleError(operationException, reset: reset);
        return;
      }

      final results =
          (result.data?['pokemon_v2_pokemon'] as List<dynamic>? ?? [])
              .map((dynamic entry) =>
                  PokemonListItem.fromGraphQL(entry as Map<String, dynamic>))
              .toList();
      final aggregateMap =
          result.data?['pokemon_v2_pokemon_aggregate'] as Map<String, dynamic>?;
      final count =
          (aggregateMap?['aggregate'] as Map<String, dynamic>?)?['count'] as int?;

      final FavoritesController? favoritesController =
          _favoritesController ?? FavoritesScope.maybeOf(context);
      List<PokemonListItem> resolvedResults = results;
      await _pokemonCacheService.cachePokemons(resolvedResults);
      if (favoritesController != null && results.isNotEmpty) {
        resolvedResults =
            favoritesController.applyFavoriteStateToList(results);
        await favoritesController.cachePokemons(resolvedResults);
      }

      List<PokemonListItem> updatedPokemons;
      if (reset) {
        updatedPokemons = resolvedResults;
      } else if (shouldPaginate) {
        updatedPokemons = <PokemonListItem>[..._pokemons, ...resolvedResults];
      } else {
        updatedPokemons = resolvedResults;
      }

      if (favoritesController != null && updatedPokemons.isNotEmpty) {
        updatedPokemons =
            favoritesController.applyFavoriteStateToList(updatedPokemons);
      }

      setState(() {
        _pokemons = updatedPokemons;
        _totalCount = count ?? _pokemons.length;
        final expectedTotal = _totalCount == 0 ? _pokemons.length : _totalCount;
        _hasMore = shouldPaginate && _pokemons.length < expectedTotal;
        _errorMessage = '';
      });
      _updateOfflineMode(false);
    } catch (error) {
      if (!mounted) return;
      final bool offlineHandled = await _handleOfflineFallback(
        reset: reset,
        offset: offset,
        shouldPaginate: shouldPaginate,
        error: error,
      );
      if (!offlineHandled) {
        _handleGenericError(error, reset: reset);
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isFetching = false;
        _isInitialLoading = false;
      });
    }
  }

  Future<bool> _handleOfflineFallback({
    required bool reset,
    required int offset,
    required bool shouldPaginate,
    required Object error,
  }) async {
    final bool isLinkError =
        (error is OperationException && error.linkException != null) ||
            error is LinkException;
    final bool isSocketError =
        error.toString().toLowerCase().contains('socketexception');
    if (!isLinkError && !isSocketError) {
      return false;
    }

    return _loadPokemonsFromCache(
      reset: reset,
      offset: offset,
      shouldPaginateOverride: shouldPaginate,
      showOfflineMessage: true,
    );
  }

  Future<bool> _loadPokemonsFromCache({
    required bool reset,
    required int offset,
    bool? shouldPaginateOverride,
    bool showOfflineMessage = false,
  }) async {
    final List<PokemonListItem> cached =
        _pokemonCacheService.getAll(sorted: false);
    if (cached.isEmpty) {
      _updateOfflineMode(true, showMessage: showOfflineMessage);
      if (!mounted) {
        return false;
      }
      setState(() {
        if (reset) {
          _pokemons = <PokemonListItem>[];
          _hasMore = false;
        }
        _errorMessage =
            'Sin conexión y sin datos guardados localmente.';
        _isFetching = false;
        _isInitialLoading = false;
      });
      return false;
    }

    final List<PokemonListItem> filtered = _applyOfflineFilters(cached);
    final int? numericId = int.tryParse(_debouncedSearch);
    final bool includeIdFilter =
        numericId != null && _debouncedSearch.isNotEmpty;
    final bool shouldPaginate =
        shouldPaginateOverride ?? !includeIdFilter;

    final FavoritesController? favoritesController =
        _favoritesController ?? FavoritesScope.maybeOf(context);

    List<PokemonListItem> page;
    if (shouldPaginate) {
      page = filtered.skip(offset).take(_pageSize).toList();
    } else {
      page = filtered;
    }

    if (favoritesController != null && page.isNotEmpty) {
      page = favoritesController.applyFavoriteStateToList(page);
    }

    if (!mounted) {
      return true;
    }

    setState(() {
      if (reset || !shouldPaginate) {
        _pokemons = page;
      } else {
        _pokemons = <PokemonListItem>[..._pokemons, ...page];
      }
      _totalCount = filtered.length;
      final int expectedTotal =
          shouldPaginate ? filtered.length : page.length;
      _hasMore = shouldPaginate && _pokemons.length < expectedTotal;
      _errorMessage = '';
      _isFetching = false;
      _isInitialLoading = false;
    });

    _updateOfflineMode(true, showMessage: showOfflineMessage);
    return true;
  }

  List<PokemonListItem> _applyOfflineFilters(List<PokemonListItem> source) {
    Iterable<PokemonListItem> filtered = source;
    final String trimmedSearch = _debouncedSearch.trim().toLowerCase();
    final int? numericId = int.tryParse(_debouncedSearch.trim());

    if (trimmedSearch.isNotEmpty) {
      filtered = filtered.where((PokemonListItem pokemon) {
        final bool matchesName =
            pokemon.name.toLowerCase().contains(trimmedSearch);
        final bool matchesId = numericId != null && pokemon.id == numericId;
        return matchesName || matchesId;
      });
    }

    if (_selectedTypes.isNotEmpty) {
      final Set<String> selectedTypesLower =
          _selectedTypes.map((type) => type.toLowerCase()).toSet();
      filtered = filtered.where((PokemonListItem pokemon) {
        final Set<String> pokemonTypes =
            pokemon.types.map((type) => type.toLowerCase()).toSet();
        return selectedTypesLower
            .every((String type) => pokemonTypes.contains(type));
      });
    }

    if (_selectedGenerations.isNotEmpty) {
      filtered = filtered.where((PokemonListItem pokemon) {
        final String? generation = pokemon.generationName;
        return generation != null &&
            _selectedGenerations.contains(generation);
      });
    }

    if (_selectedRegions.isNotEmpty) {
      filtered = filtered.where((PokemonListItem pokemon) {
        final String? region = pokemon.regionName;
        return region != null && _selectedRegions.contains(region);
      });
    }

    if (_selectedShapes.isNotEmpty) {
      filtered = filtered.where((PokemonListItem pokemon) {
        final String? shape = pokemon.shapeName;
        return shape != null && _selectedShapes.contains(shape);
      });
    }

    List<PokemonListItem> sorted = filtered.toList();
    sorted.sort(_comparePokemonsForOffline);
    if (!_isSortAscending) {
      sorted = sorted.reversed.toList();
    }
    return sorted;
  }

  int _comparePokemonsForOffline(
    PokemonListItem a,
    PokemonListItem b,
  ) {
    switch (_sortOption) {
      case PokemonSortOption.id:
        return a.id.compareTo(b.id);
      case PokemonSortOption.name:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      case PokemonSortOption.height:
        return (a.height ?? 0).compareTo(b.height ?? 0);
      case PokemonSortOption.weight:
        return (a.weight ?? 0).compareTo(b.weight ?? 0);
    }
    return 0;
  }

  void _updateOfflineMode(bool offline, {bool showMessage = false}) {
    if (!mounted) return;
    if (offline) {
      if (!_isOfflineMode) {
        setState(() {
          _isOfflineMode = true;
        });
      }
      if (showMessage && !_offlineSnackShown) {
        _showTransientMessage(
          'Modo offline activo. Mostrando datos guardados localmente.',
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
        _showTransientMessage('Conexión restablecida.');
        _offlineSnackShown = false;
      }
    }
  }

  void _handleError(OperationException exception, {required bool reset}) {
    _updateOfflineMode(false);
    final rawMessage = exception.graphqlErrors.isNotEmpty
        ? exception.graphqlErrors.first.message
        : exception.linkException?.originalException?.toString() ??
            exception.toString();
    final friendlyMessage = rawMessage.isEmpty
        ? 'No se pudo cargar la Pokédex. Intenta nuevamente.'
        : rawMessage;
    _showTransientMessage(friendlyMessage);
    setState(() {
      if (reset) {
        _pokemons = <PokemonListItem>[];
        _hasMore = false;
      }
      _errorMessage = friendlyMessage;
      if (!reset) {
        _hasMore = true;
      }
    });
  }

  void _handleGenericError(Object error, {required bool reset}) {
    _updateOfflineMode(false);
    final rawMessage = error.toString();
    final friendlyMessage = rawMessage.isEmpty
        ? 'No se pudo cargar la Pokédex. Intenta nuevamente.'
        : rawMessage;
    _showTransientMessage(friendlyMessage);
    setState(() {
      if (reset) {
        _pokemons = <PokemonListItem>[];
        _hasMore = false;
      }
      _errorMessage = friendlyMessage;
      if (!reset) {
        _hasMore = true;
      }
    });
  }

  void _showTransientMessage(String message) {
    if (!mounted || message.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _onRefresh() async {
    _debounce?.cancel();
    setState(() {
      _debouncedSearch = _searchTerm.trim();
      _hasMore = true;
      _totalCount = 0;
      _errorMessage = '';
      _activeFiltersCount = _calculateActiveFiltersCount();
    });
    await _fetchPokemons(reset: true);
  }

  Future<void> _openFiltersSheet() async {
    final result = await showModalBottomSheet<_FiltersResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return FiltersSheet(
                scrollController: scrollController,
                availableTypes: _availableTypes,
                availableGenerations: _availableGenerations,
                availableRegions: _availableRegions,
                availableShapes: _availableShapes,
                initialSelectedTypes: Set<String>.from(_selectedTypes),
                initialSelectedGenerations:
                    Set<String>.from(_selectedGenerations),
                initialSelectedRegions: Set<String>.from(_selectedRegions),
                initialSelectedShapes: Set<String>.from(_selectedShapes),
                initialSortOption: _sortOption,
                initialSortAscending: _isSortAscending,
                onApply:
                    (types, generations, regions, shapes, sortOption, isAscending) {
                  Navigator.of(context).pop(
                    _FiltersResult(
                      action: _FiltersAction.apply,
                      types: Set<String>.from(types),
                      generations: Set<String>.from(generations),
                      regions: Set<String>.from(regions),
                      shapes: Set<String>.from(shapes),
                      sortOption: sortOption,
                      isAscending: isAscending,
                    ),
                  );
                },
                onClear: () {
                  Navigator.of(context).pop(
                    _FiltersResult(
                      action: _FiltersAction.clear,
                      types: <String>{},
                      generations: <String>{},
                      regions: <String>{},
                      shapes: <String>{},
                      sortOption: kDefaultSortOption,
                      isAscending: kDefaultSortAscending,
                    ),
                  );
                },
                onCancel: () {
                  Navigator.of(context).pop(
                    _FiltersResult(
                      action: _FiltersAction.cancel,
                      types: Set<String>.from(_selectedTypes),
                      generations: Set<String>.from(_selectedGenerations),
                      regions: Set<String>.from(_selectedRegions),
                      shapes: Set<String>.from(_selectedShapes),
                      sortOption: _sortOption,
                      isAscending: _isSortAscending,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );

    if (!mounted || result == null) return;

    switch (result.action) {
      case _FiltersAction.apply:
        _applyFilters(
          types: result.types,
          generations: result.generations,
          regions: result.regions,
          shapes: result.shapes,
          sortOption: result.sortOption,
          isSortAscending: result.isAscending,
        );
        break;
      case _FiltersAction.clear:
        final hasFilters = _selectedTypes.isNotEmpty ||
            _selectedGenerations.isNotEmpty ||
            _selectedRegions.isNotEmpty ||
            _selectedShapes.isNotEmpty ||
            !_isDefaultSort;
        if (!hasFilters) {
          return;
        }
        setState(() {
          _selectedTypes.clear();
          _selectedGenerations.clear();
          _selectedRegions.clear();
          _selectedShapes.clear();
          _sortOption = kDefaultSortOption;
          _isSortAscending = kDefaultSortAscending;
        });
        _resetAndFetch();
        break;
      case _FiltersAction.cancel:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accentColor = widget.accentColor;
    final heroTag = widget.heroTag;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: accentColor,
        foregroundColor: accentColor != null ? Colors.white : null,
        title: heroTag != null
            ? Hero(
                tag: heroTag,
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: accentColor != null ? Colors.white : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : Text(
                widget.title,
                style: theme.textTheme.titleLarge,
              ),
      ),
      body: Column(
        children: [
          _buildSearchBar(theme),
          if (_isFetching && !_isInitialLoading)
            const LinearProgressIndicator(minHeight: 2),
          if (_isOfflineMode) _buildOfflineBanner(theme),
          _buildSummary(theme),
          Expanded(child: _buildPokemonList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: localizations.pokedexSearchHint,
                prefixIcon: const Icon(Icons.search),
                prefixIconColor: theme.colorScheme.primary,
                suffixIcon: _searchTerm.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        icon: const Icon(Icons.clear),
                      ),
                suffixIconColor: theme.colorScheme.primary,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: localizations.pokedexFiltersTooltip,
                onPressed: _filtersLoading ? null : _openFiltersSheet,
                icon: const Icon(Icons.tune),
              ),
              if (_activeFiltersCount > 0)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Badge(
                    backgroundColor: theme.colorScheme.primary,
                    label: Text(
                      '$_activeFiltersCount',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(ThemeData theme) {
    final Color backgroundColor =
        theme.colorScheme.tertiaryContainer.withOpacity(0.85);
    final Color foregroundColor = theme.colorScheme.onTertiaryContainer;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.cloud_off_rounded,
              color: foregroundColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Modo offline activo. Algunos filtros pueden ser limitados.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(ThemeData theme) {
    final localizations = AppLocalizations.of(context)!;
    if (_pokemons.isEmpty && !_isFetching) {
      return const SizedBox.shrink();
    }
    final countText = _totalCount == 0
        ? localizations.pokedexShowingCountSimple(_pokemons.length)
        : localizations.pokedexShowingCountWithTotal(
            _pokemons.length,
            _totalCount,
          );
    final details = <String>[];
    if (_activeFiltersCount > 0) {
      details.add(localizations.pokedexActiveFilters(_activeFiltersCount));
    }
    if (!_isDefaultSort) {
      final directionText = _isSortAscending
          ? localizations.pokedexSortDirectionAscending
          : localizations.pokedexSortDirectionDescending;
      final sortLabel = '${_sortOption.label(localizations)} $directionText';
      details.add(
        localizations.pokedexFilterSummarySort(
          sortLabel,
        ),
      );
    }
    final suffix = details.isNotEmpty ? ' · ${details.join(' · ')}' : '';
    final summaryText = '$countText$suffix';
    final chips = _buildActiveFilterChipWidgets(theme);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: theme.colorScheme.secondaryContainer.withOpacity(0.45),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  summaryText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips,
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildActiveFilterChipWidgets(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final chips = <Widget>[];
    final searchValue = _debouncedSearch.trim();
    if (searchValue.isNotEmpty) {
      chips.add(
        _buildActiveChip(
          theme: theme,
          label: l10n.pokedexFilterSummarySearch(searchValue),
          onDeleted: _clearSearchFilter,
        ),
      );
    }
    for (final type in _sortedStrings(_selectedTypes)) {
      chips.add(
        _buildActiveChip(
          theme: theme,
          label: l10n.pokedexFilterSummaryType(_capitalize(type)),
          onDeleted: () => _removeTypeFilter(type),
        ),
      );
    }
    for (final generation in _sortedStrings(_selectedGenerations)) {
      chips.add(
        _buildActiveChip(
          theme: theme,
          label: l10n
              .pokedexFilterSummaryGeneration(_formatGenerationLabel(generation)),
          onDeleted: () => _removeGenerationFilter(generation),
        ),
      );
    }
    for (final region in _sortedStrings(_selectedRegions)) {
      chips.add(
        _buildActiveChip(
          theme: theme,
          label: l10n.pokedexFilterSummaryRegion(_formatRegionLabel(region)),
          onDeleted: () => _removeRegionFilter(region),
        ),
      );
    }
    for (final shape in _sortedStrings(_selectedShapes)) {
      chips.add(
        _buildActiveChip(
          theme: theme,
          label: l10n.pokedexFilterSummaryShape(_formatShapeLabel(shape)),
          onDeleted: () => _removeShapeFilter(shape),
        ),
      );
    }
    if (!_isDefaultSort) {
      final directionText =
          _isSortAscending ? l10n.pokedexSortDirectionAscending : l10n.pokedexSortDirectionDescending;
      chips.add(
        _buildActiveChip(
          theme: theme,
          label: l10n
              .pokedexFilterSummarySort('${_sortOption.label(l10n)} $directionText'),
          onDeleted: _resetSortSelection,
        ),
      );
    }
    return chips;
  }

  List<String> _sortedStrings(Iterable<String> values) {
    final list = List<String>.from(values);
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  Widget _buildActiveChip({
    required ThemeData theme,
    required String label,
    required VoidCallback onDeleted,
  }) {
    return InputChip(
      label: Text(label),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close_rounded, size: 18),
      deleteIconColor: theme.colorScheme.onSurfaceVariant,
      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.7),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }

  Widget _buildPokemonList() {
    final localizations = AppLocalizations.of(context)!;
    if (_isInitialLoading && _pokemons.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty && _pokemons.isEmpty) {
      return _ErrorView(
        message: _errorMessage,
        onRetry: () => _fetchPokemons(reset: true),
      );
    }

    if (_pokemons.isEmpty) {
      return Center(
        child: Text(localizations.pokedexNoResults),
      );
    }

    final showLoadingMore =
        _isFetching && !_isInitialLoading && _pokemons.isNotEmpty;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: _pokemons.length + (showLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index >= _pokemons.length) {
            return const _LoadingTile();
          }
          final pokemon = _pokemons[index];
          return _PokemonListTile(
            key: ValueKey('pokemon-${pokemon.id}'),
            pokemon: pokemon,
          );
        },
      ),
    );
  }
}

enum _FiltersAction { apply, clear, cancel }

class _FiltersResult {
  const _FiltersResult({
    required this.action,
    required this.types,
    required this.generations,
    required this.regions,
    required this.shapes,
    required this.sortOption,
    required this.isAscending,
  });

  final _FiltersAction action;
  final Set<String> types;
  final Set<String> generations;
  final Set<String> regions;
  final Set<String> shapes;
  final PokemonSortOption sortOption;
  final bool isAscending;
}

class FiltersSheet extends StatefulWidget {
  const FiltersSheet({
    super.key,
    required this.availableTypes,
    required this.availableGenerations,
    required this.availableRegions,
    required this.availableShapes,
    required this.initialSelectedTypes,
    required this.initialSelectedGenerations,
    required this.initialSelectedRegions,
    required this.initialSelectedShapes,
    required this.initialSortOption,
    required this.initialSortAscending,
    required this.onApply,
    required this.onClear,
    required this.onCancel,
    required this.scrollController,
  });

  final List<String> availableTypes;
  final List<String> availableGenerations;
  final List<String> availableRegions;
  final List<String> availableShapes;
  final Set<String> initialSelectedTypes;
  final Set<String> initialSelectedGenerations;
  final Set<String> initialSelectedRegions;
  final Set<String> initialSelectedShapes;
  final PokemonSortOption initialSortOption;
  final bool initialSortAscending;
  final void Function(
    Set<String> types,
    Set<String> generations,
    Set<String> regions,
    Set<String> shapes,
    PokemonSortOption sortOption,
    bool isAscending,
  ) onApply;
  final VoidCallback onClear;
  final VoidCallback onCancel;
  final ScrollController scrollController;

  @override
  State<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<FiltersSheet> {
  late Set<String> _selectedTypes;
  late Set<String> _selectedGenerations;
  late Set<String> _selectedRegions;
  late Set<String> _selectedShapes;
  late PokemonSortOption _sortOption;
  late bool _isSortAscending;

  @override
  void initState() {
    super.initState();
    _selectedTypes = Set<String>.from(widget.initialSelectedTypes);
    _selectedGenerations =
        Set<String>.from(widget.initialSelectedGenerations);
    _selectedRegions = Set<String>.from(widget.initialSelectedRegions);
    _selectedShapes = Set<String>.from(widget.initialSelectedShapes);
    _sortOption = widget.initialSortOption;
    _isSortAscending = widget.initialSortAscending;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasSelection = _selectedTypes.isNotEmpty ||
        _selectedGenerations.isNotEmpty ||
        _selectedRegions.isNotEmpty ||
        _selectedShapes.isNotEmpty ||
        _sortOption != kDefaultSortOption ||
        _isSortAscending != kDefaultSortAscending;

    return SafeArea(
      top: false,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.pokedexFiltersTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: l10n.pokedexFiltersCloseTooltip,
                    onPressed: _handleCancel,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context)
                    .copyWith(scrollbars: false),
                child: Scrollbar(
                  controller: widget.scrollController,
                  interactive: false,
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSortSection(theme, l10n),
                        const SizedBox(height: 24),
                        _buildFilterSection(
                          title: l10n.pokedexFilterSectionTypes,
                          options: widget.availableTypes,
                          selectedValues: _selectedTypes,
                          labelBuilder: _capitalize,
                          emptyMessage: l10n.pokedexFilterEmptyTypes,
                          onToggle: _toggleType,
                        ),
                        const SizedBox(height: 24),
                        _buildFilterSection(
                          title: l10n.pokedexFilterSectionGenerations,
                          options: widget.availableGenerations,
                          selectedValues: _selectedGenerations,
                          labelBuilder: _formatGenerationLabel,
                          emptyMessage: l10n.pokedexFilterEmptyGenerations,
                          onToggle: _toggleGeneration,
                        ),
                        const SizedBox(height: 24),
                        _buildFilterSection(
                          title: l10n.pokedexFilterSectionRegions,
                          options: widget.availableRegions,
                          selectedValues: _selectedRegions,
                          labelBuilder: _formatRegionLabel,
                          emptyMessage: l10n.pokedexFilterEmptyRegions,
                          onToggle: _toggleRegion,
                        ),
                        const SizedBox(height: 24),
                        _buildFilterSection(
                          title: l10n.pokedexFilterSectionShapes,
                          options: widget.availableShapes,
                          selectedValues: _selectedShapes,
                          labelBuilder: _formatShapeLabel,
                          emptyMessage: l10n.pokedexFilterEmptyShapes,
                          onToggle: _toggleShape,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                12,
                24,
                24 + MediaQuery.of(context).padding.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: hasSelection ? _handleClear : null,
                      child: Text(l10n.pokedexFiltersClear),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: _handleCancel,
                      child: Text(l10n.pokedexFiltersCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _handleApply,
                      child: Text(l10n.pokedexFiltersApply),
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

  Widget _buildSortSection(ThemeData theme, AppLocalizations l10n) {
    final directionLabel = _isSortAscending
        ? l10n.pokedexSortAscendingLabel
        : l10n.pokedexSortDescendingLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.pokedexSortSheetTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DropdownButtonFormField<PokemonSortOption>(
                value: _sortOption,
                decoration: InputDecoration(
                  labelText: l10n.pokedexSortCriteriaLabel,
                  border: const OutlineInputBorder(),
                ),
                items: PokemonSortOption.values
                    .map(
                      (option) => DropdownMenuItem<PokemonSortOption>(
                        value: option,
                        child: Text(option.label(l10n)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _sortOption = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Tooltip(
              message: directionLabel,
              child: FilledButton.tonalIcon(
                onPressed: _toggleSortDirection,
                icon: Icon(
                  _isSortAscending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                ),
                label: Text(
                  _isSortAscending
                      ? l10n.pokedexSortAscendingShort
                      : l10n.pokedexSortDescendingShort,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required Set<String> selectedValues,
    required String Function(String value) labelBuilder,
    required String emptyMessage,
    required ValueChanged<String> onToggle,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (options.isEmpty)
          Text(
            emptyMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((option) {
              final isSelected = selectedValues.contains(option);
              return FilterChip(
                label: Text(labelBuilder(option)),
                selected: isSelected,
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                backgroundColor:
                    theme.colorScheme.surfaceVariant.withOpacity(0.6),
                selectedColor: theme.colorScheme.primaryContainer,
                labelStyle: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.45)
                      : Colors.transparent,
                ),
                onSelected: (_) => onToggle(option),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _toggleType(String type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
    });
  }

  void _toggleGeneration(String generation) {
    setState(() {
      if (_selectedGenerations.contains(generation)) {
        _selectedGenerations.remove(generation);
      } else {
        _selectedGenerations.add(generation);
      }
    });
  }

  void _toggleRegion(String region) {
    setState(() {
      if (_selectedRegions.contains(region)) {
        _selectedRegions.remove(region);
      } else {
        _selectedRegions.add(region);
      }
    });
  }

  void _toggleShape(String shape) {
    setState(() {
      if (_selectedShapes.contains(shape)) {
        _selectedShapes.remove(shape);
      } else {
        _selectedShapes.add(shape);
      }
    });
  }

  void _toggleSortDirection() {
    setState(() {
      _isSortAscending = !_isSortAscending;
    });
  }

  void _handleApply() {
    widget.onApply(
      Set<String>.from(_selectedTypes),
      Set<String>.from(_selectedGenerations),
      Set<String>.from(_selectedRegions),
      Set<String>.from(_selectedShapes),
      _sortOption,
      _isSortAscending,
    );
  }

  void _handleClear() {
    setState(() {
      _selectedTypes.clear();
      _selectedGenerations.clear();
      _selectedRegions.clear();
      _selectedShapes.clear();
      _sortOption = kDefaultSortOption;
      _isSortAscending = kDefaultSortAscending;
    });
    widget.onClear();
  }

  void _handleCancel() {
    widget.onCancel();
  }
}

class _PokemonListTile extends ConsumerStatefulWidget {
  const _PokemonListTile({super.key, required this.pokemon});

  final PokemonListItem pokemon;

  @override
  ConsumerState<_PokemonListTile> createState() => _PokemonListTileState();
}

class _PokemonListTileState extends ConsumerState<_PokemonListTile> {
  bool _isPressed = false;

  void _handleTap(
    BuildContext context,
    String heroTag,
    PokemonListItem pokemon,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          pokemonId: pokemon.id,
          pokemonName: pokemon.name,
          initialPokemon: pokemon,
          heroTag: heroTag,
        ),
      ),
    );
  }

  Color _shiftLightness(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final double lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final favoritesController = ref.watch(favoritesControllerProvider);
    final pokemon = favoritesController.applyFavoriteState(widget.pokemon);
    final isFavorite = favoritesController.isFavorite(widget.pokemon.id);

    return _buildTile(
      context,
      pokemon: pokemon,
      isFavorite: isFavorite,
      favoritesController: favoritesController,
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required PokemonListItem pokemon,
    required bool isFavorite,
    required FavoritesController favoritesController,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final heroTag = 'pokemon-artwork-${pokemon.id}';
    final primaryTypeKey =
        pokemon.types.isNotEmpty ? pokemon.types.first.toLowerCase() : 'normal';
    final baseColor =
        pokemonTypeColors[primaryTypeKey] ?? theme.colorScheme.primary;
    final gradient = LinearGradient(
      colors: [
        _shiftLightness(baseColor, 0.18),
        _shiftLightness(baseColor, -0.06),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final textColor = Colors.white;
    final displayTypes =
        pokemon.types.isNotEmpty ? pokemon.types : const <String>['unknown'];
    final statBadges = pokemon.stats.take(3).toList();

    final semanticLabel = l10n.pokedexCardSemanticLabel(pokemon.name);
    final semanticHint = l10n.pokedexCardSemanticHint(pokemon.name);

    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      scale: _isPressed ? 0.97 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.28),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Semantics(
          button: true,
          label: semanticLabel,
          hint: semanticHint,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            clipBehavior: Clip.antiAlias,
            child: InkResponse(
              containedInkWell: true,
              highlightShape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(28),
              onHighlightChanged: (value) {
                if (_isPressed != value) {
                  setState(() => _isPressed = value);
                }
              },
              onTap: () => _handleTap(context, heroTag, pokemon),
              child: Stack(
                children: [
                  Positioned(
                    top: -14,
                  right: -14,
                  child: Icon(
                    Icons.catching_pokemon,
                    size: 96,
                    color: textColor.withOpacity(0.12),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.22),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      splashRadius: 22,
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            isFavorite ? Colors.redAccent : Colors.white,
                      ),
                      tooltip: isFavorite
                          ? l10n.detailFavoriteRemoveTooltip
                          : l10n.detailFavoriteAddTooltip,
                      onPressed: () {
                        favoritesController.toggleFavorite(pokemon);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      PokemonArtwork(
                        heroTag: heroTag,
                        imageUrl: pokemon.imageUrl,
                        size: 90,
                        borderRadius: 24,
                        padding: const EdgeInsets.all(10),
                        showShadow: false,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatPokemonNumber(pokemon.id),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: textColor.withOpacity(0.88),
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              pokemon.name.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: displayTypes
                                  .map(
                                    (type) => _PokemonTypeChip(
                                      type: type,
                                      backgroundColor:
                                          textColor.withOpacity(0.16),
                                      foregroundColor: textColor,
                                    ),
                                  )
                                  .toList(),
                            ),
                            if (statBadges.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: statBadges
                                    .map(
                                      (stat) => _PokemonStatBadge(
                                        stat: stat,
                                        backgroundColor:
                                            textColor.withOpacity(0.14),
                                        foregroundColor: textColor,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: textColor.withOpacity(0.9),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class _PokemonTypeChip extends StatelessWidget {
  const _PokemonTypeChip({
    required this.type,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String type;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor =
        backgroundColor ?? theme.colorScheme.secondaryContainer.withOpacity(0.85);
    final fgColor = foregroundColor ?? theme.colorScheme.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        type.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _PokemonStatBadge extends StatelessWidget {
  const _PokemonStatBadge({
    required this.stat,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final PokemonStat stat;
  final Color backgroundColor;
  final Color foregroundColor;

  String _statLabel(String name) {
    switch (name.toLowerCase()) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'ATK';
      case 'defense':
        return 'DEF';
      case 'special-attack':
        return 'SPA';
      case 'special-defense':
        return 'SPD';
      case 'speed':
        return 'SPE';
      default:
        return name.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${_statLabel(stat.name)} ${stat.baseStat}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}

String _capitalizeWords(String value) {
  final sanitized = value.replaceAll(RegExp(r'[_-]+'), ' ').trim();
  if (sanitized.isEmpty) return sanitized;
  final parts = sanitized.split(RegExp(r'\s+'));
  return parts
      .map((part) {
        final lower = part.toLowerCase();
        if (lower.isEmpty) return lower;
        return lower[0].toUpperCase() + lower.substring(1);
      })
      .join(' ');
}

String _formatGenerationLabel(String value) {
  final sanitized = value.replaceAll('-', ' ').trim();
  if (sanitized.isEmpty) return sanitized;
  final parts = sanitized.split(RegExp(r'\s+'));
  if (parts.isEmpty) return sanitized;
  if (parts.first.toLowerCase() == 'generation') {
    final suffix = parts
        .skip(1)
        .map((part) => part.toUpperCase())
        .join(' ')
        .trim();
    return suffix.isEmpty ? 'Generación' : 'Generación $suffix';
  }
  return parts.map(_capitalize).join(' ');
}

String _formatRegionLabel(String value) {
  return _capitalizeWords(value);
}

String _formatShapeLabel(String value) {
  return _capitalizeWords(value);
}

String _formatPokemonNumber(int id) {
  return '#${id.toString().padLeft(3, '0')}';
}
