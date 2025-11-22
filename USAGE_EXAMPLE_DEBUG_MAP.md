# Debug Map System - Usage Example

This document shows how to use the debug spawn visualization system in the Flutter app.

## Quick Start

### 1. Using Existing Debug Example

The easiest way to see the debug system in action:

```dart
import 'package:pokedex/features/locations/examples/spawn_debug_example.dart';

// In your navigation/routing:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const SpawnDebugExample(),
  ),
);
```

### 2. Custom Debug Map Implementation

Create your own debug map screen:

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokedex/features/locations/widgets/region_map_viewer.dart';

class CustomDebugMapScreen extends StatefulWidget {
  const CustomDebugMapScreen({super.key});

  @override
  State<CustomDebugMapScreen> createState() => _CustomDebugMapScreenState();
}

class _CustomDebugMapScreenState extends State<CustomDebugMapScreen> {
  List<Map<String, dynamic>>? _spawns;
  String _currentRegion = 'alola';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSpawns();
  }

  Future<void> _loadSpawns() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/maps/test_spawns/${_currentRegion}_test.json',
      );
      
      final data = json.decode(jsonString);
      setState(() {
        _spawns = (data['spawns'] as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading spawns: $e');
      setState(() {
        _spawns = null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Map - ${_currentRegion.toUpperCase()}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Region selector
            _buildRegionSelector(),
            
            const SizedBox(height: 16),
            
            // Map with debug markers
            Expanded(
              child: RegionMapViewer(
                region: _currentRegion,
                encounters: const [],
                debugMode: true,
                debugSpawns: _spawns,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Spawn list
            if (_spawns != null && _spawns!.isNotEmpty)
              _buildSpawnList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionSelector() {
    final regions = [
      'kanto', 'johto', 'hoenn', 'sinnoh', 'unova',
      'kalos', 'alola', 'galar', 'hisui', 'paldea'
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: regions.map((region) {
          final isSelected = region == _currentRegion;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(region[0].toUpperCase() + region.substring(1)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _currentRegion = region;
                    _loading = true;
                  });
                  _loadSpawns();
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSpawnList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
      child: Card(
        child: ListView.builder(
          itemCount: _spawns!.length,
          itemBuilder: (context, index) {
            final spawn = _spawns![index];
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundColor: Colors.amber,
                child: Text('${index + 1}'),
              ),
              title: Text(spawn['pokemon'] ?? 'Unknown'),
              subtitle: Text(
                'X: ${spawn['x']}, Y: ${spawn['y']}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: spawn['area'] != null
                  ? Text(
                      spawn['area'],
                      style: const TextStyle(fontSize: 11),
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Mode Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🟡 Yellow circles = Test spawn points',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap any marker to see coordinates',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Loaded ${_spawns?.length ?? 0} spawn points',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

## Creating Test Spawn Files

### File Structure

Create JSON files in `assets/maps/test_spawns/`:

```
assets/maps/test_spawns/
├── alola_test.json     ✅ Already exists
├── kanto_test.json     (optional)
├── johto_test.json     (optional)
└── hoenn_test.json     (optional)
```

### JSON Format

```json
{
  "region": "alola",
  "mapSize": 1000,
  "spawns": [
    {
      "pokemon": "pikachu",
      "x": 260,
      "y": 240,
      "area": "Route 1"
    },
    {
      "pokemon": "wingull",
      "x": 650,
      "y": 820,
      "area": "Seafolk Village"
    }
  ]
}
```

### Field Requirements

- `region`: String - Must match the region name (lowercase)
- `mapSize`: Number - Standard is 1000 (matches SVG viewBox)
- `spawns`: Array of spawn objects
  - `pokemon`: String - Pokemon name (any string works for testing)
  - `x`: Number - X coordinate (0-1000)
  - `y`: Number - Y coordinate (0-1000)
  - `area`: String (optional) - Location name for display

## Coordinate System

All SVG maps use a **1000×1000** coordinate system:

```
(0,0)                                (1000,0)
  ┌──────────────────────────────────┐
  │                                  │
  │                                  │
  │         SVG MAP AREA             │
  │        1000 x 1000               │
  │                                  │
  │                                  │
  └──────────────────────────────────┘
(0,1000)                          (1000,1000)
```

### Finding Coordinates

To find the right coordinates for spawns:

1. **Use image editing software**: Open the SVG in Inkscape or Illustrator
2. **Enable ruler/grid**: Most tools show X,Y when hovering
3. **Click locations**: Note the X,Y coordinates
4. **Add to JSON**: Use those coordinates in your test file

### Example Coordinates for Common Locations

**Kanto Map:**
- Pallet Town: ~(400, 850)
- Viridian City: ~(350, 750)
- Pewter City: ~(350, 650)
- Cerulean City: ~(450, 550)

**Alola Map (Melemele Island):**
- Route 1: ~(260, 240)
- Hau'oli City: ~(200, 300)
- Ten Carat Hill: ~(430, 360)

## Debug Marker Features

### Visual Indicators

- **Yellow circles** with numbers (1, 2, 3...)
- **Orange border** for visibility
- **Shadow effect** for depth
- **Tap to interact** - Shows pokemon name and coordinates

### Interactive Features

1. **Zoom controls**: +/- buttons to zoom in/out
2. **Pan**: Drag to move around the map
3. **Reset**: Button to reset view to default
4. **Tap markers**: Shows snackbar with spawn info

## Integration with Real Data

Once you have real Pokemon encounter data, switch from debug mode:

```dart
// Debug mode (test data)
RegionMapViewer(
  region: 'alola',
  encounters: const [],
  debugMode: true,          // Show test spawns
  debugSpawns: testSpawns,
)

// Production mode (real data)
RegionMapViewer(
  region: 'alola',
  encounters: realEncounters,  // Actual Pokemon locations
  debugMode: false,             // Hide test spawns
)
```

## Tips & Best Practices

### 1. Testing Multiple Regions

Create a test file for each region you're actively developing:

```dart
Future<void> _loadTestData(String region) async {
  try {
    final json = await rootBundle.loadString(
      'assets/maps/test_spawns/${region}_test.json',
    );
    return jsonDecode(json);
  } catch (e) {
    // Return sample data if file doesn't exist
    return {
      'region': region,
      'mapSize': 1000,
      'spawns': [
        {'pokemon': 'test', 'x': 500, 'y': 500}
      ]
    };
  }
}
```

### 2. Coordinate Validation

Always validate coordinates are within bounds:

```dart
bool isValidCoordinate(num x, num y, {num maxSize = 1000}) {
  return x >= 0 && x <= maxSize && y >= 0 && y <= maxSize;
}

// Filter invalid spawns
final validSpawns = spawns.where((spawn) {
  return isValidCoordinate(spawn['x'], spawn['y']);
}).toList();
```

### 3. Dynamic Spawn Loading

Load spawns dynamically based on current map version:

```dart
String _getTestFileName(String region, String version) {
  // Load version-specific test data if available
  return 'assets/maps/test_spawns/${region}_${version}_test.json';
}
```

### 4. Debugging Tips

- Start with 2-3 spawn points per region
- Place them in well-known locations (cities, routes)
- Use descriptive Pokemon names for testing
- Add area names to help identify locations

## Troubleshooting

### Spawns Not Showing

1. Check `debugMode: true` is set
2. Verify `debugSpawns` is not null
3. Check coordinates are 0-1000 range
4. Ensure JSON file is in correct location

### Wrong Positions

1. Verify SVG viewBox is "0 0 1000 1000"
2. Check coordinate system matches
3. Test with known locations first

### JSON Loading Errors

1. Validate JSON syntax
2. Check file path in pubspec.yaml
3. Run `flutter pub get` after changes
4. Clear build cache: `flutter clean`

## Advanced Usage

### Custom Marker Styles

Override debug marker appearance:

```dart
// This requires modifying RegionMapViewer widget
// Current markers are yellow circles with numbers
// You can customize in region_map_viewer.dart:
// - _buildDebugSpawnMarkers() method
```

### Multiple Test Sets

Create different test scenarios:

```
assets/maps/test_spawns/
├── alola_common.json     (Common Pokemon)
├── alola_rare.json       (Rare Pokemon)
├── alola_legendary.json  (Legendary locations)
```

### Export Coordinates

Create a helper to export clicked coordinates:

```dart
void _onMapTap(TapUpDetails details) {
  final x = details.localPosition.dx;
  final y = details.localPosition.dy;
  
  debugPrint('Coordinates: ($x, $y)');
  // Copy to clipboard or save to file
}
```

## Resources

- **Existing Implementation**: `lib/features/locations/examples/spawn_debug_example.dart`
- **Widget Source**: `lib/features/locations/widgets/region_map_viewer.dart`
- **Test Data**: `assets/maps/test_spawns/alola_test.json`
- **Tests**: `test/map_debug_system_test.dart`

## Next Steps

1. ✅ Basic debug system is working
2. Create test spawn files for other regions (optional)
3. Test with real Pokemon encounter data
4. Fine-tune marker positions
5. Add more spawn points as needed
