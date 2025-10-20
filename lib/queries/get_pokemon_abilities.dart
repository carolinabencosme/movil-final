const String getPokemonAbilitiesQuery = r'''
  query GetPokemonAbilities {
    pokemon_v2_ability(order_by: {name: asc}) {
      id
      name
      pokemon_v2_abilitynames(where: {language_id: {_in: [7, 9]}}) {
        language_id
        name
      }
      pokemon_v2_abilityeffecttexts(where: {language_id: {_in: [7, 9]}}) {
        language_id
        short_effect
        effect
      }
    }
  }
''';
