import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/pokemon_model.dart';
import '../queries/get_pokemon_list.dart';
import '../queries/get_pokemon_types.dart';
import '../widgets/pokemon_artwork.dart';
import 'detail_screen.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({
    super.key,
    this.heroTag,
    this.accentColor,
    this.title = 'Pokédex',
  });

  final String? heroTag;
  final Color? accentColor;
  final String title;

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  static const int _pageSize = 30;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedTypes = <String>{};
  final Set<String> _selectedGenerations = <String>{};

  Timer? _debounce;
  List<PokemonListItem> _pokemons = <PokemonListItem>[];
  List<String> _availableTypes = <String>[];
  List<String> _availableGenerations = <String>[];

  bool _isFetching = false;
  bool _isInitialLoading = true;
  bool _hasMore = true;
  bool _filtersLoading = false;
  bool _didInit = false;

  int _totalCount = 0;
  int _activeFiltersCount = 0;
  String _searchTerm = '';
  String _debouncedSearch = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isFetching) {
      return;
    }
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchPokemons();
    }
  }

  void _onSearchChanged(String value) {
    setState(() => _searchTerm = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _debouncedSearch = value.trim();
      _resetAndFetch();
    });
  }

  void _toggleType(String type) {
    final updatedTypes = Set<String>.from(_selectedTypes);
    if (updatedTypes.contains(type)) {
      updatedTypes.remove(type);
    } else {
      updatedTypes.add(type);
    }
    _applyFilters(types: updatedTypes);
  }

  void _applyFilters({
    Set<String>? types,
    Set<String>? generations,
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
    });

    if (hasChanges) {
      _resetAndFetch();
    }
  }

  int _calculateActiveFiltersCount() {
    final searchCount = _debouncedSearch.trim().isEmpty ? 0 : 1;
    return _selectedTypes.length + _selectedGenerations.length + searchCount;
  }

  void _resetAndFetch() {
    setState(() {
      _hasMore = true;
      _totalCount = 0;
      _errorMessage = '';
      _activeFiltersCount = _calculateActiveFiltersCount();
    });
    _fetchPokemons(reset: true);
  }

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
      setState(() {
        _availableTypes = types;
        _availableGenerations = generations;
        _filtersLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _filtersLoading = false);
    }
  }

  Future<void> _fetchPokemons({bool reset = false}) async {
    if (_isFetching || (!_hasMore && !reset)) {
      return;
    }

    final offset = reset ? 0 : _pokemons.length;
    setState(() {
      _isFetching = true;
      if (_pokemons.isEmpty) {
        _isInitialLoading = true;
      }
    });

    final client = GraphQLProvider.of(context).value;
    final searchValue = _debouncedSearch.toLowerCase();
    final numericId = int.tryParse(_debouncedSearch);
    final includeIdFilter = numericId != null && _debouncedSearch.isNotEmpty;
    final includeTypeFilter = _selectedTypes.isNotEmpty;
    final includeGenerationFilter = _selectedGenerations.isNotEmpty;
    final shouldPaginate = !includeIdFilter;

    final document = gql(
      buildPokemonListQuery(
        includeIdFilter: includeIdFilter,
        includeTypeFilter: includeTypeFilter,
        includeGenerationFilter: includeGenerationFilter,
        includePagination: shouldPaginate,
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

    try {
      final result = await client.query(
        QueryOptions(
          document: document,
          variables: variables,
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (!mounted) return;

      if (result.hasException) {
        _handleError(result.exception!, reset: reset);
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

      setState(() {
        if (reset) {
          _pokemons = results;
        } else {
          _pokemons = shouldPaginate
              ? <PokemonListItem>[..._pokemons, ...results]
              : results;
        }
        _totalCount = count ?? _pokemons.length;
        final expectedTotal = _totalCount == 0 ? _pokemons.length : _totalCount;
        _hasMore = shouldPaginate && _pokemons.length < expectedTotal;
        _errorMessage = '';
      });
    } catch (error) {
      if (!mounted) return;
      _handleGenericError(error, reset: reset);
    } finally {
      if (!mounted) return;
      setState(() {
        _isFetching = false;
        _isInitialLoading = false;
      });
    }
  }

  void _handleError(OperationException exception, {required bool reset}) {
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
                initialSelectedTypes: Set<String>.from(_selectedTypes),
                initialSelectedGenerations:
                    Set<String>.from(_selectedGenerations),
                onApply: (types, generations) {
                  Navigator.of(context).pop(
                    _FiltersResult(
                      action: _FiltersAction.apply,
                      types: Set<String>.from(types),
                      generations: Set<String>.from(generations),
                    ),
                  );
                },
                onClear: () {
                  Navigator.of(context).pop(
                    _FiltersResult(
                      action: _FiltersAction.clear,
                      types: <String>{},
                      generations: <String>{},
                    ),
                  );
                },
                onCancel: () {
                  Navigator.of(context).pop(
                    _FiltersResult(
                      action: _FiltersAction.cancel,
                      types: Set<String>.from(_selectedTypes),
                      generations: Set<String>.from(_selectedGenerations),
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
        );
        break;
      case _FiltersAction.clear:
        if (_selectedTypes.isEmpty && _selectedGenerations.isEmpty) {
          return;
        }
        setState(() {
          _selectedTypes.clear();
          _selectedGenerations.clear();
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
    final accentColor = widget.accentColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: accentColor,
        foregroundColor: accentColor != null ? Colors.white : null,
        title: widget.heroTag != null
            ? Hero(
                tag: widget.heroTag!,
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
          _buildSummary(theme),
          Expanded(child: _buildPokemonList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o número',
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
                tooltip: 'Filtros',
                onPressed: _openFilters,
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

  void _openFilters() {
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildTypeFilters(theme),
          ),
        );
      },
    );
  }

  Widget _buildTypeFilters(ThemeData theme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _filtersLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(),
            )
          : _availableTypes.isEmpty
              ? const SizedBox.shrink()
              : Scrollbar(
                  child: SingleChildScrollView(
                    primary: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _availableTypes
                          .map((type) {
                            final isSelected = _selectedTypes.contains(type);
                            return FilterChip(
                              label: Text(_capitalize(type)),
                              selected: isSelected,
                              showCheckmark: false,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              backgroundColor: theme.colorScheme.surfaceVariant
                                  .withOpacity(0.6),
                              selectedColor:
                                  theme.colorScheme.primaryContainer,
                              labelStyle: theme.textTheme.labelLarge?.copyWith(
                                color: isSelected
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                        .withOpacity(0.45)
                                    : Colors.transparent,
                              ),
                              onSelected: (_) => _toggleType(type),
                            );
                          })
                          .toList(),
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummary(ThemeData theme) {
    if (_pokemons.isEmpty && !_isFetching) {
      return const SizedBox.shrink();
    }
    final countText = _totalCount == 0
        ? 'Mostrando ${_pokemons.length} Pokémon'
        : 'Mostrando ${_pokemons.length} de $_totalCount Pokémon';
    final filtersSuffix = _activeFiltersCount > 0
        ? ' · $_activeFiltersCount filtro${_activeFiltersCount == 1 ? '' : 's'} activos'
        : '';
    final summaryText = '$countText$filtersSuffix';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
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
    );
  }

  Widget _buildPokemonList() {
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
      return const Center(
        child: Text('No se encontraron Pokémon para los filtros actuales.'),
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
          return _PokemonListTile(pokemon: pokemon);
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
  });

  final _FiltersAction action;
  final Set<String> types;
  final Set<String> generations;
}

class FiltersSheet extends StatefulWidget {
  const FiltersSheet({
    super.key,
    required this.availableTypes,
    required this.availableGenerations,
    required this.initialSelectedTypes,
    required this.initialSelectedGenerations,
    required this.onApply,
    required this.onClear,
    required this.onCancel,
    required this.scrollController,
  });

  final List<String> availableTypes;
  final List<String> availableGenerations;
  final Set<String> initialSelectedTypes;
  final Set<String> initialSelectedGenerations;
  final void Function(Set<String> types, Set<String> generations) onApply;
  final VoidCallback onClear;
  final VoidCallback onCancel;
  final ScrollController scrollController;

  @override
  State<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<FiltersSheet> {
  late Set<String> _selectedTypes;
  late Set<String> _selectedGenerations;

  @override
  void initState() {
    super.initState();
    _selectedTypes = Set<String>.from(widget.initialSelectedTypes);
    _selectedGenerations =
        Set<String>.from(widget.initialSelectedGenerations);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSelection =
        _selectedTypes.isNotEmpty || _selectedGenerations.isNotEmpty;

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
                      'Filtros',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Cerrar',
                    onPressed: _handleCancel,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection(
                      title: 'Tipos',
                      options: widget.availableTypes,
                      selectedValues: _selectedTypes,
                      labelBuilder: _capitalize,
                      emptyMessage: 'No hay tipos disponibles por ahora.',
                      onToggle: _toggleType,
                    ),
                    const SizedBox(height: 24),
                    _buildFilterSection(
                      title: 'Generaciones',
                      options: widget.availableGenerations,
                      selectedValues: _selectedGenerations,
                      labelBuilder: _formatGenerationLabel,
                      emptyMessage:
                          'No hay generaciones disponibles por ahora.',
                      onToggle: _toggleGeneration,
                    ),
                  ],
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
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: _handleCancel,
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _handleApply,
                      child: const Text('Aplicar'),
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

  void _handleApply() {
    widget.onApply(
      Set<String>.from(_selectedTypes),
      Set<String>.from(_selectedGenerations),
    );
  }

  void _handleClear() {
    setState(() {
      _selectedTypes.clear();
      _selectedGenerations.clear();
    });
    widget.onClear();
  }

  void _handleCancel() {
    widget.onCancel();
  }
}

class _PokemonListTile extends StatelessWidget {
  const _PokemonListTile({required this.pokemon});

  final PokemonListItem pokemon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heroTag = 'pokemon-image-${pokemon.id}';
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(
                pokemonId: pokemon.id,
                initialPokemon: pokemon,
                heroTag: heroTag,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: heroTag,
                child: PokemonArtwork(
                  imageUrl: pokemon.imageUrl,
                  size: 86,
                  borderRadius: 24,
                  padding: const EdgeInsets.all(10),
                  showShadow: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text(
                            _formatPokemonNumber(pokemon.id),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _capitalize(pokemon.name),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (pokemon.types.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: pokemon.types
                            .map((type) => _PokemonTypeChip(type: type))
                            .toList(),
                      )
                    else
                      Text(
                        'Tipo desconocido',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: theme.colorScheme.primary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PokemonTypeChip extends StatelessWidget {
  const _PokemonTypeChip({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(_capitalize(type)),
      backgroundColor:
          theme.colorScheme.secondaryContainer.withOpacity(0.85),
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSecondaryContainer,
        fontWeight: FontWeight.w600,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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

String _formatPokemonNumber(int id) {
  return '#${id.toString().padLeft(3, '0')}';
}
