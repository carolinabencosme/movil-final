# Pokemon Region Maps Implementation

## Overview

This implementation replaces the real-world OpenStreetMap-based location display with fictional Pokemon region maps. The maps are displayed using Flutter's `InteractiveViewer` widget, allowing users to zoom and pan over static region images with markers positioned using X/Y coordinates.

## Key Changes

### 1. Removed Dependencies
- `flutter_map: ^6.0.0` - No longer needed for map display
- `latlong2: ^0.9.0` - Replaced with custom `MapCoordinates` class

### 2. New Files Created

#### Assets
- `assets/maps/kanto.png` - Kanto region map (800x600px placeholder)
- `assets/maps/johto.png` - Johto region map (800x600px placeholder)
- `assets/maps/hoenn.png` - Hoenn region map (800x600px placeholder)
- `assets/maps/sinnoh.png` - Sinnoh region map (800x600px placeholder)
- `assets/maps/unova.png` - Unova region map (800x600px placeholder)
- `assets/maps/kalos.png` - Kalos region map (800x600px placeholder)
- `assets/maps/alola.png` - Alola region map (800x600px placeholder)
- `assets/maps/galar.png` - Galar region map (800x600px placeholder)

**Note:** These are placeholder images with text. Replace them with actual Pokemon region map images.

#### Data Layer
- `lib/features/locations/data/region_map_markers.dart`
  - Contains X/Y coordinate mappings for all major routes and locations in each region
  - Provides helper functions to retrieve markers by region and area name
  - Coordinates are relative to 800x600px images

#### Widget Layer
- `lib/features/locations/widgets/region_map_viewer.dart`
  - Main widget that displays region maps using `InteractiveViewer`
  - Supports zoom (0.8x to 4x) and pan
  - Displays Pokemon-style markers (red circles with white borders)
  - Shows popup when marker is tapped
  - Includes zoom controls (+, -, reset)

### 3. Modified Files

#### Models
- `lib/features/locations/models/pokemon_location.dart`
  - Added `MapCoordinates` class for X/Y positioning
  - Changed `coordinates` field from `LatLng?` to `MapCoordinates?`
  - `LocationsByRegion` now uses `MapCoordinates` instead of `LatLng`

#### Data Services
- `lib/features/locations/data/region_coordinates.dart`
  - Changed from returning `LatLng` to returning `MapCoordinates`
  - All regions now centered at (400, 300) on 800x600px images
  - Removed `latlong2` import

- `lib/features/locations/data/location_service.dart`
  - Removed `latlong2` import
  - No functional changes needed (coordinate system abstracted)

#### Screens
- `lib/features/locations/screens/locations_tab.dart`
  - Changed from single world map to multiple region-specific maps
  - Each region displays its own map with markers
  - Uses `RegionMapViewer` instead of `PokemonLocationMap`

#### Configuration
- `pubspec.yaml`
  - Removed `flutter_map` and `latlong2` dependencies
  - Added `assets/maps/` directory to assets

#### Tests
- `test/locations_test.dart`
  - Updated to use `MapCoordinates` instead of `LatLng`
  - Added tests for `region_map_markers` functionality
  - Removed `latlong2` import

### 4. Deleted Files
- `lib/features/locations/widgets/pokemon_location_map.dart` - Old flutter_map implementation
- `lib/features/locations/widgets/location_marker.dart` - Old marker widget (now integrated into RegionMapViewer)

## How It Works

### Map Display
1. When a Pokemon has location data, the system groups encounters by region
2. For each region, a `RegionMapViewer` widget is created
3. The viewer loads the corresponding PNG image from `assets/maps/{region}.png`
4. Markers are positioned using coordinates from `region_map_markers.dart`

### Coordinate System
- All maps are designed for 800x600px images
- Coordinates are absolute X/Y positions in pixels
- Origin (0,0) is at the top-left corner
- Center of map is at (400, 300)

### Marker Positioning
```dart
// Example marker for Route 1 in Kanto
'route-1': RegionMarker(400, 450, 'Route 1'),
//                       ^    ^
//                       X    Y
```

### User Interaction
- **Pinch/Scroll**: Zoom in/out (0.8x to 4x)
- **Drag**: Pan around the map
- **Tap marker**: Show location details popup
- **+ button**: Zoom in
- **- button**: Zoom out
- **⊙ button**: Reset view to default

