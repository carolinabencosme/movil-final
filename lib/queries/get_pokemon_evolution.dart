const String getPokemonEvolutionQuery = r'''
  query GetPokemonEvolution($pokemonId: Int!) {
    pokemon_v2_pokemon_by_pk(id: $pokemonId) {
      id
      name
      pokemon_v2_pokemonspecy {
        id
        evolution_chain_id
        evolves_from_species_id
        pokemon_v2_evolutionchain {
          id
          pokemon_v2_pokemonspecies(order_by: {order: asc}) {
            id
            name
            order
            evolves_from_species_id
            pokemon_v2_pokemons(limit: 1, order_by: {id: asc}) {
              id
              name
              pokemon_v2_pokemonsprites(limit: 1) {
                sprites
              }
            }
            pokemon_v2_pokemonevolutions {
              id
              min_level
              evolution_trigger_id
              pokemon_v2_evolutiontrigger {
                name
              }
            }
          }
        }
      }
    }
  }
''';
