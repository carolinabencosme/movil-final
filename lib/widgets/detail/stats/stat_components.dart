import 'package:flutter/material.dart';

/// Data model for Pokemon characteristics
class CharacteristicData {
  const CharacteristicData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

/// Stat bar widget displaying Pokemon stats
class StatBar extends StatelessWidget {
  const StatBar({super.key, required this.label, required this.value});

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
          SizedBox(
            height: 28,
            child: Row(
              children: [
                for (var i = 0; i < 10; i++) ...[
                  Expanded(
                    child: StatSegment(
                      fill: (normalized * 10) - i,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (i != 9) const SizedBox(width: 4),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual segment of a stat bar
class StatSegment extends StatelessWidget {
  const StatSegment({super.key, required this.fill, required this.color});

  final double fill;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedFill = fill.clamp(0.0, 1.0);
    final brightness = theme.colorScheme.brightness == Brightness.dark
        ? Colors.white
        : theme.colorScheme.onPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FractionallySizedBox(
            widthFactor: clampedFill,
            alignment: Alignment.centerLeft,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.85),
                    color,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              opacity: clampedFill >= 0.95
                  ? 1
                  : clampedFill > 0.4
                      ? 0.7
                      : 0.25,
              child: Icon(
                Icons.catching_pokemon,
                size: 16,
                color: clampedFill > 0
                    ? brightness.withOpacity(0.9)
                    : color.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
