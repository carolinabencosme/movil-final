import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../pokemon_artwork.dart';

/// Error view displayed when Pokemon detail data cannot be loaded
class PokemonDetailErrorView extends StatelessWidget {
  const PokemonDetailErrorView({super.key, this.onRetry});

  final Future<QueryResult<Object?>?> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
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
              'No se pudo obtener los datos del Pokémon.\nVerifica tu conexión o intenta de nuevo.',
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
                label: const Text('Reintentar'),
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
