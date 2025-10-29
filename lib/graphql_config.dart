import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';


/// Inicializa el cliente de conexión con PokeAPI GraphQL
ValueNotifier<GraphQLClient> initGraphQLClient() {
  final HttpLink httpLink = HttpLink(
    'https://beta.pokeapi.co/graphql/v1beta', // endpoint real
  );

  final InMemoryStore store = InMemoryStore();

  final Policies defaultQueryPolicies = Policies(
    fetch: FetchPolicy.networkOnly,
    error: ErrorPolicy.ignore,
    cacheReread: CacheRereadPolicy.ignoreAll,
  );

  return ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: store),
      defaultPolicies: DefaultPolicies(
        watchQuery: defaultQueryPolicies,
        query: defaultQueryPolicies,
        mutate: Policies(
          fetch: FetchPolicy.networkOnly,
          error: ErrorPolicy.none,
          cacheReread: CacheRereadPolicy.ignoreAll,
        ),
      ),
    ),
  );
}
