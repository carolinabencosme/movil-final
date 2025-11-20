import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';

import '../models/trivia_score.dart';

/// Repositorio para persistir y consultar puntuaciones de trivia usando Hive.
class TriviaRepository extends ChangeNotifier {
  TriviaRepository._(this._scoresBox);

  static const String _scoresBoxName = 'trivia_scores_box';

  final Box<TriviaScore> _scoresBox;

  /// Inicializa el adaptador y abre la caja dedicada de puntuaciones.
  static Future<TriviaRepository> init() async {
    final TriviaScoreAdapter adapter = TriviaScoreAdapter();
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }

    final Box<TriviaScore> box =
        await Hive.openBox<TriviaScore>(_scoresBoxName);
    return TriviaRepository._(box);
  }

  /// Devuelve las mejores puntuaciones, ordenadas descendentemente por score
  /// y, en caso de empate, por la fecha más reciente.
  List<TriviaScore> getTopScores({int limit = 10}) {
    final List<TriviaScore> scores = _scoresBox.values.toList(growable: false);
    scores.sort((TriviaScore a, TriviaScore b) {
      final int scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) return scoreComparison;
      return b.playedAt.compareTo(a.playedAt);
    });

    if (limit <= 0 || scores.length <= limit) {
      return scores;
    }
    return scores.take(limit).toList(growable: false);
  }

  /// Guarda una sesión de trivia y devuelve el registro creado.
  Future<TriviaScore> saveSession({
    required String playerName,
    required int score,
    required int questionsPlayed,
  }) async {
    final String normalizedName = playerName.trim().isEmpty
        ? 'Entrenador anónimo'
        : playerName.trim();

    final TriviaScore entry = TriviaScore(
      playerName: normalizedName,
      score: score,
      questionsPlayed: questionsPlayed,
      playedAt: DateTime.now(),
    );

    await _scoresBox.add(entry);
    await _trimIfNeeded();
    notifyListeners();
    return entry;
  }

  /// Elimina todos los registros almacenados.
  Future<void> clearAll() async {
    await _scoresBox.clear();
    notifyListeners();
  }

  /// Mantiene un tamaño máximo de historial para evitar crecimiento infinito.
  Future<void> _trimIfNeeded({int maxEntries = 50}) async {
    if (_scoresBox.length <= maxEntries) return;

    final List<int> keys = _scoresBox.keys.whereType<int>().toList();
    final int overflow = _scoresBox.length - maxEntries;
    if (overflow <= 0) return;

    // Se eliminan los registros más antiguos.
    keys.sort();
    final Iterable<int> toDelete = keys.take(overflow);
    await _scoresBox.deleteAll(toDelete);
  }

  @override
  void dispose() {
    unawaited(_scoresBox.close());
    super.dispose();
  }
}

class TriviaRepositoryScope extends InheritedNotifier<TriviaRepository> {
  const TriviaRepositoryScope({
    super.key,
    required TriviaRepository notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static TriviaRepository of(BuildContext context) {
    final TriviaRepositoryScope? scope =
        context.dependOnInheritedWidgetOfExactType<TriviaRepositoryScope>();
    assert(scope != null,
        'TriviaRepositoryScope.of() called with a context that does not contain a TriviaRepositoryScope.');
    if (scope == null) {
      throw StateError(
        'TriviaRepositoryScope.of() called with a context that does not contain a TriviaRepositoryScope.',
      );
    }

    final TriviaRepository? repository = scope.notifier;
    if (repository == null) {
      throw StateError(
        'TriviaRepositoryScope.of() called with a TriviaRepositoryScope that has a null notifier.',
      );
    }

    return repository;
  }

  static TriviaRepository? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TriviaRepositoryScope>()
        ?.notifier;
  }
}
