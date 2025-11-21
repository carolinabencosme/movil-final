import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/controllers/auth_controller.dart';
import 'package:pokedex/controllers/favorites_controller.dart';
import 'package:pokedex/controllers/theme_controller.dart';
import 'package:pokedex/controllers/locale_controller.dart';
import 'package:pokedex/providers/auth_provider.dart';
import 'package:pokedex/providers/favorites_provider.dart';
import 'package:pokedex/providers/theme_provider.dart';
import 'package:pokedex/providers/locale_provider.dart';
import 'package:pokedex/services/auth_repository.dart';
import 'package:pokedex/services/favorites_repository.dart';
import 'package:pokedex/services/pokemon_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Riverpod Providers', () {
    late ProviderContainer container;
    late AuthRepository authRepository;
    late FavoritesRepository favoritesRepository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      authRepository = await AuthRepository.init();
      final pokemonCacheService = await PokemonCacheService.init();
      favoritesRepository = await FavoritesRepository.init(pokemonCacheService);

      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          favoritesRepositoryProvider.overrideWithValue(favoritesRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('authControllerProvider provides AuthController', () {
      final controller = container.read(authControllerProvider);
      expect(controller, isA<AuthController>());
      expect(controller.isAuthenticated, isFalse);
    });

    test('favoritesControllerProvider provides FavoritesController', () {
      final controller = container.read(favoritesControllerProvider);
      expect(controller, isA<FavoritesController>());
      expect(controller.favoriteIds, isEmpty);
    });

    test('themeControllerProvider provides ThemeController', () {
      final controller = container.read(themeControllerProvider);
      expect(controller, isA<ThemeController>());
      expect(controller.isDarkMode, isTrue);
    });

    test('localeControllerProvider provides LocaleController', () {
      final controller = container.read(localeControllerProvider);
      expect(controller, isA<LocaleController>());
    });

    test('isAuthenticatedProvider reflects auth state', () {
      final isAuthenticated = container.read(isAuthenticatedProvider);
      expect(isAuthenticated, isFalse);
    });

    test('favoriteIdsProvider returns empty list initially', () {
      final favoriteIds = container.read(favoriteIdsProvider);
      expect(favoriteIds, isEmpty);
    });

    test('themeModeProvider returns theme mode', () {
      final themeMode = container.read(themeModeProvider);
      expect(themeMode, isNotNull);
    });
  });
}
