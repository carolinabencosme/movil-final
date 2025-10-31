const String getPokemonDetailsQuery = r'''
  query GetPokemonDetail($id: Int!, $languageId: Int!) {
    pokemon: pokemon_v2_pokemon_by_pk(id: $id) {
      id
      name
      height
      weight
      base_experience
      species: pokemon_v2_pokemonspecy {
        id
        name
        capture_rate
        generation_id
        pokemon_v2_pokemonspeciesnames(
          where: {language_id: {_eq: $languageId}}
          limit: 1
        ) {
          genus
        }
        pokemon_v2_generation {
          id
          name
        }
        evolution_chain: pokemon_v2_evolutionchain {
          id
          species_list: pokemon_v2_pokemonspecies(order_by: {order: asc}) {
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
              evolved_species_id
              min_level
              min_happiness
              min_beauty
              min_affection
              time_of_day
              gender_id
              needs_overworld_rain
              relative_physical_stats
              trade_species_id
              turn_upside_down
              pokemon_v2_evolutiontrigger {
                name
              }
              item: pokemon_v2_item {
                name
                pokemon_v2_itemnames(
                  where: {language_id: {_eq: $languageId}}
                  limit: 1
                ) {
                  name
                }
              }
              held_item: pokemon_v2_itemByHeldItemId {
                name
                pokemon_v2_itemnames(
                  where: {language_id: {_eq: $languageId}}
                  limit: 1
                ) {
                  name
                }
              }
              location: pokemon_v2_location {
                name
                pokemon_v2_locationnames(
                  where: {language_id: {_eq: $languageId}}
                  limit: 1
                ) {
                  name
                }
              }
              known_move: pokemon_v2_move {
                name
                pokemon_v2_movenames(
                  where: {language_id: {_eq: $languageId}}
                  limit: 1
                ) {
                  name
                }
              }
              known_move_type: pokemon_v2_typeByKnownMoveTypeId {
                name
                pokemon_v2_typenames(
                  where: {language_id: {_eq: $languageId}}
                  limit: 1
                ) {
                  name
                }
              }
              party_species: pokemon_v2_pokemonspecyByPartySpeciesId {
                name
                pokemon_v2_pokemonspeciesnames(
                  where: {language_id: {_eq: $languageId}}
                  limit: 1
                ) {
                  name
                }
              }
              party_type: pokemon_v2_typeByPartyTypeId {
                name
                pokemon_v2_typenames(
                  where: {language_id: {_eq: $languageId}}
                  limit: 1
                ) {
                  name
                }
              }
              trade_species: pokemon_v2_pokemonspecyByTradeSpeciesId {
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
    type_efficacy: pokemon_v2_typeefficacy {
      damage_factor
      damage_type_id
      target_type_id
    }
  }
''';
