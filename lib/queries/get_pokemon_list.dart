String buildPokemonListQuery({
  required bool includeIdFilter,
  required bool includeTypeFilter,
  bool includePagination = true,
}) {
  final variableDefinitions = <String>[
    if (includePagination) r'$limit: Int!',
    if (includePagination) r'$offset: Int!',
    r'$search: String!',
  ];
  if (includeIdFilter) {
    variableDefinitions.add(r'$id: Int');
  }
  if (includeTypeFilter) {
    variableDefinitions.add(r'$typeNames: [String!]!');
  }

  final orConditions = <String>[
    r'{name: {_ilike: $search}}',
  ];
  if (includeIdFilter) {
    orConditions.add(r'{id: {_eq: $id}}');
  }

  final bufferOrConditions = orConditions.join(',\n            ');

  final andConditions = <String>[
    '''
        {
          _or: [
            $bufferOrConditions
          ]
        }
    '''.trim(),
  ];

  if (includeTypeFilter) {
    andConditions.add(
      r'{pokemon_v2_pokemontypes: {pokemon_v2_type: {name: {_in: $typeNames}}}}',
    );
  }

  final bufferAndConditions = andConditions.join(',\n        ');

  final paginationBlock = includePagination
      ? r'''      limit: $limit
      offset: $offset
'''
      : '';

  return '''
  query GetPokemonList(${variableDefinitions.join(', ')}) {
    pokemon_v2_pokemon(
${paginationBlock}      order_by: {id: asc}
      where: {
        _and: [
        $bufferAndConditions
        ]
      }
    ) {
      id
      name
      pokemon_v2_pokemonsprites(limit: 1) {
        sprites
      }
      pokemon_v2_pokemontypes(order_by: {slot: asc}) {
        pokemon_v2_type {
          name
        }
      }
    }
    pokemon_v2_pokemon_aggregate(
      where: {
        _and: [
        $bufferAndConditions
        ]
      }
    ) {
      aggregate {
        count
      }
    }
  }
  ''';
}
