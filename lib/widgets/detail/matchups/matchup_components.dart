import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../models/pokemon_model.dart';
import '../../../theme/pokemon_type_colors.dart';
import '../detail_constants.dart';

/// Enum for matchup categories
enum MatchupCategory { weakness, resistance, immunity }

/// Enum for legend color roles
enum LegendColorRole { critical, warning, emphasis, success }

/// Data class for legend entries
class LegendEntry {
  const LegendEntry({
    required this.label,
    required this.description,
    required this.icon,
    required this.colorRole,
  });

  final String label;
  final String description;
  final IconData icon;
  final LegendColorRole colorRole;
}

/// Formats a multiplier for display
String formatMultiplier(double multiplier) {
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

/// Section displaying type matchups with resistances and immunities
class TypeMatchupSection extends StatelessWidget {
  const TypeMatchupSection({
    super.key,
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
          MatchupGroup(
            title: 'Resistencias',
            matchups: resistances,
            formatLabel: formatLabel,
            category: MatchupCategory.resistance,
          ),
          if (immunities.isNotEmpty) const SizedBox(height: 12),
        ],
        if (immunities.isNotEmpty)
          MatchupGroup(
            title: 'Inmunidades',
            matchups: immunities,
            formatLabel: formatLabel,
            category: MatchupCategory.immunity,
          ),
        const SizedBox(height: 16),
        const MatchupLegend(
          entries: [
            LegendEntry(
              label: '0×',
              description: 'Sin efecto: el Pokémon es inmune a este tipo.',
              icon: Icons.block,
              colorRole: LegendColorRole.emphasis,
            ),
            LegendEntry(
              label: '0.25×',
              description:
                  'Resistencia doble: el daño recibido se reduce a la cuarta parte.',
              icon: Icons.shield,
              colorRole: LegendColorRole.success,
            ),
            LegendEntry(
              label: '0.5×',
              description:
                  'Resistencia clásica: el daño recibido se reduce a la mitad.',
              icon: Icons.shield_outlined,
              colorRole: LegendColorRole.warning,
            ),
          ],
        ),
      ],
    );
  }
}

/// Group of matchups (resistances or immunities)
class MatchupGroup extends StatelessWidget {
  const MatchupGroup({
    super.key,
    required this.title,
    required this.matchups,
    required this.formatLabel,
    required this.category,
  });

  final String title;
  final List<TypeMatchup> matchups;
  final String Function(String) formatLabel;
  final MatchupCategory category;

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
        MatchupHexGrid(
          matchups: matchups,
          formatLabel: formatLabel,
          category: category,
        ),
      ],
    );
  }
}

/// Legend explaining matchup multipliers
class MatchupLegend extends StatelessWidget {
  const MatchupLegend({super.key, required this.entries});

  final List<LegendEntry> entries;

  Color _resolveColor(ColorScheme scheme, LegendColorRole role) {
    switch (role) {
      case LegendColorRole.critical:
        return scheme.error;
      case LegendColorRole.warning:
        return scheme.tertiary;
      case LegendColorRole.emphasis:
        return scheme.primary;
      case LegendColorRole.success:
        return scheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: entries
          .map(
            (entry) {
              final color = _resolveColor(scheme, entry.colorRole);
              final background = Color.alphaBlend(
                color.withOpacity(0.14),
                scheme.surface.withOpacity(0.92),
              );
              return Tooltip(
                message: entry.description,
                waitDuration: const Duration(milliseconds: 200),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(entry.icon, size: 16, color: color),
                      const SizedBox(width: 6),
                      Text(
                        entry.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
          .toList(),
    );
  }
}

/// Grid of hexagonal matchup cells
class MatchupHexGrid extends StatelessWidget {
  const MatchupHexGrid({
    super.key,
    required this.matchups,
    required this.formatLabel,
    required this.category,
  });

  final List<TypeMatchup> matchups;
  final String Function(String) formatLabel;
  final MatchupCategory category;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = math.max(2, math.min(4, (width / 150).floor()));

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
          ),
          itemCount: matchups.length,
          itemBuilder: (context, index) {
            final matchup = matchups[index];
            return MatchupHexCell(
              matchup: matchup,
              formatLabel: formatLabel,
              category: category,
            );
          },
        );
      },
    );
  }
}

