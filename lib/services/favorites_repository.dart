import 'package:shared_preferences/shared_preferences.dart';

/// Simple local persistence layer for storing favorite Pokémon ids per user.
///
/// Uses `SharedPreferences` to keep the latest selection in disk so we can
/// restore it instantly when relaunching the app.
/// 
/// Favorites are stored per user, using the user's email as part of the key.
class FavoritesRepository {
  FavoritesRepository._(this._prefs);

  static const String _favoritesKeyPrefix = 'favorite_pokemon_ids';

  final SharedPreferences _prefs;

  static Future<FavoritesRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return FavoritesRepository._(prefs);
  }

  /// Generates a unique key for storing favorites for a specific user.
  String _getUserKey(String? userEmail) {
    if (userEmail == null || userEmail.isEmpty) {
      return _favoritesKeyPrefix; // Fallback for backward compatibility
    }
    final normalizedEmail = userEmail.trim().toLowerCase();
    return '${_favoritesKeyPrefix}_$normalizedEmail';
  }

  /// Loads the stored favorite Pokémon ids for a specific user.
  /// If [userEmail] is null, returns an empty set.
  Set<int> loadFavoritesForUser(String? userEmail) {
    if (userEmail == null || userEmail.isEmpty) {
      return <int>{};
    }
    final key = _getUserKey(userEmail);
    final stored = _prefs.getStringList(key);
    if (stored == null) {
      return <int>{};
    }
    return stored
        .map((value) => int.tryParse(value))
        .whereType<int>()
        .toSet();
  }

  /// Saves favorites for a specific user.
  /// If [userEmail] is null, does nothing.
  Future<void> saveFavoritesForUser(String? userEmail, Set<int> favorites) async {
    if (userEmail == null || userEmail.isEmpty) {
      return;
    }
    final key = _getUserKey(userEmail);
    final serialized = favorites.map((id) => id.toString()).toList();
    await _prefs.setStringList(key, serialized);
  }

  /// Clears all favorites data. Used for testing or data reset.
  Future<void> clearAllFavorites() async {
    final allKeys = _prefs.getKeys();
    final favoriteKeys = allKeys.where((key) => key.startsWith(_favoritesKeyPrefix));
    for (final key in favoriteKeys) {
      await _prefs.remove(key);
    }
  }
}
