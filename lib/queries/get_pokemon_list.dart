const String getPokemonListQuery = r'''
  query GetPokemons {
    pokemon_v2_pokemon(limit: 50, order_by: {id: asc}) {
      id
      name
      pokemon_v2_pokemonsprites(limit: 1) {
        sprites
      }
    }
  }
''';
