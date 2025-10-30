import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'abilities_screen.dart';
import 'pokedex_screen.dart';
import 'settings_screen.dart';

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
      graphics: [
        _SectionGraphic.icon(
          icon: Icons.catching_pokemon,
          scale: 0.92,
          color: Colors.white,
          opacity: 0.96,
        ),
        _SectionGraphic.icon(
          icon: Icons.auto_awesome_motion,
          scale: 0.42,
          color: Colors.white,
          opacity: 0.5,
          alignment: Alignment.bottomLeft,
          offset: Offset(-18, 24),
        ),
      ],
      accents: [
        _AccentShape.circle(
          top: -52,
          right: -28,
          diameterFactor: 1.05,
          color: Colors.white,
          opacity: 0.2,
        ),
        _AccentShape.circle(
          bottom: -48,
          left: -18,
          diameterFactor: 0.68,
          color: Colors.white,
          opacity: 0.12,
        ),
        _AccentShape.roundedRect(
          bottom: 36,
          right: -48,
          widthFactor: 0.58,
          heightFactor: 0.22,
          color: Colors.black,
          opacity: 0.18,
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
      ],
    ),
    _SectionInfo(
      title: 'Moves',
      subtitle: 'Damage, effects & contest data',
      icon: Icons.flash_on,
      color: Color(0xFF4DA3FF),
      heroTag: 'section-moves',
      graphics: [
        _SectionGraphic.icon(
          icon: Icons.flash_on,
          scale: 0.88,
          color: Colors.white,
          opacity: 0.94,
        ),
        _SectionGraphic.icon(
          icon: Icons.stacked_line_chart,
          scale: 0.4,
          color: Colors.white,
          opacity: 0.48,
          alignment: Alignment.bottomLeft,
          offset: Offset(-12, 18),
        ),
      ],
      accents: [
        _AccentShape.circle(
          top: -40,
          right: -26,
          diameterFactor: 0.9,
          color: Colors.white,
          opacity: 0.18,
        ),
        _AccentShape.roundedRect(
          bottom: -24,
          right: 12,
          widthFactor: 0.54,
          heightFactor: 0.18,
          color: Colors.white,
          opacity: 0.12,
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ],
    ),
    _SectionInfo(
      title: 'TM',
      subtitle: 'Machines & tutors by generation',
      icon: Icons.memory,
      color: Color(0xFFF2A649),
      heroTag: 'section-tm',
      graphics: [
        _SectionGraphic.icon(
          icon: Icons.memory,
          scale: 0.88,
          color: Colors.white,
          opacity: 0.94,
        ),
        _SectionGraphic.icon(
          icon: Icons.settings_input_component,
          scale: 0.38,
          color: Colors.white,
          opacity: 0.48,
          alignment: Alignment.bottomLeft,
          offset: Offset(-10, 20),
        ),
      ],
      accents: [
        _AccentShape.circle(
          top: -34,
          right: -22,
          diameterFactor: 0.84,
          color: Colors.white,
          opacity: 0.18,
        ),
        _AccentShape.roundedRect(
          bottom: -20,
          right: 18,
          widthFactor: 0.52,
          heightFactor: 0.18,
          color: Colors.black,
          opacity: 0.1,
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
      ],
    ),
    _SectionInfo(
      title: 'Abilities',
      subtitle: 'Passive effects & triggers',
      icon: Icons.auto_fix_high,
      color: Color(0xFF9D4EDD),
      heroTag: 'section-abilities',
      graphics: [
        _SectionGraphic.icon(
          icon: Icons.auto_fix_high,
          scale: 0.9,
          color: Colors.white,
          opacity: 0.95,
        ),
        _SectionGraphic.icon(
          icon: Icons.bubble_chart,
          scale: 0.4,
          color: Colors.white,
          opacity: 0.48,
          alignment: Alignment.bottomLeft,
          offset: Offset(-14, 16),
        ),
      ],
      accents: [
        _AccentShape.circle(
          top: -36,
          right: -24,
          diameterFactor: 0.92,
          color: Colors.white,
          opacity: 0.2,
        ),
        _AccentShape.roundedRect(
          bottom: -18,
          right: 16,
          widthFactor: 0.5,
          heightFactor: 0.2,
          color: Colors.white,
          opacity: 0.13,
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
      ],
    ),
    _SectionInfo(
      title: 'Checklists',
      subtitle: 'Track goals & collections',
      icon: Icons.checklist_rtl,
      color: Color(0xFF59CD90),
      heroTag: 'section-checklists',
      graphics: [
        _SectionGraphic.icon(
          icon: Icons.check_circle_outline,
          scale: 0.86,
          color: Colors.white,
          opacity: 0.92,
        ),
        _SectionGraphic.icon(
          icon: Icons.fact_check,
          scale: 0.38,
          color: Colors.white,
          opacity: 0.5,
          alignment: Alignment.bottomLeft,
          offset: Offset(-12, 18),
        ),
      ],
      accents: [
        _AccentShape.circle(
          top: -32,
          right: -20,
          diameterFactor: 0.82,
          color: Colors.white,
          opacity: 0.18,
        ),
        _AccentShape.roundedRect(
          bottom: -22,
          right: 12,
          widthFactor: 0.5,
          heightFactor: 0.18,
          color: Colors.black,
          opacity: 0.12,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ],
    ),
    _SectionInfo(
      title: 'Parties',
      subtitle: 'Build teams & strategies',
      icon: Icons.groups_2,
      color: Color(0xFFFF6F91),
      heroTag: 'section-parties',
      graphics: [
        _SectionGraphic.icon(
          icon: Icons.groups_2,
          scale: 0.88,
          color: Colors.white,
          opacity: 0.95,
        ),
        _SectionGraphic.icon(
          icon: Icons.auto_graph,
          scale: 0.38,
          color: Colors.white,
          opacity: 0.48,
          alignment: Alignment.bottomLeft,
          offset: Offset(-14, 18),
        ),
      ],
      accents: [
        _AccentShape.circle(
          top: -36,
          right: -18,
          diameterFactor: 0.84,
          color: Colors.white,
          opacity: 0.18,
        ),
        _AccentShape.roundedRect(
          bottom: -20,
          right: 16,
          widthFactor: 0.52,
          heightFactor: 0.18,
          color: Colors.white,
          opacity: 0.12,
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
      ],
    ),
    _SectionInfo(
      title: 'Locations',
      subtitle: 'Regions, maps & encounter data',
      icon: Icons.travel_explore,
      color: Color(0xFF3BC9DB),
      heroTag: 'section-locations',
      graphics: [
        _SectionGraphic.icon(
          icon: Icons.travel_explore,
          scale: 0.88,
          color: Colors.white,
          opacity: 0.95,
        ),
        _SectionGraphic.icon(
          icon: Icons.explore,
          scale: 0.38,
          color: Colors.white,
          opacity: 0.48,
          alignment: Alignment.bottomLeft,
          offset: Offset(-10, 20),
        ),
      ],
      accents: [
        _AccentShape.circle(
          top: -32,
          right: -20,
          diameterFactor: 0.9,
          color: Colors.white,
          opacity: 0.18,
        ),
        _AccentShape.roundedRect(
          bottom: -22,
          right: 12,
          widthFactor: 0.5,
          heightFactor: 0.2,
          color: Colors.black,
          opacity: 0.12,
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ],
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
    final List<_SectionInfo> sections = _sections;
    final _SectionInfo? heroSection =
        sections.isNotEmpty ? sections.first : null;
    final List<_SectionInfo> otherSections =
        sections.length > 1 ? sections.sublist(1) : <_SectionInfo>[];
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
                                const _HeaderIcon(
                                  icon: Icons.notifications_none,
                                ),
                                const SizedBox(width: 12),
                                const _HeaderIcon(
                                  icon: Icons.shopping_bag_outlined,
                                ),
                                const SizedBox(width: 12),
                                _HeaderIcon(
                                  icon: Icons.settings_outlined,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const SettingsScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                      if (heroSection != null) ...[
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),
                        SliverToBoxAdapter(
                          child: _HomeSectionCard(
                            info: heroSection,
                            onTap: () => _openSection(heroSection),
                            isHero: true,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                      if (otherSections.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.only(bottom: 28),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final section = otherSections[index];
                                return _HomeSectionCard(
                                  info: section,
                                  onTap: () => _openSection(section),
                                );
                              },
                              childCount: otherSections.length,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: gridSpacing,
                              crossAxisSpacing: gridSpacing,
                              childAspectRatio: childAspectRatio,
                            ),
                          ),
                        ),
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
    final bool isHero = widget.isHero;
    final baseTitleStyle = isHero
        ? textTheme.headlineMedium ?? textTheme.headlineSmall
        : textTheme.titleLarge ?? textTheme.titleMedium;
    final titleStyle = baseTitleStyle?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      height: 1.05,
      letterSpacing: -0.2,
    );

    final baseSubtitleStyle = isHero
        ? textTheme.bodyLarge ?? textTheme.bodyMedium
        : textTheme.bodyMedium ?? textTheme.bodySmall;
    final subtitleStyle = baseSubtitleStyle?.copyWith(
      color: Colors.white.withOpacity(isHero ? 0.88 : 0.84),
      height: 1.35,
    );

    final double cornerRadius = isHero ? 36 : 28;
    final double pressedScale = isHero ? 0.975 : 0.965;

    final card = Material(
      color: Colors.transparent,
      child: AnimatedScale(
        scale: _pressed ? pressedScale : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
          borderRadius: BorderRadius.circular(cornerRadius),
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: isHero ? 16 : 10,
            shadowColor: widget.info.color.withOpacity(0.45),
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double basePadding = isHero ? 28 : 22;
                final double verticalPadding = isHero ? 30 : 24;
                final double maxTextWidth =
                    constraints.maxWidth * (isHero ? 0.68 : 0.74);

                final List<_SectionGraphic> graphics =
                    widget.info.graphics.isNotEmpty
                        ? widget.info.graphics
                        : [
                            _SectionGraphic.icon(
                              icon: widget.info.icon,
                              color: Colors.white,
                              opacity: 0.94,
                            ),
                          ];

                return Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.info.color
                                  .withOpacity(isHero ? 0.96 : 0.92),
                              widget.info.color
                                  .withOpacity(isHero ? 0.8 : 0.78),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    ..._buildBackgroundAccents(
                      constraints: constraints,
                      fallbackRadius: cornerRadius,
                    ),
                    Positioned(
                      right: basePadding - (isHero ? 8 : 6),
                      top: verticalPadding - (isHero ? 8 : 6),
                      child: _buildGraphicGroup(
                        constraints: constraints,
                        graphics: graphics,
                      ),
                    ),
                    Positioned(
                      left: basePadding,
                      bottom: verticalPadding,
                      right: basePadding,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: maxTextWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.info.title,
                              style: titleStyle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: isHero ? 12 : 10),
                            Text(
                              widget.info.subtitle,
                              style: subtitleStyle,
                              maxLines: isHero ? 3 : 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    if (!isHero) {
      return card;
    }

    return Hero(
      tag: widget.info.heroTag,
      child: card,
    );
  }

  Widget _buildGraphicGroup({
    required BoxConstraints constraints,
    required List<_SectionGraphic> graphics,
  }) {
    final double minDimension =
        math.min(constraints.maxWidth, constraints.maxHeight);
    final double baseExtent =
        (widget.isHero ? 0.64 : 0.58) * minDimension;
    final double extent = baseExtent.clamp(
      108.0,
      widget.isHero ? 220.0 : 172.0,
    );

    return SizedBox(
      width: extent,
      height: extent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final graphic in graphics)
            Align(
              alignment: graphic.alignment,
              child: Transform.translate(
                offset: graphic.offset,
                child: _buildGraphic(
                  graphic,
                  baseExtent: extent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGraphic(
    _SectionGraphic graphic, {
    required double baseExtent,
  }) {
    final double rawSize =
        graphic.fixedSize ?? (baseExtent * graphic.scale);
    final double size = rawSize.clamp(32.0, baseExtent * 1.05).toDouble();
    final Color? baseColor = graphic.color ??
        (graphic.icon != null ? Colors.white : null);
    final Color? effectiveColor =
        baseColor?.withOpacity(graphic.opacity);

    final assetPath = graphic.asset;
    if (assetPath != null) {
      return SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          assetPath,
          color: effectiveColor,
          colorBlendMode:
              effectiveColor != null ? BlendMode.srcIn : null,
          fit: BoxFit.contain,
        ),
      );
    }

    return Icon(
      graphic.icon,
      size: size,
      color: effectiveColor ?? Colors.white.withOpacity(graphic.opacity),
    );
  }

  List<Widget> _buildBackgroundAccents({
    required BoxConstraints constraints,
    required double fallbackRadius,
  }) {
    if (widget.info.accents.isEmpty) {
      return const <Widget>[];
    }

    final double baseDimension =
        math.min(constraints.maxWidth, constraints.maxHeight);

    return widget.info.accents.map((accent) {
      final double width = accent.width ??
          baseDimension * (accent.widthFactor ?? 0.58);
      final double height = accent.height ??
          (accent.shape == BoxShape.circle
              ? width
              : baseDimension * (accent.heightFactor ?? 0.2));

      return Positioned(
        top: accent.top,
        right: accent.right,
        bottom: accent.bottom,
        left: accent.left,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: accent.color.withOpacity(accent.opacity),
            shape: accent.shape,
            borderRadius: accent.shape == BoxShape.rectangle
                ? accent.borderRadius ??
                    BorderRadius.circular(fallbackRadius * 0.7)
                : null,
          ),
        ),
      );
    }).toList();
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceVariant.withOpacity(0.35),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
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
    this.graphics = const [],
    this.accents = const [],
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String heroTag;
  final List<_SectionGraphic> graphics;
  final List<_AccentShape> accents;
}

class _SectionGraphic {
  const _SectionGraphic.icon({
    required this.icon,
    this.fixedSize,
    this.scale = 1,
    this.opacity = 1,
    this.color,
    this.alignment = Alignment.topRight,
    this.offset = Offset.zero,
  }) : asset = null;

  const _SectionGraphic.asset({
    required this.asset,
    this.fixedSize,
    this.scale = 1,
    this.opacity = 1,
    this.color,
    this.alignment = Alignment.topRight,
    this.offset = Offset.zero,
  }) : icon = null;

  final IconData? icon;
  final String? asset;
  final double? fixedSize;
  final double scale;
  final double opacity;
  final Color? color;
  final Alignment alignment;
  final Offset offset;
}

class _AccentShape {
  const _AccentShape._({
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.width,
    this.height,
    this.widthFactor,
    this.heightFactor,
    required this.color,
    required this.shape,
    this.borderRadius,
    this.opacity = 1,
  });

  const _AccentShape.circle({
    double? top,
    double? right,
    double? bottom,
    double? left,
    double? diameter,
    double? diameterFactor,
    required Color color,
    double opacity = 1,
  }) : this._(
          top: top,
          right: right,
          bottom: bottom,
          left: left,
          width: diameter,
          height: diameter,
          widthFactor: diameterFactor,
          heightFactor: diameterFactor,
          color: color,
          shape: BoxShape.circle,
          opacity: opacity,
        );

  const _AccentShape.roundedRect({
    double? top,
    double? right,
    double? bottom,
    double? left,
    double? width,
    double? height,
    double? widthFactor,
    double? heightFactor,
    required Color color,
    double opacity = 1,
    BorderRadius? borderRadius,
  }) : this._(
          top: top,
          right: right,
          bottom: bottom,
          left: left,
          width: width,
          height: height,
          widthFactor: widthFactor,
          heightFactor: heightFactor,
          color: color,
          shape: BoxShape.rectangle,
          borderRadius: borderRadius,
          opacity: opacity,
        );

  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final double? width;
  final double? height;
  final double? widthFactor;
  final double? heightFactor;
  final Color color;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final double opacity;
}
