import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/controllers/favorites_controller.dart';
import 'package:pokedex/services/favorites_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FavoritesController', () {
    late FavoritesRepository repository;
    late FavoritesController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repository = await FavoritesRepository.init();
    });

    test('initializes with empty favorites for null user', () {
      controller = FavoritesController(
        repository: repository,
        currentUserEmail: null,
      );

      expect(controller.favoriteIds, isEmpty);
    });

    test('initializes with user favorites when user is provided', () async {
      const email = 'test@example.com';
      final testFavorites = {1, 4, 7};

      await repository.saveFavoritesForUser(email, testFavorites);

      controller = FavoritesController(
        repository: repository,
        currentUserEmail: email,
      );

      expect(controller.favoriteIds, equals(testFavorites));
    });

    test('isFavorite returns correct value', () async {
      const email = 'test@example.com';
      await repository.saveFavoritesForUser(email, {1, 4, 7});

      controller = FavoritesController(
        repository: repository,
        currentUserEmail: email,
      );

      expect(controller.isFavorite(1), isTrue);
      expect(controller.isFavorite(4), isTrue);
      expect(controller.isFavorite(7), isTrue);
      expect(controller.isFavorite(25), isFalse);
    });

    test('toggleFavorite adds pokemon to favorites', () async {
      const email = 'test@example.com';
      controller = FavoritesController(
        repository: repository,
        currentUserEmail: email,
      );

      expect(controller.isFavorite(25), isFalse);

      await controller.toggleFavorite(25);

      expect(controller.isFavorite(25), isTrue);
      expect(controller.favoriteIds, contains(25));
    });

    test('toggleFavorite removes pokemon from favorites', () async {
      const email = 'test@example.com';
      await repository.saveFavoritesForUser(email, {1, 4, 7});

      controller = FavoritesController(
        repository: repository,
        currentUserEmail: email,
      );

      expect(controller.isFavorite(4), isTrue);

      await controller.toggleFavorite(4);

      expect(controller.isFavorite(4), isFalse);
      expect(controller.favoriteIds, isNot(contains(4)));
    });

    test('toggleFavorite persists changes', () async {
      const email = 'test@example.com';
      controller = FavoritesController(
        repository: repository,
        currentUserEmail: email,
      );

      await controller.toggleFavorite(25);
      await controller.toggleFavorite(150);

      // Create a new controller to verify persistence
      final newController = FavoritesController(
        repository: repository,
        currentUserEmail: email,
      );

      expect(newController.favoriteIds, equals({25, 150}));
    });

    test('setCurrentUser loads favorites for new user', () async {
      const user1 = 'user1@example.com';
      const user2 = 'user2@example.com';
      
      await repository.saveFavoritesForUser(user1, {1, 2, 3});
      await repository.saveFavoritesForUser(user2, {4, 5, 6});

      controller = FavoritesController(
        repository: repository,
        currentUserEmail: user1,
      );

      expect(controller.favoriteIds, equals({1, 2, 3}));

      controller.setCurrentUser(user2);

      expect(controller.favoriteIds, equals({4, 5, 6}));
    });

    test('setCurrentUser clears favorites for null user', () async {
      const email = 'test@example.com';
      await repository.saveFavoritesForUser(email, {1, 2, 3});

      controller = FavoritesController(
        repository: repository,
        currentUserEmail: email,
      );

      expect(controller.favoriteIds, equals({1, 2, 3}));

      controller.setCurrentUser(null);

      expect(controller.favoriteIds, isEmpty);
    });

    test('setCurrentUser does nothing if email is the same', () async {
      const email = 'test@example.com';
      await repository.saveFavoritesForUser(email, {1, 2, 3});

      controller = FavoritesController(
        repository: repository,
        currentUserEmail: email,
      );

      final originalIds = controller.favoriteIds;
      controller.setCurrentUser(email);

      expect(controller.favoriteIds, same(originalIds));
    });

    test('clearFavorites removes all favorites and user', () async {
      const email = 'test@example.com';
      await repository.saveFavoritesForUser(email, {1, 2, 3});

      controller = FavoritesController(
        repository: repository,
        currentUserEmail: email,
      );

      expect(controller.favoriteIds, isNotEmpty);

      controller.clearFavorites();

      expect(controller.favoriteIds, isEmpty);
    });

    test('notifies listeners on toggleFavorite', () async {
      const email = 'test@example.com';
      controller = FavoritesController(
        repository: repository,
        currentUserEmail: email,
      );

      var notified = false;
      controller.addListener(() {
        notified = true;
      });

      await controller.toggleFavorite(25);

      expect(notified, isTrue);
    });

    test('notifies listeners on setCurrentUser', () async {
      const user1 = 'user1@example.com';
      const user2 = 'user2@example.com';
      
      controller = FavoritesController(
        repository: repository,
        currentUserEmail: user1,
      );

      var notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.setCurrentUser(user2);

      expect(notified, isTrue);
    });

    test('notifies listeners on clearFavorites', () async {
      const email = 'test@example.com';
      controller = FavoritesController(
        repository: repository,
        currentUserEmail: email,
      );

      var notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.clearFavorites();

      expect(notified, isTrue);
    });
  });
}