## Customization Guide

### Replacing Placeholder Images

1. Obtain high-quality Pokemon region map images (recommended: 800x600px or maintain aspect ratio)
2. Replace files in `assets/maps/`:
   - `kanto.png`
   - `johto.png`
   - `hoenn.png`
   - `sinnoh.png`
   - `unova.png`
   - `kalos.png`
   - `alola.png`
   - `galar.png`

### Adjusting Marker Coordinates

After replacing images, you'll need to adjust marker coordinates in `region_map_markers.dart`:

1. Open your map image in an image editor
2. Note the X/Y pixel coordinates of each location
3. Update the coordinates in `regionMarkers` map
4. If your images are a different size, scale coordinates proportionally

Example:
```dart
'kanto': {
  'route-1': RegionMarker(130, 450, 'Route 1'),  // Update X and Y
  'viridian-forest': RegionMarker(200, 300, 'Viridian Forest'),
  // ... more locations
},
```

### Adding New Regions

To add a new region (e.g., Paldea):

1. Add the map image: `assets/maps/paldea.png`
2. Add coordinates in `region_map_markers.dart`:
```dart
'paldea': {
  'route-1': RegionMarker(x, y, 'Route 1'),
  // ... more locations
},
```
3. Add to `region_coordinates.dart`:
```dart
'paldea': MapCoordinates(400, 300),
```

## Technical Details

### InteractiveViewer Configuration
- **minScale**: 0.8 (can zoom out slightly)
- **maxScale**: 4.0 (can zoom in 4x)
- **boundaryMargin**: 20px padding around edges

### Marker Style
- **Shape**: Circle
- **Color**: Theme primary color (customizable)
- **Border**: 3px white border
- **Icon**: Material Icons `place`
- **Shadow**: 8px blur, 2px offset (12px when selected)
- **Animation**: 200ms scale animation on selection

### Performance Considerations
- Images are loaded as assets (bundled with app)
- Markers are positioned using `Stack` and `Positioned` widgets
- InteractiveViewer handles pan/zoom transformations efficiently
- Only visible markers are rendered (clipping handled by container)

## Migration Notes

### For Developers
If you're migrating from the old OpenStreetMap implementation:

1. **Imports**: Change from `pokemon_location_map` to `region_map_viewer`
2. **Coordinates**: Use `MapCoordinates` instead of `LatLng`
3. **Map Display**: Each region now has its own map view instead of a single world map

### Breaking Changes
- `LatLng` is no longer used in location models
- `PokemonLocationMap` widget has been removed
- Single world map view replaced with per-region maps

## Future Enhancements

Possible improvements:
- [ ] Add region selection dropdown to switch between maps
- [ ] Implement custom marker icons per location type
- [ ] Add heatmap overlay for encounter rates
- [ ] Support for animated routes between locations
- [ ] Pinch-to-zoom gesture improvements
- [ ] Mini-map overview in corner
- [ ] Location search functionality
- [ ] Custom zoom levels per region

## Troubleshooting

### Map image not showing
- Verify image exists in `assets/maps/{region}.png`
- Check `pubspec.yaml` includes `assets/maps/` in assets section
- Run `flutter pub get` to update asset manifest
- Restart app (hot reload may not refresh assets)

### Markers not appearing
- Check region name matches exactly (case-insensitive but must be correct)
- Verify area name is normalized (e.g., "route-1-area" becomes "route-1")
- Ensure coordinates are within image bounds (0-800, 0-600 for default)
- Check `region_map_markers.dart` has entry for that area

### Zoom not working
- Ensure InteractiveViewer is not nested inside another gesture detector
- Check min/max scale values are reasonable
- Verify transformationController is properly initialized

## Resources

- [Flutter InteractiveViewer Documentation](https://api.flutter.dev/flutter/widgets/InteractiveViewer-class.html)
- [Pokemon Region Maps](https://bulbapedia.bulbagarden.net/wiki/Region) - For reference when creating maps
- [PokéAPI Location Data](https://pokeapi.co/docs/v2#locations) - API reference

## Credits

Implementation by: GitHub Copilot
Date: November 2024
