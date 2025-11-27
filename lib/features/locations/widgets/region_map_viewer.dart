import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/pokemon_model.dart';
import '../../../screens/detail_screen.dart';
import '../../../theme/pokemon_type_colors.dart';
import '../data/map_parser.dart';
import '../data/region_map_data.dart';
import '../data/region_map_markers.dart';
import '../models/pokemon_location.dart';
import '../models/parsed_map.dart';

/// Widget que muestra un mapa de región Pokémon usando InteractiveViewer
///
/// Usa mapas oficiales de los juegos Pokémon extraídos de Spriter's Resource.
/// Permite zoom y pan sobre la imagen del mapa, con marcadores posicionados
/// usando coordenadas X/Y relativas.
class RegionMapViewer extends StatefulWidget {
  const RegionMapViewer({
    super.key,
    required this.region,
    required this.encounters,
    this.locationPoints,
    this.height = 300.0,
    this.previewMode = false,
    this.markerColor = const Color(0xFF3B9DFF),
    this.mapBoundsPx,
    this.mapMarginPx = 0,
    this.onMarkerTap,
    this.onAreaTap,
    this.debugMode = false,
    this.debugSpawns,
  });

  /// Nombre de la región (ej: "kanto", "johto")
  final String region;

  /// Lista de encuentros en esta región
  final List<PokemonEncounter> encounters;

  /// Lista de ubicaciones enriquecidas con coordenadas en píxeles
  final List<PokemonLocationPoint>? locationPoints;

  /// Altura del widget en píxeles
  final double height;

  /// Si está habilitado, muestra solo el CTA para abrir el mapa completo
  final bool previewMode;

  /// Color de los marcadores
  final Color markerColor;

  /// Rectángulo opcional que delimita el área útil del mapa en píxeles
  final Rect? mapBoundsPx;

  /// Margen configurable para calcular [mapBoundsPx] si no se provee manualmente
  final double mapMarginPx;

  /// Callback cuando se toca un marcador
  final Function(PokemonEncounter)? onMarkerTap;

  /// Callback cuando se toca un área definida en el mapa
  final void Function(ClickableArea area)? onAreaTap;

  /// Modo debug para mostrar spawn test markers
  final bool debugMode;

  /// Lista de coordenadas de spawn para debug
  final List<Map<String, dynamic>>? debugSpawns;

  @override
  State<RegionMapViewer> createState() => _RegionMapViewerState();
}

class _RegionMapViewerState extends State<RegionMapViewer> {
  final TransformationController _transformationController =
      TransformationController();
  PokemonEncounter? _selectedEncounter;
  List<RegionMapData> _availableVersions = [];
  int _selectedVersionIndex = 0;
  ParsedMap? _parsedMap;
  final MapParser _mapParser = const MapParser();

  Future<void> _openFullscreenMap() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final theme = Theme.of(context);

          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: AppBar(
              title: Text('Mapa de ${_formatRegionName(widget.region)}'),
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Cerrar pantalla completa',
                  icon: const Icon(Icons.close_fullscreen),
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    if (_availableVersions.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildVersionSelector(theme),
                      ),
                    Expanded(
                      child: _buildMapContainer(
                        theme,
                        height: null,
                        showFullscreenButton: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        fullscreenDialog: true,
      ),
    );

    setState(() {});
  }

