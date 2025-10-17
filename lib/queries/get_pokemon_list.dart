const String getPokemonListQuery = r'''
  query GetPokemons {
    pokemon_v2_pokemon(limit: 10) {
      id
      name
      height
      weight
    }
  }
''';
