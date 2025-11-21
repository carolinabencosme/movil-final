import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pokedex/controllers/favorites_controller.dart';
import 'package:pokedex/models/favorites_model.dart';
import 'package:pokedex/services/favorites_repository.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing
    await Hive.initFlutter();
  });

  tearDown(() async {
    // Clean up Hive boxes after each test
    await Hive.deleteBoxFromDisk('favorites_box');
  });

  group('FavoritePokemon Model', () {
    test('creates a FavoritePokemon instance', () {
      final pokemon = FavoritePokemon(
        id: 25,
        name: 'Pikachu',
        imageUrl: 'https://example.com/pikachu.png',
        types: ['electric'],
      );

      expect(pokemon.id, 25);
      expect(pokemon.name, 'Pikachu');
      expect(pokemon.imageUrl, 'https://example.com/pikachu.png');
      expect(pokemon.types, ['electric']);
    });

    test('equality is based on id', () {
      final pokemon1 = FavoritePokemon(
        id: 25,
        name: 'Pikachu',
        imageUrl: 'https://example.com/pikachu.png',
        types: ['electric'],
      );

      final pokemon2 = FavoritePokemon(
        id: 25,
        name: 'Raichu',
        imageUrl: 'https://example.com/raichu.png',
        types: ['electric'],
      );

      expect(pokemon1, equals(pokemon2));
      expect(pokemon1.hashCode, equals(pokemon2.hashCode));
    });
  });

  group('FavoritesRepository', () {
    test('initializes successfully', () async {
      final repository = await FavoritesRepository.init();
      expect(repository, isNotNull);
      expect(repository.favorites, isEmpty);
    });

    test('adds a favorite pokemon', () async {
      final repository = await FavoritesRepository.init();
      final pokemon = FavoritePokemon(
        id: 1,
        name: 'Bulbasaur',
        imageUrl: 'https://example.com/bulbasaur.png',
        types: ['grass', 'poison'],
      );

      await repository.addFavorite(pokemon);

      expect(repository.isFavorite(1), isTrue);
      expect(repository.favorites.length, 1);
      expect(repository.favoriteIds.contains(1), isTrue);
    });

    test('removes a favorite pokemon', () async {
      final repository = await FavoritesRepository.init();
      final pokemon = FavoritePokemon(
        id: 4,
        name: 'Charmander',
        imageUrl: 'https://example.com/charmander.png',
        types: ['fire'],
      );

      await repository.addFavorite(pokemon);
      expect(repository.isFavorite(4), isTrue);

      await repository.removeFavorite(4);
      expect(repository.isFavorite(4), isFalse);
      expect(repository.favorites, isEmpty);
    });

    test('toggles favorite status', () async {
      final repository = await FavoritesRepository.init();
      final pokemon = FavoritePokemon(
        id: 7,
        name: 'Squirtle',
        imageUrl: 'https://example.com/squirtle.png',
        types: ['water'],
      );

      // Toggle on
      await repository.toggleFavorite(pokemon);
      expect(repository.isFavorite(7), isTrue);

      // Toggle off
      await repository.toggleFavorite(pokemon);
      expect(repository.isFavorite(7), isFalse);
    });

    test('clears all favorites', () async {
      final repository = await FavoritesRepository.init();

      await repository.addFavorite(FavoritePokemon(
        id: 1,
        name: 'Bulbasaur',
        imageUrl: '',
        types: ['grass'],
      ));

      await repository.addFavorite(FavoritePokemon(
        id: 4,
        name: 'Charmander',
        imageUrl: '',
        types: ['fire'],
      ));

      expect(repository.favorites.length, 2);

      await repository.clearAll();
      expect(repository.favorites, isEmpty);
    });
  });

  group('FavoritesController', () {
    test('initializes with repository', () async {
      final repository = await FavoritesRepository.init();
      final controller = FavoritesController(repository: repository);

      expect(controller.favorites, isEmpty);
      expect(controller.favoriteIds, isEmpty);
    });

    test('adds favorite through controller', () async {
      final repository = await FavoritesRepository.init();
      final controller = FavoritesController(repository: repository);

      final pokemon = FavoritePokemon(
        id: 25,
        name: 'Pikachu',
        imageUrl: 'https://example.com/pikachu.png',
        types: ['electric'],
      );

      await controller.addFavorite(pokemon);

      expect(controller.isFavorite(25), isTrue);
      expect(controller.favorites.length, 1);
    });

    test('notifies listeners when favorites change', () async {
      final repository = await FavoritesRepository.init();
      final controller = FavoritesController(repository: repository);

      var notificationCount = 0;
      controller.addListener(() {
        notificationCount++;
      });

      final pokemon = FavoritePokemon(
        id: 150,
        name: 'Mewtwo',
        imageUrl: 'https://example.com/mewtwo.png',
        types: ['psychic'],
      );

      await controller.addFavorite(pokemon);
      expect(notificationCount, greaterThan(0));
    });
  });

  group('FavoritesScope', () {
    testWidgets('provides FavoritesController to descendants', (tester) async {
      final repository = await FavoritesRepository.init();
      final controller = FavoritesController(repository: repository);

      FavoritesController? capturedController;

      await tester.pumpWidget(
        MaterialApp(
          home: FavoritesScope(
            notifier: controller,
            child: Builder(
              builder: (context) {
                capturedController = FavoritesScope.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedController, equals(controller));
    });

    testWidgets('throws error when FavoritesScope is missing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              try {
                FavoritesScope.of(context);
                return const Text('No error');
              } catch (e) {
                return Text('Error: ${e.runtimeType}');
              }
            },
          ),
        ),
      );

      expect(find.text('Error: StateError'), findsOneWidget);
    });

    testWidgets('maybeOf returns null when FavoritesScope is missing',
        (tester) async {
      FavoritesController? capturedController;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedController = FavoritesScope.maybeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedController, isNull);
    });
  });
}
