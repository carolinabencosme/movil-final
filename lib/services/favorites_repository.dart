import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/favorites_model.dart';

/// Repositorio que gestiona el almacenamiento persistente de Pokémon favoritos
class FavoritesRepository extends ChangeNotifier {
  FavoritesRepository._(this._favoritesBox);

  static const String favoritesBoxName = 'favorites_box';

  final Box<FavoritePokemon> _favoritesBox;

  /// Inicializa el repositorio y abre el box de Hive
  static Future<FavoritesRepository> init() async {
    final adapter = FavoritePokemonAdapter();
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }

    final favoritesBox = await Hive.openBox<FavoritePokemon>(favoritesBoxName);
    return FavoritesRepository._(favoritesBox);
  }

  /// Obtiene la lista de IDs de Pokémon favoritos
  Set<int> get favoriteIds {
    return _favoritesBox.values.map((fav) => fav.id).toSet();
  }

  /// Obtiene la lista completa de Pokémon favoritos
  List<FavoritePokemon> get favorites {
    return _favoritesBox.values.toList();
  }

  /// Verifica si un Pokémon es favorito
  bool isFavorite(int pokemonId) {
    return _favoritesBox.containsKey(pokemonId);
  }

  /// Agrega un Pokémon a favoritos
  Future<void> addFavorite(FavoritePokemon pokemon) async {
    await _favoritesBox.put(pokemon.id, pokemon);
    notifyListeners();
  }

  /// Remueve un Pokémon de favoritos
  Future<void> removeFavorite(int pokemonId) async {
    await _favoritesBox.delete(pokemonId);
    notifyListeners();
  }

  /// Alterna el estado de favorito de un Pokémon
  Future<void> toggleFavorite(FavoritePokemon pokemon) async {
    if (isFavorite(pokemon.id)) {
      await removeFavorite(pokemon.id);
    } else {
      await addFavorite(pokemon);
    }
  }

  /// Limpia todos los favoritos
  Future<void> clearAll() async {
    await _favoritesBox.clear();
    notifyListeners();
  }
}
