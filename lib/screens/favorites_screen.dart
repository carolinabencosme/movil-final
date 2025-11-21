part of 'pokedex_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({
    super.key,
    this.heroTag,
    this.accentColor,
    this.title,
  });

  final String? heroTag;
  final Color? accentColor;
  final String? title;

  Future<void> _handleRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final Color accentColor = this.accentColor ?? const Color(0xFFE94256);
    final heroTag = this.heroTag;
    final title = this.title ?? l10n.favoritesDefaultTitle;
    final favorites = ref.watch(favoritePokemonsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E7),
      appBar: AppBar(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        title: heroTag != null
            ? Hero(
                tag: heroTag,
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: accentColor,
          onRefresh: _handleRefresh,
          child: favorites.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 64,
                  ),
                  children: [
                    Icon(
                      Icons.favorite_border,
                      color: accentColor.withOpacity(0.85),
                      size: 82,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.favoritesEmptyTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.favoritesEmptySubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  itemBuilder: (context, index) {
                    final pokemon = favorites[index];
                    return _PokemonListTile(
                      key: ValueKey('favorite-${pokemon.id}'),
                      pokemon: pokemon,
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemCount: favorites.length,
                ),
        ),
      ),
    );
  }
}
