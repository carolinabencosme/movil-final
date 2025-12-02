import 'dart:ui';

/// Tipo de forma soportada en un área clickeable del mapa.
enum AreaShape { rect, circle, poly }

/// Área clickeable declarada en el archivo de mapas (tag `<area>`)
class ClickableArea {
  const ClickableArea({
    required this.shape,
    required this.href,
    required this.title,
    this.location = '',
    required this.points,
    this.rect,
    this.center,
    this.radius,
  });

  /// Forma de la región interactiva.
  final AreaShape shape;

  /// Enlace original asociado al área.
  final String href;

  /// Título descriptivo del área.
  final String title;

  /// Nombre de la ubicación representada por el área.
  final String location;

  /// Puntos normalizados que describen la geometría del área.
  final List<Offset> points;

  /// Rectángulo normalizado cuando la forma es [AreaShape.rect].
  final Rect? rect;

  /// Centro de la circunferencia cuando la forma es [AreaShape.circle].
  final Offset? center;

  /// Radio de la circunferencia cuando la forma es [AreaShape.circle].
  final double? radius;

  /// Límite que encapsula el área sin importar la forma.
  Rect get bounds {
    if (rect != null) return rect!;
    if (center != null && radius != null) {
      return Rect.fromCircle(center: center!, radius: radius!);
    }
    if (points.isEmpty) return Rect.zero;
    double minX = points.first.dx;
    double maxX = points.first.dx;
    double minY = points.first.dy;
    double maxY = points.first.dy;

    for (final point in points.skip(1)) {
      if (point.dx < minX) minX = point.dx;
      if (point.dx > maxX) maxX = point.dx;
      if (point.dy < minY) minY = point.dy;
      if (point.dy > maxY) maxY = point.dy;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

/// Resultado del parseo de un mapa con sus áreas clickeables.
class ParsedMap {
  const ParsedMap({
    required this.imagePath,
    required this.mapSize,
    required this.areas,
  });

  /// Ruta del asset de la imagen del mapa.
  final String imagePath;

  /// Tamaño real del mapa.
  final Size mapSize;

  /// Áreas interactivas presentes en el mapa.
  final List<ClickableArea> areas;
}
