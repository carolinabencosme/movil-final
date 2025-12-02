import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/trivia_provider.dart';
import '../services/trivia_repository.dart';
import 'pokemon_trivia_screen.dart';
import 'trivia_achievements_screen.dart';
import 'trivia_ranking_screen.dart';

class TriviaScreen extends ConsumerWidget {
  const TriviaScreen({
    super.key,
    this.heroTag,
    this.accentColor,
    this.title,
  });

  final String? heroTag;
  final Color? accentColor;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final Color highlightColor = accentColor ?? theme.colorScheme.secondary;
    final textTheme = theme.textTheme;
    final cards = _buildTriviaCards(l10n, highlightColor, theme);
    final TriviaRepository repository = ref.read(triviaRepositoryProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: highlightColor,
        foregroundColor: Colors.white,
        title: heroTag != null
            ? Hero(
                tag: heroTag!,
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    title ?? l10n.triviaTitle,
                    style: textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : Text(
                title ?? l10n.triviaTitle,
                style: textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(
              l10n.triviaDescription,
              style: textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.8),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            _ActionCard(
              color: highlightColor,
              title: l10n.triviaPlayCardTitle,
              subtitle: l10n.triviaPlayCardSubtitle,
              icon: Icons.rocket_launch,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PokemonTriviaScreen(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              color: highlightColor,
              title: l10n.triviaRankingCardTitle,
              subtitle: l10n.triviaRankingCardSubtitle,
              icon: Icons.leaderboard,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TriviaRepositoryScope(
                    notifier: repository,
                    child: TriviaRankingScreen(
                      accentColor: highlightColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              color: highlightColor,
              title: l10n.triviaAchievementsCardTitle,
              subtitle: l10n.triviaAchievementsCardSubtitle,
              icon: Icons.emoji_events_outlined,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TriviaRepositoryScope(
                    notifier: repository,
                    child: TriviaAchievementsScreen(
                      accentColor: highlightColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            ...cards,
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTriviaCards(
    AppLocalizations l10n,
    Color highlightColor,
    ThemeData theme,
  ) {
    final List<_TriviaCardData> triviaItems = [
      _TriviaCardData(
        title: l10n.triviaFactSkittyTitle,
        description: l10n.triviaFactSkittyDescription,
        icon: Icons.pets,
      ),
      _TriviaCardData(
        title: l10n.triviaFactDittoTitle,
        description: l10n.triviaFactDittoDescription,
        icon: Icons.blur_on,
      ),
      _TriviaCardData(
        title: l10n.triviaFactPikachuTitle,
        description: l10n.triviaFactPikachuDescription,
        icon: Icons.emoji_emotions,
      ),
    ];

    final Color gradientStart = highlightColor.withOpacity(0.12);
    final Color gradientEnd = highlightColor.withOpacity(0.04);
    final Color overlay = highlightColor.withOpacity(0.1);

    return triviaItems
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Card(
              elevation: 6,
              margin: EdgeInsets.zero,
              shadowColor: highlightColor.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: [gradientStart, gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -32,
                      right: -10,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: overlay,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: highlightColor,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              item.icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.description,
                                  style:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .toList();
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final Color color;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 6,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward_ios_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _TriviaCardData {
  const _TriviaCardData({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}
