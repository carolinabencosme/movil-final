# SVG Maps Implementation - Pokémon Region System

## Overview

This implementation adds complete SVG vector map support to the Pokémon region map system, providing clean, scalable maps for all 10 Pokémon regions. Additionally, it includes a spawn point debug layer for testing and positioning Pokémon encounters.

## What's New

### 1. SVG Vector Maps (✅ Complete)

All 10 Pokémon regions now have SVG vector maps:

- **Kanto** - `assets/maps/regions/kanto/kanto_vector.svg`
- **Johto** - `assets/maps/regions/johto/johto_vector.svg`
- **Hoenn** - `assets/maps/regions/hoenn/hoenn_vector.svg`
- **Sinnoh** - `assets/maps/regions/sinnoh/sinnoh_vector.svg`
- **Unova** - `assets/maps/regions/unova/unova_vector.svg`
- **Kalos** - `assets/maps/regions/kalos/kalos_vector.svg`
- **Alola** - `assets/maps/regions/alola/alola_vector.svg`
- **Galar** - `assets/maps/regions/galar/galar_vector.svg`
- **Hisui** - `assets/maps/regions/hisui/hisui_vector.svg`
- **Paldea** - `assets/maps/regions/paldea/paldea_vector.svg`

**Features:**
- ✅ All maps use `viewBox="0 0 1000 1000"` for consistent sizing
- ✅ Clean vector paths with simplified gradients
- ✅ No copyrighted sprites or pixel textures
- ✅ Authentic color palettes inspired by official games
- ✅ File sizes ~5-6KB each (highly optimized)

### 2. Enhanced Map Data System (✅ Complete)

**File:** `lib/features/locations/data/region_map_data.dart`

**Changes:**
- Added `isSvg` getter to `RegionMapData` class to detect SVG files
- Added "Vector Map" version for each region in `regionMapsByVersion`
- Full backward compatibility with existing PNG maps

**Example:**
```dart
final mapData = getRegionMapData('alola');
if (mapData.isSvg) {
  print('This is an SVG map!');
}
```

### 3. SVG Rendering Support (✅ Complete)

**File:** `lib/features/locations/widgets/region_map_viewer.dart`

**Changes:**
- Imported `flutter_svg` package (already in dependencies)
- Added `_buildMapImage()` method to handle both PNG and SVG rendering
- Automatic detection and rendering based on file extension
- Consistent error handling for both formats

**How it works:**
```dart
// The widget automatically detects the file type
Widget _buildMapImage(ThemeData theme) {
  final isSvg = mapData?.isSvg ?? assetPath.toLowerCase().endsWith('.svg');
  
  if (isSvg) {
    return SvgPicture.asset(...); // SVG rendering
  } else {
    return Image.asset(...);       // PNG rendering
  }
}
```

### 4. Spawn Debug System (✅ Complete)

**New Features:**
- Debug mode parameter in `RegionMapViewer`
- Visual spawn point markers with numbered circles
- Test spawn data format (JSON)
- Example implementation

**Files Created:**
- `lib/features/locations/models/spawn_test_data.dart` - Data models
- `assets/maps/test_spawns/alola_test.json` - Example test data
- `lib/features/locations/examples/spawn_debug_example.dart` - Usage example

**Usage Example:**
```dart
RegionMapViewer(
  region: 'alola',
  encounters: encounters,
  debugMode: true,  // Enable debug overlay
  debugSpawns: [
    {'pokemon': 'pikachu', 'x': 260, 'y': 240},
    {'pokemon': 'wingull', 'x': 650, 'y': 820},
  ],
)
```

## Technical Details

### SVG Map Structure

Each SVG map includes:
- **Sea/Ocean gradients** - For water bodies
- **Land gradients** - For terrain
- **Mountain/terrain gradients** - For elevation
- **City markers** - Simplified geometric shapes
- **Routes/paths** - Connecting lines
- **Clouds** - Stylized weather elements
- **Shadow effects** - Depth and dimension

### Asset Configuration

**File:** `pubspec.yaml`

```yaml
assets:
  - assets/maps/regions/      # Includes all PNG and SVG files
  - assets/maps/test_spawns/  # Includes spawn test data
```

### Dependencies

Already included in the project:
- `flutter_svg: ^2.0.10+1` - For SVG rendering

