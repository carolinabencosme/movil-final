const String getPokemonDetailsQuery = r'''
  query GetPokemonDetails($id: Int!) {
    pokemon_v2_pokemon_by_pk(id: $id) {
      id
      name
      height
      weight
      pokemon_v2_pokemontypes(order_by: {slot: asc}) {
        pokemon_v2_type {
          name
        }
      }
      pokemon_v2_pokemonstats(order_by: {pokemon_v2_stat: {id: asc}}) {
        base_stat
        pokemon_v2_stat {
          name
        }
      }
      pokemon_v2_pokemonabilities(order_by: {slot: asc}) {
        pokemon_v2_ability {
          name
        }
      }
      pokemon_v2_pokemonsprites(limit: 1) {
        sprites
      }
    }
  }
''';
