const String getPokemonDetailsQuery = r'''
  query GetPokemonDetails($id: Int!, $languageId: Int!) {
    pokemon_v2_pokemon_by_pk(id: $id) {
      id
      name
      height
      weight
      base_experience
      pokemon_v2_pokemonspecy {
        id
        name
        capture_rate
        pokemon_v2_pokemonspeciesnames(
          where: {language_id: {_eq: $languageId}}
          limit: 1
        ) {
          genus
        }
        pokemon_v2_evolutionchain {
          id
          pokemon_v2_pokemonspecies(order_by: {order: asc}) {
            id
            name
            order
            evolves_from_species_id
            pokemon_v2_pokemonspeciesnames(
              where: {language_id: {_eq: $languageId}}
              limit: 1
            ) {
              name
            }
            pokemon_v2_pokemonevolutions {
              min_level
              min_happiness
              min_affection
              min_beauty
              time_of_day
              gender_id
              relative_physical_stats
              pokemon_v2_evolutiontrigger {
                name
              }
              pokemon_v2_item {
                name
              }
              pokemon_v2_move {
                name
              }
              pokemon_v2_location {
                name
              }
              pokemon_v2_type {
                name
              }
              pokemon_v2_pokemon_species {
                id
                name
                pokemon_v2_pokemonspeciesnames(
                  where: {language_id: {_eq: $languageId}}
                  limit: 1
                ) {
                  name
                }
              }
              pokemon_v2_pokemon_speciesByEvolved_species_id {
                id
                name
                pokemon_v2_pokemonspeciesnames(
                  where: {language_id: {_eq: $languageId}}
                  limit: 1
                ) {
                  name
                }
              }
            }
            pokemon_v2_pokemons(limit: 1) {
              id
              pokemon_v2_pokemonsprites(limit: 1) {
                sprites
              }
            }
          }
        }
      }
      pokemon_v2_pokemontypes(order_by: {slot: asc}) {
        slot
        pokemon_v2_type {
          id
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
        is_hidden
        pokemon_v2_ability {
          name
          pokemon_v2_abilitynames(
            where: {language_id: {_eq: $languageId}}
            limit: 1
          ) {
            name
          }
          pokemon_v2_abilityeffecttexts(
            where: {language_id: {_eq: $languageId}}
            limit: 1
          ) {
            short_effect
            effect
          }
        }
      }
      pokemon_v2_pokemonmoves(
        order_by: [
          {level: asc_nulls_last}
          {pokemon_v2_move: {name: asc}}
        ]
      ) {
        level
        pokemon_v2_movelearnmethod {
          name
        }
        pokemon_v2_versiongroup {
          id
          name
        }
        pokemon_v2_move {
          id
          name
          pokemon_v2_movenames(
            where: {language_id: {_eq: $languageId}}
            limit: 1
          ) {
            name
          }
          pokemon_v2_type {
            id
            name
          }
        }
      }
      pokemon_v2_pokemonsprites(limit: 1) {
        sprites
      }
    }
    pokemon_v2_typeefficacy {
      damage_factor
      damage_type_id
      target_type_id
    }
  }
''';
