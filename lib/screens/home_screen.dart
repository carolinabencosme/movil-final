import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'abilities_screen.dart';
import 'pokedex_screen.dart';

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
      subtitle: 'National index & regional dexes',
      icon: Icons.catching_pokemon,
      color: Color(0xFFE94256),
      heroTag: 'section-pokedex',
    ),
    _SectionInfo(
      title: 'Moves',
      subtitle: 'Damage, effects & contest data',
      icon: Icons.flash_on,
      color: Color(0xFF4DA3FF),
      heroTag: 'section-moves',
    ),
    _SectionInfo(
      title: 'TM',
      subtitle: 'Machines & tutors by generation',
      icon: Icons.memory,
      color: Color(0xFFF2A649),
      heroTag: 'section-tm',
    ),
    _SectionInfo(
      title: 'Abilities',
      subtitle: 'Passive effects & triggers',
      icon: Icons.auto_fix_high,
      color: Color(0xFF9D4EDD),
      heroTag: 'section-abilities',
    ),
    _SectionInfo(
      title: 'Checklists',
      subtitle: 'Track goals & collections',
      icon: Icons.checklist_rtl,
      color: Color(0xFF59CD90),
      heroTag: 'section-checklists',
    ),
    _SectionInfo(
      title: 'Parties',
      subtitle: 'Build teams & strategies',
      icon: Icons.groups_2,
      color: Color(0xFFFF6F91),
      heroTag: 'section-parties',
    ),
    _SectionInfo(
      title: 'Locations',
      subtitle: 'Regions, maps & encounter data',
      icon: Icons.travel_explore,
      color: Color(0xFF3BC9DB),
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

  void _openSection(_SectionInfo section) {
    Widget destination;
    switch (section.title) {
      case 'Pokédex':
        destination = PokedexScreen(
          heroTag: section.heroTag,
          accentColor: section.color,
          title: section.title,
        );
        break;
      case 'Abilities':
        destination = AbilitiesScreen(
          heroTag: section.heroTag,
          accentColor: section.color,
          title: section.title,
        );
        break;
      default:
        destination = SectionPlaceholderScreen(info: section);
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: destination,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final heroSection = _sections.first;
    final gridSections = _sections.skip(1).toList();
    const double pageHorizontalPadding = 20;
    const double gridSpacing = 16;
    final Size size = MediaQuery.of(context).size;
    final double availableWidth =
        size.width - (pageHorizontalPadding * 2) - gridSpacing;
    final double tileWidth = math.max(0, availableWidth / 2);
    final double tileHeight = math.max(220, tileWidth + 56);
    final double childAspectRatio =
        tileWidth > 0 ? tileWidth / tileHeight : 0.95;

    const quickAccess = [
      'Gym Leaders & Elite 4',
      'Natures',
      'Type Matchups',
      'Evolution Chains',
      'Breeding Guides',
      'Berry Farming',
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: pageHorizontalPadding,
            vertical: 16,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _showGrid
                ? CustomScrollView(
                    key: const ValueKey('home-scroll'),
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'ProDex',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                  ),
                                ),
                                const _HeaderIcon(icon: Icons.notifications_none),
                                const SizedBox(width: 12),
                                const _HeaderIcon(icon: Icons.shopping_bag_outlined),
                                const SizedBox(width: 12),
                                const _HeaderIcon(icon: Icons.person_outline),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: math.max(220, tileHeight),
                          child: _HomeSectionCard(
                            info: heroSection,
                            onTap: () => _openSection(heroSection),
                            isHero: true,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final section = gridSections[index];
                            return _HomeSectionCard(
                              info: section,
                              onTap: () => _openSection(section),
                            );
                          },
                          childCount: gridSections.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: gridSpacing,
                          crossAxisSpacing: gridSpacing,
                          childAspectRatio: childAspectRatio,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 28)),
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick access',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final label in quickAccess)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: label == quickAccess.last ? 0 : 12,
                                      ),
                                      child: Chip(
                                        label: Text(label),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _HomeSectionCard extends StatefulWidget {
  const _HomeSectionCard({
    required this.info,
    required this.onTap,
    this.isHero = false,
  });

  final _SectionInfo info;
  final VoidCallback onTap;
  final bool isHero;

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
    final textTheme = Theme.of(context).textTheme;
    final baseTitleStyle = widget.isHero
        ? textTheme.headlineMedium ?? textTheme.headlineSmall
        : textTheme.titleLarge ?? textTheme.titleMedium;
    final titleStyle = baseTitleStyle?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    );

    final baseSubtitleStyle = widget.isHero
        ? textTheme.bodyLarge ?? textTheme.bodyMedium
        : textTheme.bodyMedium ?? textTheme.bodySmall;
    final subtitleStyle = baseSubtitleStyle?.copyWith(
      color: Colors.white.withOpacity(widget.isHero ? 0.9 : 0.85),
      height: 1.4,
    );

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
              color: widget.info.color.withOpacity(0.92),
              elevation: 6,
              shadowColor: widget.info.color.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: EdgeInsets.all(widget.isHero ? 26 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: EdgeInsets.all(widget.isHero ? 18 : 14),
                      child: Icon(
                        widget.info.icon,
                        size: widget.isHero ? 56 : 36,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: widget.isHero ? 12 : 16),
                    if (widget.isHero) const Spacer(),
                    Text(
                      widget.info.title,
                      style: titleStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.info.subtitle,
                      style: subtitleStyle,
                      maxLines: widget.isHero ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
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

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceVariant.withOpacity(0.35),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 44,
          width: 44,
          child: Icon(
            icon,
            color: colorScheme.onSurface,
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
                        info.subtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white.withOpacity(0.88)),
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
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.heroTag,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String heroTag;
}
