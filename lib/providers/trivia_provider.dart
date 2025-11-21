import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../controllers/trivia_controller.dart';
import '../models/pokemon_model.dart';
import '../services/pokemon_cache_service.dart';
import '../services/trivia_repository.dart';

/// Provider for GraphQL Client
final graphQLClientProvider = Provider<GraphQLClient>((ref) {
  throw UnimplementedError(
    'graphQLClientProvider must be overridden in ProviderScope',
  );
});

/// Provider for PokemonCacheService
final pokemonCacheServiceProvider = Provider<PokemonCacheService>((ref) {
  throw UnimplementedError(
    'pokemonCacheServiceProvider must be overridden in ProviderScope',
  );
});

/// Provider for TriviaRepository
final triviaRepositoryProvider = Provider<TriviaRepository>((ref) {
  throw UnimplementedError(
    'triviaRepositoryProvider must be overridden in ProviderScope',
  );
});

/// Provider for TriviaController
final triviaControllerProvider = ChangeNotifierProvider<TriviaController>((ref) {
  final client = ref.watch(graphQLClientProvider);
  final cacheService = ref.watch(pokemonCacheServiceProvider);
  final repository = ref.watch(triviaRepositoryProvider);
  
  return TriviaController(
    graphQLClient: client,
    cacheService: cacheService,
    triviaRepository: repository,
  );
});

/// Provider for current pokemon
final currentPokemonProvider = Provider<PokemonListItem?>((ref) {
  return ref.watch(triviaControllerProvider).currentPokemon;
});

/// Provider for trivia score
final triviaScoreProvider = Provider<int>((ref) {
  return ref.watch(triviaControllerProvider).score;
});

/// Provider for trivia streak
final triviaStreakProvider = Provider<int>((ref) {
  return ref.watch(triviaControllerProvider).streak;
});

/// Provider for trivia loading state
final triviaLoadingProvider = Provider<bool>((ref) {
  return ref.watch(triviaControllerProvider).isLoading;
});

/// Provider for attempt state
final triviaAttemptStateProvider = Provider<TriviaAttemptState>((ref) {
  return ref.watch(triviaControllerProvider).attemptState;
});
