import 'package:flutter/material.dart';

import '../models/pokemon_location.dart';

/// Widget para el marcador de ubicación en el mapa
///
/// Muestra un marcador circular con un ícono y color personalizado
class LocationMarkerWidget extends StatelessWidget {
  const LocationMarkerWidget({
    super.key,
    required this.region,
    this.color = const Color(0xFF3B9DFF),
    this.size = 40.0,
  });

  final String region;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.place,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

/// Popup que se muestra al tocar un marcador
class LocationPopup extends StatelessWidget {
  const LocationPopup({
    super.key,
    required this.location,
  });

  final LocationsByRegion location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 280,
          minWidth: 200,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la región
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatRegionName(location.region),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Número de áreas
            _InfoRow(
              icon: Icons.map_outlined,
              label: 'Áreas',
              value: '${location.areaCount}',
            ),
            const SizedBox(height: 8),

            // Juegos donde aparece
            if (location.allVersions.isNotEmpty) ...[
              _InfoRow(
                icon: Icons.videogame_asset,
                label: 'Juegos',
                value: _formatVersions(location.allVersions),
              ),
            ],

            // Ejemplo de área (primera de la lista)
            if (location.encounters.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Ejemplo de ubicación:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                location.encounters.first.displayName,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatRegionName(String region) {
    return region[0].toUpperCase() + region.substring(1);
  }

  String _formatVersions(List<String> versions) {
    if (versions.isEmpty) return 'N/A';
    if (versions.length <= 3) {
      return versions
          .map((v) => v[0].toUpperCase() + v.substring(1))
          .join(', ');
    }
    return '${versions.length} versiones';
  }
}

/// Fila de información en el popup
class _InfoRow extends StatelessWidget {
  const _InfoRow({
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

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
