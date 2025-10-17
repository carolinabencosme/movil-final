import 'package:flutter/material.dart';

import '../models/pokemon_model.dart';
import '../services/pokeapi_service.dart';

class PokemonScreen extends StatelessWidget {
  PokemonScreen({super.key}) : _pokemonFuture = PokeApiService().fetchPokemon();

  final Future<Pokemon> _pokemonFuture;

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1);
  }

  String _formatTypes(List<String> types) {
    if (types.isEmpty) {
      return 'Desconocido';
    }

    return types
        .map((type) => type.isEmpty ? type : _capitalize(type))
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon (REST)'),
      ),
      body: FutureBuilder<Pokemon>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Ocurrió un error al cargar el Pokémon.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          final pokemon = snapshot.data;

          if (pokemon == null) {
            return const Center(
              child: Text('No se encontró información del Pokémon.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    '🧬 Nombre: ${_capitalize(pokemon.name)}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Image.network(
                    pokemon.spriteUrl,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '📏 Altura: ${pokemon.height}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '⚖️ Peso: ${pokemon.weight}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '🌈 Tipo: ${_formatTypes(pokemon.types)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
