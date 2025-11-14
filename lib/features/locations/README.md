# Locations Module

Este módulo implementa mapas interactivos para mostrar las ubicaciones donde aparecen los Pokémon en diferentes regiones y juegos.

## Estructura

```
locations/
├── data/
│   ├── location_service.dart      # Servicio para obtener datos de PokéAPI
│   └── region_coordinates.dart    # Coordenadas geográficas de regiones
├── models/
│   └── pokemon_location.dart      # Modelos de datos
├── screens/
│   └── locations_tab.dart         # Tab de ubicaciones en detail screen
├── widgets/
│   ├── location_marker.dart       # Marcador y popup del mapa
│   └── pokemon_location_map.dart  # Widget del mapa interactivo
└── locations.dart                 # Archivo de exportación del módulo
```

## Características

### 1. Mapa Interactivo
- **Tiles**: OpenStreetMap para el mapa base
- **Zoom**: Control de zoom con botones (+/-) y gestos
- **Pan**: Arrastrar para mover el mapa
- **Reset**: Botón para volver al centro y zoom inicial
- **Responsive**: Se adapta al tamaño de la pantalla

### 2. Marcadores de Ubicación
- **Diseño**: Círculo con ícono de ubicación
- **Color**: Personalizable (por defecto azul Pokémon)
- **Interactividad**: Tap para mostrar popup con información
- **Visualización**: Borde blanco y sombra para contraste

### 3. Información Detallada
- **Popup en mapa**: Al tocar un marcador
  - Nombre de la región
  - Número de áreas
  - Juegos donde aparece
  - Ejemplo de ubicación
- **Lista de regiones**: Debajo del mapa
  - Cards expandibles por región
  - Chips de versiones
  - Áreas de ejemplo

### 4. Manejo de Estados
- **Loading**: Spinner con mensaje
- **Error**: Icono, mensaje y botón de reintentar
- **Empty**: Estado cuando no hay datos
- **Success**: Mapa y lista de ubicaciones

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

PokemonLocationMap(
  locations: locationsByRegion,
  height: 300.0,
  initialZoom: 4.0,
  markerColor: Colors.blue,
)
```

## Dependencias

- **flutter_map**: ^6.0.0 - Widget de mapa interactivo
- **latlong2**: ^0.9.0 - Coordenadas geográficas
- **http**: ^1.0.0 - Peticiones HTTP a PokéAPI

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
// Obtener coordenadas
final coords = getRegionCoordinates('kanto'); // LatLng(35.4, 138.7)

// Verificar disponibilidad
final hasCoords = hasRegionCoordinates('kanto'); // true

// Lista de regiones disponibles
final regions = getAvailableRegions(); // ['kanto', 'johto', ...]
```

## Modelos de Datos

### PokemonEncounter
Representa un encuentro en un área específica.

```dart
class PokemonEncounter {
  final String locationArea;
  final List<EncounterVersionDetail> versionDetails;
  final String? region;
  final LatLng? coordinates;
  
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
  final LatLng coordinates;
  
  List<String> get allVersions;
  int get areaCount;
}
```

## Regiones Soportadas

| Región | Inspiración Real | Coordenadas |
|--------|------------------|-------------|
| Kanto | Región de Kanto, Japón | (35.4, 138.7) |
| Johto | Región de Kansai, Japón | (36.2, 138.5) |
| Hoenn | Kyushu, Japón | (34.7, 135.5) |
| Sinnoh | Hokkaido, Japón | (39.7, 140.0) |
| Unova | Nueva York, EE.UU. | (40.7, -74.0) |
| Kalos | Francia | (46.2, 2.2) |
| Alola | Hawái, EE.UU. | (20.8, -156.3) |
| Galar | Reino Unido | (53.0, -1.5) |
| Paldea | Península Ibérica | (40.4, -3.7) |

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

### Coordenadas Geográficas

Como la PokéAPI no proporciona coordenadas geográficas reales, se utilizan coordenadas basadas en las inspiraciones reales de cada región. Este es un enfoque de fallback razonable que proporciona una experiencia visual coherente.

### Rendimiento

- Los datos se cargan bajo demanda (lazy loading)
- El estado se mantiene con `AutomaticKeepAliveClientMixin`
- Las imágenes del mapa usan cache del navegador
- Los marcadores son widgets ligeros

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

## Mejoras Futuras

Posibles mejoras para futuras iteraciones:

1. **Filtros**: Filtrar por versión del juego o método de encuentro
2. **Detalles expandibles**: Modal con información completa al tocar una región
3. **Comparación**: Comparar ubicaciones de múltiples Pokémon
4. **Navegación**: Navegar entre Pokémon desde el mapa
5. **Personalización**: Temas de mapa (satélite, terreno, etc.)
6. **Caché**: Cache local de datos de ubicaciones
7. **Animaciones**: Animaciones al aparecer marcadores
8. **Clustering**: Agrupar marcadores cercanos en zoom bajo

## Contribuir

Al modificar este módulo:

1. Mantener la estructura de archivos actual
2. Añadir tests para nuevas funcionalidades
3. Documentar cambios en este README
4. Seguir el estilo de código existente
5. Actualizar los tipos según sea necesario

## Licencia

Este módulo es parte del proyecto Pokédex y sigue la misma licencia del proyecto principal.
