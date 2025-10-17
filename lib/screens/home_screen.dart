import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showGrid = false;

  final List<_SectionInfo> _sections = const [
    _SectionInfo(
      title: 'Pokédex',
      icon: Icons.catching_pokemon,
      color: Color(0xFFFF6B6B),
      heroTag: 'section-pokedex',
    ),
    _SectionInfo(
      title: 'Moves',
      icon: Icons.sports_martial_arts,
      color: Color(0xFF4D96FF),
      heroTag: 'section-moves',
    ),
    _SectionInfo(
      title: 'Abilities',
      icon: Icons.auto_awesome,
      color: Color(0xFF9D4EDD),
      heroTag: 'section-abilities',
    ),
    _SectionInfo(
      title: 'Items',
      icon: Icons.backpack,
      color: Color(0xFFFFC75F),
      heroTag: 'section-items',
    ),
    _SectionInfo(
      title: 'Locations',
      icon: Icons.public,
      color: Color(0xFF59CD90),
      heroTag: 'section-locations',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _showGrid = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex GraphQL'),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _showGrid
            ? GridView.builder(
                key: const ValueKey('home-grid'),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  final section = _sections[index];
                  return _HomeSectionCard(
                    info: section,
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 450),
                          pageBuilder: (_, animation, secondaryAnimation) =>
                              FadeTransition(
                            opacity: animation,
                            child: SectionPlaceholderScreen(info: section),
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _HomeSectionCard extends StatefulWidget {
  const _HomeSectionCard({
    required this.info,
    required this.onTap,
  });

  final _SectionInfo info;
  final VoidCallback onTap;

  @override
  State<_HomeSectionCard> createState() => _HomeSectionCardState();
}

class _HomeSectionCardState extends State<_HomeSectionCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.info.heroTag,
      child: Material(
        color: Colors.transparent,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            borderRadius: BorderRadius.circular(24),
            child: Card(
              color: widget.info.color.withOpacity(0.85),
              elevation: 6,
              shadowColor: widget.info.color.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.info.icon,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.info.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explorar ${widget.info.title.toLowerCase()}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SectionPlaceholderScreen extends StatelessWidget {
  const SectionPlaceholderScreen({
    super.key,
    required this.info,
  });

  final _SectionInfo info;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(info.title),
        backgroundColor: info.color,
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Hero(
            tag: info.heroTag,
            child: Card(
              key: ValueKey(info.title),
              color: info.color.withOpacity(0.9),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: SizedBox(
                width: 260,
                height: 260,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(info.icon, size: 64, color: Colors.white),
                      const SizedBox(height: 20),
                      Text(
                        info.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'La sección de ${info.title.toLowerCase()} estará disponible pronto.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white.withOpacity(0.85)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionInfo {
  const _SectionInfo({
    required this.title,
    required this.icon,
    required this.color,
    required this.heroTag,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String heroTag;
}