  Future<void> _loadParsedMap() async {
    try {
      final parsedMap = await _mapParser.load(widget.region);
      if (!mounted) return;

      setState(() {
        _parsedMap = parsedMap;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _parsedMap = null;
      });
      debugPrint('Error loading map data for ${widget.region}: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _availableVersions = getRegionMapVersions(widget.region);
    if (_availableVersions.isEmpty) {
      // Fallback to default map data if no versions found
      final defaultMap = getRegionMapData(widget.region);
      if (defaultMap != null) {
        _availableVersions = [defaultMap];
      }
    }
    _loadParsedMap();
  }

  @override
  void didUpdateWidget(RegionMapViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.region != widget.region) {
      setState(() {
        _selectedVersionIndex = 0;
        _availableVersions = getRegionMapVersions(widget.region);
        if (_availableVersions.isEmpty) {
          final defaultMap = getRegionMapData(widget.region);
          if (defaultMap != null) {
            _availableVersions = [defaultMap];
          }
        }
        _transformationController.value = Matrix4.identity();
        _selectedEncounter = null;
        _parsedMap = null;
      });
      _loadParsedMap();
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  /// Obtiene el mapa actualmente seleccionado
  RegionMapData? get _currentMapData {
    if (_availableVersions.isEmpty) return null;
    return _availableVersions[_selectedVersionIndex];
  }

  /// Obtiene el path del asset de la imagen del mapa
  String _getMapAssetPath() {
    if (_parsedMap != null) return _parsedMap!.imagePath;
    if (_currentMapData != null) return _currentMapData!.assetPath;

    final normalizedRegion = widget.region.toLowerCase();

    // Si no hay datos de versión cargados, usar la primera entrada conocida
    // para la región antes de construir una ruta manual.
    final regionVersions = regionMapsByVersion[normalizedRegion];
    if (regionVersions != null && regionVersions.isNotEmpty) {
      return regionVersions.first.assetPath;
    }

    // Último recurso: tomar el primer mapa disponible en el bundle para evitar
    // renderizar el contenedor de error.
    for (final entry in regionMapsByVersion.entries) {
      if (entry.value.isNotEmpty) {
        return entry.value.first.assetPath;
      }
    }

    final versions = regionMapsByVersion[normalizedRegion];
    if (versions != null && versions.isNotEmpty) {
      return versions.first.assetPath;
    }

    return 'assets/maps/regions/$normalizedRegion/${normalizedRegion}.png';
  }

  /// Obtiene el tamaño del mapa
  Size _getMapSize() {
    if (_parsedMap != null) return _parsedMap!.mapSize;
    if (_currentMapData != null) return _currentMapData!.mapSize;

    final normalizedRegion = widget.region.toLowerCase().trim();
    final versions = regionMapsByVersion[normalizedRegion];
    if (versions != null && versions.isNotEmpty) {
      return versions.first.mapSize;
    }

    return const Size(800, 600);
  }

  /// Determina el rectángulo usable del mapa para colocar sprites
  Rect _resolveMapBounds(Size mapSize) {
    if (widget.mapBoundsPx != null) {
      return widget.mapBoundsPx!;
    }

    final horizontalMargin = widget.mapMarginPx.clamp(0.0, mapSize.width / 2);
    final verticalMargin = widget.mapMarginPx.clamp(0.0, mapSize.height / 2);

    return Rect.fromLTWH(
      horizontalMargin,
      verticalMargin,
      mapSize.width - (horizontalMargin * 2),
      mapSize.height - (verticalMargin * 2),
    );
  }

  /// Construye los marcadores sobre el mapa
  static const double _fullscreenSpriteScale = 0.75;

  List<Widget> _buildSpriteMarkers({
    required Rect mapBounds,
    double scaleFactor = 1.0,
  }) {
    final points = widget.locationPoints;
    if (points == null || points.isEmpty) return [];

    final mapSize = _getMapSize();
    final normalizedScale = (mapSize.shortestSide / 800).clamp(0.8, 1.25);
    final spriteSize = 44.0 * normalizedScale * scaleFactor;

    return points.map((point) {
      final pixelCoordinates = point.toPixelCoordinates(mapBounds);
      if (pixelCoordinates == null) return const SizedBox.shrink();

      final left = pixelCoordinates.x - spriteSize / 2;
      final top = pixelCoordinates.y - spriteSize / 2;

      return Positioned(
        left: left,
        top: top,
        width: spriteSize,
        height: spriteSize,
        child: Image.network(
          point.spriteUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.catching_pokemon),
        ),
      );
    }).toList();
  }

  List<Widget> _buildMarkers({double scaleFactor = 1.0}) {
    if (widget.encounters.isEmpty) return [];

    final Map<String, _MarkerGroup> groupedMarkers = {};

    for (final encounter in widget.encounters) {
      final marker = getRegionMarker(
        widget.region,
        encounter.locationArea,
        gameVersion: _currentMapData?.gameVersion,
      );

      if (marker == null) continue;

      final key = '${marker.x}-${marker.y}-${_currentMapData?.gameVersion ?? 'default'}';
      groupedMarkers.putIfAbsent(
        key,
        () => _MarkerGroup(marker: marker, encounters: []),
      );
      groupedMarkers[key]!.encounters.add(encounter);
    }

    final mapSize = _getMapSize();
    final normalizedScale = (mapSize.shortestSide / 800).clamp(0.8, 1.25);
    final markerSize = 44.0 * normalizedScale * scaleFactor;

    return groupedMarkers.values.map((group) {
      final isSelected = _selectedEncounter != null &&
          group.encounters.contains(_selectedEncounter);

      return Positioned(
        left: group.marker.x,
        top: group.marker.y,
        child: GestureDetector(
          onTap: () {
            setState(() {
              final currentIndex = _selectedEncounter != null
                  ? group.encounters.indexOf(_selectedEncounter!)
                  : -1;

              if (group.encounters.length == 1) {
                _selectedEncounter = currentIndex != -1
                    ? null
                    : group.encounters.first;
              } else {
                final nextIndex = currentIndex == -1
                    ? 0
                    : (currentIndex + 1) % group.encounters.length;
                _selectedEncounter = group.encounters[nextIndex];
              }
            });

            if (_selectedEncounter != null) {
              widget.onMarkerTap?.call(_selectedEncounter!);
            }
          },
          child: RegionMarkerWidget(
            encounters: group.encounters,
            isSelected: isSelected,
            color: widget.markerColor,
            size: markerSize,
          ),
        ),
      );
    }).toList();
  }

  void _handleAreaTap(ClickableArea area) {
    if (widget.onAreaTap != null) {
      widget.onAreaTap!(area);
      return;
    }

    _showAreaDialog(area);
  }

  Future<void> _showAreaDialog(ClickableArea area) async {
    final uri = _resolveAreaUri(area);
    final displayName = _areaDisplayName(area);
    final locationLabel = _areaLocationLabel(area, uri);

    await showDialog<void>(
      context: context,
      builder: (context) => _AreaInfoDialog(
        areaName: displayName,
        locationLabel: locationLabel,
        linkUri: uri,
      ),
    );
  }

  Uri? _resolveAreaUri(ClickableArea area) {
    final href = area.href.trim();
    if (href.isEmpty) return null;

    final parsed = Uri.tryParse(href);
    if (parsed == null) return null;
    if (parsed.hasScheme) return parsed;

    final normalizedHref = href.startsWith('/') ? href : '/$href';
    return Uri.parse('https://www.serebii.net$normalizedHref');
  }

  String _areaDisplayName(ClickableArea area) {
    if (area.title.trim().isNotEmpty) return area.title.trim();

    final uri = _resolveAreaUri(area);
    final segments = uri?.pathSegments.where((segment) => segment.isNotEmpty).toList();
    if (segments != null && segments.isNotEmpty) {
      return _prettifySegment(segments.last);
    }

    if (area.href.isNotEmpty) return area.href;
    return 'Área sin nombre';
  }

  String _areaLocationLabel(ClickableArea area, Uri? uri) {
    final trimmedLocation = area.location.trim();
    if (trimmedLocation.isNotEmpty) return trimmedLocation;

    if (area.title.trim().isNotEmpty) return area.title.trim();

    final resolvedUri = uri ?? _resolveAreaUri(area);
    if (resolvedUri == null) return 'Ubicación desconocida';

    final formattedSegments = resolvedUri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .map(_prettifySegment)
        .where((segment) => segment.isNotEmpty)
        .toList();

    final host = resolvedUri.host.isNotEmpty ? resolvedUri.host : null;
    if (formattedSegments.isEmpty && host == null) return 'Ubicación desconocida';

    if (host != null && formattedSegments.isEmpty) return host;
    if (host != null) {
      return '$host · ${formattedSegments.join(' / ')}';
    }

    return formattedSegments.join(' / ');
  }

  String _prettifySegment(String segment) {
    final cleaned = segment
        .replaceAll(RegExp(r'\.(s)?html?$', caseSensitive: false), '')
        .replaceAll('.', ' ');
    final normalized = cleaned.replaceAll(RegExp(r'[_\-]+'), ' ').trim();

    if (normalized.isEmpty) return segment;

    return normalized
        .split(' ')
        .map(
          (word) =>
              word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  List<Widget> _buildClickableAreas() {
    final parsedMap = _parsedMap;
    if (parsedMap == null || parsedMap.areas.isEmpty) return [];

    return parsedMap.areas.map((area) {
      switch (area.shape) {
        case AreaShape.circle:
          return _buildCircleArea(area);
        case AreaShape.poly:
          return _buildPolygonArea(area);
        case AreaShape.rect:
        default:
          return _buildRectArea(area);
      }
    }).toList();
  }

  Widget _buildRectArea(ClickableArea area) {
    final rect = area.rect ?? area.bounds;
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _handleAreaTap(area),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.blueAccent.withOpacity(0.35),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleArea(ClickableArea area) {
    final bounds = area.bounds;
    final center = area.center ?? bounds.center;
    final localCenter = center - Offset(bounds.left, bounds.top);
    final radius = area.radius ?? bounds.width / 2;

    return Positioned(
      left: bounds.left,
      top: bounds.top,
      width: bounds.width,
      height: bounds.height,
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: () => _handleAreaTap(area),
        child: CustomPaint(
          painter: _CircleAreaPainter(
            center: localCenter,
            radius: radius,
          ),
        ),
      ),
    );
  }

  Widget _buildPolygonArea(ClickableArea area) {
    final bounds = area.bounds;
    final points = area.points
        .map((point) => point - Offset(bounds.left, bounds.top))
        .toList();

    return Positioned(
      left: bounds.left,
      top: bounds.top,
      width: bounds.width,
      height: bounds.height,
      child: _PolygonAreaWidget(
        points: points,
        onTap: () => _handleAreaTap(area),
      ),
    );
  }

  /// Construye marcadores de debug para spawn points
  List<Widget> _buildDebugSpawnMarkers() {
    if (!widget.debugMode || widget.debugSpawns == null) {
      return [];
    }

    final List<Widget> markers = [];
    final spawns = widget.debugSpawns!;

    for (var i = 0; i < spawns.length; i++) {
      final spawn = spawns[i];
      final x = (spawn['x'] as num).toDouble();
      final y = (spawn['y'] as num).toDouble();
      final pokemon = spawn['pokemon'] as String? ?? 'Unknown';

      // Validar que las coordenadas estén dentro de los límites del mapa
      final mapSize = _getMapSize();
      if (x < 0 || x > mapSize.width || y < 0 || y > mapSize.height) {
        debugPrint('Warning: Spawn point $i ($pokemon) has invalid coordinates: ($x, $y)');
        continue;
      }

      markers.add(
        Positioned(
          left: x - 15, // Centro del círculo (30/2)
          top: y - 15,
          child: GestureDetector(
            onTap: () {
              // Mostrar tooltip o popup con info del spawn
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pokémon: $pokemon, Coordinates: ($x, $y)'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.7),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.orange,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  /// Construye la imagen del mapa (PNG o SVG)
  Widget _buildMapImage(ThemeData theme) {
    final mapData = _currentMapData;
    final assetPath = _getMapAssetPath();
    final size = _getMapSize();

    // Determinar si es SVG o PNG
    final isSvg = mapData?.isSvg ?? assetPath.toLowerCase().endsWith('.svg');

    Widget errorWidget = Container(
      width: size.width,
      height: size.height,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Mapa de ${_formatRegionName(widget.region)}',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Imagen del mapa no disponible',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );

    if (isSvg) {
      // Renderizar SVG
      return SvgPicture.asset(
        assetPath,
        width: size.width,
        height: size.height,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => errorWidget,
      );
    } else {
      // Renderizar PNG
      return Image.asset(
        assetPath,
        width: size.width,
        height: size.height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    }
  }

  Widget _buildMapContainer(
    ThemeData theme, {
    double? height,
    bool showFullscreenButton = true,
  }) {
    final isFullscreen = height == null || !showFullscreenButton;
    final containerHeight = height ?? (isFullscreen ? null : widget.height);

    final mapContainer = Container(
      height: containerHeight,
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
      clipBehavior: Clip.hardEdge,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mapSize = _getMapSize();
          final mapBounds = _resolveMapBounds(mapSize);
          final hasSpriteMarkers = widget.locationPoints?.isNotEmpty ?? false;
          final markerScaleFactor = isFullscreen ? _fullscreenSpriteScale : 1.0;
          final fitScale = constraints.maxWidth / mapSize.width;
          final minScale = fitScale;
          final maxScale = fitScale * 4;

          if (_transformationController.value == Matrix4.identity()) {
            _transformationController.value = Matrix4.identity()..scale(fitScale);
          }

          final List<Widget> controlButtons = [
            _MapControlButton(
              icon: Icons.add,
              tooltip: 'Acercar',
              onPressed: () {
                final currentMatrix = _transformationController.value;
                final currentScale = currentMatrix.getMaxScaleOnAxis();
                final newScale = (currentScale * 1.5).clamp(minScale, maxScale);

                final scaleFactor = newScale / currentScale;
                final focal = Offset(
                  constraints.maxWidth / 2,
                  constraints.maxHeight / 2,
                );
                final adjustedMatrix = Matrix4.copy(currentMatrix)
                  ..translate(focal.dx, focal.dy)
                  ..scale(scaleFactor)
                  ..translate(-focal.dx, -focal.dy);

                _transformationController.value = adjustedMatrix;
              },
            ),
            const SizedBox(height: 8),
            _MapControlButton(
              icon: Icons.remove,
              tooltip: 'Alejar',
              onPressed: () {
                final currentMatrix = _transformationController.value;
                final currentScale = currentMatrix.getMaxScaleOnAxis();
                final newScale = (currentScale / 1.5).clamp(minScale, maxScale);

                final scaleFactor = newScale / currentScale;
                final focal = Offset(
                  constraints.maxWidth / 2,
                  constraints.maxHeight / 2,
                );
                final adjustedMatrix = Matrix4.copy(currentMatrix)
                  ..translate(focal.dx, focal.dy)
                  ..scale(scaleFactor)
                  ..translate(-focal.dx, -focal.dy);

                _transformationController.value = adjustedMatrix;
              },
            ),
          ];

          if (showFullscreenButton) {
            controlButtons.addAll([
              const SizedBox(height: 8),
              _MapControlButton(
                icon: Icons.fullscreen,
                tooltip: 'Pantalla completa',
                onPressed: _openFullscreenMap,
              ),
            ]);
          }

          return Stack(
            children: [
              // Mapa interactivo con zoom/pan
              InteractiveViewer(
                transformationController: _transformationController,
                minScale: minScale,
                maxScale: maxScale,
                constrained: false,
                alignment: Alignment.topLeft,
                boundaryMargin: const EdgeInsets.all(12),
                clipBehavior: Clip.none,
                child: SizedBox(
                  width: mapSize.width,
                  height: mapSize.height,
                  child: Stack(
                    children: [
                      // Imagen del mapa de la región (PNG o SVG)
                      _buildMapImage(theme),
                      // Áreas clickeables provenientes del archivo de mapa
                      ..._buildClickableAreas(),
                      // Sprites posicionados según coordenadas en píxeles
                      if (hasSpriteMarkers)
                        ..._buildSpriteMarkers(
                          mapBounds: mapBounds,
                          scaleFactor: markerScaleFactor,
                        )
                      else
                        ..._buildMarkers(scaleFactor: markerScaleFactor),
                      // Marcadores de debug (si está habilitado)
                      ..._buildDebugSpawnMarkers(),
                    ],
                  ),
                ),
              ),

              // Popup cuando se selecciona un marcador
              if (_selectedEncounter != null)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _MarkerPopup(
                    encounter: _selectedEncounter!,
                    onClose: () {
                      setState(() {
                        _selectedEncounter = null;
                      });
                    },
                  ),
                ),

              // Botones de control
              Positioned(
                right: 16,
                bottom: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: controlButtons,
                ),
              ),
            ],
          );
        },
      ),
    );

    if (isFullscreen) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: FractionallySizedBox(
          heightFactor: 0.95,
          widthFactor: 0.98,
          child: mapContainer,
        ),
      );
    }

    return mapContainer;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.previewMode) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Explora el mapa interactivo en pantalla completa',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _openFullscreenMap,
              icon: const Icon(Icons.map),
              label: const Text('Ver mapa'),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Version selector (only show if multiple versions available)
        if (_availableVersions.length > 1)
          _buildVersionSelector(theme),

        // Map container
        _buildMapContainer(theme),
      ],
    );
  }

  /// Construye el selector de versiones del juego
  Widget _buildVersionSelector(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.videogame_asset,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _availableVersions.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(right: index < _availableVersions.length - 1 ? 8.0 : 0.0),
                    child: _VersionChip(
                      label: _availableVersions[index].gameVersion,
                      isSelected: index == _selectedVersionIndex,
                      onTap: () {
                        setState(() {
                          _selectedVersionIndex = index;
                          _selectedEncounter = null; // Reset selection
                          _transformationController.value = Matrix4.identity();
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRegionName(String region) {
    return region[0].toUpperCase() + region.substring(1);
  }
}

/// Chip para seleccionar versión del juego
class _VersionChip extends StatelessWidget {
  const _VersionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para el marcador de ubicación estilo Pokémon
class RegionMarkerWidget extends StatelessWidget {
  const RegionMarkerWidget({
    super.key,
    required this.encounters,
    this.isSelected = false,
    this.color = const Color(0xFFEF5350),
    this.size = 40.0,
  });

  final List<PokemonEncounter> encounters;
  final bool isSelected;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final visibleEncounters = encounters.take(3).toList();
    final markerScale = isSelected ? 1.12 : 1.0;
    final spriteSize = size * markerScale;
    final overlapOffset = spriteSize * 0.32;
    final markerWidth = spriteSize + overlapOffset * (visibleEncounters.length - 1);
    final markerHeight = spriteSize;

    Widget badge() {
      if (encounters.length <= visibleEncounters.length) return const SizedBox();

      return Positioned(
        right: -4,
        bottom: -4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.75),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Text(
            '+${encounters.length - visibleEncounters.length}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: markerWidth,
      height: markerHeight,
      transform: Matrix4.translationValues(-markerWidth / 2, -markerHeight / 2, 0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(markerHeight / 2),
        border: Border.all(
          color: Colors.white,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: isSelected ? 14 : 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < visibleEncounters.length; i++)
            Positioned(
              left: overlapOffset * i,
              child: _SpriteBubble(
                encounter: visibleEncounters[i],
                size: spriteSize,
                isSelected: isSelected,
              ),
            ),
          badge(),
        ],
      ),
    );
  }
}

class _SpriteBubble extends StatelessWidget {
  const _SpriteBubble({
    required this.encounter,
    required this.size,
    required this.isSelected,
  });

  final PokemonEncounter encounter;
  final double size;
  final bool isSelected;

  Color _typeColor() {
    if (encounter.pokemonTypes.isEmpty) {
      return pokemonTypeColors['unknown'] ?? Colors.grey.shade600;
    }

    final primaryType = encounter.pokemonTypes.first.toLowerCase();
    return pokemonTypeColors[primaryType] ?? Colors.grey.shade600;
  }

  Widget _buildFallbackIcon(Color accent) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            accent.withOpacity(0.14),
            accent.withOpacity(0.42),
          ],
        ),
      ),
      child: Icon(
        Icons.catching_pokemon,
        color: accent,
        size: size * 0.55,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = _typeColor();
    final hasSprite = encounter.spriteUrl.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: accent.withOpacity(isSelected ? 0.9 : 0.65),
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.35),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: hasSprite
            ? Image.network(
                encounter.spriteUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(accent),
              )
            : _buildFallbackIcon(accent),
      ),
    );
  }
}

class _MarkerGroup {
  _MarkerGroup({
    required this.marker,
    required this.encounters,
  });

