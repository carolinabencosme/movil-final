// Language ID constant for Spanish
const int _defaultLanguageId = 7;

const String getPokemonDetailsQuery = r'''
  query PokemonDetails($where: pokemon_v2_pokemon_bool_exp!) {
    pokemon_v2_pokemon(where: $where, limit: 1) {
      id
      name
      height
      weight
      base_experience

      pokemon_v2_pokemontypes(order_by: {slot: asc}) {
        pokemon_v2_type { 
          id
          name 
        }
      }

      pokemon_v2_pokemonspecy {
        id
        name
        capture_rate
        generation_id
        pokemon_v2_pokemonspeciesnames(
          where: {language_id: {_eq: 7}}
          limit: 1
        ) {
          genus
        }
        pokemon_v2_pokemonspeciesflavortexts(
          where: {language_id: {_eq: 7}}
          order_by: {version_id: desc}
          limit: 1
        ) { 
          flavor_text 
        }
        pokemon_v2_generation {
          id
          name
        }

        pokemon_v2_evolutionchain {
          pokemon_v2_pokemonspecies(order_by: {order: asc}) {
            id
            name
            evolves_from_species_id
            pokemon_v2_pokemons(limit: 1) {
              id
              pokemon_v2_pokemonsprites(limit: 1) {
                sprites
              }
            }
          }
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
            where: {language_id: {_eq: 7}}
            limit: 1
          ) {
            name
          }
          pokemon_v2_abilityeffecttexts(
            where: {language_id: {_eq: 7}}
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
            where: {language_id: {_eq: 7}}
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
    type_efficacy: pokemon_v2_typeefficacy {
      damage_factor
      damage_type_id
      target_type_id
    }
  }
''';
