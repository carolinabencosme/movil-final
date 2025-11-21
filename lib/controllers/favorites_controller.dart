import 'package:flutter/material.dart';

import '../models/favorites_model.dart';
import '../services/favorites_repository.dart';

/// Controlador que gestiona el estado de favoritos en la aplicación
class FavoritesController extends ChangeNotifier {
  FavoritesController({required FavoritesRepository repository})
      : _repository = repository {
    _repository.addListener(_onRepositoryChanged);
  }

  final FavoritesRepository _repository;

  /// Obtiene el conjunto de IDs de Pokémon favoritos
  Set<int> get favoriteIds => _repository.favoriteIds;

  /// Obtiene la lista completa de Pokémon favoritos
  List<FavoritePokemon> get favorites => _repository.favorites;

  /// Verifica si un Pokémon es favorito
  bool isFavorite(int pokemonId) {
    return _repository.isFavorite(pokemonId);
  }

  /// Agrega un Pokémon a favoritos
  Future<void> addFavorite(FavoritePokemon pokemon) async {
    await _repository.addFavorite(pokemon);
  }

  /// Remueve un Pokémon de favoritos
  Future<void> removeFavorite(int pokemonId) async {
    await _repository.removeFavorite(pokemonId);
  }

  /// Alterna el estado de favorito de un Pokémon
  Future<void> toggleFavorite(FavoritePokemon pokemon) async {
    await _repository.toggleFavorite(pokemon);
  }

  /// Limpia todos los favoritos
  Future<void> clearAll() async {
    await _repository.clearAll();
  }

  void _onRepositoryChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }
}

/// InheritedNotifier que proporciona acceso al FavoritesController en el árbol de widgets
class FavoritesScope extends InheritedNotifier<FavoritesController> {
  const FavoritesScope({
    super.key,
    required FavoritesController notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  /// Obtiene el FavoritesController del contexto
  /// Lanza un error si no se encuentra un FavoritesScope en el árbol
  static FavoritesController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FavoritesScope>();
    assert(scope != null,
        'FavoritesScope.of() called with a context that does not contain a FavoritesScope.');
    if (scope == null) {
      throw StateError(
        'FavoritesScope.of() called with a context that does not contain a FavoritesScope.',
      );
    }

    final controller = scope.notifier;
    if (controller == null) {
      throw StateError(
        'FavoritesScope.of() called with a FavoritesScope that has a null notifier.',
      );
    }

    return controller;
  }

  /// Intenta obtener el FavoritesController del contexto
  /// Retorna null si no se encuentra un FavoritesScope en el árbol
  static FavoritesController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FavoritesScope>()
        ?.notifier;
  }
}
