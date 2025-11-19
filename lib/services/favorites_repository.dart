import 'package:shared_preferences/shared_preferences.dart';

/// Simple local persistence layer for storing favorite Pokémon ids.
///
/// Uses `SharedPreferences` to keep the latest selection in disk so we can
/// restore it instantly when relaunching the app.
class FavoritesRepository {
  FavoritesRepository._(this._prefs);

  static const String _favoritesKey = 'favorite_pokemon_ids';

  final SharedPreferences _prefs;

  static Future<FavoritesRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return FavoritesRepository._(prefs);
  }

  /// Loads the stored favorite Pokémon ids.
  Set<int> loadFavorites() {
    final stored = _prefs.getStringList(_favoritesKey);
    if (stored == null) {
      return <int>{};
    }
    return stored
        .map((value) => int.tryParse(value))
        .whereType<int>()
        .toSet();
  }

  Future<void> saveFavorites(Set<int> favorites) async {
    final serialized = favorites.map((id) => id.toString()).toList();
    await _prefs.setStringList(_favoritesKey, serialized);
  }
}
