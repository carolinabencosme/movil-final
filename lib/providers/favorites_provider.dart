import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/favorites_controller.dart';
import '../models/pokemon_model.dart';
import '../services/favorites_repository.dart';

/// Provider for FavoritesRepository
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  throw UnimplementedError(
    'favoritesRepositoryProvider must be overridden in ProviderScope',
  );
});

/// Provider for FavoritesController
final favoritesControllerProvider =
    ChangeNotifierProvider<FavoritesController>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return FavoritesController(repository: repository);
});

/// Provider for favorite IDs
final favoriteIdsProvider = Provider<List<int>>((ref) {
  return ref.watch(favoritesControllerProvider).favoriteIds;
});

/// Provider for favorite pokemons
final favoritePokemonsProvider = Provider<List<PokemonListItem>>((ref) {
  return ref.watch(favoritesControllerProvider).favorites;
});

/// Provider to check if a pokemon is favorite
final isFavoriteProvider = Provider.family<bool, int>((ref, pokemonId) {
  return ref.watch(favoritesControllerProvider).isFavorite(pokemonId);
});
