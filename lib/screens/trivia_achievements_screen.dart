import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/trivia_achievement.dart';
import '../services/trivia_repository.dart';

class TriviaAchievementsScreen extends StatelessWidget {
  const TriviaAchievementsScreen({super.key, this.accentColor});

  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final Color highlight = accentColor ?? Theme.of(context).colorScheme.secondary;
    final TriviaRepository repository = TriviaRepositoryScope.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.triviaAchievementsTitle),
        backgroundColor: highlight,
        foregroundColor: Colors.white,
      ),
      body: AnimatedBuilder(
        animation: repository,
        builder: (_, __) {
          final List<TriviaAchievement> achievements =
              repository.getAchievements(l10n);
          if (achievements.isEmpty) {
            return Center(
              child: Text(l10n.triviaAchievementsEmpty),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            itemBuilder: (_, int index) {
              final TriviaAchievement achievement = achievements[index];
              return _AchievementTile(
                achievement: achievement,
                highlight: highlight,
                l10n: l10n,
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: achievements.length,
          );
        },
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.achievement,
    required this.highlight,
    required this.l10n,
  });

  final TriviaAchievement achievement;
  final Color highlight;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool unlocked = achievement.isUnlocked;
    final IconData icon = _mapIcon(achievement.iconName);
    final Color overlay = unlocked
        ? highlight.withOpacity(0.1)
        : theme.colorScheme.surfaceVariant.withOpacity(0.4);

    return Container(
      decoration: BoxDecoration(
        color: unlocked
            ? highlight.withOpacity(0.15)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unlocked ? highlight.withOpacity(0.4) : overlay,
        ),
        boxShadow: [
          BoxShadow(
            color: highlight.withOpacity(0.16),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor:
                unlocked ? highlight : theme.colorScheme.surfaceVariant,
            foregroundColor:
                unlocked ? Colors.white : theme.colorScheme.onSurfaceVariant,
            child: Icon(icon, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: unlocked
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  achievement.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                _buildStatus(theme, unlocked),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(ThemeData theme, bool unlocked) {
    if (!unlocked) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_clock, color: theme.colorScheme.outline, size: 18),
          const SizedBox(width: 6),
          Text(
            l10n.triviaAchievementsLockedLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final DateFormat formatter =
        DateFormat(l10n.triviaAchievementsDateFormat, l10n.localeName);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.emoji_events, color: highlight, size: 18),
        const SizedBox(width: 6),
        Text(
          l10n.triviaAchievementsUnlockedLabel(
            formatter.format(achievement.unlockedAt!),
          ),
          style: theme.textTheme.labelLarge?.copyWith(
            color: highlight,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
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
