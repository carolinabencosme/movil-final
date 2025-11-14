import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

/// Inicializa el cliente de conexión con PokeAPI GraphQL usando Hive para
/// persistir el caché de GraphQL entre ejecuciones.
Future<ValueNotifier<GraphQLClient>> initGraphQLClient() async {
  final HttpLink httpLink = HttpLink(
    'https://beta.pokeapi.co/graphql/v1beta', // endpoint real
  );

  final HiveStore store = await HiveStore.open();

  // Optimized caching policy - use cache first, then network
  final Policies defaultQueryPolicies = Policies(
    fetch: FetchPolicy.cacheFirst, // Use cache first for better performance
    error: ErrorPolicy.all,
    cacheReread: CacheRereadPolicy.mergeOptimistic,
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
          error: ErrorPolicy.all,
          cacheReread: CacheRereadPolicy.ignoreAll,
        ),
      ),
    ),
  );
}
