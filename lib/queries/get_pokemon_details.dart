const String getPokemonDetailsQuery = r'''
  query GetPokemonDetails($name: String!) {
    pokemon_v2_pokemon(where: {name: {_eq: $name}}, limit: 1) {
      id
      name
      height
      weight
      pokemon_v2_pokemontypes {
        pokemon_v2_type {
          name
        }
      }
      pokemon_v2_pokemonsprites(limit: 1) {
        sprites
      }
    }
  }
''';
