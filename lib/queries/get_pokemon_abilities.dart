/// GraphQL: obtiene TODAS las habilidades (pokemon_v2_ability) ordenadas por nombre (ASC)
/// e incluye solo nombres y descripciones en Español (language_id=7) e Inglés (language_id=9).
/// Para cada habilidad retorna:
/// - id, name                → identificadores básicos de la habilidad (en inglés/base)
/// - pokemon_v2_abilitynames → nombres localizados (ES/EN) con su language_id
/// - pokemon_v2_abilityeffecttexts → textos de efecto: short_effect (resumen) y effect (completo) en ES/EN

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
