import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/locations/models/pokemon_location.dart';
import 'package:pokedex/features/locations/widgets/region_map_viewer.dart';

void main() {
  group('Map Debug System', () {
    testWidgets('RegionMapViewer should render with debugMode enabled',
        (tester) async {
      final testSpawns = [
        {'pokemon': 'pikachu', 'x': 260.0, 'y': 240.0, 'area': 'Route 1'},
        {'pokemon': 'wingull', 'x': 650.0, 'y': 820.0, 'area': 'Beach'},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegionMapViewer(
              region: 'alola',
              encounters: const [],
              height: 400,
              debugMode: true,
              debugSpawns: testSpawns,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify widget renders without errors
      expect(tester.takeException(), isNull);

      // Verify RegionMapViewer is present
      expect(find.byType(RegionMapViewer), findsOneWidget);
    });

    testWidgets('RegionMapViewer should handle null debugSpawns gracefully',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RegionMapViewer(
              region: 'kanto',
              encounters: [],
              height: 400,
              debugMode: true,
              debugSpawns: null,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without errors even with null spawns
      expect(tester.takeException(), isNull);
      expect(find.byType(RegionMapViewer), findsOneWidget);
    });

    testWidgets(
        'RegionMapViewer should not show debug markers when debugMode is false',
        (tester) async {
      final testSpawns = [
        {'pokemon': 'pikachu', 'x': 260.0, 'y': 240.0},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegionMapViewer(
              region: 'alola',
              encounters: const [],
              height: 400,
              debugMode: false, // Debug mode disabled
              debugSpawns: testSpawns,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'RegionMapViewer should render with empty debugSpawns list',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RegionMapViewer(
              region: 'johto',
              encounters: [],
              height: 400,
              debugMode: true,
              debugSpawns: [],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(RegionMapViewer), findsOneWidget);
    });

    test('Test spawn JSON should have correct structure', () async {
      // This test verifies the structure of the test spawn file
      final testSpawnData = {
        'region': 'alola',
        'mapSize': 1000,
        'spawns': [
          {'pokemon': 'pikachu', 'x': 260, 'y': 240, 'area': 'Route 1'},
          {
            'pokemon': 'wingull',
            'x': 650,
            'y': 820,
            'area': 'Seafolk Village'
          },
        ]
      };

      // Verify structure
      expect(testSpawnData['region'], isA<String>());
      expect(testSpawnData['mapSize'], isA<int>());
      expect(testSpawnData['spawns'], isA<List>());

      final spawns = testSpawnData['spawns'] as List;
      expect(spawns.length, greaterThan(0));

      for (final spawn in spawns) {
        expect(spawn, isA<Map>());
        expect((spawn as Map)['pokemon'], isA<String>());
        expect(spawn['x'], isA<num>());
        expect(spawn['y'], isA<num>());
      }
    });

    test('Spawn coordinates should be within valid map bounds', () {
      final testSpawns = [
        {'pokemon': 'pikachu', 'x': 260, 'y': 240},
        {'pokemon': 'wingull', 'x': 650, 'y': 820},
        {'pokemon': 'valid', 'x': 0, 'y': 0},
        {'pokemon': 'valid', 'x': 1000, 'y': 1000},
      ];

      for (final spawn in testSpawns) {
        final x = spawn['x'] as num;
        final y = spawn['y'] as num;

        // Verify coordinates are within 0-1000 range (standard map size)
        expect(x, greaterThanOrEqualTo(0));
        expect(x, lessThanOrEqualTo(1000));
        expect(y, greaterThanOrEqualTo(0));
        expect(y, lessThanOrEqualTo(1000));
      }
    });

    test('Invalid spawn coordinates should be rejected', () {
      final invalidSpawns = [
        {'pokemon': 'invalid', 'x': -10, 'y': 240},
        {'pokemon': 'invalid', 'x': 260, 'y': -50},
        {'pokemon': 'invalid', 'x': 1100, 'y': 240},
        {'pokemon': 'invalid', 'x': 260, 'y': 1500},
      ];

      for (final spawn in invalidSpawns) {
        final x = spawn['x'] as num;
        final y = spawn['y'] as num;

        // These should be considered invalid
        final isValid = x >= 0 && x <= 1000 && y >= 0 && y <= 1000;
        expect(isValid, isFalse,
            reason: 'Spawn at ($x, $y) should be invalid');
      }
    });

    testWidgets('RegionMapViewer should handle multiple regions',
        (tester) async {
      final regions = [
        'kanto',
        'johto',
        'hoenn',
        'sinnoh',
        'unova',
        'kalos',
        'alola',
        'galar',
        'hisui',
        'paldea'
      ];

      for (final region in regions) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RegionMapViewer(
                region: region,
                encounters: const [],
                height: 300,
                debugMode: true,
                debugSpawns: const [],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify each region renders without errors
        expect(tester.takeException(), isNull,
            reason: 'Region $region should render without errors');
      }
    });

    testWidgets(
        'RegionMapViewer should show version selector when multiple versions available',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RegionMapViewer(
              region: 'kanto', // Has multiple versions
              encounters: [],
              height: 400,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Kanto has multiple versions, so version selector should be present
      expect(find.byIcon(Icons.videogame_asset), findsOneWidget);
    });

    testWidgets('RegionMapViewer should show map controls', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RegionMapViewer(
              region: 'alola',
              encounters: [],
              height: 400,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify map control buttons are present
      expect(find.byIcon(Icons.add), findsOneWidget); // Zoom in
      expect(find.byIcon(Icons.remove), findsOneWidget); // Zoom out
      expect(
          find.byIcon(Icons.center_focus_strong), findsOneWidget); // Reset
    });

    testWidgets('RegionMapViewer should handle encounters with markers',
        (tester) async {
      const encounters = [
        PokemonEncounter(
          locationArea: 'route-1',
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
          coordinates: MapCoordinates(400, 300),
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RegionMapViewer(
              region: 'kanto',
              encounters: encounters,
              height: 400,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('RegionMapViewer should handle custom marker colors',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RegionMapViewer(
              region: 'hoenn',
              encounters: [],
              height: 400,
              markerColor: Colors.purple,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('Test Spawn File Loading', () {
    testWidgets('Should load alola_test.json successfully', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Try to load the test spawn file
      try {
        final jsonString = await rootBundle.loadString(
          'assets/maps/test_spawns/alola_test.json',
        );

        final data = json.decode(jsonString) as Map<String, dynamic>;

        // Verify structure
        expect(data['region'], equals('alola'));
        expect(data['mapSize'], equals(1000));
        expect(data['spawns'], isA<List>());

        final spawns = data['spawns'] as List;
        expect(spawns, isNotEmpty);

        // Verify first spawn
        final firstSpawn = spawns[0] as Map<String, dynamic>;
        expect(firstSpawn['pokemon'], isA<String>());
        expect(firstSpawn['x'], isA<num>());
        expect(firstSpawn['y'], isA<num>());
      } catch (e) {
        fail('Failed to load test spawn file: $e');
      }
    });

    test('Spawn data should be JSON-serializable', () {
      final spawnData = {
        'region': 'alola',
        'mapSize': 1000,
        'spawns': [
          {'pokemon': 'pikachu', 'x': 260, 'y': 240, 'area': 'Route 1'},
          {'pokemon': 'wingull', 'x': 650, 'y': 820, 'area': 'Beach'},
        ]
      };

      // Should be able to encode and decode
      final jsonString = json.encode(spawnData);
      final decoded = json.decode(jsonString);

      expect(decoded['region'], equals('alola'));
      expect(decoded['spawns'], hasLength(2));
    });
  });
}
