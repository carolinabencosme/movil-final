import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/locations/data/region_coordinates.dart';
import 'package:pokedex/features/locations/data/region_map_data.dart';
import 'package:pokedex/features/locations/data/region_map_markers.dart';
import 'package:pokedex/features/locations/models/pokemon_location.dart';
import 'package:pokedex/features/locations/widgets/region_map_viewer.dart';

void main() {
  group('Region Map Data', () {
    test('should return map data for known regions', () {
      expect(getRegionMapData('kanto'), isNotNull);
      expect(getRegionMapData('johto'), isNotNull);
      expect(getRegionMapData('hoenn'), isNotNull);
      expect(getRegionMapData('sinnoh'), isNotNull);
      expect(getRegionMapData('unova'), isNotNull);
      expect(getRegionMapData('kalos'), isNotNull);
      expect(getRegionMapData('alola'), isNotNull);
      expect(getRegionMapData('galar'), isNotNull);
      expect(getRegionMapData('paldea'), isNotNull);
    });

    test('should have correct asset paths', () {
      final kantoData = getRegionMapData('kanto');
      expect(kantoData?.assetPath, contains('assets/maps/regions/kanto/'));
      expect(kantoData?.gameVersion, isNotEmpty);
    });

    test('should have valid map sizes', () {
      final kantoData = getRegionMapData('kanto');
      expect(kantoData?.mapSize.width, greaterThan(0));
      expect(kantoData?.mapSize.height, greaterThan(0));
    });

    test('should return null for unknown regions', () {
      expect(getRegionMapData('unknown-region'), isNull);
    });

    test('should check if region has map data', () {
      expect(hasRegionMapData('kanto'), isTrue);
      expect(hasRegionMapData('unknown-region'), isFalse);
    });

    test('should list available region maps', () {
      final regions = getAvailableRegionMaps();
      expect(regions, isNotEmpty);
      expect(regions.length, greaterThanOrEqualTo(10));
      expect(regions, contains('kanto'));
      expect(regions, contains('paldea'));
      expect(regions, contains('hisui'));
    });

    test('should return multiple versions for a region', () {
      final kantoVersions = getRegionMapVersions('kanto');
      expect(kantoVersions, isNotEmpty);
      expect(kantoVersions.length, equals(4)); // RBY, FRLG, Let's Go, Vector

      final johtoVersions = getRegionMapVersions('johto');
      expect(johtoVersions.length, equals(3)); // GSC, HGSS, Vector

      final galarVersions = getRegionMapVersions('galar');
      expect(galarVersions.length, equals(4)); // SwSh, IoA, CT, Vector
    });

    test('should return empty list for unknown region versions', () {
      final unknownVersions = getRegionMapVersions('unknown-region');
      expect(unknownVersions, isEmpty);
    });

    test('should get specific map by version', () {
      final kantoFRLG = getRegionMapByVersion('kanto', 'FireRed/LeafGreen');
      expect(kantoFRLG, isNotNull);
      expect(kantoFRLG?.gameVersion, equals('FireRed/LeafGreen'));
      expect(kantoFRLG?.region, equals('kanto'));
      
      final kantoLetsGo = getRegionMapByVersion('kanto', "Let's Go Pikachu/Eevee");
      expect(kantoLetsGo, isNotNull);
      expect(kantoLetsGo?.gameVersion, equals("Let's Go Pikachu/Eevee"));
    });

    test('should return null for non-existent version', () {
      final nonExistent = getRegionMapByVersion('kanto', 'Crystal');
      expect(nonExistent, isNull);
    });

    test('should count versions correctly', () {
      expect(getRegionMapVersionCount('kanto'), equals(4));
      expect(getRegionMapVersionCount('johto'), equals(3));
      expect(getRegionMapVersionCount('kalos'), equals(2));
      expect(getRegionMapVersionCount('hisui'), equals(2));
      expect(getRegionMapVersionCount('unknown'), equals(0));
    });

    test('should include Hisui region', () {
      expect(getRegionMapData('hisui'), isNotNull);
      final hisuiVersions = getRegionMapVersions('hisui');
      expect(hisuiVersions.length, equals(2));
      expect(hisuiVersions.first.gameVersion, equals('Legends: Arceus'));
    });

    test('should have all Paldea DLC maps', () {
      final paldeaVersions = getRegionMapVersions('paldea');
      expect(paldeaVersions.length, equals(4));

      final versionNames = paldeaVersions.map((v) => v.gameVersion).toList();
      expect(versionNames, contains('Scarlet/Violet'));
      expect(versionNames, contains('The Teal Mask'));
      expect(versionNames, contains('The Indigo Disk'));
    });

    test('should have all Galar DLC maps', () {
      final galarVersions = getRegionMapVersions('galar');
      expect(galarVersions.length, equals(4));
      
      final versionNames = galarVersions.map((v) => v.gameVersion).toList();
      expect(versionNames, contains('Sword/Shield'));
      expect(versionNames, contains('The Isle of Armor'));
      expect(versionNames, contains('The Crown Tundra'));
    });
  });

  group('Region Coordinates', () {
    test('should return coordinates for known regions', () {
      expect(getRegionCoordinates('kanto'), isNotNull);
      expect(getRegionCoordinates('johto'), isNotNull);
      expect(getRegionCoordinates('hoenn'), isNotNull);
      expect(getRegionCoordinates('sinnoh'), isNotNull);
      expect(getRegionCoordinates('unova'), isNotNull);
      expect(getRegionCoordinates('kalos'), isNotNull);
      expect(getRegionCoordinates('alola'), isNotNull);
      expect(getRegionCoordinates('galar'), isNotNull);
      expect(getRegionCoordinates('paldea'), isNotNull);
    });

    test('should return null for unknown regions', () {
      expect(getRegionCoordinates('unknown-region'), isNull);
      expect(getRegionCoordinates(''), isNull);
    });

    test('should be case-insensitive', () {
      expect(getRegionCoordinates('Kanto'), isNotNull);
      expect(getRegionCoordinates('JOHTO'), isNotNull);
      expect(getRegionCoordinates('  hoenn  '), isNotNull);
    });

    test('should correctly identify regions with coordinates', () {
      expect(hasRegionCoordinates('kanto'), isTrue);
      expect(hasRegionCoordinates('unknown-region'), isFalse);
    });

    test('should return list of available regions', () {
      final regions = getAvailableRegions();
      expect(regions, isNotEmpty);
      expect(regions.length, greaterThanOrEqualTo(9));
      expect(regions, contains('kanto'));
      expect(regions, contains('johto'));
    });
  });

  group('Region map assets bundle', () {
    testWidgets('asset manifest includes all defined map assets', (tester) async {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifest = jsonDecode(manifestContent) as Map<String, dynamic>;

      final missingAssets = <String>[];

      for (final regionEntry in regionMapsByVersion.values) {
        for (final map in regionEntry) {
          if (!manifest.containsKey(map.assetPath)) {
            missingAssets.add(map.assetPath);
          }
        }
      }

      expect(
        missingAssets,
        isEmpty,
        reason: 'Missing map assets in manifest: ${missingAssets.join(', ')}',
      );
    });

    testWidgets('RegionMapViewer renders Kanto map without errorBuilder', (tester) async {
      const encounters = [
        PokemonEncounter(
          locationArea: 'pallet-town-area',
          versionDetails: [
            EncounterVersionDetail(
              version: 'red',
              maxChance: 100,
              encounterDetails: [
                EncounterDetail(
                  chance: 100,
                  method: 'walk',
                ),
              ],
            ),
          ],
          coordinates: MapCoordinates(100, 100),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegionMapViewer(
              region: 'kanto',
              encounters: encounters,
              height: 200,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Imagen del mapa no disponible'), findsNothing);

      final image = tester.widget<Image>(find.byType(Image));
      final assetImage = image.image as AssetImage;
      expect(assetImage.assetName, startsWith('assets/maps/regions/kanto/'));
    });
  });

  group('PokemonEncounter Model', () {
    test('should create from JSON correctly', () {
      final json = {
        'location_area': {
          'name': 'route-1-area',
          'url': 'https://pokeapi.co/api/v2/location-area/1/'
        },
        'version_details': [
          {
            'version': {'name': 'red', 'url': ''},
            'max_chance': 50,
            'encounter_details': [
              {
                'chance': 50,
                'method': {'name': 'walk', 'url': ''},
                'min_level': 2,
                'max_level': 5
              }
            ]
          }
        ]
      };

      final encounter = PokemonEncounter.fromJson(json);
      expect(encounter.locationArea, equals('route-1-area'));
      expect(encounter.versionDetails, hasLength(1));
      expect(encounter.versionDetails.first.version, equals('red'));
    });

    test('should handle missing fields gracefully', () {
      final json = {
        'location_area': null,
        'version_details': []
      };

      final encounter = PokemonEncounter.fromJson(json);
      expect(encounter.locationArea, equals('unknown'));
      expect(encounter.versionDetails, isEmpty);
    });

    test('should format display name correctly', () {
      final json = {
        'location_area': {
          'name': 'route-1-area',
          'url': ''
        },
        'version_details': []
      };

      final encounter = PokemonEncounter.fromJson(json);
      expect(encounter.displayName, equals('Route 1 Area'));
    });

    test('should extract all versions', () {
      final json = {
        'location_area': {'name': 'test', 'url': ''},
        'version_details': [
          {
            'version': {'name': 'red', 'url': ''},
            'max_chance': 50,
            'encounter_details': []
          },
          {
            'version': {'name': 'blue', 'url': ''},
            'max_chance': 50,
            'encounter_details': []
          }
        ]
      };

      final encounter = PokemonEncounter.fromJson(json);
      expect(encounter.allVersions, hasLength(2));
      expect(encounter.allVersions, containsAll(['red', 'blue']));
    });
  });

  group('EncounterVersionDetail Model', () {
    test('should format display version correctly', () {
      final json = {
        'version': {'name': 'heart-gold', 'url': ''},
        'max_chance': 50,
        'encounter_details': []
      };

      final detail = EncounterVersionDetail.fromJson(json);
      expect(detail.displayVersion, equals('Heart Gold'));
    });
  });

  group('EncounterDetail Model', () {
    test('should format display method correctly', () {
      final json = {
        'chance': 50,
        'method': {'name': 'old-rod', 'url': ''},
        'min_level': 5,
        'max_level': 10
      };

      final detail = EncounterDetail.fromJson(json);
      expect(detail.displayMethod, equals('Old Rod'));
    });

    test('should format level range correctly', () {
      final json1 = {
        'chance': 50,
        'method': {'name': 'walk', 'url': ''},
        'min_level': 5,
        'max_level': 10
      };
      final detail1 = EncounterDetail.fromJson(json1);
      expect(detail1.levelRange, equals('Lv. 5-10'));

      final json2 = {
        'chance': 50,
        'method': {'name': 'walk', 'url': ''},
        'min_level': 7,
        'max_level': 7
      };
      final detail2 = EncounterDetail.fromJson(json2);
      expect(detail2.levelRange, equals('Lv. 7'));

      final json3 = {
        'chance': 50,
        'method': {'name': 'walk', 'url': ''},
      };
      final detail3 = EncounterDetail.fromJson(json3);
      expect(detail3.levelRange, equals('Unknown level'));
    });
  });

  group('RegionMapMarkers', () {
    test('should return marker for known areas', () {
      final marker = getRegionMarker('kanto', 'route-1');
      expect(marker, isNotNull);
      expect(marker?.area, equals('Route 1'));
      expect(marker?.game, isNotEmpty);
    });

    test('should include game version information', () {
      final kantoMarker = getRegionMarker('kanto', 'viridian-forest');
      expect(kantoMarker?.game, isNotEmpty);
      
      final johtoMarker = getRegionMarker('johto', 'route-29');
      expect(johtoMarker?.game, isNotEmpty);
    });

    test('should handle area name normalization', () {
      final marker1 = getRegionMarker('kanto', 'route-1-area');
      final marker2 = getRegionMarker('kanto', 'route-1');
      expect(marker1, isNotNull);
      expect(marker2, isNotNull);
      expect(marker1?.x, equals(marker2?.x));
      expect(marker1?.y, equals(marker2?.y));
    });

    test('should return null for unknown regions', () {
      final marker = getRegionMarker('unknown-region', 'route-1');
      expect(marker, isNull);
    });

    test('should return null for unknown areas', () {
      final marker = getRegionMarker('kanto', 'unknown-area');
      expect(marker, isNull);
    });

    test('should get all markers for a region', () {
      final markers = getRegionMarkers('kanto');
      expect(markers, isNotNull);
      expect(markers, isNotEmpty);
      expect(markers?['route-1'], isNotNull);
    });

    test('should check if region has markers', () {
      expect(hasRegionMarkers('kanto'), isTrue);
      expect(hasRegionMarkers('unknown-region'), isFalse);
    });

    test('should return default marker', () {
      final marker = getDefaultRegionMarker('test-region');
      expect(marker.x, equals(400));
      expect(marker.y, equals(300));
    });
  });

  group('LocationsByRegion Model', () {
    test('should aggregate versions from all encounters', () {
      final encounters = [
        PokemonEncounter.fromJson({
          'location_area': {'name': 'area-1', 'url': ''},
          'version_details': [
            {
              'version': {'name': 'red', 'url': ''},
              'max_chance': 50,
              'encounter_details': []
            }
          ]
        }),
        PokemonEncounter.fromJson({
          'location_area': {'name': 'area-2', 'url': ''},
          'version_details': [
            {
              'version': {'name': 'blue', 'url': ''},
              'max_chance': 50,
              'encounter_details': []
            }
          ]
        }),
      ];

      final location = LocationsByRegion(
        region: 'kanto',
        encounters: encounters,
        coordinates: const MapCoordinates(400, 300),
      );

      expect(location.allVersions, hasLength(2));
      expect(location.allVersions, containsAll(['red', 'blue']));
      expect(location.areaCount, equals(2));
    });
  });
}
