import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';


/// Inicializa el cliente de conexión con PokeAPI GraphQL
ValueNotifier<GraphQLClient> initGraphQLClient() {
  final HttpLink httpLink = HttpLink(
    'https://beta.pokeapi.co/graphql/v1beta', // endpoint real
  );

  return ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    ),
  );
}
