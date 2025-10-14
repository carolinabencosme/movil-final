import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class PokemonListPage extends StatelessWidget {
  final String query = """
    query GetPokemons {
      pokemon_v2_pokemon(limit: 10) {
        id
        name
        height
        weight
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pokédex GraphQL")),
      body: Query(
        options: QueryOptions(document: gql(query)),
        builder: (result, {fetchMore, refetch}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(child: Text(result.exception.toString()));
          }

          final List pokemons = result.data?['pokemon_v2_pokemon'] ?? [];

          return ListView.builder(
            itemCount: pokemons.length,
            itemBuilder: (context, index) {
              final p = pokemons[index];
              return ListTile(
                leading: CircleAvatar(child: Text(p['id'].toString())),
                title: Text(p['name'].toString().toUpperCase()),
                subtitle: Text('Altura: ${p['height']} | Peso: ${p['weight']}'),
              );
            },
          );
        },
      ),
    );
  }
}
