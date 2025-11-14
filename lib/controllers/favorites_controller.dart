import 'package:flutter/material.dart';

import '../models/pokemon_model.dart';
import '../services/favorites_repository.dart';

class FavoritesController extends ChangeNotifier {
  FavoritesController({required FavoritesRepository repository})
      : _repository = repository {
    _repository.addListener(_onRepositoryChanged);
  }

  final FavoritesRepository _repository;

  List<int> get favoriteIds => _repository.favoriteIds;

  List<PokemonListItem> get favorites => _repository.favoritePokemons;

  bool isFavorite(int pokemonId) => _repository.isFavorite(pokemonId);

  PokemonListItem applyFavoriteState(PokemonListItem pokemon) {
    return _repository.withFavoriteState(pokemon);
  }

  List<PokemonListItem> applyFavoriteStateToList(
    Iterable<PokemonListItem> pokemons,
  ) {
    return _repository.withFavoriteStateForList(pokemons);
  }

  PokemonListItem? getCachedPokemon(int pokemonId) {
    return _repository.getCachedPokemon(pokemonId);
  }

  Future<void> toggleFavorite(PokemonListItem pokemon) async {
    await _repository.toggleFavorite(pokemon);
  }

  Future<void> cachePokemon(PokemonListItem pokemon) async {
    await _repository.cachePokemon(pokemon);
  }

  Future<void> cachePokemons(Iterable<PokemonListItem> pokemons) async {
    await _repository.cachePokemons(pokemons);
  }

  void _onRepositoryChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    _repository.dispose();
    super.dispose();
  }
}

class FavoritesScope extends InheritedNotifier<FavoritesController> {
  const FavoritesScope({
    super.key,
    required FavoritesController notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static FavoritesController of(BuildContext context) {
    final FavoritesScope? scope =
        context.dependOnInheritedWidgetOfExactType<FavoritesScope>();
    assert(scope != null,
        'FavoritesScope.of() called with a context that does not contain a FavoritesScope.');
    if (scope == null) {
      throw StateError(
        'FavoritesScope.of() called with a context that does not contain a FavoritesScope.',
      );
    }

    final FavoritesController? controller = scope.notifier;
    if (controller == null) {
      throw StateError(
        'FavoritesScope.of() called with a FavoritesScope that has a null notifier.',
      );
    }

    return controller;
  }

  static FavoritesController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FavoritesScope>()?.notifier;
  }
}
