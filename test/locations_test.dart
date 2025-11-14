import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:pokedex/features/locations/data/region_coordinates.dart';
import 'package:pokedex/features/locations/models/pokemon_location.dart';

void main() {
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
        coordinates: const LatLng(35.4, 138.7),
      );

      expect(location.allVersions, hasLength(2));
      expect(location.allVersions, containsAll(['red', 'blue']));
      expect(location.areaCount, equals(2));
    });
  });
}
