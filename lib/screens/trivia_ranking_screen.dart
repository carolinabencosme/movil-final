import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/trivia_score.dart';
import '../services/trivia_repository.dart';

class TriviaRankingScreen extends StatelessWidget {
  const TriviaRankingScreen({
    super.key,
    this.accentColor,
  });

  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color highlight = accentColor ?? theme.colorScheme.primary;
    final TriviaRepository repository = TriviaRepositoryScope.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: highlight,
        foregroundColor: Colors.white,
        title: const Text('Ranking trivia'),
        actions: [
          IconButton(
            onPressed: () => repository.clearAll(),
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Limpiar historial',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: repository,
        builder: (_, __) {
          final List<TriviaScore> topScores = repository.getTopScores(limit: 10);

          if (topScores.isEmpty) {
            return _EmptyState(highlight: highlight);
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            itemBuilder: (_, index) {
              final TriviaScore score = topScores[index];
              return _RankingTile(
                position: index + 1,
                score: score,
                accentColor: highlight,
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: topScores.length,
          );
        },
      ),
    );
  }
}

class _RankingTile extends StatelessWidget {
  const _RankingTile({
    required this.position,
    required this.score,
    required this.accentColor,
  });

  final int position;
  final TriviaScore score;
  final Color accentColor;

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat.MMMd().add_Hm();
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color badgeColor = position == 1
        ? accentColor
        : position == 2
            ? accentColor.withOpacity(0.8)
            : accentColor.withOpacity(0.65);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      shadowColor: badgeColor.withOpacity(0.25),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: badgeColor,
              foregroundColor: Colors.white,
              child: Text('$position'),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    score.playerName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${score.questionsPlayed} preguntas · ${_formatDate(score.playedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${score.score} pts',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events_outlined,
                        color: accentColor, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Top ${position <= 10 ? position : ''}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: accentColor.withOpacity(0.8)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.highlight});

  final Color highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.quiz_outlined,
              color: highlight.withOpacity(0.8),
              size: 72,
            ),
            const SizedBox(height: 16),
            Text(
              'Aún no hay partidas registradas',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Juega una ronda y guarda tu puntuación para aparecer en el Top 10.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
