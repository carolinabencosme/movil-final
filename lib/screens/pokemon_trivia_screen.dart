import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../l10n/app_localizations.dart';
import '../models/trivia_achievement.dart';
import '../services/trivia_repository.dart';
import 'trivia_achievements_screen.dart';
import 'trivia_ranking_screen.dart';

class PokemonTriviaScreen extends StatefulWidget {
  const PokemonTriviaScreen({super.key});

  @override
  State<PokemonTriviaScreen> createState() => _PokemonTriviaScreenState();
}

class _PokemonTriviaScreenState extends State<PokemonTriviaScreen> {
  final List<_TriviaQuestion> _questions = const [
    _TriviaQuestion(
      name: 'pikachu',
      prompt: '¿Quién es este Pokémon eléctrico icónico?',
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
      options: ['Pikachu', 'Raichu', 'Pichu'],
    ),
    _TriviaQuestion(
      name: 'bulbasaur',
      prompt: 'Inicia la Pokédex y posee una semilla en su espalda.',
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png',
      options: ['Bulbasaur', 'Ivysaur', 'Oddish'],
    ),
    _TriviaQuestion(
      name: 'charizard',
      prompt: 'Dragón que escupe fuego y pertenece a Kanto.',
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png',
      options: ['Charizard', 'Aerodactyl', 'Charmeleon'],
    ),
  ];

  final TextEditingController _answerController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = 20;
  int _currentIndex = 0;
  bool _showSolution = false;
  bool _isAnimating = false;
  int _questionsPlayed = 0;
  int _correctAnswers = 0;
  int _streak = 0;
  TriviaRepository? _triviaRepository;
  AuthController? _authController;
  final StreamController<TriviaAchievement> _achievementEvents =
      StreamController<TriviaAchievement>.broadcast();
  StreamSubscription<TriviaAchievement>? _achievementSubscription;

  int get _score => _correctAnswers * 100;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _achievementSubscription =
        _achievementEvents.stream.listen(_showAchievementBanner);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _triviaRepository = TriviaRepositoryScope.maybeOf(context);
    _authController = AuthScope.maybeOf(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    _achievementSubscription?.cancel();
    _achievementEvents.close();
    super.dispose();
  }

  void _startTimer() {
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

  void _handleTimeout() {
    _timer?.cancel();
    _questionsPlayed += 1;
    _streak = 0;
    _showFeedback(
      message: '¡Tiempo agotado! La respuesta era ${_currentQuestion.name}.',
      isSuccess: false,
    );
    _evaluateAchievements(isCorrect: false);
    _advanceQuestion();
  }

  _TriviaQuestion get _currentQuestion => _questions[_currentIndex];

  void _advanceQuestion() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _questions.length;
      _showSolution = false;
      _isAnimating = false;
      _answerController.clear();
    });
    _startTimer();
  }

  void _submitAnswer([String? selected]) {
    final normalizedInput = (selected ?? _answerController.text).trim().toLowerCase();
    if (normalizedInput.isEmpty || _isAnimating) return;

    final correctAnswer = _currentQuestion.name.toLowerCase();
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
          ? '¡Correcto! Era ${_currentQuestion.name}.'
          : 'Respuesta incorrecta. Inténtalo con el siguiente.',
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
    final TriviaRepository? repository = _triviaRepository;
    if (repository == null) {
      _showFeedback(
        message: 'No se pudo acceder al ranking en este momento.',
        isSuccess: false,
      );
      return;
    }

    if (_questionsPlayed == 0) {
      _showFeedback(
        message: 'Juega al menos una pregunta antes de guardar.',
        isSuccess: false,
      );
      return;
    }

    final String playerName = _authController?.currentEmail ?? 'Invitado';
    await repository.saveSession(
      playerName: playerName,
      score: _score,
      questionsPlayed: _questionsPlayed,
    );

    if (!mounted) return;
    _showFeedback(
      message: 'Sesión guardada en el ranking',
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
    final question = _currentQuestion;
    final filterActive = !_showSolution;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.triviaTitle),
        actions: [
          IconButton(
            onPressed: _openRanking,
            icon: const Icon(Icons.leaderboard_outlined),
            tooltip: 'Ver ranking',
          ),
          IconButton(
            onPressed: _openAchievements,
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: 'Ver logros',
          ),
          IconButton(
            onPressed: _saveSession,
            icon: const Icon(Icons.save_alt),
            tooltip: 'Guardar sesión',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimer(theme),
              const SizedBox(height: 10),
              _buildStats(theme),
              const SizedBox(height: 16),
              Text(
                question.prompt,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    child: _PokemonSilhouette(
                      key: ValueKey(question.name + filterActive.toString()),
                      question: question,
                      filterActive: filterActive,
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showSolution
                    ? Text(
                        question.name.toUpperCase(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          letterSpacing: 1.2,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              _buildOptions(theme, question),
              const SizedBox(height: 12),
              _buildInput(theme),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submitAnswer,
                      icon: const Icon(Icons.quiz_outlined),
                      label: const Text('Comprobar'),
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
                    tooltip: 'Saltar',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatChip(
                icon: Icons.check_circle_outline,
                label: 'Correctas',
                value: '$_correctAnswers',
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatChip(
                icon: Icons.star_border_rounded,
                label: 'Puntuación',
                value: '$_score pts',
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
            label: 'Racha',
            value: '$_streak',
            color: theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _buildTimer(ThemeData theme) {
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
              'Tiempo restante',
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            Text(
              '${_remainingSeconds}s',
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

  Widget _buildOptions(ThemeData theme, _TriviaQuestion question) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: question.options
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

  Widget _buildInput(ThemeData theme) {
    return TextField(
      controller: _answerController,
      textInputAction: TextInputAction.done,
      onSubmitted: _submitAnswer,
      decoration: InputDecoration(
        labelText: 'Tu respuesta',
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
    final TriviaRepository? repository = _triviaRepository;
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
                  '¡Logro desbloqueado! 🎉',
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
    required this.question,
    required this.filterActive,
  });

  final _TriviaQuestion question;
  final bool filterActive;

  @override
  Widget build(BuildContext context) {
    final Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 260,
            width: double.infinity,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: AnimatedScale(
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
                    question.imageUrl,
                    fit: BoxFit.contain,
                    height: 240,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: image,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
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
        ],
      ),
    );
  }
}

class _TriviaQuestion {
  const _TriviaQuestion({
    required this.name,
    required this.prompt,
    required this.imageUrl,
    this.options = const [],
  });

  final String name;
  final String prompt;
  final String imageUrl;
  final List<String> options;
}
