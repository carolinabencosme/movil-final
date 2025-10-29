import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/pokemon_model.dart';
import '../queries/get_pokemon_details.dart';
import '../theme/pokemon_type_colors.dart';
import '../widgets/pokemon_artwork.dart';

const Map<String, String> _typeEmojis = {
  'normal': '⭐️',
  'fire': '🔥',
  'water': '💧',
  'electric': '⚡️',
  'grass': '🍃',
  'ice': '❄️',
  'fighting': '🥊',
  'poison': '☠️',
  'ground': '🌋',
  'flying': '🕊️',
  'psychic': '🔮',
  'bug': '🐛',
  'rock': '🪨',
  'ghost': '👻',
  'dragon': '🐲',
  'dark': '🌑',
  'steel': '⚙️',
  'fairy': '🧚',
};

const String _backgroundTextureSvg = '''
<svg width="400" height="400" viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <radialGradient id="halo" cx="0.5" cy="0.5" r="0.5">
      <stop offset="0%" stop-color="white" stop-opacity="0.32"/>
      <stop offset="100%" stop-color="white" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <g fill="none" stroke="white" stroke-width="12" stroke-linecap="round" stroke-opacity="0.18">
    <path d="M50 200h300"/>
    <path d="M200 50v300"/>
    <circle cx="200" cy="200" r="160"/>
    <circle cx="200" cy="200" r="110" stroke-opacity="0.12" stroke-width="10"/>
    <circle cx="200" cy="200" r="60" stroke-opacity="0.1" stroke-width="8"/>
  </g>
  <circle cx="200" cy="200" r="48" fill="url(#halo)"/>
</svg>
''';

class _DetailTabConfig {
  const _DetailTabConfig({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

const List<_DetailTabConfig> _detailTabConfigs = [
  _DetailTabConfig(icon: Icons.info_outline_rounded, label: 'Información'),
  _DetailTabConfig(icon: Icons.bar_chart_rounded, label: 'Estadísticas'),
  _DetailTabConfig(icon: Icons.auto_awesome_motion_rounded, label: 'Matchups'),
  _DetailTabConfig(icon: Icons.upcoming_rounded, label: 'Futuras'),
];

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.pokemonId,
    this.initialPokemon,
    this.heroTag,
  });

  static const int _defaultLanguageId = 7;

