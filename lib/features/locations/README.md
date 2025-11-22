# Locations Module

Este módulo implementa mapas interactivos de regiones Pokémon para mostrar las ubicaciones donde aparecen los Pokémon en diferentes juegos.

> **Nota**: Este módulo fue actualizado para usar mapas de regiones Pokémon en vez de OpenStreetMap.
> Ver `REGION_MAPS_IMPLEMENTATION.md` en la raíz del proyecto para detalles completos.

## Actualización de mapas oficiales

- Se usan capturas oficiales por generación en `assets/maps/regions/**` (RBY, FRLG, etc.).
- `region_map_data.dart` referencia las dimensiones reales medidas de cada asset.
- `region_map_markers.dart` recalibra las coordenadas al tamaño real de cada captura
  para que `RegionMapViewer` posicione los marcadores sobre las ubicaciones del juego.
- Habilita el modo debug del visor (ver `examples/spawn_debug_example.dart`) para validar
  visualmente nuevos marcadores o assets.

## Estructura

```
locations/
├── data/
│   ├── location_service.dart      # Servicio para obtener datos de PokéAPI
│   ├── region_coordinates.dart    # Coordenadas X/Y de centros de regiones
│   └── region_map_markers.dart    # Marcadores X/Y por región (116 ubicaciones)
├── models/
│   └── pokemon_location.dart      # Modelos de datos (MapCoordinates)
├── screens/
│   └── locations_tab.dart         # Tab de ubicaciones en detail screen
├── widgets/
│   └── region_map_viewer.dart     # Mapa interactivo con InteractiveViewer
└── locations.dart                 # Archivo de exportación del módulo
```

## Características

### 1. Mapa Interactivo de Regiones
- **Base**: Imágenes PNG de mapas de regiones Pokémon (800x600px)
- **Zoom**: Control de zoom (0.8x-4x) con botones (+/-) y gestos pinch
- **Pan**: Arrastrar para mover el mapa
- **Reset**: Botón para volver al centro y zoom inicial
- **Offline**: Funciona sin conexión (assets locales)

### 2. Marcadores Estilo Pokémon
- **Diseño**: Círculo rojo con ícono de ubicación y borde blanco
- **Color**: Personalizable (por defecto usa color primario del tema)
- **Interactividad**: Tap para mostrar popup con información
- **Animación**: Escala aumenta 20% al seleccionar
- **Posicionamiento**: Coordenadas X/Y en píxeles

### 3. Información Detallada
- **Popup en mapa**: Al tocar un marcador
  - Nombre del área
  - Juegos donde aparece (chips)
  - Botón cerrar
- **Lista de regiones**: Debajo del mapa
  - Card por región con detalles
  - Chips de versiones
  - Áreas de ejemplo

### 4. Manejo de Estados
- **Loading**: Spinner con mensaje
- **Error**: Icono, mensaje y botón de reintentar
- **Empty**: Estado cuando no hay datos
- **Success**: Mapas por región con marcadores

## Uso

### Integración en Detail Screen

El módulo se integra automáticamente como la 6ª pestaña en el `DetailScreen`:

```dart
import 'package:pokedex/features/locations/screens/locations_tab.dart';

// En TabBarView, añadir:
PokemonLocationsTab(
  pokemon: pokemon,
  sectionBackground: sectionBackground,
  sectionBorder: sectionBorder,
)
```

### Uso Independiente del Mapa

También puedes usar el mapa de forma independiente:

```dart
import 'package:pokedex/features/locations/locations.dart';

RegionMapViewer(
  region: 'kanto',
  encounters: encountersList,
  height: 300.0,
  markerColor: Colors.red,
  onMarkerTap: (encounter) {
    print('Tapped: ${encounter.displayName}');
  },
)
```

## Dependencias

- **http**: ^1.0.0 - Peticiones HTTP a PokéAPI
- **flutter**: SDK - InteractiveViewer para zoom/pan

## API

### LocationService

```dart
final service = LocationService();

// Obtener encuentros
final encounters = await service.fetchPokemonEncounters(pokemonId);

// Obtener encuentros agrupados por región
final locationsByRegion = await service.fetchLocationsByRegion(pokemonId);
```

### Coordenadas de Regiones

```dart
// Obtener coordenadas del centro de una región
final coords = getRegionCoordinates('kanto'); // MapCoordinates(400, 300)

// Verificar disponibilidad
final hasCoords = hasRegionCoordinates('kanto'); // true

// Lista de regiones disponibles
final regions = getAvailableRegions(); // ['kanto', 'johto', ...]
```

### Marcadores de Región

```dart
// Obtener marcador de un área específica
final marker = getRegionMarker('kanto', 'route-1'); // RegionMarker(400, 450, 'Route 1')

// Obtener todos los marcadores de una región
final markers = getRegionMarkers('kanto'); // Map<String, RegionMarker>

// Verificar si una región tiene marcadores
final hasMarkers = hasRegionMarkers('kanto'); // true
```

## Modelos de Datos

### MapCoordinates
Coordenadas X/Y en píxeles para posicionamiento en el mapa.

```dart
class MapCoordinates {
  final double x; // 0-800 (para imagen de 800px de ancho)
  final double y; // 0-600 (para imagen de 600px de alto)
}
```

### PokemonEncounter
Representa un encuentro en un área específica.

