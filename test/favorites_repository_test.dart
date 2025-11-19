import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/services/favorites_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FavoritesRepository', () {
    late FavoritesRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = FavoritesRepository._(prefs);
    });

    test('loadFavoritesForUser returns empty set for null user', () {
      final favorites = repository.loadFavoritesForUser(null);
      expect(favorites, isEmpty);
    });

    test('loadFavoritesForUser returns empty set for empty email', () {
      final favorites = repository.loadFavoritesForUser('');
      expect(favorites, isEmpty);
    });

    test('loadFavoritesForUser returns empty set for new user', () {
      final favorites = repository.loadFavoritesForUser('test@example.com');
      expect(favorites, isEmpty);
    });

    test('saveFavoritesForUser and loadFavoritesForUser work correctly', () async {
      const email = 'test@example.com';
      final testFavorites = {1, 4, 7, 25, 150};

      await repository.saveFavoritesForUser(email, testFavorites);
      final loaded = repository.loadFavoritesForUser(email);

      expect(loaded, equals(testFavorites));
    });

    test('different users have separate favorites', () async {
      const user1 = 'user1@example.com';
      const user2 = 'user2@example.com';
      final favorites1 = {1, 4, 7};
      final favorites2 = {25, 150};

      await repository.saveFavoritesForUser(user1, favorites1);
      await repository.saveFavoritesForUser(user2, favorites2);

      final loaded1 = repository.loadFavoritesForUser(user1);
      final loaded2 = repository.loadFavoritesForUser(user2);

      expect(loaded1, equals(favorites1));
      expect(loaded2, equals(favorites2));
    });

    test('saveFavoritesForUser does nothing for null email', () async {
      await repository.saveFavoritesForUser(null, {1, 2, 3});
      // Should not throw and should not save anything
    });

    test('email normalization works correctly', () async {
      final favorites = {1, 2, 3};

      // Save with uppercase
      await repository.saveFavoritesForUser('TEST@EXAMPLE.COM', favorites);

      // Load with lowercase
      final loaded = repository.loadFavoritesForUser('test@example.com');

      expect(loaded, equals(favorites));
    });

    test('clearAllFavorites removes all favorite data', () async {
      await repository.saveFavoritesForUser('user1@example.com', {1, 2, 3});
      await repository.saveFavoritesForUser('user2@example.com', {4, 5, 6});

      await repository.clearAllFavorites();

      final loaded1 = repository.loadFavoritesForUser('user1@example.com');
      final loaded2 = repository.loadFavoritesForUser('user2@example.com');

      expect(loaded1, isEmpty);
      expect(loaded2, isEmpty);
    });

    test('updating favorites for user replaces old favorites', () async {
      const email = 'test@example.com';
      final initialFavorites = {1, 2, 3};
      final updatedFavorites = {4, 5, 6, 7};

      await repository.saveFavoritesForUser(email, initialFavorites);
      await repository.saveFavoritesForUser(email, updatedFavorites);

      final loaded = repository.loadFavoritesForUser(email);

      expect(loaded, equals(updatedFavorites));
    });
  });
}
