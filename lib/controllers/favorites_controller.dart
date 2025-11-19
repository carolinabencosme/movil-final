import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/favorites_repository.dart';

class FavoritesController extends ChangeNotifier {
  FavoritesController({
    required FavoritesRepository repository,
    String? currentUserEmail,
  })  : _repository = repository,
        _currentUserEmail = currentUserEmail,
        _favoriteIds = repository.loadFavoritesForUser(currentUserEmail);

  final FavoritesRepository _repository;
  String? _currentUserEmail;
  final Set<int> _favoriteIds;

  UnmodifiableSetView<int> get favoriteIds => UnmodifiableSetView(_favoriteIds);

  bool isFavorite(int pokemonId) => _favoriteIds.contains(pokemonId);

  /// Updates the current user and loads their favorites.
  /// Call this when a user logs in or the authentication state changes.
  void setCurrentUser(String? userEmail) {
    if (_currentUserEmail == userEmail) {
      return;
    }
    _currentUserEmail = userEmail;
    _favoriteIds.clear();
    if (userEmail != null && userEmail.isNotEmpty) {
      final userFavorites = _repository.loadFavoritesForUser(userEmail);
      _favoriteIds.addAll(userFavorites);
    }
    notifyListeners();
  }

  /// Clears all favorites for the current user.
  /// Typically called when logging out.
  void clearFavorites() {
    _favoriteIds.clear();
    _currentUserEmail = null;
    notifyListeners();
  }

  Future<void> toggleFavorite(int pokemonId) async {
    final isFavorite = _favoriteIds.contains(pokemonId);
    if (isFavorite) {
      _favoriteIds.remove(pokemonId);
    } else {
      _favoriteIds.add(pokemonId);
    }
    notifyListeners();
    await _persistFavorites();
  }

  Future<void> _persistFavorites() async {
    final stopwatch = Stopwatch()..start();
    await _repository.saveFavoritesForUser(_currentUserEmail, _favoriteIds);
    if (kDebugMode) {
      debugPrint('Saved ${_favoriteIds.length} favorites for user '
          '${_currentUserEmail ?? "unknown"} in '
          '${stopwatch.elapsedMilliseconds}ms');
    }
  }
}

class FavoritesScope extends InheritedNotifier<FavoritesController> {
  const FavoritesScope({
    super.key,
    required FavoritesController notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static FavoritesController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<FavoritesScope>();
    assert(scope != null,
        'FavoritesScope.of() called with a context that does not contain a FavoritesScope.');
    final notifier = scope?.notifier;
    if (notifier == null) {
      throw StateError('FavoritesScope.of() found a null notifier');
    }
    return notifier;
  }

  static FavoritesController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FavoritesScope>()
        ?.notifier;
  }
}
