# Map System Implementation - Flutter Guide

## Overview

This document describes the **Flutter implementation** of the map system. The original requirements were written for React Native, but this project uses Flutter/Dart.

## ✅ Implementation Mapping

### React Native → Flutter Equivalent

| React Native Component | Flutter Equivalent | Location |
|----------------------|-------------------|----------|
| `metro.config.js` | `pubspec.yaml` | Root directory |
| `react-native-svg` | `flutter_svg: ^2.0.10+1` | Already installed |
| `RegionRegistry.ts` | `region_map_data.dart` | `lib/features/locations/data/` |
| `MapRenderer.tsx` | `RegionMapViewer` | `lib/features/locations/widgets/` |
| `require('./path/to/svg')` | `SvgPicture.asset('path/to/svg')` | Used in RegionMapViewer |

## ✅ Directory Structure

All required directories and files exist:

```
assets/maps/
├── regions/
│   ├── kanto/
│   │   └── kanto_vector.svg ✓
│   ├── johto/
│   │   └── johto_vector.svg ✓
│   ├── hoenn/
│   │   └── hoenn_vector.svg ✓
│   ├── sinnoh/
│   │   └── sinnoh_vector.svg ✓
│   ├── unova/
│   │   └── unova_vector.svg ✓
│   ├── kalos/
│   │   └── kalos_vector.svg ✓
│   ├── alola/
│   │   └── alola_vector.svg ✓
│   ├── galar/
│   │   └── galar_vector.svg ✓
│   ├── hisui/
│   │   └── hisui_vector.svg ✓
│   └── paldea/
│       └── paldea_vector.svg ✓
└── test_spawns/
    └── alola_test.json ✓
```

## ✅ Region Registry (Flutter)

**File:** `lib/features/locations/data/region_map_data.dart`

This file serves as the Flutter equivalent of `RegionRegistry.ts`:

```dart
/// Region map data registry
final Map<String, List<RegionMapData>> regionMapsByVersion = {
  'kanto': [/* multiple versions */],
  'johto': [/* multiple versions */],
  'hoenn': [/* multiple versions */],
  'sinnoh': [/* multiple versions */],
  'unova': [/* multiple versions */],
  'kalos': [/* multiple versions */],
  'alola': [/* multiple versions */],
  'galar': [/* multiple versions */],
  'hisui': [/* multiple versions */],
  'paldea': [/* multiple versions */],
};

/// Helper functions
RegionMapData? getRegionMapData(String regionName);
List<RegionMapData> getRegionMapVersions(String regionName);
RegionMapData? getRegionMapByVersion(String regionName, String gameVersion);
```

## ✅ Map Renderer (Flutter)

**File:** `lib/features/locations/widgets/region_map_viewer.dart`

The `RegionMapViewer` widget is the Flutter equivalent of `MapRenderer.tsx`:

```dart
RegionMapViewer(
  region: 'alola',              // Region to display
  encounters: [],                // Pokemon encounters (empty for testing)
  height: 400.0,                // Widget height
  debugMode: true,              // Enable debug spawn markers
  debugSpawns: testSpawns,      // Test spawn data
)
```

### Features:
- ✅ SVG rendering using `flutter_svg`
- ✅ Interactive zoom and pan
- ✅ Multiple game version support
- ✅ Debug mode for spawn visualization
- ✅ Custom markers with animations
- ✅ Error handling and loading states

## ✅ Debug System

**File:** `lib/features/locations/examples/spawn_debug_example.dart`

A complete example showing how to use the debug system:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

// Load test spawn data
final jsonString = await rootBundle.loadString(
  'assets/maps/test_spawns/alola_test.json',
);
final data = json.decode(jsonString);

// Use in RegionMapViewer
RegionMapViewer(
  region: 'alola',
  encounters: const [],
  debugMode: true,
  debugSpawns: data['spawns'],
)
```

## ✅ Test Spawn File Format

**File:** `assets/maps/test_spawns/alola_test.json`

```json
{
  "region": "alola",
  "mapSize": 1000,
  "spawns": [
    { "pokemon": "pikachu", "x": 260, "y": 240, "area": "Route 1" },
    { "pokemon": "wingull", "x": 650, "y": 820, "area": "Seafolk Village" }
  ]
}
```

## Usage Examples

### Basic Map Display
```dart
RegionMapViewer(
  region: 'kanto',
  encounters: pokemonEncounters,
  height: 300,
)
```

### Debug Mode with Test Spawns
```dart
// 1. Load test spawn data
final testData = await rootBundle.loadString(
  'assets/maps/test_spawns/alola_test.json',
);
final spawns = json.decode(testData)['spawns'];

// 2. Display with debug markers
RegionMapViewer(
  region: 'alola',
  encounters: const [],
  debugMode: true,
  debugSpawns: spawns,
  height: 400,
)
```

### Version Selection
The widget automatically shows version selector if multiple versions exist:
```dart
RegionMapViewer(
  region: 'kanto',  // Has: RBY, FRLG, Let's Go, Vector
  encounters: [],
  // User can switch between versions in UI
)
```

## Assets Configuration

**File:** `pubspec.yaml`

Assets are properly configured:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/maps/regions/kanto/
    - assets/maps/regions/johto/
    - assets/maps/regions/hoenn/
    - assets/maps/regions/sinnoh/
    - assets/maps/regions/unova/
    - assets/maps/regions/kalos/
    - assets/maps/regions/alola/
    - assets/maps/regions/galar/
    - assets/maps/regions/hisui/
    - assets/maps/regions/paldea/
    - assets/maps/test_spawns/
```

## Dependencies

All required packages are installed:

```yaml
dependencies:
  flutter_svg: ^2.0.10+1  # For SVG rendering
  flutter_riverpod: ^2.6.1  # State management
```

## Key Differences from React Native

| Feature | React Native | Flutter |
|---------|-------------|---------|
| SVG Library | `react-native-svg` + transformer | `flutter_svg` package |
| SVG Asset Loading | `require('./file.svg')` | `SvgPicture.asset('path/to/file.svg')` |
| JSON Asset Loading | `require('./file.json')` | `rootBundle.loadString('path/to/file.json')` |
| Component Type | Function/Class Component | StatefulWidget |
| Styling | StyleSheet API | Widget properties |
| Rendering | React Native View | Flutter Widget tree |

## Running the Debug Example

To see the debug system in action:

1. Navigate to the spawn debug example screen
2. The map will display with yellow numbered circles showing spawn points
3. Tap on any spawn marker to see coordinates and Pokemon name
4. Use zoom/pan controls to explore the map

## Testing

The system is ready for testing with:
- ✅ All 10 region SVG maps
- ✅ Debug spawn visualization
- ✅ Interactive map controls
- ✅ Multiple game version support
- ✅ Error handling and loading states

## Next Steps

To extend the system:
1. Add more test spawn JSON files for other regions
2. Create real Pokemon encounter data
3. Add more markers and location types
4. Implement advanced filtering and search
