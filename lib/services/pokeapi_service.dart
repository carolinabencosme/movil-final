import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon_model.dart';

class PokeApiService {
  static const String _pokemonUrl =
      'https://pokeapi.co/api/v2/pokemon/ditto';

  Future<Pokemon> fetchPokemon() async {
    final response = await http.get(Uri.parse(_pokemonUrl));

    if (response.statusCode != 200) {
      throw Exception(
          'Error fetching Pokémon data: ${response.statusCode} ${response.reasonPhrase ?? ''}'.trim());
    }

    try {
      final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
      return Pokemon.fromJson(data);
    } catch (error) {
      throw Exception('Error parsing Pokémon data: $error');
    }
  }
}
