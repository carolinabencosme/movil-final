import 'package:flutter/material.dart';

import 'screens/pokemon_screen.dart';
import 'services/pokeapi_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) : _pokeApiService = PokeApiService();

  final PokeApiService _pokeApiService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PokeDex REST',
      home: PokemonScreen(pokeApiService: _pokeApiService),
    );
  }
}
