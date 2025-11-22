# Pokemon Region Maps Implementation

## Overview

This implementation provides comprehensive Pokémon region maps covering **all official game versions** from Generation I through IX. The maps are displayed using Flutter's `InteractiveViewer` widget, allowing users to zoom and pan over beautifully styled region images with markers positioned using X/Y coordinates.

### Features
- ✅ **21 Total Maps** across 10 regions
- ✅ **Multiple Game Versions** per region (RBY, FRLG, Let's Go, etc.)
- ✅ **Interactive Version Selector** - Switch between game versions seamlessly
- ✅ **Authentic Styling** - Maps use game-accurate color palettes
- ✅ **Responsive Design** - Works on all screen sizes
- ✅ **Full Zoom/Pan Support** - Explore every detail

## Key Changes

### 1. Removed Dependencies
- `flutter_map: ^6.0.0` - No longer needed for map display
- `latlong2: ^0.9.0` - Replaced with custom `MapCoordinates` class

### 2. New Files Created

#### Assets (21 Map Images)

**Kanto (3 maps)**
- `assets/maps/regions/kanto/kanto_rby.png` - Red/Blue/Yellow (1024x768px)
- `assets/maps/regions/kanto/kanto_frlg.png` - FireRed/LeafGreen (1024x768px)
- `assets/maps/regions/kanto/kanto_letsgo.png` - Let's Go Pikachu/Eevee (1024x768px)

**Johto (2 maps)**
- `assets/maps/regions/johto/johto_gsc.png` - Gold/Silver/Crystal (1200x900px)
- `assets/maps/regions/johto/johto_hgss.png` - HeartGold/SoulSilver (1200x900px)

**Hoenn (2 maps)**
- `assets/maps/regions/hoenn/hoenn_rse.png` - Ruby/Sapphire/Emerald (1500x1100px)
- `assets/maps/regions/hoenn/hoenn_oras.png` - Omega Ruby/Alpha Sapphire (1500x1100px)

**Sinnoh (2 maps)**
- `assets/maps/regions/sinnoh/sinnoh_dpp.png` - Diamond/Pearl/Platinum (1400x1000px)
- `assets/maps/regions/sinnoh/sinnoh_bdsp.png` - Brilliant Diamond/Shining Pearl (1400x1000px)

**Unova (2 maps)**
- `assets/maps/regions/unova/unova_bw.png` - Black/White (1600x1200px)
- `assets/maps/regions/unova/unova_b2w2.png` - Black 2/White 2 (1600x1200px)

**Kalos (1 map)**
- `assets/maps/regions/kalos/kalos_xy.png` - X/Y (1800x1400px)

**Alola (2 maps)**
- `assets/maps/regions/alola/alola_sm.png` - Sun/Moon (1600x1200px)
- `assets/maps/regions/alola/alola_usum.png` - Ultra Sun/Ultra Moon (1600x1200px)

**Galar (3 maps)**
- `assets/maps/regions/galar/galar_swsh.png` - Sword/Shield (2000x1500px)
- `assets/maps/regions/galar/galar_isle_of_armor.png` - The Isle of Armor (1500x1200px)
- `assets/maps/regions/galar/galar_crown_tundra.png` - The Crown Tundra (1500x1200px)

**Paldea (3 maps)**
- `assets/maps/regions/paldea/paldea_sv.png` - Scarlet/Violet (2200x1600px)
- `assets/maps/regions/paldea/paldea_teal_mask.png` - The Teal Mask (1800x1400px)
- `assets/maps/regions/paldea/paldea_indigo_disk.png` - The Indigo Disk (1800x1400px)

**Hisui (1 map)**
- `assets/maps/regions/hisui/hisui_legends.png` - Legends: Arceus (2000x1500px)

**Notas de assets actualizados**
- Se retiraron los SVG vectoriales provisionales (`*_vector.svg`) en favor de las capturas oficiales de cada juego/DLC.
- Las dimensiones de `RegionMapData.mapSize` reflejan los píxeles reales de cada PNG (obtenidos directamente de los archivos en `assets/maps/regions/**`).
- Los marcadores ahora se escalan en tiempo de ejecución usando el tamaño exacto del mapa seleccionado, evitando descuadres al alternar entre versiones con resoluciones distintas (ej. Paldea base 2200x1600 → DLC 1800x1400).

**Map Features:**
- Authentic Pokémon color palettes (grass, water, mountains, cities)
- Geographical features (routes, cities, forests, water bodies)
- Clear visual distinction between game versions
- Optimized PNG format for fast loading

#### Data Layer

**`lib/features/locations/data/region_map_data.dart`** (UPDATED)
- Extended to support multiple game versions per region
- New structure: `regionMapsByVersion` - Maps organized by region and game version
- Helper functions:
  - `getRegionMapVersions(regionName)` - Get all versions for a region
  - `getRegionMapByVersion(region, gameVersion)` - Get specific version
  - `getRegionMapVersionCount(regionName)` - Count available versions
- Backward compatible with existing `regionMaps` map

**`lib/features/locations/data/region_map_markers.dart`**
- Contains X/Y coordinate mappings for all major routes and locations
- Provides helper functions to retrieve markers by region and area name
- Coordinates are scaled relative to each map's dimensions

#### Widget Layer

**`lib/features/locations/widgets/region_map_viewer.dart`** (UPDATED)
- **NEW:** Game version selector with chips UI
- Automatically shows version selector when multiple versions available
- Displays region maps using `InteractiveViewer`
- Supports zoom (0.8x to 4x) and pan
- Displays Pokémon-style markers (red circles with white borders)
- Shows popup when marker is tapped
- Includes zoom controls (+, -, reset)
- Resets view when switching between versions

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
1. When a Pokémon has location data, the system groups encounters by region
2. For each region, a `RegionMapViewer` widget is created
3. The viewer loads all available game versions for that region
4. If multiple versions exist, a version selector appears above the map
5. User can switch between versions by tapping version chips
6. The viewer loads the corresponding PNG image from `assets/maps/regions/{region}/{version}.png`
7. Markers are positioned using coordinates from `region_map_markers.dart`

### Version Selection
- **Automatic Detection:** Widget automatically detects available versions per region
- **Chip Interface:** Clean, modern chip-based selector
- **State Management:** Selection resets zoom and marker highlights
- **Single Version:** Selector hidden when only one version available
- **Smooth Transitions:** Instant switching between versions

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

## Map Generation

### Current Implementation

All maps were generated using Python with the Pillow library. The generation script creates:
- **Authentic color palettes** matching official Pokémon games
- **Geographical features:**
  - Grass (light and dark green)
  - Water bodies (blue, deep blue)
  - Mountains (brown, with highlights)
  - Cities (red buildings with roofs)
  - Routes (beige pathways)
  - Forests (dark green)
  - Special features (caves, ice, lava)

### Map Styles by Generation

**Kanto Maps:**
- **RBY:** Classic Game Boy style with simple shapes
- **FRLG:** Enhanced GBA style with better shading
- **Let's Go:** Modern 3D-inspired style with vibrant colors

**Other Regions:**
- Procedurally generated with region-specific seeds
- Unique landmass shapes per region
- Varied geographical features

### Enhancing Maps

To replace with higher-quality maps:

1. Source authentic map images from official games or fan resources
2. Maintain or exceed current dimensions for each region
3. Replace files in `assets/maps/regions/{region}/{version}.png`
4. Update `region_map_data.dart` if dimensions change
5. Adjust marker coordinates in `region_map_markers.dart` if needed

## Customization Guide

### Adding New Map Versions

To add a new game version to an existing region:

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

### Adding New Map Versions

To add a new game version to an existing region:

1. **Create the map image:**
   ```
   assets/maps/regions/{region}/{region}_{version}.png
   ```

2. **Update `region_map_data.dart`:**
   ```dart
   'regionName': [
     // ... existing versions
     const RegionMapData(
       region: 'regionName',
       assetPath: 'assets/maps/regions/regionName/regionName_newversion.png',
       mapSize: Size(width, height),
       gameVersion: 'New Game Version',
     ),
   ],
   ```

3. **Update marker coordinates** if map layout differs

### Adding New Regions

To add a completely new region:

1. **Create directory structure:**
   ```
   assets/maps/regions/newregion/
   ```

2. **Add map images:**
   ```
   assets/maps/regions/newregion/newregion_version1.png
   assets/maps/regions/newregion/newregion_version2.png
   ```

3. **Add to `region_map_data.dart`:**
   ```dart
   'newregion': [
     const RegionMapData(
       region: 'newregion',
       assetPath: 'assets/maps/regions/newregion/newregion_version1.png',
       mapSize: Size(width, height),
       gameVersion: 'Version 1',
     ),
   ],
   ```

4. **Add marker coordinates in `region_map_markers.dart`:**
   ```dart
   'newregion': {
     'route-1': RegionMarker(x, y, 'Route 1'),
     'city-name': RegionMarker(x, y, 'City Name'),
     // ... more locations
   },
   ```

5. **Add to `region_coordinates.dart`:**
   ```dart
   'newregion': MapCoordinates(centerX, centerY),
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

## Complete Map List

### Generation I - Kanto
| Game Version | File Path | Dimensions |
|-------------|-----------|------------|
| Red/Blue/Yellow | `kanto/kanto_rby.png` | 1024x768 |
| FireRed/LeafGreen | `kanto/kanto_frlg.png` | 1024x768 |
| Let's Go Pikachu/Eevee | `kanto/kanto_letsgo.png` | 1024x768 |

### Generation II - Johto
| Game Version | File Path | Dimensions |
|-------------|-----------|------------|
| Gold/Silver/Crystal | `johto/johto_gsc.png` | 1200x900 |
| HeartGold/SoulSilver | `johto/johto_hgss.png` | 1200x900 |

### Generation III - Hoenn
| Game Version | File Path | Dimensions |
|-------------|-----------|------------|
| Ruby/Sapphire/Emerald | `hoenn/hoenn_rse.png` | 1500x1100 |
| Omega Ruby/Alpha Sapphire | `hoenn/hoenn_oras.png` | 1500x1100 |

### Generation IV - Sinnoh
| Game Version | File Path | Dimensions |
|-------------|-----------|------------|
| Diamond/Pearl/Platinum | `sinnoh/sinnoh_dpp.png` | 1400x1000 |
| Brilliant Diamond/Shining Pearl | `sinnoh/sinnoh_bdsp.png` | 1400x1000 |

### Generation V - Unova
| Game Version | File Path | Dimensions |
|-------------|-----------|------------|
| Black/White | `unova/unova_bw.png` | 1600x1200 |
| Black 2/White 2 | `unova/unova_b2w2.png` | 1600x1200 |

### Generation VI - Kalos
| Game Version | File Path | Dimensions |
|-------------|-----------|------------|
| X/Y | `kalos/kalos_xy.png` | 1800x1400 |

### Generation VII - Alola
| Game Version | File Path | Dimensions |
|-------------|-----------|------------|
| Sun/Moon | `alola/alola_sm.png` | 1600x1200 |
| Ultra Sun/Ultra Moon | `alola/alola_usum.png` | 1600x1200 |

### Generation VIII - Galar
| Game Version | File Path | Dimensions |
|-------------|-----------|------------|
| Sword/Shield | `galar/galar_swsh.png` | 2000x1500 |
| The Isle of Armor | `galar/galar_isle_of_armor.png` | 1500x1200 |
| The Crown Tundra | `galar/galar_crown_tundra.png` | 1500x1200 |

### Generation VIII - Hisui
| Game Version | File Path | Dimensions |
|-------------|-----------|------------|
| Legends: Arceus | `hisui/hisui_legends.png` | 2000x1500 |

### Generation IX - Paldea
| Game Version | File Path | Dimensions |
|-------------|-----------|------------|
| Scarlet/Violet | `paldea/paldea_sv.png` | 2200x1600 |
| The Teal Mask | `paldea/paldea_teal_mask.png` | 1800x1400 |
| The Indigo Disk | `paldea/paldea_indigo_disk.png` | 1800x1400 |

**Total: 21 maps across 10 regions**

## Future Enhancements

Possible improvements:
- [x] ~~Add region selection dropdown to switch between maps~~ ✅ IMPLEMENTED
- [x] ~~Support multiple game versions per region~~ ✅ IMPLEMENTED
- [ ] Implement custom marker icons per location type
- [ ] Add heatmap overlay for encounter rates
- [ ] Support for animated routes between locations
- [ ] Pinch-to-zoom gesture improvements
- [ ] Mini-map overview in corner
- [ ] Location search functionality
- [ ] Custom zoom levels per region
- [ ] SVG-based maps for infinite scaling
- [ ] More detailed hand-drawn maps for each version

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
