/// GraphQL: obtiene catálogos/maestros para filtros de la Pokédex, todos ordenados por `id` asc.
/// Se piden cuatro listas independientes, útiles para poblar dropdowns o chips:
/// 1) `pokemon_v2_type`        → Tipos (normal, fire, water, etc.) con `id` y `name`.
/// 2) `pokemon_v2_generation`  → Generaciones (generation-i, generation-ii, ...) con `id` y `name`.
/// 3) `pokemon_v2_region`      → Regiones (kanto, johto, hoenn, ...) con `id` y `name`.
/// 4) `pokemon_v2_pokemonshape`→ Formas (ball, squiggle, fish, ...) con `id` y `name`.
///
/// Ideal para inicializar filtros de la UI en una sola llamada (menos roundtrips).

const String getPokemonTypesQuery = r'''
  query GetPokemonTypes {
    pokemon_v2_type(order_by: {id: asc}) {
      id
      name
    }
    pokemon_v2_generation(order_by: {id: asc}) {
      id
      name
    }
    pokemon_v2_region(order_by: {id: asc}) {
      id
      name
    }
    pokemon_v2_pokemonshape(order_by: {id: asc}) {
      id
      name
    }
  }
''';