  final int pokemonId;
  final PokemonListItem? initialPokemon;
  final String? heroTag;

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedHeroTag = heroTag ?? 'pokemon-image-$pokemonId';
    final previewName =
        initialPokemon != null ? _capitalize(initialPokemon!.name) : null;
    final previewImage = initialPokemon?.imageUrl ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(previewName ?? 'Detalles del Pokémon'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(getPokemonDetailsQuery),
          fetchPolicy: FetchPolicy.networkOnly,
          cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
          errorPolicy: ErrorPolicy.ignore,
          variables: {
            'id': pokemonId,
            'languageId': _defaultLanguageId,
          },
        ),
        builder: (result, {fetchMore, refetch}) {
          final data = result.data?['pokemon'] as Map<String, dynamic>?;

          if (result.isLoading && data == null) {
            return _LoadingDetailView(
              heroTag: resolvedHeroTag,
              imageUrl: previewImage,
              name: previewName,
            );
          }

          if (result.hasException && data == null) {
            debugPrint(
              'Error al cargar el detalle del Pokémon: ${result.exception}',
            );
            return _PokemonDetailErrorView(
              onRetry: refetch,
            );
          }

          if (data == null) {
            return const Center(
              child: Text('No se encontró información para este Pokémon.'),
            );
          }

          if (result.hasException) {
            debugPrint(
              'Se recibieron datos parciales con errores: ${result.exception}',
            );
          }

          final typeEfficacies =
              result.data?['type_efficacy'] as List<dynamic>? ?? [];

          final pokemon = PokemonDetail.fromGraphQL(
            data,
            typeEfficacies: typeEfficacies,
          );

          return RefreshIndicator(
            onRefresh: () async {
              await refetch?.call();
            },
            child: Stack(
              children: [
                _PokemonDetailBody(
                  pokemon: pokemon,
                  resolvedHeroTag: resolvedHeroTag,
                  capitalize: _capitalize,
                ),
                if (result.isLoading)
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PokemonDetailBody extends StatefulWidget {
  const _PokemonDetailBody({
    required this.pokemon,
    required this.resolvedHeroTag,
    required this.capitalize,
  });

  final PokemonDetail pokemon;
  final String resolvedHeroTag;
  final String Function(String) capitalize;

  @override
  State<_PokemonDetailBody> createState() => _PokemonDetailBodyState();
}

class _PokemonDetailBodyState extends State<_PokemonDetailBody> {
  String _formatHeight(int height) {
    if (height <= 0) return '—';
    final meters = height / 10.0;
    return '${_stripTrailingZeros(meters)} m';
  }

  String _formatWeight(int weight) {
    if (weight <= 0) return '—';
    final kilograms = weight / 10.0;
    return '${_stripTrailingZeros(kilograms)} kg';
  }

  String _stripTrailingZeros(double value) {
    final fixed = value.toStringAsFixed(value >= 10 ? 1 : 2);
    return fixed
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  String _formatLabel(String value) {
    if (value.isEmpty) {
      return value;
    }
    final sanitized = value.replaceAll('-', ' ');
    return widget.capitalize(sanitized);
  }

  Color _resolveTypeColor(String type, ColorScheme colorScheme) {
    return _resolveStaticTypeColor(type, colorScheme);
  }

  Widget _buildFloatingSummaryCard(
    ThemeData theme,
    ColorScheme colorScheme,
    PokemonDetail pokemon,
  ) {
    final textTheme = theme.textTheme;
    final idText = '#${pokemon.id.toString().padLeft(4, '0')}';
    final heightText = _formatHeight(pokemon.characteristics.height);
    final weightText = _formatWeight(pokemon.characteristics.weight);
    final labelStyle = textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );

    Widget buildMetric(String label, String value) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      );
    }

    final typeChips = pokemon.types
        .map((type) {
          final typeColor = _resolveTypeColor(type, colorScheme);
          final textColor = ThemeData.estimateBrightnessForColor(typeColor) ==
                  Brightness.dark
              ? Colors.white
              : colorScheme.onSurface;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: typeColor.withOpacity(0.35)),
            ),
            child: Text(
              _formatLabel(type),
              style: textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          );
        })
        .toList();

    return Card(
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surface.withOpacity(0.82),
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                idText,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              if (typeChips.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: typeChips,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildMetric('Altura', heightText),
                  const SizedBox(width: 14),
                  buildMetric('Peso', weightText),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pokemon = widget.pokemon;
    final mainAbilityDetail =
        pokemon.abilities.isNotEmpty ? pokemon.abilities.first : null;
    final mainAbility =
        mainAbilityDetail != null ? _formatLabel(mainAbilityDetail.name) : null;
    final abilitySubtitle = mainAbilityDetail == null
        ? null
        : (mainAbilityDetail.isHidden ? 'Habilidad oculta' : 'Habilidad principal');

    final colorScheme = theme.colorScheme;
    final typeColor = pokemon.types.isNotEmpty
        ? _resolveTypeColor(pokemon.types.first, colorScheme)
        : colorScheme.primary;
    final onTypeColor =
        ThemeData.estimateBrightnessForColor(typeColor) == Brightness.dark
            ? Colors.white
            : Colors.black87;
    final backgroundTint =
        Color.alphaBlend(typeColor.withOpacity(0.04), colorScheme.surface);
    final sectionBackground =
        Color.alphaBlend(typeColor.withOpacity(0.08), colorScheme.surfaceVariant);
    final sectionBorder = typeColor.withOpacity(0.25);

    return DefaultTabController(
      length: 4,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context)!;
          return DecoratedBox(
            decoration: BoxDecoration(color: backgroundTint),
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 360,
                    backgroundColor: typeColor,
                    foregroundColor: onTypeColor,
                    surfaceTintColor: typeColor,
                    flexibleSpace: LayoutBuilder(
                      builder: (context, constraints) {
                        final settings = context
                            .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
                        final currentExtent = settings?.currentExtent ?? constraints.maxHeight;
                        final maxExtent = settings?.maxExtent ?? constraints.maxHeight;
                        final minExtent = settings?.minExtent ?? kToolbarHeight;
                        final extentDelta = maxExtent - minExtent;
                        final expansionFactor = extentDelta <= 0
                            ? 0.0
                            : ((currentExtent - minExtent) / extentDelta)
                                .clamp(0.0, 1.0);
                        final parallaxFactor = 1 - expansionFactor;
                        final particleOpacity =
                            (ui.lerpDouble(0.35, 0.85, expansionFactor) ?? 0.35)
                                .clamp(0.0, 1.0);
                        final particleOffset =
                            ui.lerpDouble(-0.08, 0.14, parallaxFactor) ?? 0.0;

                        return FlexibleSpaceBar(
                          title: Text(widget.capitalize(pokemon.name)),
                          background: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        typeColor,
                                        Color.alphaBlend(
                                          typeColor.withOpacity(0.45),
                                          theme.colorScheme.surface,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      center: const Alignment(0, -0.4),
                                      radius: 1.05,
                                      colors: [
                                        typeColor.withOpacity(0.75),
                                        typeColor.withOpacity(0.1),
                                      ],
                                      stops: const [0.0, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: Opacity(
                                    opacity: 0.35,
                                    child: SvgPicture.string(
                                      _backgroundTextureSvg,
                                      fit: BoxFit.cover,
                                      colorFilter: ColorFilter.mode(
                                        onTypeColor.withOpacity(0.25),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: ClipRect(
                                  child: BackdropFilter(
                                    filter: ui.ImageFilter.blur(
                                      sigmaX: 18,
                                      sigmaY: 18,
                                    ),
                                    child: Container(
                                      color: typeColor.withOpacity(0.08),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: AnimatedSlide(
                                    duration: const Duration(milliseconds: 360),
                                    curve: Curves.easeOutCubic,
                                    offset: Offset(0, particleOffset),
                                    child: AnimatedOpacity(
                                      duration: const Duration(milliseconds: 320),
                                      curve: Curves.easeOut,
                                      opacity: particleOpacity,
                                      child: _ParticleField(
                                        color: onTypeColor.withOpacity(0.4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 24,
                                bottom: 24,
                                child: _buildFloatingSummaryCard(
                                  theme,
                                  colorScheme,
                                  pokemon,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 18),
                                  child: Hero(
                                    tag: widget.resolvedHeroTag,
                                    child: PokemonArtwork(
                                      imageUrl: pokemon.imageUrl,
                                      size: 210,
                                      borderRadius: 36,
                                      padding: const EdgeInsets.fromLTRB(
                                        24,
                                        16,
                                        48,
                                        16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(72),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12, top: 8),
                        child: Theme(
                          data: theme.copyWith(
                            tabBarTheme: theme.tabBarTheme.copyWith(
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              overlayColor: MaterialStateProperty.all(
                                Colors.transparent,
                              ),
                              splashFactory: NoSplash.splashFactory,
                            ),
                          ),
                          child: ChipTheme(
                            data: ChipTheme.of(context).copyWith(
                              backgroundColor: Colors.transparent,
                              selectedColor: onTypeColor.withOpacity(0.18),
                              disabledColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              shape: const StadiumBorder(),
                              labelStyle:
                                  theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: onTypeColor,
                              ),
                            ),
                            child: TabBar(
                              controller: tabController,
                              isScrollable: true,
                              indicator: _PillUnderlineTabIndicator(
                                borderSide: BorderSide(
                                  color: onTypeColor.withOpacity(0.18),
                                  width: 40,
                                ),
                                insets: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                              labelColor: onTypeColor,
                              unselectedLabelColor:
                                  onTypeColor.withOpacity(0.72),
                              tabs: [
                                for (var i = 0;
                                    i < _detailTabConfigs.length;
                                    i++)
                                  Tab(
                                    child: _ElasticTabChip(
                                      controller: tabController,
                                      index: i,
                                      config: _detailTabConfigs[i],
                                      foregroundColor: onTypeColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: AnimatedBuilder(
                animation: tabController.animation!,
                builder: (context, _) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    transitionBuilder: (child, animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      ));
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: TabBarView(
                      key: ValueKey<int>(tabController.index),
                      controller: tabController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _PokemonInfoTab(
                          pokemon: pokemon,
                          formatLabel: _formatLabel,
                          formatHeight: _formatHeight,
                          formatWeight: _formatWeight,
                          mainAbility: mainAbility,
                          abilitySubtitle: abilitySubtitle,
                          sectionBackground: sectionBackground,
                          sectionBorder: sectionBorder,
                        ),
                        _PokemonStatsTab(
                          pokemon: pokemon,
                          formatLabel: _formatLabel,
                          sectionBackground: sectionBackground,
                          sectionBorder: sectionBorder,
                        ),
                        _PokemonMatchupsTab(
                          pokemon: pokemon,
                          formatLabel: _formatLabel,
                          sectionBackground: sectionBackground,
                          sectionBorder: sectionBorder,
                        ),
                        _PokemonFutureTab(
                          pokemon: pokemon,
                          formatLabel: _formatLabel,
                          sectionBackground: sectionBackground,
                          sectionBorder: sectionBorder,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ElasticTabChip extends StatelessWidget {
  const _ElasticTabChip({
    required this.controller,
    required this.index,
    required this.config,
    required this.foregroundColor,
  });

  final TabController controller;
  final int index;
  final _DetailTabConfig config;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: controller.animation!,
      builder: (context, _) {
        final double animationValue = controller.animation!.value;
        final double distance =
            (animationValue - index).abs().clamp(0.0, 1.0).toDouble();
        final double activation = (1 - distance).clamp(0.0, 1.0).toDouble();
        final curvedActivation = CurvedAnimation(
          parent: AlwaysStoppedAnimation<double>(activation),
          curve: Curves.elasticOut,
        ).value;
        final scale = ui.lerpDouble(0.94, 1.08, curvedActivation) ?? 1.0;
        final Color textColor = Color.lerp(
              foregroundColor.withOpacity(0.65),
              foregroundColor,
              curvedActivation,
            ) ??
            foregroundColor;

        return Transform.scale(
          scale: scale,
          child: Chip(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            backgroundColor: Colors.transparent,
            avatar: Icon(
              config.icon,
              size: 18,
              color: textColor,
            ),
            label: Text(
              config.label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            shape: const StadiumBorder(),
          ),
        );
      },
    );
  }
}

class _PillUnderlineTabIndicator extends UnderlineTabIndicator {
  const _PillUnderlineTabIndicator({
    required super.borderSide,
    super.insets = EdgeInsets.zero,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size!;
    final TextDirection textDirection =
        configuration.textDirection ?? TextDirection.ltr;
    final Rect indicator = insets.resolve(textDirection).deflateRect(rect);
    final double indicatorHeight = math.min(borderSide.width, indicator.height);
    final double top =
        indicator.top + (indicator.height - indicatorHeight) / 2.0;
    final Rect pillRect = Rect.fromLTWH(
      indicator.left,
      top,
      indicator.width,
      indicatorHeight,
    );
    final Paint paint = borderSide.toPaint()..style = PaintingStyle.fill;
    final RRect rRect = RRect.fromRectAndRadius(
      pillRect,
      Radius.circular(indicatorHeight / 2.0),
    );
    canvas.drawRRect(rRect, paint);
  }
}

class _ParticleField extends StatelessWidget {
  const _ParticleField({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlePainter(color),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final shortestSide = size.shortestSide;
    final baseRadius = shortestSide * 0.06;
    final blurPaint = Paint()
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8);

    final clusters = <Offset>[
      Offset(size.width * 0.2, size.height * 0.35),
      Offset(size.width * 0.8, size.height * 0.42),
      Offset(size.width * 0.65, size.height * 0.18),
      Offset(size.width * 0.35, size.height * 0.72),
      Offset(size.width * 0.55, size.height * 0.58),
    ];

    for (final offset in clusters) {
      final gradientPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            color,
            color.withOpacity(0),
          ],
        ).createShader(
          Rect.fromCircle(center: offset, radius: baseRadius * 1.8),
        );

      canvas.drawCircle(offset, baseRadius * 1.6, gradientPaint);
      blurPaint.color = color.withOpacity(0.35);
      canvas.drawCircle(offset, baseRadius, blurPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _PokemonInfoTab extends StatelessWidget {
  const _PokemonInfoTab({
    required this.pokemon,
    required this.formatLabel,
    required this.formatHeight,
    required this.formatWeight,
    required this.mainAbility,
    required this.abilitySubtitle,
    required this.sectionBackground,
    required this.sectionBorder,
  });

  final PokemonDetail pokemon;
  final String Function(String) formatLabel;
  final String Function(int) formatHeight;
  final String Function(int) formatWeight;
  final String? mainAbility;
  final String? abilitySubtitle;
  final Color sectionBackground;
  final Color sectionBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final characteristics = pokemon.characteristics;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoSectionCard(
            title: 'Tipos',
            backgroundColor: sectionBackground,
            borderColor: sectionBorder,
            child: pokemon.types.isNotEmpty
                ? Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: pokemon.types
                        .map((type) {
                          final typeColor = _resolveStaticTypeColor(
                            type,
                            theme.colorScheme,
                          );
                          return Chip(
                            label: Text(formatLabel(type)),
                            backgroundColor: typeColor.withOpacity(0.18),
                            labelStyle: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(color: typeColor.withOpacity(0.45)),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        })
                        .toList(),
                  )
                : const Text('Sin información de tipos disponible.'),
          ),
          const SizedBox(height: 16),
          _InfoSectionCard(
            title: 'Datos básicos',
            backgroundColor: sectionBackground,
            borderColor: sectionBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.height,
                        label: 'Altura',
                        value: formatHeight(characteristics.height),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.monitor_weight_outlined,
                        label: 'Peso',
                        value: formatWeight(characteristics.weight),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  color: sectionBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: sectionBorder.withOpacity(0.8)),
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mainAbility ?? 'Sin habilidad principal disponible.',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (abilitySubtitle != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  abilitySubtitle!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withOpacity(0.75),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoSectionCard(
            title: 'Características',
            backgroundColor: sectionBackground,
            borderColor: sectionBorder,
            child: _CharacteristicsSection(
              characteristics: characteristics,
              formatHeight: formatHeight,
              formatWeight: formatWeight,
            ),
          ),
          const SizedBox(height: 16),
          _InfoSectionCard(
            title: 'Habilidades',
            backgroundColor: sectionBackground,
            borderColor: sectionBorder,
            child: pokemon.abilities.isNotEmpty
                ? Column(
                    children: pokemon.abilities
                        .map(
                          (ability) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: _AbilityTile(
                              ability: ability,
                              formatLabel: formatLabel,
                            ),
                          ),
                        )
                        .toList(),
                  )
                : const Text('Sin información de habilidades disponible.'),
          ),
        ],
      ),
    );
  }
}

class _PokemonStatsTab extends StatelessWidget {
  const _PokemonStatsTab({
    required this.pokemon,
    required this.formatLabel,
    required this.sectionBackground,
    required this.sectionBorder,
  });

  final PokemonDetail pokemon;
  final String Function(String) formatLabel;
  final Color sectionBackground;
  final Color sectionBorder;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: _InfoSectionCard(
        title: 'Estadísticas',
        backgroundColor: sectionBackground,
        borderColor: sectionBorder,
        child: pokemon.stats.isNotEmpty
            ? Column(
                children: pokemon.stats
                    .map(
                      (stat) => _StatBar(
                        label: formatLabel(stat.name.replaceAll('-', ' ')),
                        value: stat.baseStat,
                      ),
                    )
                    .toList(),
              )
            : const Text('Sin información de estadísticas disponible.'),
      ),
    );
  }
}

class _PokemonMatchupsTab extends StatelessWidget {
  const _PokemonMatchupsTab({
    required this.pokemon,
    required this.formatLabel,
    required this.sectionBackground,
    required this.sectionBorder,
  });

  final PokemonDetail pokemon;
  final String Function(String) formatLabel;
  final Color sectionBackground;
  final Color sectionBorder;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoSectionCard(
            title: 'Debilidades',
            backgroundColor: sectionBackground,
            borderColor: sectionBorder,
            child: _WeaknessSection(
              matchups: pokemon.typeMatchups,
              formatLabel: formatLabel,
            ),
          ),
          const SizedBox(height: 16),
          _InfoSectionCard(
            title: 'Resistencias e inmunidades',
            backgroundColor: sectionBackground,
            borderColor: sectionBorder,
            child: _TypeMatchupSection(
              matchups: pokemon.typeMatchups,
              formatLabel: formatLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _PokemonFutureTab extends StatelessWidget {
  const _PokemonFutureTab({
    required this.pokemon,
    required this.formatLabel,
    required this.sectionBackground,
    required this.sectionBorder,
  });

  final PokemonDetail pokemon;
  final String Function(String) formatLabel;
  final Color sectionBackground;
  final Color sectionBorder;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoSectionCard(
            title: 'Movimientos',
            backgroundColor: sectionBackground,
            borderColor: sectionBorder,
            child: _MovesSection(
              moves: pokemon.moves,
              formatLabel: formatLabel,
            ),
          ),
          const SizedBox(height: 16),
          _InfoSectionCard(
            title: 'Cadena evolutiva',
            backgroundColor: sectionBackground,
            borderColor: sectionBorder,
            child: _EvolutionSection(
              evolutionChain: pokemon.evolutionChain,
              currentSpeciesId: pokemon.speciesId,
              formatLabel: formatLabel,
            ),
          ),
        ],
      ),
    );
  }
}

Color _resolveStaticTypeColor(String type, ColorScheme colorScheme) {
  final color = pokemonTypeColors[type.toLowerCase()];
  return color ?? colorScheme.primary;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _InfoSectionCard extends StatelessWidget {
  const _InfoSectionCard({
    required this.title,
    required this.child,
    this.backgroundColor,
    this.borderColor,
  });

  final String title;
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardColor = backgroundColor ?? colorScheme.surfaceVariant.withOpacity(0.4);
    final outlineColor = borderColor ?? colorScheme.outline.withOpacity(0.12);
    return Card(
      margin: EdgeInsets.zero,
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(color: outlineColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: title),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _CharacteristicsSection extends StatelessWidget {
  const _CharacteristicsSection({
    required this.characteristics,
    required this.formatHeight,
    required this.formatWeight,
  });

  final PokemonCharacteristics characteristics;
  final String Function(int) formatHeight;
  final String Function(int) formatWeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <_CharacteristicData>[
      _CharacteristicData(
        icon: Icons.height,
        label: 'Altura',
        value: formatHeight(characteristics.height),
      ),
      _CharacteristicData(
        icon: Icons.monitor_weight_outlined,
        label: 'Peso',
        value: formatWeight(characteristics.weight),
      ),
      _CharacteristicData(
        icon: Icons.category_outlined,
        label: 'Categoría',
        value: characteristics.category.isNotEmpty
            ? characteristics.category
            : 'Sin categoría',
      ),
      _CharacteristicData(
        icon: Icons.catching_pokemon,
        label: 'Ratio de captura',
        value: characteristics.captureRate > 0
            ? characteristics.captureRate.toString()
            : '—',
      ),
      _CharacteristicData(
        icon: Icons.star_border_rounded,
        label: 'Experiencia base',
        value: characteristics.baseExperience > 0
            ? characteristics.baseExperience.toString()
            : '—',
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => _CharacteristicTile(
              icon: item.icon,
              label: item.label,
              value: item.value,
            ),
          )
          .toList(),
    );
  }
}

class _WeaknessSection extends StatefulWidget {
  const _WeaknessSection({
    required this.matchups,
    required this.formatLabel,
  });

  final List<TypeMatchup> matchups;
  final String Function(String) formatLabel;

  @override
  State<_WeaknessSection> createState() => _WeaknessSectionState();
}

class _WeaknessSectionState extends State<_WeaknessSection> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weaknesses = widget.matchups
        .where((matchup) => matchup.multiplier > 1.0)
        .toList()
      ..sort((a, b) => b.multiplier.compareTo(a.multiplier));

    if (weaknesses.isEmpty) {
      return const Text('No hay información de debilidades disponible.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
          child: _isExpanded
              ? Padding(
                  key: const ValueKey(true),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _WeaknessChipGrid(
                    weaknesses: weaknesses,
                    formatLabel: widget.formatLabel,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey(false)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _toggleExpanded,
            icon: Icon(_isExpanded ? Icons.expand_less : Icons.visibility),
            label: Text(
              _isExpanded ? 'Ocultar debilidades' : 'Ver debilidades',
            ),
          ),
        ),
      ],
    );
  }
}

class _WeaknessChipGrid extends StatelessWidget {
  const _WeaknessChipGrid({
    required this.weaknesses,
    required this.formatLabel,
  });

  final List<TypeMatchup> weaknesses;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: weaknesses
          .map(
            (matchup) => _WeaknessChip(
              matchup: matchup,
              formatLabel: formatLabel,
            ),
          )
          .toList(),
    );
  }
}

class _WeaknessChip extends StatelessWidget {
  const _WeaknessChip({
    required this.matchup,
    required this.formatLabel,
  });

  final TypeMatchup matchup;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final typeKey = matchup.type.toLowerCase();
    final typeColor = pokemonTypeColors[typeKey] ?? colorScheme.primary;
    final emoji = _typeEmojis[typeKey];
    final background = Color.alphaBlend(
      typeColor.withOpacity(0.16),
      colorScheme.surface.withOpacity(0.95),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: typeColor.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            formatLabel(matchup.type),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatMultiplier(matchup.multiplier),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: typeColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MovesSection extends StatefulWidget {
  const _MovesSection({
    required this.moves,
    required this.formatLabel,
  });

  final List<PokemonMove> moves;
  final String Function(String) formatLabel;

  @override
  State<_MovesSection> createState() => _MovesSectionState();
}

class _MovesSectionState extends State<_MovesSection> {
  String? _selectedMethod;
  bool _onlyWithLevel = false;

  String _resolveDisplayName(String value) {
    if (value.isEmpty) {
      return 'Movimiento desconocido';
    }
    final lowercase = value.toLowerCase();
    if (value == lowercase) {
      return widget.formatLabel(value);
    }
    return value;
  }

  String _formatMethod(String method) {
    if (method.toLowerCase() == 'unknown') {
      return 'Desconocido';
    }
    return widget.formatLabel(method);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.moves.isEmpty) {
      return const Text('Sin información de movimientos disponible.');
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final methods = widget.moves
        .map((move) => move.method)
        .where((method) => method.isNotEmpty)
        .toSet()
        .toList()
      ..sort(
        (a, b) => widget.formatLabel(a).compareTo(widget.formatLabel(b)),
      );

    final filteredMoves = widget.moves.where((move) {
      if (_selectedMethod != null && move.method != _selectedMethod) {
        return false;
      }
      if (_onlyWithLevel && !move.hasLevel) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final levelA = a.level ?? 999;
        final levelB = b.level ?? 999;
        final levelComparison = levelA.compareTo(levelB);
        if (levelComparison != 0) {
          return levelComparison;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Todos'),
              selected: _selectedMethod == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedMethod = null);
                }
              },
            ),
            ...methods.map(
              (method) => ChoiceChip(
                label: Text(_formatMethod(method)),
                selected: _selectedMethod == method,
                onSelected: (selected) {
                  setState(() {
                    _selectedMethod = selected ? method : null;
                  });
                },
              ),
            ),
            FilterChip(
              label: const Text('Solo movimientos con nivel'),
              selected: _onlyWithLevel,
              onSelected: (selected) {
                setState(() => _onlyWithLevel = selected);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (filteredMoves.isEmpty)
          const Text('No hay movimientos que coincidan con los filtros.')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredMoves.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final move = filteredMoves[index];
              final typeKey = move.type?.toLowerCase() ?? '';
              final typeColor =
                  pokemonTypeColors[typeKey] ?? colorScheme.primary;
              final emoji = _typeEmojis[typeKey];
              final typeLabel = move.type == null || move.type!.isEmpty
                  ? '—'
                  : widget.formatLabel(move.type!);
              final methodLabel = _formatMethod(move.method);
              final versionLabel = move.versionGroup == null ||
                      move.versionGroup!.isEmpty
                  ? null
                  : widget.formatLabel(move.versionGroup!);

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: typeColor.withOpacity(0.28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (emoji != null) ...[
                          Text(emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            _resolveDisplayName(move.name),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            typeLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _MoveInfoChip(
                          icon: Icons.school_outlined,
                          label: methodLabel,
                        ),
                        _MoveInfoChip(
                          icon: Icons.trending_up,
                          label: move.hasLevel
                              ? 'Nivel ${move.level}'
                              : 'Sin nivel definido',
                        ),
                        if (versionLabel != null)
                          _MoveInfoChip(
                            icon: Icons.videogame_asset_outlined,
                            label: versionLabel,
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _EvolutionSection extends StatelessWidget {
  const _EvolutionSection({
    required this.evolutionChain,
    required this.currentSpeciesId,
    required this.formatLabel,
  });

  final PokemonEvolutionChain? evolutionChain;
  final int? currentSpeciesId;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    final chain = evolutionChain;
    if (chain == null || chain.isEmpty) {
      return const Text('Sin información de evoluciones disponible.');
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < chain.groups.length; index++) ...[
          _EvolutionStageRow(
            nodes: chain.groups[index],
            currentSpeciesId: currentSpeciesId,
            formatLabel: formatLabel,
          ),
          if (index < chain.groups.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Icon(
                  Icons.arrow_downward_rounded,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.65),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _EvolutionStageRow extends StatelessWidget {
  const _EvolutionStageRow({
    required this.nodes,
    required this.currentSpeciesId,
    required this.formatLabel,
  });

  final List<PokemonEvolutionNode> nodes;
  final int? currentSpeciesId;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return const SizedBox.shrink();
    }

    final mediaWidth = MediaQuery.of(context).size.width;
    final double rawMaxWidth = mediaWidth < 480 ? mediaWidth - 64 : 260;
    final double maxWidth = rawMaxWidth.clamp(180.0, 320.0).toDouble();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: nodes
          .map(
            (node) => ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 180,
                maxWidth: maxWidth,
              ),
              child: _EvolutionStageCard(
                node: node,
                isCurrent: currentSpeciesId != null &&
                    currentSpeciesId == node.speciesId,
                formatLabel: formatLabel,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _EvolutionStageCard extends StatelessWidget {
  const _EvolutionStageCard({
    required this.node,
    required this.isCurrent,
    required this.formatLabel,
  });

  final PokemonEvolutionNode node;
  final bool isCurrent;
  final String Function(String) formatLabel;

  String _resolveName(String value) {
    if (value.isEmpty) {
      return 'Desconocido';
    }
    final lowercase = value.toLowerCase();
    if (value == lowercase) {
      return formatLabel(value);
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final borderColor = isCurrent
        ? colorScheme.primary
        : colorScheme.outline.withOpacity(0.35);
    final backgroundColor = isCurrent
        ? colorScheme.primaryContainer.withOpacity(0.7)
        : colorScheme.surface.withOpacity(0.96);
    final textColor = isCurrent
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;
    final subtitleColor = isCurrent
        ? colorScheme.onPrimaryContainer.withOpacity(0.88)
        : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: borderColor,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PokemonArtwork(
            imageUrl: node.imageUrl,
            size: 110,
            borderRadius: 24,
            padding: const EdgeInsets.all(12),
            showShadow: false,
          ),
          const SizedBox(height: 12),
          Text(
            _resolveName(node.name),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          if (node.conditions.isEmpty)
            Text(
              'Sin requisitos adicionales.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: subtitleColor,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: node.conditions
                  .map(
                    (condition) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: subtitleColor,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              condition,
                              style:
                                  theme.textTheme.bodyMedium?.copyWith(
                                color: subtitleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _MoveInfoChip extends StatelessWidget {
  const _MoveInfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacteristicTile extends StatelessWidget {
  const _CharacteristicTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: 165,
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.75),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AbilityTile extends StatelessWidget {
  const _AbilityTile({
    required this.ability,
    required this.formatLabel,
  });

  final PokemonAbilityDetail ability;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final subtitle = ability.isHidden ? 'Habilidad oculta' : 'Habilidad principal';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_fix_high_outlined,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formatLabel(ability.name),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary.withOpacity(0.75),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ability.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeMatchupSection extends StatelessWidget {
  const _TypeMatchupSection({
    required this.matchups,
    required this.formatLabel,
  });

  final List<TypeMatchup> matchups;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    final resistances = matchups
        .where((matchup) => matchup.multiplier > 0 && matchup.multiplier < 0.99)
        .toList()
      ..sort((a, b) => a.multiplier.compareTo(b.multiplier));
    final immunities = matchups
        .where((matchup) => matchup.multiplier <= 0.01)
        .toList();

    final hasContent = resistances.isNotEmpty || immunities.isNotEmpty;

    if (!hasContent) {
      return const Text('Sin información de resistencias o inmunidades disponible.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (resistances.isNotEmpty) ...[
          _MatchupGroup(
            title: 'Resistencias',
            matchups: resistances,
            formatLabel: formatLabel,
          ),
          if (immunities.isNotEmpty) const SizedBox(height: 12),
        ],
        if (immunities.isNotEmpty)
          _MatchupGroup(
            title: 'Inmunidades',
            matchups: immunities,
            formatLabel: formatLabel,
          ),
      ],
    );
  }
}

class _MatchupGroup extends StatelessWidget {
  const _MatchupGroup({
    required this.title,
    required this.matchups,
    required this.formatLabel,
  });

  final String title;
  final List<TypeMatchup> matchups;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: matchups
              .map(
                (matchup) => _TypeMatchupChip(
                  matchup: matchup,
                  formatLabel: formatLabel,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

String _formatMultiplier(double multiplier) {
  if (multiplier <= 0) {
    return '0×';
  }
  if ((multiplier - multiplier.round()).abs() < 0.01) {
    return '${multiplier.round()}×';
  }
  final text = multiplier
      .toStringAsFixed(2)
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');
  return '$text×';
}

class _TypeMatchupChip extends StatelessWidget {
  const _TypeMatchupChip({
    required this.matchup,
    required this.formatLabel,
  });

  final TypeMatchup matchup;
  final String Function(String) formatLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final typeColor =
        pokemonTypeColors[matchup.type.toLowerCase()] ?? colorScheme.primary;
    final background = Color.alphaBlend(
      typeColor.withOpacity(0.16),
      colorScheme.surface.withOpacity(0.95),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: typeColor.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: typeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatLabel(matchup.type),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatMultiplier(matchup.multiplier),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: typeColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacteristicData {
  const _CharacteristicData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _StatBar extends StatelessWidget {
  const _StatBar({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double normalized = (value / 200).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Text(
                value.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: normalized,
              minHeight: 8,
              color: theme.colorScheme.primary,
              backgroundColor:
                  theme.colorScheme.primary.withOpacity(0.18),
            ),
          ),
        ],
      ),
    );
  }
}

class _PokemonDetailErrorView extends StatelessWidget {
  const _PokemonDetailErrorView({this.onRetry});

  final Future<QueryResult<Object?>?> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'No se pudo obtener los datos del Pokémon.\nVerifica tu conexión o intenta de nuevo.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () async {
                  try {
                    await onRetry!.call();
                  } catch (error, stackTrace) {
                    debugPrint('Error al reintentar la carga: $error');
                    debugPrint('$stackTrace');
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadingDetailView extends StatelessWidget {
  const _LoadingDetailView({
    required this.heroTag,
    required this.imageUrl,
    this.name,
  });

  final String heroTag;
  final String imageUrl;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: heroTag,
              child: PokemonArtwork(
                imageUrl: imageUrl,
                size: 180,
                borderRadius: 32,
                padding: const EdgeInsets.all(20),
              ),
            ),
            if (name != null) ...[
              const SizedBox(height: 16),
              Text(
                name!,
                style: theme.textTheme.titleLarge,
              ),
            ],
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: colorScheme.onPrimaryContainer),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.85),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
