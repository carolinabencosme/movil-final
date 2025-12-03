import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/trivia_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/pokemon_model.dart';
import '../models/trivia_achievement.dart';
import '../services/trivia_repository.dart';
import 'trivia_achievements_screen.dart';
import 'trivia_ranking_screen.dart';

class PokemonTriviaScreen extends ConsumerStatefulWidget {
  const PokemonTriviaScreen({super.key});

  @override
  ConsumerState<PokemonTriviaScreen> createState() => _PokemonTriviaScreenState();
}

class _PokemonTriviaScreenState extends ConsumerState<PokemonTriviaScreen> {
  final TextEditingController _answerController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = 20;
  bool _showSolution = false;
  bool _isAnimating = false;
  int _questionsPlayed = 0;
  int _correctAnswers = 0;
  int _streak = 0;

  PokemonListItem? _currentPokemon;
  List<String> _currentOptions = <String>[];
  int? _currentPokemonId;
  bool _sessionRequested = false;
  int _lastServedCount = 0;
  final Random _random = Random();
  final StreamController<TriviaAchievement> _achievementEvents =
      StreamController<TriviaAchievement>.broadcast();
  StreamSubscription<TriviaAchievement>? _achievementSubscription;

  int get _score => _correctAnswers * 100;

  void _requestSessionLoad() {
    if (_sessionRequested) return;
    final controller = ref.read(triviaControllerProvider);
    _sessionRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.loadSession());
  }

  void _syncCurrentPokemon() {
    final controller = ref.read(triviaControllerProvider);
    final pokemon = controller.currentPokemon;
    if (pokemon != null) {
      _onControllerChanged();
    }
  }

  void _onControllerChanged() {
    final controller = ref.read(triviaControllerProvider);
    final pokemon = controller.currentPokemon;
    final int served = controller.questionsServed;
    if (pokemon == null) return;

    if (_currentPokemonId == pokemon.id && _lastServedCount == served) return;

    setState(() {
      _currentPokemon = pokemon;
      _currentPokemonId = pokemon.id;
      _lastServedCount = served;
      _currentOptions = _buildOptionsForPokemon(pokemon);
      _showSolution = false;
      _isAnimating = false;
      _remainingSeconds = 20;
      _answerController.clear();
    });
    _startTimer();
  }

  @override
  void initState() {
    super.initState();
    _achievementSubscription =
        _achievementEvents.stream.listen(_showAchievementBanner);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = ref.read(triviaControllerProvider);
    controller.addListener(_onControllerChanged);
    _sessionRequested = false;
    _requestSessionLoad();
    _syncCurrentPokemon();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    _achievementSubscription?.cancel();
    _achievementEvents.close();
    ref.read(triviaControllerProvider).removeListener(_onControllerChanged);
    super.dispose();
  }

  void _startTimer() {
    if (_currentPokemon == null) return;
    _timer?.cancel();
    setState(() => _remainingSeconds = 20);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        _handleTimeout();
      } else {
        setState(() => _remainingSeconds -= 1);
      }
    });
  }

  List<String> _buildOptionsForPokemon(PokemonListItem pokemon) {
    final controller = ref.read(triviaControllerProvider);
    final List<PokemonListItem> pool = controller.pool;
    final List<PokemonListItem> candidates =
        pool.where((p) => p.id != pokemon.id).toList(growable: true);
    candidates.shuffle(_random);

    const int totalOptions = 3;
    final List<String> options = <String>[pokemon.name];

    while (options.length < totalOptions && candidates.isNotEmpty) {
      options.add(candidates.removeAt(0).name);
    }

    options.shuffle(_random);
    return options;
  }

  void _handleTimeout() {
    final l10n = AppLocalizations.of(context)!;
    final String pokemonName = _currentPokemon?.name ?? l10n.triviaTitle;
    _timer?.cancel();
    _questionsPlayed += 1;
    _streak = 0;
    _showFeedback(
      message: l10n.triviaTimeoutMessage(pokemonName),
      isSuccess: false,
    );
    _evaluateAchievements(isCorrect: false);
    _advanceQuestion();
  }

  void _advanceQuestion() {
    _timer?.cancel();
    ref.read(triviaControllerProvider).loadNextPokemon();
  }

  void _submitAnswer([String? selected]) {
    final l10n = AppLocalizations.of(context)!;
    final PokemonListItem? pokemon = _currentPokemon;
    final normalizedInput = (selected ?? _answerController.text).trim().toLowerCase();
    if (normalizedInput.isEmpty || _isAnimating || pokemon == null) return;

    final correctAnswer = pokemon.name.toLowerCase();
    final isCorrect = normalizedInput == correctAnswer;
    _timer?.cancel();
    setState(() {
      _showSolution = isCorrect;
      _isAnimating = true;
      _questionsPlayed += 1;
      if (isCorrect) {
        _correctAnswers += 1;
        _streak += 1;
      } else {
        _streak = 0;
      }
    });

    _showFeedback(
      message: isCorrect
          ? l10n.triviaCorrectMessage(pokemon.name)
          : l10n.triviaIncorrectMessage,
      isSuccess: isCorrect,
    );

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      _advanceQuestion();
    });

    _evaluateAchievements(isCorrect: isCorrect);
  }

  void _showFeedback({required String message, required bool isSuccess}) {
    final theme = Theme.of(context);
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor:
          isSuccess ? theme.colorScheme.primary : theme.colorScheme.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(milliseconds: 1800),
    );
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _saveSession() async {
    final l10n = AppLocalizations.of(context)!;
    final TriviaRepository? repository = ref.read(triviaRepositoryProvider);
    if (repository == null) {
      _showFeedback(
        message: l10n.triviaSaveUnavailableMessage,
        isSuccess: false,
      );
      return;
    }

    if (_questionsPlayed == 0) {
      _showFeedback(
        message: l10n.triviaSaveNoQuestionsMessage,
        isSuccess: false,
      );
      return;
    }

    final String playerName =
        ref.watch(currentUserEmailProvider) ?? l10n.triviaGuestPlayerName;
    await repository.saveSession(
      playerName: playerName,
      score: _score,
      questionsPlayed: _questionsPlayed,
    );

    if (!mounted) return;
    _showFeedback(
      message: l10n.triviaSessionSavedMessage,
      isSuccess: true,
    );
  }

  void _openRanking() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TriviaRankingScreen(
          accentColor: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  void _openAchievements() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TriviaAchievementsScreen(
          accentColor: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final PokemonListItem? pokemon = _currentPokemon;
    final bool isLoading = ref.watch(triviaLoadingProvider);
    final bool filterActive = !_showSolution;
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    final appBar = AppBar(
      title: Text(l10n.triviaTitle),
      actions: [
        IconButton(
          onPressed: _openRanking,
          icon: const Icon(Icons.leaderboard_outlined),
          tooltip: l10n.triviaRankingTooltip,
        ),
        IconButton(
          onPressed: _openAchievements,
          icon: const Icon(Icons.emoji_events_outlined),
          tooltip: l10n.triviaAchievementsTooltip,
        ),
        IconButton(
          onPressed: _saveSession,
          icon: const Icon(Icons.save_alt),
          tooltip: l10n.triviaSaveSessionTooltip,
        ),
      ],
    );

    if (pokemon == null) {
      return Scaffold(
        appBar: appBar,
        body: SafeArea(
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : Text(l10n.triviaPlayCardSubtitle),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20).add(
            EdgeInsets.only(bottom: viewInsets.bottom),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimer(theme, l10n),
              const SizedBox(height: 10),
              _buildStats(theme, l10n),
              const SizedBox(height: 16),
              Text(
                l10n.triviaGuessPrompt(pokemon.id),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    child: _PokemonSilhouette(
                      key: ValueKey('${pokemon.id}-$filterActive'),
                      pokemon: pokemon,
                      filterActive: filterActive,
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showSolution
                    ? Text(
                        pokemon.name.toUpperCase(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          letterSpacing: 1.2,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              _buildOptions(theme),
              const SizedBox(height: 12),
              _buildInput(theme, l10n),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submitAnswer,
                      icon: const Icon(Icons.quiz_outlined),
                      label: Text(l10n.triviaCheckButtonLabel),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: _advanceQuestion,
                    icon: const Icon(Icons.skip_next_rounded),
                    tooltip: l10n.triviaSkipTooltip,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatChip(
                icon: Icons.check_circle_outline,
                label: l10n.triviaStatsCorrectAnswers,
                value: '$_correctAnswers',
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatChip(
                icon: Icons.star_border_rounded,
                label: l10n.triviaStatsScore,
                value: '$_score ${l10n.triviaPointsAbbreviation}',
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: _StatChip(
            icon: Icons.local_fire_department_outlined,
            label: l10n.triviaStatsStreak,
            value: '$_streak',
            color: theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _buildTimer(ThemeData theme, AppLocalizations l10n) {
    final Color color = _remainingSeconds <= 5
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(Icons.timer, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.triviaRemainingTimeLabel,
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            Text(
              l10n.triviaRemainingSeconds(_remainingSeconds),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptions(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _currentOptions
          .map(
            (option) => ChoiceChip(
              label: Text(option),
              selected: _answerController.text.toLowerCase() ==
                  option.toLowerCase(),
              onSelected: (_) => _submitAnswer(option),
              labelStyle: theme.textTheme.bodyMedium,
              avatar: const Icon(Icons.lightbulb_outline, size: 18),
            ),
          )
          .toList(),
    );
  }

  Widget _buildInput(ThemeData theme, AppLocalizations l10n) {
    return TextField(
      controller: _answerController,
      textInputAction: TextInputAction.done,
      onSubmitted: _submitAnswer,
      decoration: InputDecoration(
        labelText: l10n.triviaAnswerLabel,
        prefixIcon: const Icon(Icons.catching_pokemon),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Future<void> _evaluateAchievements({required bool isCorrect}) async {
    final TriviaRepository? repository = ref.read(triviaRepositoryProvider);
    if (repository == null) return;

    Future<void> tryUnlock(String id) async {
      final TriviaAchievement? unlocked =
          await repository.unlockAchievement(id);
      if (unlocked != null) {
        _achievementEvents.add(unlocked);
      }
    }

    if (isCorrect && _correctAnswers >= 1) {
      await tryUnlock('first_correct');
    }
    if (isCorrect && _streak >= 3) {
      await tryUnlock('streak_three');
    }
    if (isCorrect && _streak >= 5) {
      await tryUnlock('streak_five');
    }
    if (_questionsPlayed >= 10) {
      await tryUnlock('ten_questions');
    }
    if (_score >= 500) {
      await tryUnlock('score_hunter');
    }
  }

  void _showAchievementBanner(TriviaAchievement achievement) {
    if (!mounted) return;
    final theme = Theme.of(context);
    final icon = _mapIcon(achievement.iconName);

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: theme.colorScheme.primary,
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            foregroundColor: theme.colorScheme.primary,
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.triviaAchievementUnlockedTitle,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  achievement.title,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(snackBar);
  }

  IconData _mapIcon(String name) {
    switch (name) {
      case 'celebration':
        return Icons.celebration_outlined;
      case 'bolt':
        return Icons.bolt;
      case 'local_fire_department':
        return Icons.local_fire_department_outlined;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'military_tech':
        return Icons.military_tech_outlined;
      default:
        return Icons.emoji_events_outlined;
    }
  }
}

class _PokemonSilhouette extends StatelessWidget {
  const _PokemonSilhouette({
    super.key,
    required this.pokemon,
    required this.filterActive,
  });

  final PokemonListItem pokemon;
  final bool filterActive;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height;
        final double maxSilhouetteHeight =
            (availableHeight * 0.45).clamp(180.0, 260.0);

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSilhouetteHeight),
          child: AspectRatio(
            aspectRatio: 1.15,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primaryContainer,
                              Theme.of(context).colorScheme.secondaryContainer,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: LayoutBuilder(
                        builder: (context, innerConstraints) {
                          final double imageHeight =
                              (innerConstraints.maxHeight * 0.85)
                                  .clamp(120.0, maxSilhouetteHeight);

                          return AnimatedScale(
                            duration: const Duration(milliseconds: 400),
                            scale: filterActive ? 0.95 : 1.02,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 400),
                              opacity: filterActive ? 0.65 : 1,
                              child: ColorFiltered(
                                colorFilter: filterActive
                                    ? const ColorFilter.matrix(<double>[
                                        0, 0, 0, 0, 0, // Red
                                        0, 0, 0, 0, 0, // Green
                                        0, 0, 0, 0, 0, // Blue
                                        0, 0, 0, 1, 0, // Alpha
                                      ])
                                    : const ColorFilter.mode(
                                        Colors.transparent, BlendMode.multiply),
                                child: Image.network(
                                  pokemon.imageUrl,
                                  fit: BoxFit.contain,
                                  height: imageHeight,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.18),
            foregroundColor: color,
            radius: 18,
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

