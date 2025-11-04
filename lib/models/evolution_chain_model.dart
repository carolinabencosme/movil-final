import 'dart:convert';

class EvolutionChain {
  EvolutionChain({
    required this.species,
    required this.isBranched,
  });

  final List<EvolutionSpecies> species;
  final bool isBranched;

  factory EvolutionChain.fromGraphQL(Map<String, dynamic> json) {
    final speciesList = (json['pokemon_v2_pokemonspecies'] as List<dynamic>? ?? [])
        .map((dynamic entry) => EvolutionSpecies.fromGraphQL(entry as Map<String, dynamic>))
        .toList();

    // Determine if the evolution chain is branched
    // A chain is branched if multiple species evolve from the same parent
    final Map<int?, List<EvolutionSpecies>> groupedByParent = {};
    for (final species in speciesList) {
      final parentId = species.evolvesFromSpeciesId;
      if (!groupedByParent.containsKey(parentId)) {
        groupedByParent[parentId] = [];
      }
      groupedByParent[parentId]!.add(species);
    }

    // If any parent has more than one child, it's branched
    final isBranched = groupedByParent.values.any((children) => children.length > 1);

    return EvolutionChain(
      species: speciesList,
      isBranched: isBranched,
    );
  }

  /// Get the root species (the one that doesn't evolve from anything)
  EvolutionSpecies? get root {
    final roots = species.where((s) => s.evolvesFromSpeciesId == null).toList();
    return roots.isNotEmpty ? roots.first : null;
  }

  /// Get all species that evolve from the given species ID
  List<EvolutionSpecies> getEvolutionsFrom(int? speciesId) {
    return species.where((s) => s.evolvesFromSpeciesId == speciesId).toList();
  }
}

class EvolutionSpecies {
  EvolutionSpecies({
    required this.id,
    required this.name,
    required this.order,
    required this.evolvesFromSpeciesId,
    required this.pokemonId,
    required this.pokemonName,
    required this.imageUrl,
    required this.minLevel,
    required this.evolutionTrigger,
  });

  final int id;
  final String name;
  final int order;
  final int? evolvesFromSpeciesId;
  final int pokemonId;
  final String pokemonName;
  final String imageUrl;
  final int? minLevel;
  final String? evolutionTrigger;

  factory EvolutionSpecies.fromGraphQL(Map<String, dynamic> json) {
    final pokemons = json['pokemon_v2_pokemons'] as List<dynamic>? ?? [];
    final firstPokemon = pokemons.isNotEmpty ? pokemons[0] as Map<String, dynamic> : null;

    int pokemonId = 0;
    String pokemonName = '';
    String imageUrl = '';

    if (firstPokemon != null) {
      pokemonId = firstPokemon['id'] as int? ?? 0;
      pokemonName = firstPokemon['name'] as String? ?? '';
      imageUrl = _extractSpriteUrl(firstPokemon['pokemon_v2_pokemonsprites']);
    }

    final evolutions = json['pokemon_v2_pokemonevolutions'] as List<dynamic>? ?? [];
    int? minLevel;
    String? evolutionTrigger;

    if (evolutions.isNotEmpty) {
      final firstEvolution = evolutions[0] as Map<String, dynamic>;
      minLevel = firstEvolution['min_level'] as int?;
      final trigger = firstEvolution['pokemon_v2_evolutiontrigger'] as Map<String, dynamic>?;
      evolutionTrigger = trigger?['name'] as String?;
    }

    return EvolutionSpecies(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      evolvesFromSpeciesId: json['evolves_from_species_id'] as int?,
      pokemonId: pokemonId,
      pokemonName: pokemonName,
      imageUrl: imageUrl,
      minLevel: minLevel,
      evolutionTrigger: evolutionTrigger,
    );
  }
}

String _extractSpriteUrl(dynamic spriteEntries) {
  final sprites = spriteEntries as List<dynamic>?;
  if (sprites == null || sprites.isEmpty) {
    return '';
  }

  for (final entry in sprites) {
    if (entry is! Map<String, dynamic>) {
      continue;
    }

    final decoded = _decodeSprites(entry['sprites']);
    if (decoded == null) {
      continue;
    }

    final candidate = _selectSpriteFromMap(decoded);
    if (candidate != null) {
      return candidate;
    }
  }

  return '';
}

Map<String, dynamic>? _decodeSprites(dynamic rawSprites) {
  if (rawSprites == null) {
    return null;
  }

  if (rawSprites is String) {
    if (rawSprites.isEmpty) {
      return null;
    }

    try {
      final parsed = json.decode(rawSprites);
      if (parsed is Map<String, dynamic>) {
        return Map<String, dynamic>.from(parsed);
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  if (rawSprites is Map) {
    final map = <String, dynamic>{};
    rawSprites.forEach((key, value) {
      if (key != null) {
        map[key.toString()] = value;
      }
    });
    return map;
  }

  return null;
}

String? _selectSpriteFromMap(Map<String, dynamic> decoded) {
  final rawCandidates = <String?>[
    _getNestedString(decoded, ['other', 'official-artwork', 'front_default']),
    _getNestedString(decoded, ['other', 'home', 'front_default']),
    _getNestedString(decoded, ['other', 'official-artwork', 'front_shiny']),
    _getNestedString(decoded, ['other', 'home', 'front_shiny']),
    _getNestedString(decoded, ['other', 'dream_world', 'front_default']),
    _asNonEmptyString(decoded['front_default']),
    _asNonEmptyString(decoded['front_shiny']),
  ];

  for (final candidate in rawCandidates) {
    final normalized = _normalizeSpriteUrl(candidate);
    if (normalized != null) {
      return normalized;
    }
  }

  return null;
}

String? _getNestedString(
  Map<String, dynamic> root,
  List<String> path,
) {
  dynamic current = root;
  for (final key in path) {
    if (current is! Map<String, dynamic>) {
      return null;
    }
    current = current[key];
  }
  return _asNonEmptyString(current);
}

String? _asNonEmptyString(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return value;
  }
  return null;
}

String? _normalizeSpriteUrl(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.startsWith('http://')) {
    return value.replaceFirst('http://', 'https://');
  }
  return value;
}
