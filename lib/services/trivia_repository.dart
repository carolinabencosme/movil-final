import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import '../models/trivia_achievement.dart';
import '../models/trivia_score.dart';

/// Repositorio para persistir y consultar puntuaciones de trivia usando Hive.
class TriviaRepository extends ChangeNotifier {
  TriviaRepository._(this._scoresBox, this._achievementsBox);

  static const String _scoresBoxName = 'trivia_scores_box';
  static const String _achievementsBoxName = 'trivia_achievements_box';

  final Box<TriviaScore> _scoresBox;
  final Box<TriviaAchievement> _achievementsBox;

  /// Inicializa el adaptador y abre la caja dedicada de puntuaciones.
  static Future<TriviaRepository> init() async {
    final TriviaScoreAdapter scoreAdapter = TriviaScoreAdapter();
    final TriviaAchievementAdapter achievementAdapter = TriviaAchievementAdapter();
    if (!Hive.isAdapterRegistered(scoreAdapter.typeId)) {
      Hive.registerAdapter(scoreAdapter);
    }
    if (!Hive.isAdapterRegistered(achievementAdapter.typeId)) {
      Hive.registerAdapter(achievementAdapter);
    }

    final Box<TriviaScore> scoresBox =
        await Hive.openBox<TriviaScore>(_scoresBoxName);
    final Box<TriviaAchievement> achievementsBox =
        await Hive.openBox<TriviaAchievement>(_achievementsBoxName);

    final TriviaRepository repository =
        TriviaRepository._(scoresBox, achievementsBox);
    await repository._seedAchievementsIfNeeded();
    return repository;
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
        ? AppLocalizationsEn().triviaGuestPlayerName
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

  /// Devuelve todos los logros disponibles, ordenando primero los desbloqueados
  /// con fecha más reciente y luego los bloqueados.
  List<TriviaAchievement> getAchievements(AppLocalizations localizations) {
    final List<TriviaAchievement> achievements = _achievementsBox.values
        .map((TriviaAchievement achievement) =>
            _withLocalizedTexts(achievement, localizations))
        .toList(growable: false);
    achievements.sort((TriviaAchievement a, TriviaAchievement b) {
      if (a.isUnlocked && b.isUnlocked) {
        return b.unlockedAt!.compareTo(a.unlockedAt!);
      }
      if (a.isUnlocked) return -1;
      if (b.isUnlocked) return 1;
      return a.title.compareTo(b.title);
    });
    return achievements;
  }

  /// Desbloquea un logro cuando se cumplen sus condiciones.
  /// Devuelve el logro actualizado si cambió de estado.
  Future<TriviaAchievement?> unlockAchievement(String id) async {
    final TriviaAchievement? existing = _achievementsBox.get(id);
    if (existing == null || existing.isUnlocked) return null;

    final TriviaAchievement updated =
        existing.copyWith(unlockedAt: DateTime.now());

    await _achievementsBox.put(id, updated);
    notifyListeners();
    return updated;
  }

  Future<void> resetAchievements() async {
    await _achievementsBox.clear();
    await _seedAchievementsIfNeeded();
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
    unawaited(_achievementsBox.close());
    super.dispose();
  }

  Future<void> _seedAchievementsIfNeeded() async {
    if (_achievementsBox.isNotEmpty) return;

    final AppLocalizations fallbackLocalizations = AppLocalizationsEn();
    final List<TriviaAchievement> defaults =
        _buildDefaultAchievements(fallbackLocalizations);

    for (final TriviaAchievement achievement in defaults) {
      await _achievementsBox.put(achievement.id, achievement);
    }
  }
}

TriviaAchievement _withLocalizedTexts(
  TriviaAchievement achievement,
  AppLocalizations localizations,
) {
  switch (achievement.id) {
    case 'first_correct':
      return achievement.copyWith(
        title: localizations.triviaAchievementFirstCorrectTitle,
        description: localizations.triviaAchievementFirstCorrectDescription,
      );
    case 'streak_three':
      return achievement.copyWith(
        title: localizations.triviaAchievementStreakThreeTitle,
        description: localizations.triviaAchievementStreakThreeDescription,
      );
    case 'streak_five':
      return achievement.copyWith(
        title: localizations.triviaAchievementStreakFiveTitle,
        description: localizations.triviaAchievementStreakFiveDescription,
      );
    case 'ten_questions':
      return achievement.copyWith(
        title: localizations.triviaAchievementTenQuestionsTitle,
        description: localizations.triviaAchievementTenQuestionsDescription,
      );
    case 'score_hunter':
      return achievement.copyWith(
        title: localizations.triviaAchievementScoreHunterTitle,
        description: localizations.triviaAchievementScoreHunterDescription,
      );
    default:
      return achievement;
  }
}

List<TriviaAchievement> _buildDefaultAchievements(AppLocalizations l10n) {
  return <TriviaAchievement>[
    TriviaAchievement(
      id: 'first_correct',
      title: l10n.triviaAchievementFirstCorrectTitle,
      description: l10n.triviaAchievementFirstCorrectDescription,
      iconName: 'celebration',
    ),
    TriviaAchievement(
      id: 'streak_three',
      title: l10n.triviaAchievementStreakThreeTitle,
      description: l10n.triviaAchievementStreakThreeDescription,
      iconName: 'bolt',
    ),
    TriviaAchievement(
      id: 'streak_five',
      title: l10n.triviaAchievementStreakFiveTitle,
      description: l10n.triviaAchievementStreakFiveDescription,
      iconName: 'local_fire_department',
    ),
    TriviaAchievement(
      id: 'ten_questions',
      title: l10n.triviaAchievementTenQuestionsTitle,
      description: l10n.triviaAchievementTenQuestionsDescription,
      iconName: 'self_improvement',
    ),
    TriviaAchievement(
      id: 'score_hunter',
      title: l10n.triviaAchievementScoreHunterTitle,
      description: l10n.triviaAchievementScoreHunterDescription,
      iconName: 'military_tech',
    ),
  ];
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
