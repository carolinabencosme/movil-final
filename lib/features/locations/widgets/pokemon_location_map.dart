import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/pokemon_location.dart';
import 'location_marker.dart';

/// Widget de mapa interactivo para mostrar ubicaciones de Pokémon
///
/// Muestra un mapa con marcadores en las regiones donde aparece el Pokémon.
/// Los usuarios pueden hacer zoom, desplazar el mapa y tocar marcadores
/// para ver más información.
class PokemonLocationMap extends StatefulWidget {
  const PokemonLocationMap({
    super.key,
    required this.locations,
    this.height = 300.0,
    this.initialZoom = 3.0,
    this.markerColor = const Color(0xFF3B9DFF),
  });

  /// Lista de ubicaciones agrupadas por región
  final List<LocationsByRegion> locations;

  /// Altura del mapa en píxeles
  final double height;

  /// Nivel de zoom inicial (recomendado: 2-5)
  final double initialZoom;

  /// Color de los marcadores
  final Color markerColor;

  @override
  State<PokemonLocationMap> createState() => _PokemonLocationMapState();
}

class _PokemonLocationMapState extends State<PokemonLocationMap> {
  LocationsByRegion? _selectedLocation;
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Calcula el centro del mapa basado en todas las ubicaciones
  LatLng _calculateCenter() {
    if (widget.locations.isEmpty) {
      return const LatLng(35.0, 0.0); // Centro por defecto (cerca de Japón)
    }

    if (widget.locations.length == 1) {
      return widget.locations.first.coordinates;
    }

    // Calcular el centroide de todas las ubicaciones
    double totalLat = 0;
    double totalLng = 0;

    for (final location in widget.locations) {
      totalLat += location.coordinates.latitude;
      totalLng += location.coordinates.longitude;
    }

    return LatLng(
      totalLat / widget.locations.length,
      totalLng / widget.locations.length,
    );
  }

  /// Construye los marcadores para cada ubicación
  List<Marker> _buildMarkers() {
    return widget.locations.map((location) {
      return Marker(
        point: location.coordinates,
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedLocation = _selectedLocation == location ? null : location;
            });
          },
          child: LocationMarkerWidget(
            region: location.region,
            color: widget.markerColor,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final center = _calculateCenter();

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Mapa principal
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: widget.initialZoom,
              minZoom: 1.0,
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // Capa de tiles (OpenStreetMap)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.pokedex',
                tileProvider: NetworkTileProvider(),
              ),
              // Capa de marcadores
              MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          ),

          // Popup cuando se selecciona un marcador
          if (_selectedLocation != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: LocationPopup(
                location: _selectedLocation!,
              ),
            ),

          // Botones de control
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón de zoom in
                _MapControlButton(
                  icon: Icons.add,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      currentZoom + 1,
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Botón de zoom out
                _MapControlButton(
                  icon: Icons.remove,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      currentZoom - 1,
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Botón de reset/centrar
                _MapControlButton(
                  icon: Icons.my_location,
                  onPressed: () {
                    _mapController.move(
                      center,
                      widget.initialZoom,
                    );
                    setState(() {
                      _selectedLocation = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón de control del mapa
class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ),
    );
  }
}
