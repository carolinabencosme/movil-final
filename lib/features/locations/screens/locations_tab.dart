import 'package:flutter/material.dart';

import '../../../models/pokemon_model.dart';
import '../../../widgets/detail/detail_constants.dart';
import '../../../widgets/detail/detail_helper_widgets.dart';
import '../../../widgets/detail/info/info_components.dart';
import '../data/location_service.dart';
import '../models/pokemon_location.dart';
import '../widgets/region_map_viewer.dart';

/// Tab de ubicaciones para el detail screen
///
/// Muestra un mapa interactivo con las regiones donde aparece el Pokémon
/// y una lista de ubicaciones específicas con sus detalles.
class PokemonLocationsTab extends StatefulWidget {
  const PokemonLocationsTab({
    super.key,
    required this.pokemon,
    required this.sectionBackground,
    required this.sectionBorder,
  });

  final PokemonDetail pokemon;
  final Color sectionBackground;
  final Color sectionBorder;

  @override
  State<PokemonLocationsTab> createState() => _PokemonLocationsTabState();
}

class _PokemonLocationsTabState extends State<PokemonLocationsTab>
    with AutomaticKeepAliveClientMixin {
  final LocationService _locationService = LocationService();
  List<LocationsByRegion>? _locations;
  bool _isLoading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final locations = await _locationService.fetchLocationsByRegion(
        widget.pokemon.id,
      );
      
      if (mounted) {
        setState(() {
          _locations = locations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final padding = responsiveDetailTabPadding(context);

    return Padding(
      padding: padding,
      child: _buildContent(theme),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return _buildLoadingState(theme);
    }

    if (_error != null) {
      return _buildErrorState(theme);
    }

    if (_locations == null || _locations!.isEmpty) {
      return _buildEmptyState(theme);
    }

    return _buildLocationsList(theme);
  }

  Widget _buildLoadingState(ThemeData theme) {
    return InfoSectionCard(
      title: 'Ubicaciones',
      backgroundColor: widget.sectionBackground,
      borderColor: widget.sectionBorder,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Cargando ubicaciones...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return InfoSectionCard(
      title: 'Ubicaciones',
      backgroundColor: widget.sectionBackground,
      borderColor: widget.sectionBorder,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar ubicaciones',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Error desconocido',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadLocations,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return InfoSectionCard(
      title: 'Ubicaciones',
      backgroundColor: widget.sectionBackground,
      borderColor: widget.sectionBorder,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No hay datos de ubicación disponibles',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Este Pokémon no tiene encuentros registrados en regiones conocidas.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationsList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mostrar un mapa por cada región
        for (final location in _locations!) ...[
          InfoSectionCard(
            title: 'Mapa de ${_formatRegionName(location.region)}',
            backgroundColor: widget.sectionBackground,
            borderColor: widget.sectionBorder,
            child: RegionMapViewer(
              region: location.region,
              encounters: location.encounters,
              height: 300,
              markerColor: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Detalles de ubicaciones para esta región
          InfoSectionCard(
            title: 'Detalles de ${_formatRegionName(location.region)}',
            backgroundColor: widget.sectionBackground,
            borderColor: widget.sectionBorder,
            child: _RegionLocationCard(
              location: location,
              theme: theme,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  String _formatRegionName(String region) {
    return region[0].toUpperCase() + region.substring(1);
  }
}

/// Card que muestra los detalles de una región
class _RegionLocationCard extends StatelessWidget {
  const _RegionLocationCard({
    required this.location,
    required this.theme,
  });

  final LocationsByRegion location;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con región
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: theme.colorScheme.primary,
                  size: 24,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${location.areaCount} área${location.areaCount != 1 ? 's' : ''}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Versiones disponibles
            if (location.allVersions.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: location.allVersions.take(5).map((version) {
                  return Chip(
                    label: Text(
                      _formatVersion(version),
                      style: theme.textTheme.labelSmall,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
              if (location.allVersions.length > 5) ...[
                const SizedBox(height: 6),
                Text(
                  '+ ${location.allVersions.length - 5} versiones más',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],

            // Ejemplo de áreas (primeras 3)
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Áreas de ejemplo:',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...location.encounters.take(3).map((encounter) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.place,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        encounter.displayName,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (location.encounters.length > 3)
              Text(
                '+ ${location.encounters.length - 3} ubicaciones más',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatRegionName(String region) {
    return region[0].toUpperCase() + region.substring(1);
  }

  String _formatVersion(String version) {
    return version.split('-').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