/// Individual hexagonal cell displaying a type matchup
class MatchupHexCell extends StatelessWidget {
  const MatchupHexCell({
    super.key,
    required this.matchup,
    required this.formatLabel,
    required this.category,
  });

  final TypeMatchup matchup;
  final String Function(String) formatLabel;
  final MatchupCategory category;

  double _scaleForMultiplier(double multiplier) {
    switch (category) {
      case MatchupCategory.weakness:
        final normalized = (multiplier - 1).clamp(0.0, 3.5);
        return 1 + normalized * 0.12;
      case MatchupCategory.resistance:
        final normalized = (1 - multiplier).clamp(0.0, 1.0);
        return 1 + normalized * 0.12;
      case MatchupCategory.immunity:
        return 1.18;
    }
  }

  IconData _iconForMultiplier(double multiplier) {
    switch (category) {
      case MatchupCategory.weakness:
        return multiplier >= 4 ? Icons.local_fire_department : Icons.trending_up;
      case MatchupCategory.resistance:
        return Icons.shield_outlined;
      case MatchupCategory.immunity:
        return Icons.block;
    }
  }

  String _tooltipForMatchup(String label, double multiplier) {
    final formatted = formatMultiplier(multiplier);
    switch (category) {
      case MatchupCategory.weakness:
        return '$label recibe $formatted de daño: procura evitar este tipo.';
      case MatchupCategory.resistance:
        return '$label causa $formatted de daño: es una buena cobertura defensiva.';
      case MatchupCategory.immunity:
        return '$label no afecta a este Pokémon.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final typeKey = matchup.type.toLowerCase();
    final typeColor = pokemonTypeColors[typeKey] ?? scheme.primary;
    final emoji = typeEmojis[typeKey];
    final label = formatLabel(matchup.type);
    final scale = _scaleForMultiplier(matchup.multiplier);
    final tooltip = _tooltipForMatchup(label, matchup.multiplier);

    final background = Color.alphaBlend(
      typeColor.withOpacity(0.14),
      scheme.surface.withOpacity(0.94),
    );

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 200),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: HexagonContainer(
          color: typeColor,
          background: background,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (emoji != null) ...[
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              MultiplierBadge(
                multiplier: matchup.multiplier,
                icon: _iconForMultiplier(matchup.multiplier),
                color: typeColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Container with hexagonal shape
class HexagonContainer extends StatelessWidget {
  const HexagonContainer({
    super.key,
    required this.child,
    required this.color,
    required this.background,
  });

  final Widget child;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const HexagonClipper(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: color.withOpacity(0.55), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 14,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: child,
        ),
      ),
    );
  }
}

/// Custom clipper for hexagonal shape
class HexagonClipper extends CustomClipper<Path> {
  const HexagonClipper();

  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final verticalInset = height * 0.25;

    return Path()
      ..moveTo(width / 2, 0)
      ..lineTo(width, verticalInset)
      ..lineTo(width, height - verticalInset)
      ..lineTo(width / 2, height)
      ..lineTo(0, height - verticalInset)
      ..lineTo(0, verticalInset)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Badge displaying damage multiplier
class MultiplierBadge extends StatelessWidget {
  const MultiplierBadge({
    super.key,
    required this.multiplier,
    required this.icon,
    required this.color,
  });

  final double multiplier;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final background = Color.alphaBlend(
      color.withOpacity(0.18),
      scheme.surface.withOpacity(0.92),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.withOpacity(0.9)),
          const SizedBox(width: 6),
          Text(
            formatMultiplier(multiplier),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
