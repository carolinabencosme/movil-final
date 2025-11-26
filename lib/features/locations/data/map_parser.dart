import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../models/parsed_map.dart';
import 'region_map_data.dart';

class MapParser {
  const MapParser();

  Future<ParsedMap> load(String region) async {
    final normalizedRegion = region.toLowerCase().trim();
    final regionData = getRegionMapData(normalizedRegion);
    final imagePath = regionData?.assetPath ??
        'assets/maps/regions/$normalizedRegion/${normalizedRegion}_pokeearth.png';
    final mapSize = await _resolveMapSize(imagePath, regionData?.mapSize);

    final areas = await _parseAreas(normalizedRegion);

    return ParsedMap(
      imagePath: imagePath,
      mapSize: mapSize,
      areas: areas ?? const [],
    );
  }

  Future<Size> _resolveMapSize(String imagePath, Size? fallback) async {
    if (fallback != null) return fallback;

    try {
      final data = await rootBundle.load(imagePath);
      final bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return Size(
        frame.image.width.toDouble(),
        frame.image.height.toDouble(),
      );
    } catch (_) {
      return fallback ?? const Size(800, 600);
    }
  }

  Future<List<ClickableArea>?> _parseAreas(String region) async {
    final basePath = 'assets/maps/regions/$region';
    final candidates = <String>[
      '$basePath/$region.txt',
      '$basePath/${_capitalize(region)}.txt',
    ];

    String? content;
    for (final path in candidates) {
      try {
        content = await rootBundle.loadString(path);
        break;
      } catch (_) {
        continue;
      }
    }

    if (content == null) return null;

    return _extractAreas(content);
  }

  List<ClickableArea> _extractAreas(String content) {
    final List<ClickableArea> areas = [];
    final areaRegex = RegExp(r'<area[^>]*>', caseSensitive: false);
    final attributeRegex =
    RegExp(r'''(href|shape|coords|title)\s*=\s*['"]([^'"]+)['"]''');



    for (final match in areaRegex.allMatches(content)) {
      final tag = match.group(0);
      if (tag == null) continue;

      final attributes = <String, String>{};
      for (final attr in attributeRegex.allMatches(tag)) {
        attributes[attr.group(1)!.toLowerCase()] = attr.group(2)!;
      }

      if (!attributes.containsKey('coords')) continue;

      final shape = _parseShape(attributes['shape']);
      final coords = _parseCoords(attributes['coords']!);
      final area = _buildArea(
        shape: shape,
        coords: coords,
        href: attributes['href'] ?? '',
        title: attributes['title'] ?? '',
      );

      if (area != null) {
        areas.add(area);
      }
    }

    return areas;
  }

  AreaShape _parseShape(String? value) {
    final normalized = value?.toLowerCase().trim();
    switch (normalized) {
      case 'circle':
        return AreaShape.circle;
      case 'poly':
      case 'polygon':
        return AreaShape.poly;
      case 'rect':
      default:
        return AreaShape.rect;
    }
  }

  List<double> _parseCoords(String coords) {
    return coords
        .split(RegExp(r'[ ,]+'))
        .where((value) => value.trim().isNotEmpty)
        .map((value) => double.tryParse(value.trim()) ?? 0)
        .toList();
  }

  ClickableArea? _buildArea({
    required AreaShape shape,
    required List<double> coords,
    required String href,
    required String title,
  }) {
    switch (shape) {
      case AreaShape.circle:
        if (coords.length < 3) return null;
        final center = Offset(coords[0], coords[1]);
        final radius = coords[2].abs();
        return ClickableArea(
          shape: shape,
          href: href,
          title: title,
          points: [center],
          center: center,
          radius: radius,
        );
      case AreaShape.poly:
        if (coords.length < 6) return null;
        final points = <Offset>[];
        for (var i = 0; i < coords.length - 1; i += 2) {
          points.add(Offset(coords[i], coords[i + 1]));
        }
        return ClickableArea(
          shape: shape,
          href: href,
          title: title,
          points: points,
        );
      case AreaShape.rect:
      default:
        if (coords.length < 4) return null;
        final x1 = coords[0];
        final y1 = coords[1];
        final x2 = coords[2];
        final y2 = coords[3];
        final rect = Rect.fromLTRB(
          min(x1, x2),
          min(y1, y2),
          max(x1, x2),
          max(y1, y2),
        );
        return ClickableArea(
          shape: shape,
          href: href,
          title: title,
          rect: rect,
          points: [rect.topLeft, rect.bottomRight],
        );
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
