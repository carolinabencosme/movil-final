import 'dart:async';

import 'package:hive/hive.dart';

import '../models/pokemon_model.dart';
import 'pokemon_cache_service.dart';
import 'pokemon_hive_adapters.dart';

/// Repositorio que gestiona la persistencia de favoritos usando Hive.
///
/// Mantiene dos cajas:
/// - Una con los IDs marcados como favoritos.
/// - Otra con un caché de [PokemonListItem] para reconstruir la UI rápidamente.
class FavoritesRepository extends ChangeNotifier {
  FavoritesRepository._(this._favoritesBox, this._pokemonCacheService)
      : _favoriteIds = _favoritesBox.keys.whereType<int>().toSet();

  static const String _favoritesBoxName = 'favorites_ids_box';

  final Box<bool> _favoritesBox;
  final PokemonCacheService _pokemonCacheService;

  final Set<int> _favoriteIds;

  /// Inicializa Hive y abre las cajas necesarias.
  static Future<FavoritesRepository> init(
    PokemonCacheService cacheService,
  ) async {
    registerPokemonHiveAdapters();

    final Box<bool> favoritesBox = await Hive.openBox<bool>(_favoritesBoxName);

    final FavoritesRepository repository =
        FavoritesRepository._(favoritesBox, cacheService);
    await repository._normalizeCachedFavorites();
    return repository;
  }

  /// Lista de IDs favoritos ordenados ascendentemente.
  List<int> get favoriteIds {
    final List<int> ids = _favoriteIds.toList()..sort();
    return List<int>.unmodifiable(ids);
  }

  /// Lista de Pokémon favoritos actualmente almacenados.
  List<PokemonListItem> get favoritePokemons {
    final List<PokemonListItem> favorites = _favoriteIds.map((int id) {
      final PokemonListItem? cached = _pokemonCacheService.getPokemon(id);
      if (cached != null) {
        return _withFavoriteState(cached);
      }
      return PokemonListItem(
        id: id,
        name: 'Pokémon #$id',
        imageUrl: '',
        types: const <String>[],
        stats: const <PokemonStat>[],
        isFavorite: true,
      );
    }).toList()
      ..sort((PokemonListItem a, PokemonListItem b) => a.id.compareTo(b.id));
    return List<PokemonListItem>.unmodifiable(favorites);
  }

  /// Obtiene el estado de favorito para un ID determinado.
  bool isFavorite(int pokemonId) => _favoriteIds.contains(pokemonId);

  /// Devuelve el Pokémon en caché (si existe) con el estado de favorito actualizado.
  PokemonListItem? getCachedPokemon(int pokemonId) {
    final PokemonListItem? cached = _pokemonCacheService.getPokemon(pokemonId);
    if (cached == null) {
      return null;
    }
    return _withFavoriteState(cached);
  }

  /// Actualiza el estado de favorito de un Pokémon (lo agrega o lo quita).
  Future<void> toggleFavorite(PokemonListItem pokemon) async {
    final int id = pokemon.id;
    if (id <= 0) {
      return;
    }

    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
      await _favoritesBox.delete(id);
      final PokemonListItem updated = _withFavoriteState(
        pokemon.copyWith(isFavorite: false),
      );
      await _pokemonCacheService.cachePokemon(updated);
    } else {
      _favoriteIds.add(id);
      await _favoritesBox.put(id, true);
      final PokemonListItem updated = _withFavoriteState(
        pokemon.copyWith(isFavorite: true),
      );
      await _pokemonCacheService.cachePokemon(updated);
    }

    notifyListeners();
  }

  /// Guarda o actualiza un Pokémon individual en el caché.
  Future<void> cachePokemon(PokemonListItem pokemon) async {
    final PokemonListItem normalized = _withFavoriteState(pokemon);
    await _pokemonCacheService.cachePokemon(normalized);
    notifyListeners();
  }

  /// Guarda múltiples Pokémon en el caché minimizando escrituras redundantes.
  Future<void> cachePokemons(Iterable<PokemonListItem> pokemons) async {
    final Iterable<PokemonListItem> normalized =
        pokemons.map(_withFavoriteState);

    await _pokemonCacheService.cachePokemons(normalized);
    notifyListeners();
  }

  /// Devuelve una copia del Pokémon aplicando el estado de favorito almacenado.
  PokemonListItem withFavoriteState(PokemonListItem pokemon) {
    return _withFavoriteState(pokemon);
  }

  /// Aplica el estado de favorito a una lista completa de Pokémon.
  List<PokemonListItem> withFavoriteStateForList(
    Iterable<PokemonListItem> pokemons,
  ) {
    return pokemons.map(_withFavoriteState).toList(growable: false);
  }

  Future<void> _normalizeCachedFavorites() async {
    final List<Future<void>> operations = <Future<void>>[];

    for (final PokemonListItem pokemon
        in _pokemonCacheService.getAll(sorted: false)) {
      final PokemonListItem normalized = _withFavoriteState(pokemon);
      if (pokemon.isFavorite != normalized.isFavorite) {
        operations.add(_pokemonCacheService.cachePokemon(normalized));
      }
    }

    if (operations.isNotEmpty) {
      await Future.wait(operations);
    }
  }

  PokemonListItem _withFavoriteState(PokemonListItem pokemon) {
    final bool shouldBeFavorite = _favoriteIds.contains(pokemon.id);
    if (pokemon.isFavorite == shouldBeFavorite) {
      return pokemon;
    }
    return pokemon.copyWith(isFavorite: shouldBeFavorite);
  }

  @override
  void dispose() {
    unawaited(_favoritesBox.close());
    super.dispose();
  }
}
