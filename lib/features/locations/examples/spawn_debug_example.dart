import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/pokemon_location.dart';
import '../widgets/region_map_viewer.dart';

/// Ejemplo de uso del modo debug para visualizar spawn points en mapas
///
/// Este widget demuestra cómo cargar y visualizar puntos de spawn de prueba
/// sobre los mapas de región usando el modo debug del RegionMapViewer.
class SpawnDebugExample extends StatefulWidget {
  const SpawnDebugExample({super.key});

  @override
  State<SpawnDebugExample> createState() => _SpawnDebugExampleState();
}

class _SpawnDebugExampleState extends State<SpawnDebugExample> {
  List<Map<String, dynamic>>? _debugSpawns;
  bool _isLoading = true;
  String _selectedRegion = 'alola';

  @override
  void initState() {
    super.initState();
    _loadDebugSpawns();
  }

  /// Carga los datos de spawn de prueba desde el archivo JSON
  Future<void> _loadDebugSpawns() async {
    try {
      // Cargar el archivo JSON de prueba
      final jsonString = await rootBundle.loadString(
        'assets/maps/test_spawns/${_selectedRegion}_test.json',
      );
      
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final spawns = data['spawns'] as List<dynamic>;
      
      setState(() {
        _debugSpawns = spawns.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } on FlutterError catch (e) {
      debugPrint('File not found: ${e.message}');
      setState(() {
        _debugSpawns = null;
        _isLoading = false;
      });
    } on FormatException catch (e) {
      debugPrint('Invalid JSON format: ${e.message}');
      setState(() {
        _debugSpawns = null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading spawn data: $e');
      setState(() {
        _debugSpawns = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spawn Debug Mode'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Debug Mode Activo',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Los círculos amarillos numerados representan spawn points de prueba. '
                            'Toca un marcador para ver las coordenadas.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          if (_debugSpawns != null)
                            Text(
                              'Spawns cargados: ${_debugSpawns!.length}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Mapa con debug markers
                  RegionMapViewer(
                    region: _selectedRegion,
                    encounters: const [],
                    height: 400,
                    debugMode: true,
                    debugSpawns: _debugSpawns,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Lista de spawns
                  if (_debugSpawns != null && _debugSpawns!.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Spawn Points',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            ..._debugSpawns!.asMap().entries.map((entry) {
                              final index = entry.key;
                              final spawn = entry.value;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.orange, width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '${spawn['pokemon']} - (${spawn['x']}, ${spawn['y']})',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),
                                    if (spawn['area'] != null)
                                      Text(
                                        spawn['area'],
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
