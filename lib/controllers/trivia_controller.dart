import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/pokemon_model.dart';
import '../queries/get_pokemon_list.dart';
import '../services/pokemon_cache_service.dart';
import '../services/trivia_repository.dart';

enum TriviaAttemptState { idle, correct, incorrect, timeout }

class TriviaController extends ChangeNotifier {
  TriviaController({
    required GraphQLClient graphQLClient,
    PokemonCacheService? cacheService,
    Random? random,
    TriviaRepository? triviaRepository,
    this.pointsPerHit = 10,
    this.fetchLimit = 120,
  })  : _client = graphQLClient,
        _cacheService = cacheService,
        _triviaRepository = triviaRepository,
        _random = random ?? Random();

  final GraphQLClient _client;
  final PokemonCacheService? _cacheService;
  final TriviaRepository? _triviaRepository;
  final Random _random;

  /// Puntos que se otorgan por respuesta correcta.
  final int pointsPerHit;

  /// Cantidad de Pokémon a cargar para la sesión de trivia.
  final int fetchLimit;

  PokemonListItem? _currentPokemon;
  TriviaAttemptState _attemptState = TriviaAttemptState.idle;
  int _score = 0;
  int _correctAnswers = 0;
  int _streak = 0;
  int _questionsServed = 0;
  bool _isLoading = false;
  List<PokemonListItem> _pool = <PokemonListItem>[];
  List<PokemonListItem> _remaining = <PokemonListItem>[];

  PokemonListItem? get currentPokemon => _currentPokemon;
  TriviaAttemptState get attemptState => _attemptState;
  int get score => _score;
  int get streak => _streak;
  int get correctAnswers => _correctAnswers;
  int get questionsServed => _questionsServed;
  bool get isLoading => _isLoading;

  Future<void> loadSession() async {
    if (_isLoading) return;

    _setLoading(true);
    try {
      final List<PokemonListItem> cached =
          _cacheService?.getAll(sorted: true) ?? <PokemonListItem>[];

      if (cached.isNotEmpty) {
        _usePool(cached);
        return;
      }

      final String query = buildPokemonListQuery(
        includeIdFilter: false,
        includeTypeFilter: false,
        includePagination: true,
        orderField: 'id',
        isOrderAscending: true,
      );

      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(query),
          variables: <String, dynamic>{
            'limit': fetchLimit,
            'offset': 0,
            'search': '%',
          },
          fetchPolicy: FetchPolicy.cacheAndNetwork,
        ),
      );

      final List<dynamic> rawPokemons =
          result.data?['pokemon_v2_pokemon'] as List<dynamic>? ?? <dynamic>[];
      final List<PokemonListItem> pokemons = rawPokemons
          .whereType<Map<String, dynamic>>()
          .map(PokemonListItem.fromGraphQL)
          .toList(growable: false);

      if (pokemons.isNotEmpty) {
        await _cacheService?.cachePokemons(pokemons);
      }
      _usePool(pokemons);
    } finally {
      _setLoading(false);
    }
  }

  void submitAnswer(String answer) {
    final PokemonListItem? pokemon = _currentPokemon;
    if (pokemon == null) return;

    final String normalized = answer.trim().toLowerCase();
    final bool isCorrect = normalized == pokemon.name.toLowerCase();

    _attemptState = isCorrect
        ? TriviaAttemptState.correct
        : TriviaAttemptState.incorrect;
    if (isCorrect) {
      _score += pointsPerHit;
      _correctAnswers += 1;
      _streak += 1;
    } else {
      _correctAnswers = max(0, _correctAnswers);
      _streak = 0;
    }
    _evaluateAchievements(isCorrect: isCorrect);
    notifyListeners();
  }

  void onTimeout() {
    _attemptState = TriviaAttemptState.timeout;
    _streak = 0;
    _evaluateAchievements(isCorrect: false);
    notifyListeners();
  }

  void loadNextPokemon() {
    if (_pool.isEmpty) return;

    if (_remaining.isEmpty) {
      _remaining = List<PokemonListItem>.from(_pool);
    }

    final int index = _random.nextInt(_remaining.length);
    _currentPokemon = _remaining.removeAt(index);
    _attemptState = TriviaAttemptState.idle;
    _questionsServed += 1;
    notifyListeners();
  }

  void resetScore() {
    _score = 0;
    _correctAnswers = 0;
    _streak = 0;
    _attemptState = TriviaAttemptState.idle;
    notifyListeners();
  }

  void _usePool(List<PokemonListItem> pokemons) {
    _pool = pokemons;
    _remaining = List<PokemonListItem>.from(_pool);
    _questionsServed = 0;
    _correctAnswers = 0;
    _currentPokemon = null;
    loadNextPokemon();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _evaluateAchievements({required bool isCorrect}) async {
    final TriviaRepository? repository = _triviaRepository;
    if (repository == null) return;

    if (isCorrect && _correctAnswers >= 1) {
      await repository.unlockAchievement('first_correct');
    }
    if (isCorrect && _streak >= 3) {
      await repository.unlockAchievement('streak_three');
    }
    if (isCorrect && _streak >= 5) {
      await repository.unlockAchievement('streak_five');
    }
    if (_questionsServed >= 10) {
      await repository.unlockAchievement('ten_questions');
    }
    if (_score >= 500) {
      await repository.unlockAchievement('score_hunter');
    }
  }
}