## Usage

### Basic Usage (Automatic)

The system automatically detects and renders SVG files when available:

```dart
// This will use SVG if the "Vector Map" version is selected
RegionMapViewer(
  region: 'kanto',
  encounters: pokemonEncounters,
  height: 400,
)
```

### Debug Mode Usage

To test spawn point positions:

1. Create a spawn test JSON file in `assets/maps/test_spawns/`:

```json
{
  "region": "kanto",
  "mapSize": 1000,
  "spawns": [
    {
      "pokemon": "pikachu",
      "x": 400,
      "y": 450,
      "area": "Route 1"
    }
  ]
}
```

2. Load and display with debug mode:

```dart
// Load spawn data
final jsonString = await rootBundle.loadString(
  'assets/maps/test_spawns/kanto_test.json'
);
final data = json.decode(jsonString);
final spawns = data['spawns'] as List<Map<String, dynamic>>;

// Display with debug markers
RegionMapViewer(
  region: 'kanto',
  encounters: [],
  debugMode: true,
  debugSpawns: spawns,
)
```

### Version Selector

Users can switch between map versions (including Vector Map) using the built-in version selector:

```dart
// The widget automatically shows a selector when multiple versions exist
RegionMapViewer(
  region: 'kanto',
  encounters: encounters,
  // Will show selector with: Red/Blue/Yellow, FireRed/LeafGreen, Let's Go, Vector Map
)
```

## Testing

To verify the implementation:

1. Run the example:
```dart
import 'package:pokedex/features/locations/examples/spawn_debug_example.dart';

// Use in your app
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => SpawnDebugExample()),
);
```

2. Check SVG rendering:
- Navigate to any region's location screen
- Select "Vector Map" from the version selector
- Verify the map loads and renders correctly
- Test zoom/pan functionality

3. Test debug mode:
- Enable debug mode with test spawns
- Verify numbered markers appear at correct coordinates
- Tap markers to see coordinate information

## File Structure

```
movil-final/
├── assets/maps/
│   ├── regions/
│   │   ├── kanto/
│   │   │   ├── kanto_vector.svg ✅
│   │   │   ├── kanto_frlg.png
│   │   │   └── ...
│   │   ├── johto/
│   │   │   ├── johto_vector.svg ✅
│   │   │   └── ...
│   │   └── ... (all 10 regions)
│   └── test_spawns/
│       └── alola_test.json ✅
└── lib/features/locations/
    ├── data/
    │   └── region_map_data.dart ✅ (updated)
    ├── widgets/
    │   └── region_map_viewer.dart ✅ (updated)
    ├── models/
    │   └── spawn_test_data.dart ✅ (new)
    └── examples/
        └── spawn_debug_example.dart ✅ (new)
```

## Benefits

### SVG Maps
- **Scalable** - No quality loss at any zoom level
- **Lightweight** - 5-6KB vs 100KB+ for PNG
- **Consistent** - Same viewBox for all regions
- **Clean** - Vector-based, no pixelation

### Debug System
- **Precise** - Test exact spawn coordinates
- **Visual** - See all spawn points at once
- **Interactive** - Tap to get coordinates
- **Flexible** - Easy to add new test data

## Future Enhancements

Potential improvements:
- [ ] Add more region-specific test spawn files
- [ ] Create spawn coordinate editor tool
- [ ] Add animation to debug markers
- [ ] Export spawn coordinates from UI
- [ ] Multi-layer support (terrain, cities, routes)

## Troubleshooting

### SVG not rendering
- Verify file exists in correct path
- Check `flutter_svg` package is installed
- Ensure asset is declared in `pubspec.yaml`

### Debug markers not showing
- Verify `debugMode: true` is set
- Check spawn data format matches expected structure
- Ensure coordinates are within map bounds (0-1000)

### Map appears blank
- Check asset path in `RegionMapData`
- Verify file extension (.svg) is correct
- Look for errors in console/logs

## Credits

- SVG maps created with clean vector graphics
- Based on official Pokémon game region maps
- Designed for optimal performance and quality
- No copyrighted assets used

## Documentation

For more information about the location system:
- See `REGION_MAPS_IMPLEMENTATION.md` for PNG maps
- See `lib/features/locations/README.md` for general info
- Check individual code files for inline documentation
