const String getPokemonTypesQuery = r'''
  query GetPokemonTypes {
    pokemon_v2_type(order_by: {id: asc}) {
      id
      name
    }
    pokemon_v2_generation(order_by: {id: asc}) {
      id
      name
    }
  }
''';
