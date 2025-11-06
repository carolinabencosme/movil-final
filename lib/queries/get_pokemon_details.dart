// Language IDs: 7 = Spanish, 9 = English
const int _defaultLanguageId = 7;
const List<int> _preferredLanguageIds = [7, 9];

const String getPokemonDetailsQuery = r'''
  query PokemonDetails(
    $where: pokemon_v2_pokemon_bool_exp!,
    $languageIds: [Int!]!
  ) {
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

        # Nombre "genus" (p. ej., "Seed Pokémon") con fallback ES→EN
        pokemon_v2_pokemonspeciesnames(
          where: {language_id: {_in: $languageIds}}
          order_by: {language_id: asc}
          limit: 2
        ) {
          language_id
          genus
        }

        # Flavor text con fallback ES→EN (última versión primero)
        pokemon_v2_pokemonspeciesflavortexts(
          where: {language_id: {_in: $languageIds}}
          order_by: [{version_id: desc}, {language_id: asc}]
          limit: 4
        ) { 
          language_id
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
        pokemon_v2_stat { name }
      }

      pokemon_v2_pokemonabilities(order_by: {slot: asc}) {
        is_hidden
        pokemon_v2_ability {
          name

          # Nombre localizado de la habilidad (ES→EN)
          pokemon_v2_abilitynames(
            where: {language_id: {_in: $languageIds}}
            order_by: {language_id: asc}
            limit: 2
          ) {
            language_id
            name
          }

          # Descripciones de la habilidad (ES→EN), probando effect y short_effect
          pokemon_v2_abilityeffecttexts(
            where: {language_id: {_in: $languageIds}}
            order_by: {language_id: asc}
            limit: 4
          ) {
            language_id
            short_effect
            effect
          }

          # Algunos endpoints traen mejor redacción en flavor_text; úsalo como tercer fallback
          pokemon_v2_abilityflavortexts(
            where: {language_id: {_in: $languageIds}}
            order_by: [{version_group_id: desc}, {language_id: asc}]
            limit: 4
          ) {
            language_id
            flavor_text
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
        pokemon_v2_movelearnmethod { name }
        pokemon_v2_versiongroup { id name }
        pokemon_v2_move {
          id
          name

          # Nombre del movimiento con fallback ES→EN
          pokemon_v2_movenames(
            where: {language_id: {_in: $languageIds}}
            order_by: {language_id: asc}
            limit: 2
          ) {
            language_id
            name
          }

          pokemon_v2_type { id name }
        }
      }

      pokemon_v2_pokemonsprites(limit: 1) { sprites }
    }

    # Eficacias de tipos (déjalo igual)
    type_efficacy: pokemon_v2_typeefficacy {
      damage_factor
      damage_type_id
      target_type_id
    }
  }
''';
