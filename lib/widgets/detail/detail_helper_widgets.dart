import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/l10n/app_localizations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../pokemon_artwork.dart';

/// Variante de estilo para tarjetas de sección de información
/// 
/// - rounded: Esquinas completamente redondeadas (estilo normal)
/// - angled: Esquina superior derecha en ángulo (estilo distintivo)
enum InfoSectionCardVariant { rounded, angled }

/// Widget de título de sección para las secciones de detalles
/// 
/// Título grande y en negrita usado como encabezado de las diferentes
/// secciones en la pantalla de detalles del Pokémon.
class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});

  /// Texto del título a mostrar
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

/// Tarjeta de sección de información con variantes de estilo opcionales
/// 
/// Contenedor estilizado usado en toda la pantalla de detalles para agrupar
/// información relacionada. Incluye:
/// - Título de la sección
/// - Contenido personalizable (child)
/// - Color de fondo y borde configurables
/// - Dos variantes de estilo (rounded/angled)
/// 
/// El estilo "angled" usa un CustomClipper para crear una esquina cortada,
/// agregando variedad visual a la interfaz.
class InfoSectionCard extends StatelessWidget {
  const InfoSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.variant = InfoSectionCardVariant.rounded,
    this.padding,
  });

  /// Título que se muestra en la parte superior de la tarjeta
  final String title;
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final InfoSectionCardVariant variant;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardColor = backgroundColor ?? colorScheme.surfaceVariant.withOpacity(0.4);
    final outlineColor = borderColor ?? colorScheme.outline.withOpacity(0.12);
    final effectivePadding = padding ?? const EdgeInsets.all(20);
    final content = Padding(
      padding: effectivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: title),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );

    switch (variant) {
      case InfoSectionCardVariant.rounded:
        return SizedBox(
          width: double.infinity,
          child: Card(
            margin: EdgeInsets.zero,
            color: cardColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
              side: BorderSide(color: outlineColor),
            ),
            child: content,
          ),
        );
      case InfoSectionCardVariant.angled:
        return SizedBox(
          width: double.infinity,
          child: ClipPath(
            clipper: const AngledCardClipper(),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cardColor,
                border: Border.all(color: outlineColor),
              ),
              child: content,
            ),
          ),
        );
    }
  }
}

/// Custom clipper for angled card variant
class AngledCardClipper extends CustomClipper<Path> {
  const AngledCardClipper();

  @override
  Path getClip(Size size) {
    const double cut = 26;
    return Path()
      ..moveTo(0, cut)
      ..quadraticBezierTo(0, 0, cut, 0)
      ..lineTo(size.width - cut, 0)
      ..quadraticBezierTo(size.width, 0, size.width, cut)
      ..lineTo(size.width, size.height - cut)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - cut,
        size.height,
      )
      ..lineTo(cut, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - cut)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Error view displayed when Pokemon detail data cannot be loaded
class PokemonDetailErrorView extends StatelessWidget {
  const PokemonDetailErrorView({super.key, this.onRetry});

  final Future<QueryResult<Object?>?> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final retry = onRetry;

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
              l10n.detailLoadErrorDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (retry != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () async {
                  try {
                    await retry();
                  } catch (error, stackTrace) {
                    debugPrint('Error al reintentar la carga: $error');
                    debugPrint('$stackTrace');
                  }
                },
                icon: const Icon(Icons.refresh),
                label: Text(l10n.commonRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading view displayed while Pokemon detail data is being fetched
class LoadingDetailView extends StatelessWidget {
  const LoadingDetailView({
    super.key,
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
            PokemonArtwork(
              heroTag: heroTag,
              imageUrl: imageUrl,
              size: 180,
              borderRadius: 32,
              padding: const EdgeInsets.all(20),
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

/// Card widget displaying an icon, label, and value for Pokemon info
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
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

/// Chip widget displaying an icon and label for move information
class MoveInfoChip extends StatelessWidget {
  const MoveInfoChip({
    super.key,
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

/// Tile widget displaying an icon, label, and value for Pokemon characteristics
class CharacteristicTile extends StatelessWidget {
  const CharacteristicTile({
    super.key,
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
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            softWrap: true,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