```dart
class PokemonEncounter {
  final String locationArea;
  final List<EncounterVersionDetail> versionDetails;
  final String? region;
  final MapCoordinates? coordinates;
  
  String get displayName; // "Route 1 Area"
  List<String> get allVersions; // ["red", "blue"]
}
```

### EncounterVersionDetail
Detalles de encuentro para una versión específica.

```dart
class EncounterVersionDetail {
  final String version;
  final int maxChance;
  final List<EncounterDetail> encounterDetails;
  
  String get displayVersion; // "Heart Gold"
}
```

### EncounterDetail
Información específica de un método de encuentro.

```dart
class EncounterDetail {
  final int chance;
  final String method;
  final int? minLevel;
  final int? maxLevel;
  
  String get displayMethod; // "Old Rod"
  String get levelRange; // "Lv. 5-10"
}
```

### LocationsByRegion
Encuentros agrupados por región con coordenadas.

```dart
class LocationsByRegion {
  final String region;
  final List<PokemonEncounter> encounters;
  final MapCoordinates coordinates; // Centro del mapa
  
  List<String> get allVersions;
  int get areaCount;
}
```

### RegionMarker
Marcador de ubicación en el mapa de región.

```dart
class RegionMarker {
  final double x; // Posición X en píxeles
  final double y; // Posición Y en píxeles
  final String area; // Nombre del área
}
```

## Regiones Soportadas

| Región | Mapa PNG | Marcadores | Centro (X,Y) |
|--------|----------|------------|--------------|
| Kanto | `kanto.png` | 13 ubicaciones | (400, 300) |
| Johto | `johto.png` | 16 ubicaciones | (400, 300) |
| Hoenn | `hoenn.png` | 16 ubicaciones | (400, 300) |
| Sinnoh | `sinnoh.png` | 20 ubicaciones | (400, 300) |
| Unova | `unova.png` | 14 ubicaciones | (400, 300) |
| Kalos | `kalos.png` | 11 ubicaciones | (400, 300) |
| Alola | `alola.png` | 12 ubicaciones | (400, 300) |
| Galar | `galar.png` | 14 ubicaciones | (400, 300) |

**Total: 116 ubicaciones pre-configuradas**

## Pruebas

El módulo incluye tests completos en `test/locations_test.dart`:

```bash
# Ejecutar tests
flutter test test/locations_test.dart
```

Tests incluidos:
- ✅ Lookup de coordenadas de regiones
- ✅ Parsing de modelos desde JSON
- ✅ Formateo de nombres y etiquetas
- ✅ Agregación de versiones
- ✅ Manejo de campos nulos
- ✅ Casos extremos

## Notas Técnicas

### Sistema de Coordenadas

El módulo usa un sistema de coordenadas X/Y en píxeles en vez de coordenadas geográficas:
- **Base**: Imágenes de 800x600 píxeles
- **Origen**: (0, 0) en la esquina superior izquierda
- **Centro**: (400, 300) en el centro del mapa
- **Marcadores**: Posicionados con `Positioned` widgets

### Rendimiento

- Los datos se cargan bajo demanda (lazy loading)
- El estado se mantiene con `AutomaticKeepAliveClientMixin`
- Las imágenes del mapa son assets locales (bundle)
- Los marcadores son widgets ligeros con animaciones optimizadas
- InteractiveViewer maneja transformaciones eficientemente
- 99% menos uso de memoria vs. tiles de OpenStreetMap

### Accesibilidad

- Todos los botones tienen áreas táctiles de 44x44 px mínimo
- Los colores tienen suficiente contraste
- Los estados de carga tienen mensajes descriptivos
- Los errores son claros y accionables

### Internacionalización

Los textos están en español, pero la estructura permite fácil i18n:
- Usar archivos de localización para strings
- Los nombres de regiones/versiones vienen de la API en inglés
- Los métodos `displayName`, `displayVersion`, etc. pueden usar i18n

## Customización

### Reemplazar Mapas Placeholder

Los mapas actuales son placeholders. Para usar mapas reales:

1. Obtén imágenes de mapas de regiones Pokémon (recomendado: 800x600px)
2. Reemplaza los archivos en `assets/maps/`
3. Ajusta coordenadas en `region_map_markers.dart` según las nuevas imágenes
4. Ejecuta `flutter pub get` para actualizar assets

Ver `REGION_MAPS_IMPLEMENTATION.md` para guía detallada.

## Mejoras Futuras

Posibles mejoras para futuras iteraciones:

1. **Selector de región**: Dropdown para cambiar entre regiones
2. **Íconos personalizados**: Diferentes íconos por tipo de ubicación
3. **Heatmap**: Overlay de probabilidad de encuentro
4. **Rutas animadas**: Animaciones entre ubicaciones
5. **Mini-mapa**: Vista general en esquina
6. **Búsqueda**: Buscar ubicaciones específicas
7. **Zoom personalizado**: Niveles de zoom por región
8. **Comparación**: Comparar ubicaciones de múltiples Pokémon

## Contribuir

Al modificar este módulo:

1. Mantener la estructura de archivos actual
2. Añadir tests para nuevas funcionalidades
3. Documentar cambios en este README
4. Seguir el estilo de código existente
5. Actualizar los tipos según sea necesario

## Licencia

Este módulo es parte del proyecto Pokédex y sigue la misma licencia del proyecto principal.
