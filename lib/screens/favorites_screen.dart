part of 'pokedex_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
    this.heroTag,
    this.accentColor,
    this.title,
  });

  final String? heroTag;
  final Color? accentColor;
  final String? title;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  FavoritesController? _favoritesController;
  List<PokemonListItem> _favorites = <PokemonListItem>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final FavoritesController controller = FavoritesScope.of(context);
    if (!identical(controller, _favoritesController)) {
      _favoritesController?.removeListener(_handleFavoritesChanged);
      _favoritesController = controller;
      _favorites = controller.favorites;
      controller.addListener(_handleFavoritesChanged);
    }
  }

  @override
  void dispose() {
    _favoritesController?.removeListener(_handleFavoritesChanged);
    super.dispose();
  }

  void _handleFavoritesChanged() {
    final FavoritesController? controller = _favoritesController;
    if (!mounted || controller == null) return;
    setState(() {
      _favorites = controller.favorites;
    });
  }

  Future<void> _handleRefresh() async {
    final FavoritesController? controller = _favoritesController;
    if (controller == null) return;
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    setState(() {
      _favorites = controller.favorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final Color accentColor = widget.accentColor ?? const Color(0xFFE94256);
    final heroTag = widget.heroTag;
    final title = widget.title ?? l10n.favoritesDefaultTitle;
    final List<PokemonListItem> favorites = _favoritesController == null
        ? const <PokemonListItem>[]
        : _favoritesController!.applyFavoriteStateToList(_favorites);

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
