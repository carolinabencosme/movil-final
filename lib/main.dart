import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_config.dart';
import 'package:pokedex/pokemon_list_page.dart';


void main() async {
  await initHiveForFlutter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final client = initGraphQLClient();

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: CacheProvider(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PokeDex GraphQL',
          home: PokemonListPage(),
        ),
      ),
    );
  }
}
