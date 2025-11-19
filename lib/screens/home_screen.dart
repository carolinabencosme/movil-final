import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'abilities_screen.dart';
import 'pokedex_screen.dart';
import 'settings_screen.dart';
import '../localization/localization_controller.dart';

/// Pantalla principal (Home) que presenta accesos a secciones de la app.
/// - Muestra una tarjeta “hero” (la primera) y un grid con el resto.
/// - Cada tarjeta tiene animaciones sutiles, acentos decorativos y un Hero tag
///   para transiciones fluidas hacia las pantallas destino.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Controla si ya se debe mostrar el grid (se habilita un frame después para
  /// permitir animaciones de entrada suaves con AnimatedSwitcher).
  bool _showGrid = false;

  /// Configuración estática de secciones a mostrar en Home.
  /// Cada sección define:
  /// - título, subtítulo, icono, color y heroTag
  /// - gráficos decorativos (icons/assets) y acentos de fondo (shapes)
  List<_SectionInfo> _buildSections(AppLocalizations l10n) {
    return [
      _SectionInfo(
        id: 'pokedex',
        title: l10n.homeSectionPokedexTitle,
        subtitle: l10n.homeSectionPokedexSubtitle,
        icon: Icons.catching_pokemon,
        color: const Color(0xFFE94256),
        heroTag: 'section-pokedex',
        graphics: const [
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
        accents: const [
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
        id: 'favorites',
        title: l10n.homeSectionFavoritesTitle,
        subtitle: l10n.homeSectionFavoritesSubtitle,
        icon: Icons.favorite,
        color: const Color(0xFFFF8FAB),
        heroTag: 'section-favorites',
        graphics: const [
          _SectionGraphic.icon(
            icon: Icons.favorite,
            scale: 0.92,
            color: Colors.white,
            opacity: 0.94,
          ),
          _SectionGraphic.icon(
            icon: Icons.star_rounded,
            scale: 0.42,
            color: Colors.white,
            opacity: 0.52,
            alignment: Alignment.bottomLeft,
            offset: Offset(-14, 22),
          ),
        ],
        accents: const [
          _AccentShape.circle(
            top: -48,
            right: -24,
            diameterFactor: 0.95,
            color: Colors.white,
            opacity: 0.2,
          ),
          _AccentShape.roundedRect(
            bottom: -26,
            right: 16,
            widthFactor: 0.5,
            heightFactor: 0.18,
            color: Colors.black,
            opacity: 0.12,
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
        ],
      ),
      _SectionInfo(
        id: 'moves',
        title: l10n.homeSectionMovesTitle,
        subtitle: l10n.homeSectionMovesSubtitle,
        icon: Icons.flash_on,
        color: const Color(0xFF4DA3FF),
        heroTag: 'section-moves',
        graphics: const [
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
        accents: const [
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
        id: 'tm',
        title: l10n.homeSectionTmTitle,
        subtitle: l10n.homeSectionTmSubtitle,
        icon: Icons.memory,
        color: const Color(0xFFF2A649),
        heroTag: 'section-tm',
        graphics: const [
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
        accents: const [
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
        id: 'abilities',
        title: l10n.homeSectionAbilitiesTitle,
        subtitle: l10n.homeSectionAbilitiesSubtitle,
        icon: Icons.auto_fix_high,
        color: const Color(0xFF9D4EDD),
        heroTag: 'section-abilities',
        graphics: const [
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
        accents: const [
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
        id: 'checklists',
        title: l10n.homeSectionChecklistsTitle,
        subtitle: l10n.homeSectionChecklistsSubtitle,
        icon: Icons.checklist_rtl,
        color: const Color(0xFF59CD90),
        heroTag: 'section-checklists',
        graphics: const [
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
        accents: const [
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
        id: 'parties',
        title: l10n.homeSectionPartiesTitle,
        subtitle: l10n.homeSectionPartiesSubtitle,
        icon: Icons.groups_2,
        color: const Color(0xFFFF6F91),
        heroTag: 'section-parties',
        graphics: const [
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
        accents: const [
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
        id: 'locations',
        title: l10n.homeSectionLocationsTitle,
        subtitle: l10n.homeSectionLocationsSubtitle,
        icon: Icons.travel_explore,
        color: const Color(0xFF3BC9DB),
        heroTag: 'section-locations',
        graphics: const [
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
        accents: const [
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
  }

  @override
  void initState() {
    super.initState();
    // Difere el render del grid un frame para activar la animación del switcher
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _showGrid = true);
    });
  }

  /// Navega a la vista correspondiente según la sección seleccionada.
  /// Para secciones no implementadas, abre un placeholder genérico.
  void _openSection(_SectionInfo section) {
    Widget destination;
    switch (section.id) {
      case 'pokedex':
        destination = PokedexScreen(
          heroTag: section.heroTag,
          accentColor: section.color,
          title: section.title,
        );
        break;
      case 'favorites':
        destination = FavoritesScreen(
          heroTag: section.heroTag,
          accentColor: section.color,
          title: section.title,
        );
        break;
      case 'abilities':
        destination = AbilitiesScreen(
          heroTag: section.heroTag,
          accentColor: section.color,
          title: section.title,
        );
        break;
      default:
        destination = SectionPlaceholderScreen(info: section);
    }

    // Transición fade custom (PageRouteBuilder) para consistencia visual
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

  void _showLanguageSelector(
    BuildContext context,
    LocalizationController localizationController,
    AppLocalizations l10n,
  ) {
    final selectedLanguage =
        localizationController.locale?.languageCode ?? 'system';

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _LanguageSelectorSheet(
        selectedLanguage: selectedLanguage,
        onSelected: (languageCode) {
          localizationController.updateLocale(
            languageCode == 'system' ? null : Locale(languageCode),
          );
          Navigator.of(context).pop();
        },
        l10n: l10n,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localizationController = LocalizationScope.of(context);
    // Separamos la primera sección (hero) del resto (grid)
    final List<_SectionInfo> sections = _buildSections(l10n);
    final _SectionInfo? heroSection =
        sections.isNotEmpty ? sections.first : null;
    final List<_SectionInfo> otherSections =
        sections.length > 1 ? sections.sublist(1) : <_SectionInfo>[];
    // Métricas y constantes para layout responsivo
    const double pageHorizontalPadding = 20;
    const double gridSpacing = 16;
    final Size size = MediaQuery.of(context).size;
    final double availableWidth =
        size.width - (pageHorizontalPadding * 2) - gridSpacing;
    final double tileWidth = math.max(0, availableWidth / 2);
    final double tileHeight = math.max(220, tileWidth + 56);
    final double childAspectRatio =
        tileWidth > 0 ? tileWidth / tileHeight : 0.95;
    final double heroWidth = math.max(0, size.width - (pageHorizontalPadding * 2));
    final double heroHeight =
        heroWidth > 0 ? math.max(280, heroWidth * 0.58) : 280;
    // Chips de acceso rápido (placeholder de navegación futura)
    final quickAccess = [
      l10n.homeQuickAccessGym,
      l10n.homeQuickAccessNatures,
      l10n.homeQuickAccessTypes,
      l10n.homeQuickAccessEvolutions,
      l10n.homeQuickAccessBreeding,
      l10n.homeQuickAccessBerries,
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: pageHorizontalPadding,
            vertical: 16,
          ),
          // Alterna entre un SizedBox.shrink y el scroll con animación
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _showGrid
                ? CustomScrollView(
                    key: const ValueKey('home-scroll'),
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Encabezado con título y acciones (notificaciones, tienda, ajustes)
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.homeTitle,
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
                                _HeaderIcon(
                                  icon: Icons.notifications_none,
                                  semanticLabel: l10n.homeNotificationsLabel,
                                ),
                                const SizedBox(width: 12),
                                _HeaderIcon(
                                  icon: Icons.shopping_bag_outlined,
                                  semanticLabel: l10n.homeShopLabel,
                                ),
                                const SizedBox(width: 12),
                                _HeaderIcon(
                                  icon: Icons.translate,
                                  semanticLabel: l10n.homeLanguageLabel,
                                  onTap: () => _showLanguageSelector(
                                    context,
                                    localizationController,
                                    l10n,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _HeaderIcon(
                                  icon: Icons.settings_outlined,
                                  semanticLabel: l10n.homeSettingsLabel,
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
                      // Tarjeta “hero” (primera sección destacada)
                      if (heroSection != null) ...[
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: heroHeight,
                            child: _HomeSectionCard(
                              info: heroSection,
                              onTap: () => _openSection(heroSection),
                              isHero: true,
                              heroHeight: heroHeight,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                      // Grid del resto de secciones
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
                      // Fila horizontal con chips de acceso rápido
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
/// Tarjeta de sección reutilizable para el hero y los ítems del grid.
/// - Maneja animación de “press” (scale) y resalta con sombras.
/// - Dibuja fondo degradado, grupos de gráficos (iconos/assets) y acentos.
class _HomeSectionCard extends StatefulWidget {
  const _HomeSectionCard({
    required this.info,
    required this.onTap,
    this.isHero = false,
    this.heroHeight,
  });

  final _SectionInfo info;
  final VoidCallback onTap;
  final bool isHero;
  final double? heroHeight;

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
    // Estilos de tipografía adaptados si es hero o grid
    final bool isHero = widget.isHero;
    final double? heroHeight = widget.heroHeight;
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
                // Cuando la tarjeta hero está en un SliverToBoxAdapter sin altura
                // acotada, fijamos un alto para evitar “unbounded height”.
                final bool needsHeroHeight =
                    !constraints.hasBoundedHeight && heroHeight != null;
                final BoxConstraints effectiveConstraints = needsHeroHeight
                    ? BoxConstraints(
                        minWidth: constraints.minWidth,
                        maxWidth: constraints.maxWidth,
                        minHeight: constraints.minHeight,
                        maxHeight: heroHeight!,
                      )
                    : constraints;

                // Grupo de gráficos decorativos (iconos o assets) en la esquina
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
                // Stack principal de la tarjeta:
                // - Fondo degradado
                // - Acentos (shapes)
                // - Grupo de gráficos (íconos/assets)
                // - Texto (título/subtítulo) alineado abajo-izquierda

                final stack = Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    // Fondo con gradiente en función del color de la sección
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
                    // Acentos decorativos (círculos/rectángulos redondeados)
                    ..._buildBackgroundAccents(
                      constraints: effectiveConstraints,
                      fallbackRadius: cornerRadius,
                    ),
                    // Grupo de gráficos (íconos grandes) arriba-derecha
                    Positioned(
                      right: basePadding - (isHero ? 8 : 6),
                      top: verticalPadding - (isHero ? 8 : 6),
                      child: _buildGraphicGroup(
                        constraints: effectiveConstraints,
                        graphics: graphics,
                      ),
                    ),
                    // Texto (título + subtítulo) limitado en ancho para no chocar con gráficos
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

                if (needsHeroHeight) {
                  return SizedBox(
                    height: heroHeight,
                    child: stack,
                  );
                }

                return stack;
              },
            ),
          ),
        ),
      ),
    );

    Widget result = card;
    if (isHero) {
      result = Hero(
        tag: widget.info.heroTag,
        child: result,
      );
    }

    final semanticsLabel =
        '${widget.info.title}. ${widget.info.subtitle}'.trim();

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: result,
    );
  }
  /// Construye un grupo de gráficos decorativos en la esquina superior derecha.
  /// Los tamaños escalan con el tamaño disponible de la tarjeta.
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
  /// Renderiza un gráfico individual (icono o asset) con color y opacidad.
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
  /// Dibuja los acentos de fondo (círculos y rectángulos redondeados) con
  /// posiciones absolutas opcionales (top/right/bottom/left) y tamaños relativos.
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

class _LanguageSelectorSheet extends StatelessWidget {
  const _LanguageSelectorSheet({
    required this.selectedLanguage,
    required this.onSelected,
    required this.l10n,
  });

  final String selectedLanguage;
  final ValueChanged<String> onSelected;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final options = [
      ('system', l10n.settingsLanguageSystem),
      ('en', l10n.settingsLanguageEnglish),
      ('es', l10n.settingsLanguageSpanish),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.translate,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsLanguageTitle,
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.settingsLanguageSubtitle,
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...options.map(
              (option) => RadioListTile<String>(
                value: option.$1,
                groupValue: selectedLanguage,
                onChanged: (value) {
                  if (value != null) {
                    onSelected(value);
                  }
                },
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                title: Text(
                  option.$2,
                  style: textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/// Iconos del header (campana, bolsa, ajustes) con feedback táctil.
class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    this.semanticLabel,
    this.onTap,
  });

  final IconData icon;
  final String? semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconWidget = Material(
      color: colorScheme.surfaceVariant.withOpacity(0.35),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 48,
          width: 48,
          child: Icon(
            icon,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: semanticLabel,
      child: iconWidget,
    );
  }
}
/// Pantalla placeholder para secciones aún no implementadas.
/// Reutiliza el Hero para mantener coherencia de la transición.
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
/// DTO interno con la definición de cada sección del Home.
class _SectionInfo {
  const _SectionInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.heroTag,
    this.graphics = const [],
    this.accents = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String heroTag;
  /// Grupo de gráficos decorativos que se dibujan arriba-derecha.
  final List<_SectionGraphic> graphics;
  /// Acentos geométricos de fondo (círculos/rectángulos).
  final List<_AccentShape> accents;
}
/// Definición de un gráfico decorativo:
/// - Puede ser un icono (IconData) o un asset (ruta).
/// - `scale` y `fixedSize` controlan su tamaño relativo/absoluto.
/// - `alignment` y `offset` posicionan dentro del contenedor.
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
/// Acento geométrico de fondo.
/// Usa fábrica `circle` o `roundedRect` para crear formas comunes.
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

  /// Círculo con diámetro absoluto (`diameter`) o relativo (`diameterFactor`).
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

  /// Rectángulo redondeado con tamaño absoluto o relativo.
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

  // Posicionamiento absoluto opcional dentro del Stack
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  // Tamaños absolutos o relativos (si no se provee, usa factores * dimensión base)
  final double? width;
  final double? height;
  final double? widthFactor;
  final double? heightFactor;
  final Color color;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final double opacity;
}