  final RegionMarker marker;
  final List<PokemonEncounter> encounters;
}

/// Popup que se muestra al tocar un marcador
class _MarkerPopup extends StatelessWidget {
  const _MarkerPopup({
    required this.encounter,
    required this.onClose,
  });

  final PokemonEncounter encounter;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSprite = encounter.spriteUrl.isNotEmpty;

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
            // Encabezado con título y botón cerrar
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
                    encounter.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () => _openDetail(context),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasSprite)
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        encounter.spriteUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.catching_pokemon,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  if (hasSprite) const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatPokemonName(encounter.pokemonName),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: encounter.pokemonTypes
                              .map((type) => _TypeChip(type: type))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (encounter.methodSummaries.isNotEmpty) ...[
              Text(
                'Métodos de encuentro',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...encounter.versionDetails.map((versionDetail) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        versionDetail.displayVersion,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...versionDetail.encounterDetails.map(
                        (detail) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.catching_pokemon,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${detail.displayMethod} · ${detail.chance}% · ${detail.levelRange}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (encounter.allVersions.isNotEmpty)
                  Text(
                    _buildVersionsLabel(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                TextButton.icon(
                  onPressed: () => _openDetail(context),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Ver detalles'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailScreen(
          pokemonId: encounter.pokemonId,
          pokemonName: encounter.pokemonName,
          initialPokemon: PokemonListItem(
            id: encounter.pokemonId,
            name: encounter.pokemonName,
            imageUrl: encounter.spriteUrl,
            types: encounter.pokemonTypes,
          ),
        ),
      ),
    );
  }

  String _formatVersion(String version) {
    return version
        .split('-')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _buildVersionsLabel() {
    final primary = encounter.allVersions.take(2).map(_formatVersion).join(', ');
    final hasMore = encounter.allVersions.length > 2;
    return 'Versiones: $primary${hasMore ? ' +' : ''}';
  }

  String _formatPokemonName(String name) {
    if (name.isEmpty) return 'Desconocido';
    return name
        .split('-')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

class _AreaInfoDialog extends StatelessWidget {
  const _AreaInfoDialog({
    required this.areaName,
    required this.locationLabel,
    required this.linkUri,
  });

  final String areaName;
  final String locationLabel;
  final Uri? linkUri;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final linkText = linkUri?.toString() ?? 'Enlace no disponible';

    return AlertDialog(
      title: Text(areaName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.place_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  locationLabel,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: linkUri != null ? () => _openLink(context) : null,
            icon: const Icon(Icons.link),
            label: Text(linkText),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Future<void> _openLink(BuildContext context) async {
    if (linkUri == null) return;
    final messenger = ScaffoldMessenger.of(context);

    final success = await launchUrl(linkUri!, mode: LaunchMode.externalApplication);
    if (!success) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el enlace'),
        ),
      );
    }
  }
}

class _PolygonAreaWidget extends StatelessWidget {
  const _PolygonAreaWidget({required this.points, required this.onTap});

  final List<Offset> points;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: onTap,
      child: CustomPaint(
        painter: _PolygonAreaPainter(points: points),
      ),
    );
  }
}

class _PolygonAreaPainter extends CustomPainter {
  _PolygonAreaPainter({required List<Offset> points})
      : _points = points,
        _path = _buildPath(points);

  final List<Offset> _points;
  final Path _path;

  @override
  void paint(Canvas canvas, Size size) {
    if (_points.length < 3) return;

    final fillPaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.06)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(_path, fillPaint);
    canvas.drawPath(_path, borderPaint);
  }

  @override
  bool hitTest(Offset position) {
    return _points.length >= 3 && _path.contains(position);
  }

  @override
  bool shouldRepaint(covariant _PolygonAreaPainter oldDelegate) {
    return oldDelegate._points != _points;
  }

  static Path _buildPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;

    path.moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    path.close();
    return path;
  }
}

class _CircleAreaPainter extends CustomPainter {
  const _CircleAreaPainter({required this.center, required this.radius});

  final Offset center;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.06)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool hitTest(Offset position) {
    return (position - center).distance <= radius;
  }

  @override
  bool shouldRepaint(covariant _CircleAreaPainter oldDelegate) {
    return oldDelegate.center != center || oldDelegate.radius != radius;
  }
}

/// Botón de control del mapa
class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
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
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedType = _formatType(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Text(
        normalizedType,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  String _formatType(String value) {
    return value
        .split('-')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
