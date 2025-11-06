import 'package:flutter/material.dart';

class PokemonArtwork extends StatelessWidget {
  const PokemonArtwork({
    super.key,
    required this.imageUrl,
    this.size,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(12),
    this.showShadow = true,
    this.heroTag,
  });

  final String imageUrl;
  final double? size;
  final double borderRadius;
  final EdgeInsets padding;
  final bool showShadow;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradientColors = <Color>[
      colorScheme.primaryContainer.withOpacity(0.9),
      colorScheme.secondaryContainer.withOpacity(0.75),
    ];
    final boxShadow = showShadow
        ? [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ]
        : null;

    final dimension = size ?? 96.0;
    final innerRadius = borderRadius > 12 ? borderRadius - 12 : borderRadius;

    Widget child;
    if (imageUrl.isEmpty) {
      child = Center(
        child: Icon(
          Icons.catching_pokemon,
          size: dimension * 0.45,
          color: colorScheme.primary,
        ),
      );
    } else {
      child = Image.network(
        imageUrl,
        fit: BoxFit.contain,
        cacheWidth: dimension.ceil() * 2, // Cache at 2x resolution for quality
        cacheHeight: dimension.ceil() * 2,
        frameBuilder: (context, widget, frame, wasSynchronouslyLoaded) {
          final isLoaded = frame != null || wasSynchronouslyLoaded;
          return AnimatedOpacity(
            opacity: isLoaded ? 1 : 0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            child: widget,
          );
        },
        loadingBuilder: (context, widget, loadingProgress) {
          if (loadingProgress == null) {
            return widget;
          }
          return const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Center(
          child: Icon(
            Icons.hide_image_outlined,
            size: dimension * 0.45,
            color: colorScheme.error,
          ),
        ),
      );
    }

    Widget artwork = SizedBox(
      width: dimension,
      height: dimension,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: boxShadow,
        ),
        child: Padding(
          padding: padding,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(innerRadius),
            child: Container(
              color: colorScheme.surface,
              child: child,
            ),
          ),
        ),
      ),
    );

    final hero = heroTag;
    if (hero != null && hero.isNotEmpty) {
      artwork = Hero(tag: hero, child: artwork);
    }

    return artwork;
  }
}
