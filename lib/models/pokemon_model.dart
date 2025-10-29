import 'dart:convert';

const Map<int, String> _pokemonTypeNamesById = {
  1: 'normal',
  2: 'fighting',
  3: 'flying',
  4: 'poison',
  5: 'ground',
  6: 'rock',
  7: 'bug',
  8: 'ghost',
  9: 'steel',
  10: 'fire',
  11: 'water',
  12: 'grass',
  13: 'electric',
  14: 'psychic',
  15: 'ice',
  16: 'dragon',
  17: 'dark',
  18: 'fairy',
  10001: 'unknown',
  10002: 'shadow',
};

class PokemonListItem {
  PokemonListItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.types = const [],
    this.generationId,
    this.generationName,
  });

  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int? generationId;
  final String? generationName;

  factory PokemonListItem.fromGraphQL(Map<String, dynamic> json) {
    final types = (json['pokemon_v2_pokemontypes'] as List<dynamic>? ?? [])
        .map((dynamic typeEntry) {
          final type = typeEntry as Map<String, dynamic>?;
          final typeInfo = type?['pokemon_v2_type'] as Map<String, dynamic>?;
          final name = typeInfo?['name'];
          return name is String ? name : null;
        })
        .whereType<String>()
        .toList();

    final species = json['pokemon_v2_pokemonspecy'] as Map<String, dynamic>?;
    final generationId = species?['generation_id'];
    int? resolvedGenerationId;
    if (generationId is int) {
      resolvedGenerationId = generationId;
    }

    String? resolvedGenerationName;
    final generationInfo =
        species?['pokemon_v2_generation'] as Map<String, dynamic>?;
    final generationName = generationInfo?['name'] ?? species?['name'];
    if (generationName is String && generationName.isNotEmpty) {
      resolvedGenerationName = generationName;
    }

    return PokemonListItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      imageUrl: _extractSpriteUrl(json['pokemon_v2_pokemonsprites']),
      types: types,
      generationId: resolvedGenerationId,
      generationName: resolvedGenerationName,
    );
  }
}

class PokemonDetail {
  PokemonDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.abilities,
    required this.stats,
    required this.characteristics,
    required this.typeMatchups,
    required this.moves,
    this.evolutionChain,
    this.speciesId,
  });

  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final List<PokemonAbilityDetail> abilities;
  final List<PokemonStat> stats;
  final PokemonCharacteristics characteristics;
  final List<TypeMatchup> typeMatchups;
  final List<PokemonMove> moves;
  final PokemonEvolutionChain? evolutionChain;
  final int? speciesId;

  factory PokemonDetail.fromGraphQL(
    Map<String, dynamic> json, {
    Iterable<dynamic> typeEfficacies = const [],
  }) {
    final typeEntries = json['pokemon_v2_pokemontypes'] as List<dynamic>? ?? [];
    final List<String> types = <String>[];
    final Set<int> typeIds = <int>{};

    for (final dynamic entry in typeEntries) {
      final type = entry as Map<String, dynamic>?;
      final typeInfo = type?['pokemon_v2_type'] as Map<String, dynamic>?;
      if (typeInfo == null) continue;

      final typeName = typeInfo['name'];
      if (typeName is String) {
        types.add(typeName);
      }

      final typeId = typeInfo['id'];
      if (typeId is int) {
        typeIds.add(typeId);
      }
    }

    final stats = (json['pokemon_v2_pokemonstats'] as List<dynamic>? ?? [])
        .map((dynamic statEntry) {
          final stat = statEntry as Map<String, dynamic>?;
          final statInfo = stat?['pokemon_v2_stat'] as Map<String, dynamic>?;
          final name = statInfo?['name'];
          final baseStat = stat?['base_stat'];
          if (name is String && baseStat is int) {
            return PokemonStat(name: name, baseStat: baseStat);
          }
          return null;
        })
        .whereType<PokemonStat>()
        .toList();

    final abilitiesEntries =
        json['pokemon_v2_pokemonabilities'] as List<dynamic>? ?? [];
    final abilities = abilitiesEntries
        .map((dynamic abilityEntry) {
          final ability = abilityEntry as Map<String, dynamic>?;
          final abilityInfo =
              ability?['pokemon_v2_ability'] as Map<String, dynamic>?;
          if (abilityInfo == null) {
            return null;
          }

          final localizedNames =
              abilityInfo['pokemon_v2_abilitynames'] as List<dynamic>? ?? [];
          String displayName = abilityInfo['name'] as String? ?? '';
          for (final dynamic nameEntry in localizedNames) {
            final map = nameEntry as Map<String, dynamic>?;
            final localized = map?['name'];
            if (localized is String && localized.isNotEmpty) {
              displayName = localized;
              break;
            }
          }

          final effectTexts =
              abilityInfo['pokemon_v2_abilityeffecttexts'] as List<dynamic>? ??
                  [];
          String description = '';
          for (final dynamic effectEntry in effectTexts) {
            final effect = effectEntry as Map<String, dynamic>?;
            final shortEffect = effect?['short_effect'];
            final fullEffect = effect?['effect'];
            if (shortEffect is String && shortEffect.isNotEmpty) {
              description = shortEffect;
              break;
            }
            if (fullEffect is String && fullEffect.isNotEmpty) {
              description = fullEffect;
            }
          }

          if (description.isEmpty) {
            description = 'Sin descripción disponible.';
          }

          final isHidden = ability?['is_hidden'];

          description = description
              .replaceAll('\n', ' ')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();

          return PokemonAbilityDetail(
            name: displayName,
            description: description,
            isHidden: isHidden is bool ? isHidden : false,
          );
        })
        .whereType<PokemonAbilityDetail>()
        .toList();

    final moves = _parsePokemonMoves(
      json['pokemon_v2_pokemonmoves'] as List<dynamic>? ?? const [],
    );

    final species =
        json['pokemon_v2_pokemonspecy'] as Map<String, dynamic>?;
    final speciesNames =
        species?['pokemon_v2_pokemonspeciesnames'] as List<dynamic>? ?? [];
    String category = '';
    for (final dynamic nameEntry in speciesNames) {
      final map = nameEntry as Map<String, dynamic>?;
      final genus = map?['genus'];
      if (genus is String && genus.isNotEmpty) {
        category = genus;
        break;
      }
    }

    final baseExperience = json['base_experience'] as int? ?? 0;
    final captureRate = species?['capture_rate'] as int? ?? 0;
    final height = json['height'] as int? ?? 0;
    final weight = json['weight'] as int? ?? 0;

    final speciesId = species?['id'] as int?;
    final evolutionChain = _parseEvolutionChain(
      species,
      currentSpeciesId: speciesId,
    );

    final characteristics = PokemonCharacteristics(
      height: height,
      weight: weight,
      baseExperience: baseExperience,
      captureRate: captureRate,
      category: category,
    );

    final typeMatchups =
        _buildTypeMatchups(typeIds, typeEfficacies.whereType<Map<String, dynamic>>());

    return PokemonDetail(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      imageUrl: _extractSpriteUrl(json['pokemon_v2_pokemonsprites']),
      types: types,
      abilities: abilities,
      stats: stats,
      characteristics: characteristics,
      typeMatchups: typeMatchups,
      moves: moves,
      evolutionChain: evolutionChain,
      speciesId: speciesId,
    );
  }
}

class PokemonMove {
  const PokemonMove({
    this.id,
    required this.name,
    required this.method,
    this.type,
    this.level,
    this.versionGroup,
  });

  final int? id;
  final String name;
  final String method;
  final String? type;
  final int? level;
  final String? versionGroup;

  bool get hasLevel => level != null && level! > 0;
}

class PokemonEvolutionChain {
  const PokemonEvolutionChain({
    required this.groups,
    this.currentSpeciesId,
  });

  final List<List<PokemonEvolutionNode>> groups;
  final int? currentSpeciesId;

  bool get isEmpty => groups.isEmpty || groups.every((group) => group.isEmpty);
}

class PokemonEvolutionNode {
  const PokemonEvolutionNode({
    required this.speciesId,
    required this.name,
    required this.imageUrl,
    required this.order,
    this.fromSpeciesId,
    this.conditions = const <String>[],
  });

  final int speciesId;
  final String name;
  final String imageUrl;
  final int order;
  final int? fromSpeciesId;
  final List<String> conditions;
}

class _EvolutionSpeciesData {
  const _EvolutionSpeciesData({
    required this.id,
    required this.name,
    required this.order,
    this.fromSpeciesId,
    this.imageUrl = '',
  });

  final int id;
  final String name;
  final int order;
  final int? fromSpeciesId;
  final String imageUrl;
}

class _EvolutionSpeciesRef {
  const _EvolutionSpeciesRef({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
}

class PokemonStat {
  const PokemonStat({
    required this.name,
    required this.baseStat,
  });

  final String name;
  final int baseStat;
}

class PokemonAbilityDetail {
  const PokemonAbilityDetail({
    required this.name,
    required this.description,
    this.isHidden = false,
  });

  final String name;
  final String description;
  final bool isHidden;
}

class PokemonCharacteristics {
  const PokemonCharacteristics({
    required this.height,
    required this.weight,
    required this.baseExperience,
    required this.captureRate,
    required this.category,
  });

  final int height;
  final int weight;
  final int baseExperience;
  final int captureRate;
  final String category;
}

class TypeMatchup {
  const TypeMatchup({
    required this.type,
    required this.multiplier,
  });

  final String type;
  final double multiplier;
}

List<PokemonMove> _parsePokemonMoves(List<dynamic> entries) {
  if (entries.isEmpty) {
    return const <PokemonMove>[];
  }

  final List<PokemonMove> moves = <PokemonMove>[];
  final Set<String> seen = <String>{};

  for (final dynamic entry in entries) {
    final moveEntry = entry as Map<String, dynamic>?;
    if (moveEntry == null) {
      continue;
    }

    final moveInfo = moveEntry['pokemon_v2_move'] as Map<String, dynamic>?;
    if (moveInfo == null) {
      continue;
    }

    final int? moveId = moveInfo['id'] as int?;
    final String fallbackName = moveInfo['name'] as String? ?? '';
    final localizedNames =
        moveInfo['pokemon_v2_movenames'] as List<dynamic>? ?? [];
    final resolvedName = _resolveLocalizedName(localizedNames, fallbackName);

    final methodInfo =
        moveEntry['pokemon_v2_movelearnmethod'] as Map<String, dynamic>?;
    final method = methodInfo?['name'] as String? ?? 'unknown';

    final versionGroupInfo =
        moveEntry['pokemon_v2_versiongroup'] as Map<String, dynamic>?;
    final versionGroup = versionGroupInfo?['name'] as String?;

    final typeInfo = moveInfo['pokemon_v2_type'] as Map<String, dynamic>?;
    final type = typeInfo?['name'] as String?;

    final levelValue = moveEntry['level'];
    final int? level;
    if (levelValue is int) {
      level = levelValue >= 0 ? levelValue : null;
    } else {
      level = null;
    }

    final key =
        '${moveId ?? resolvedName}_${method}_${versionGroup ?? ''}_${level ?? ''}';
    if (!seen.add(key)) {
      continue;
    }

    moves.add(
      PokemonMove(
        id: moveId,
        name: resolvedName,
        method: method,
        type: type,
        level: level,
        versionGroup: versionGroup,
      ),
    );
  }

  moves.sort((a, b) {
    final levelA = a.level ?? 999;
    final levelB = b.level ?? 999;
    final levelComparison = levelA.compareTo(levelB);
    if (levelComparison != 0) {
      return levelComparison;
    }
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });

  return moves;
}

PokemonEvolutionChain? _parseEvolutionChain(
  Map<String, dynamic>? species, {
  int? currentSpeciesId,
}) {
  if (species == null) {
    return null;
  }

  final chain = species['pokemon_v2_evolutionchain'] as Map<String, dynamic>?;
  if (chain == null) {
    return null;
  }

  final speciesEntries =
      chain['pokemon_v2_pokemonspecies'] as List<dynamic>? ?? [];
  if (speciesEntries.isEmpty) {
    return null;
  }

  final Map<int, _EvolutionSpeciesData> speciesData =
      <int, _EvolutionSpeciesData>{};
  final Map<int, List<String>> conditionsByTarget =
      <int, List<String>>{};
  final Map<int, int> parentByTarget = <int, int>{};

  for (final dynamic entry in speciesEntries) {
    final speciesMap = entry as Map<String, dynamic>?;
    if (speciesMap == null) {
      continue;
    }

    final speciesId = speciesMap['id'] as int?;
    if (speciesId == null) {
      continue;
    }

    final fallbackName = speciesMap['name'] as String? ?? '';
    final localizedNames =
        speciesMap['pokemon_v2_pokemonspeciesnames'] as List<dynamic>? ?? [];
    final name = _resolveLocalizedName(localizedNames, fallbackName);

    final order = speciesMap['order'] as int? ?? 0;
    final fromSpeciesId = speciesMap['evolves_from_species_id'] as int?;

    String imageUrl = '';
    final pokemons = speciesMap['pokemon_v2_pokemons'] as List<dynamic>? ?? [];
    for (final dynamic pokemonEntry in pokemons) {
      final pokemonMap = pokemonEntry as Map<String, dynamic>?;
      if (pokemonMap == null) {
        continue;
      }
      final candidate = _extractSpriteUrl(pokemonMap['pokemon_v2_pokemonsprites']);
      if (candidate.isNotEmpty) {
        imageUrl = candidate;
        break;
      }
    }

    speciesData[speciesId] = _EvolutionSpeciesData(
      id: speciesId,
      name: name,
      order: order,
      fromSpeciesId: fromSpeciesId,
      imageUrl: imageUrl,
    );

    final evolutions =
        speciesMap['pokemon_v2_pokemonevolutions'] as List<dynamic>? ?? [];
    for (final dynamic evoEntry in evolutions) {
      final evoMap = evoEntry as Map<String, dynamic>?;
      if (evoMap == null) {
        continue;
      }
      final targetRef =
          _readEvolutionSpeciesRef(evoMap['pokemon_v2_pokemon_speciesByEvolved_species_id']);
      final sourceRef =
          _readEvolutionSpeciesRef(evoMap['pokemon_v2_pokemon_species']);

      final evolvedId = targetRef?.id;
      if (evolvedId == null) {
        continue;
      }

      final sourceId = sourceRef?.id ?? speciesId;
      if (sourceId != null) {
        parentByTarget[evolvedId] = sourceId;
      }

      final description = _describeEvolutionCondition(evoMap);
      if (description.isEmpty) {
        continue;
      }
      final conditions =
          conditionsByTarget.putIfAbsent(evolvedId, () => <String>[]);
      conditions.add(description);
    }
  }

  if (speciesData.isEmpty) {
    return null;
  }

  final List<PokemonEvolutionNode> nodes = <PokemonEvolutionNode>[];
  speciesData.forEach((int id, _EvolutionSpeciesData data) {
    final parentId = parentByTarget[id] ?? data.fromSpeciesId;
    final conditions =
        List<String>.from(conditionsByTarget[id] ?? const <String>[]);
    if (conditions.isEmpty && parentId != null) {
      conditions.add('Requisitos no especificados');
    }
    nodes.add(
      PokemonEvolutionNode(
        speciesId: data.id,
        name: data.name,
        imageUrl: data.imageUrl,
        order: data.order,
        fromSpeciesId: parentId,
        conditions: conditions,
      ),
    );
  });

  final Map<int?, List<PokemonEvolutionNode>> groupedByParent =
      <int?, List<PokemonEvolutionNode>>{};
  for (final node in nodes) {
    final parent = node.fromSpeciesId;
    final siblings = groupedByParent.putIfAbsent(
      parent,
      () => <PokemonEvolutionNode>[],
    );
    siblings.add(node);
  }

  List<PokemonEvolutionNode> currentLevel =
      List<PokemonEvolutionNode>.from(groupedByParent[null] ?? const []);
  currentLevel.sort((a, b) => a.order.compareTo(b.order));

  final List<List<PokemonEvolutionNode>> groups = <List<PokemonEvolutionNode>>[];

  if (currentLevel.isEmpty) {
    nodes.sort((a, b) => a.order.compareTo(b.order));
    groups.add(List<PokemonEvolutionNode>.from(nodes));
  } else {
    while (currentLevel.isNotEmpty) {
      groups.add(List<PokemonEvolutionNode>.from(currentLevel));
      final List<PokemonEvolutionNode> nextLevel = <PokemonEvolutionNode>[];
      for (final node in currentLevel) {
        final children = groupedByParent[node.speciesId];
        if (children == null || children.isEmpty) {
          continue;
        }
        children.sort((a, b) => a.order.compareTo(b.order));
        nextLevel.addAll(children);
      }
      currentLevel = nextLevel;
    }
  }

  return PokemonEvolutionChain(
    groups: groups,
    currentSpeciesId: currentSpeciesId,
  );
}

String _resolveLocalizedName(List<dynamic>? entries, String fallback) {
  if (entries != null) {
    for (final dynamic entry in entries) {
      final map = entry as Map<String, dynamic>?;
      final name = map?['name'];
      if (name is String && name.isNotEmpty) {
        return name;
      }
    }
  }
  return fallback;
}

_EvolutionSpeciesRef? _readEvolutionSpeciesRef(dynamic rawSpecies) {
  if (rawSpecies == null) {
    return null;
  }

  if (rawSpecies is List) {
    if (rawSpecies.isEmpty) {
      return null;
    }
    return _readEvolutionSpeciesRef(rawSpecies.first);
  }

  if (rawSpecies is! Map<String, dynamic>) {
    return null;
  }

  final idValue = rawSpecies['id'];
  if (idValue is! int) {
    return null;
  }

  final fallbackName = rawSpecies['name'] as String? ?? '';
  final localizedNames =
      rawSpecies['pokemon_v2_pokemonspeciesnames'] as List<dynamic>? ?? [];
  final name = _resolveLocalizedName(localizedNames, fallbackName);

  return _EvolutionSpeciesRef(id: idValue, name: name);
}

String _describeEvolutionCondition(Map<String, dynamic> evolution) {
  final List<String> details = <String>[];

  final minLevel = evolution['min_level'];
  if (minLevel is int && minLevel > 0) {
    details.add('Nivel $minLevel');
  }

  final triggerMap =
      evolution['pokemon_v2_evolutiontrigger'] as Map<String, dynamic>?;
  final trigger = triggerMap?['name'] as String?;
  if (trigger != null && trigger.isNotEmpty && trigger != 'level-up') {
    details.add('Método: ${_formatGraphqlLabel(trigger)}');
  }

  final itemMap = evolution['pokemon_v2_item'] as Map<String, dynamic>?;
  final item = itemMap?['name'] as String?;
  if (item != null && item.isNotEmpty) {
    details.add('Objeto: ${_formatGraphqlLabel(item)}');
  }

  final moveMap = evolution['pokemon_v2_move'] as Map<String, dynamic>?;
  final move = moveMap?['name'] as String?;
  if (move != null && move.isNotEmpty) {
    details.add('Movimiento: ${_formatGraphqlLabel(move)}');
  }

  final locationMap =
      evolution['pokemon_v2_location'] as Map<String, dynamic>?;
  final location = locationMap?['name'] as String?;
  if (location != null && location.isNotEmpty) {
    details.add('Lugar: ${_formatGraphqlLabel(location)}');
  }

  final typeMap = evolution['pokemon_v2_type'] as Map<String, dynamic>?;
  final type = typeMap?['name'] as String?;
  if (type != null && type.isNotEmpty) {
    details.add('Tipo requerido: ${_formatGraphqlLabel(type)}');
  }

  final timeOfDay = evolution['time_of_day'];
  if (timeOfDay is String && timeOfDay.isNotEmpty) {
    details.add('Momento: ${_formatGraphqlLabel(timeOfDay)}');
  }

  final minHappiness = evolution['min_happiness'];
  if (minHappiness is int && minHappiness > 0) {
    details.add('Felicidad mínima: $minHappiness');
  }

  final minAffection = evolution['min_affection'];
  if (minAffection is int && minAffection > 0) {
    details.add('Afecto mínimo: $minAffection');
  }

  final minBeauty = evolution['min_beauty'];
  if (minBeauty is int && minBeauty > 0) {
    details.add('Belleza mínima: $minBeauty');
  }

  final relativePhysicalStats = evolution['relative_physical_stats'];
  if (relativePhysicalStats is int) {
    if (relativePhysicalStats > 0) {
      details.add('Ataque > Defensa');
    } else if (relativePhysicalStats < 0) {
      details.add('Ataque < Defensa');
    } else {
      details.add('Ataque = Defensa');
    }
  }

  final gender = evolution['gender'];
  if (gender is int) {
    if (gender == 1) {
      details.add('Solo hembra');
    } else if (gender == 2) {
      details.add('Solo macho');
    }
  }

  if (details.isEmpty) {
    return '';
  }

  return details.join(' · ');
}

String _formatGraphqlLabel(String value) {
  final cleaned = value.replaceAll('-', ' ').replaceAll('_', ' ');
  final parts = cleaned.split(RegExp(r'\s+'))..removeWhere((part) => part.isEmpty);
  if (parts.isEmpty) {
    return value;
  }

  return parts
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

List<TypeMatchup> _buildTypeMatchups(
  Set<int> pokemonTypeIds,
  Iterable<Map<String, dynamic>> typeEfficacies,
) {
  if (pokemonTypeIds.isEmpty) {
    return <TypeMatchup>[];
  }

  final Map<int, double> accumulator = <int, double>{};

  for (final Map<String, dynamic> efficacy in typeEfficacies) {
    final targetTypeId = efficacy['target_type_id'];
    if (targetTypeId is! int || !pokemonTypeIds.contains(targetTypeId)) {
      continue;
    }

    final damageTypeId = efficacy['damage_type_id'];
    final damageFactor = efficacy['damage_factor'];

    if (damageTypeId is! int || damageFactor is! int) {
      continue;
    }

    final normalized = damageFactor / 100.0;
    final previous = accumulator[damageTypeId] ?? 1.0;
    accumulator[damageTypeId] = previous * normalized;
  }

  final List<TypeMatchup> matchups = <TypeMatchup>[];

  accumulator.forEach((int damageTypeId, double multiplier) {
    final normalized = double.parse(multiplier.toStringAsFixed(4));
    if ((normalized - 1.0).abs() < 0.01) {
      return;
    }

    final typeName =
        _pokemonTypeNamesById[damageTypeId] ?? 'unknown';
    matchups.add(TypeMatchup(type: typeName, multiplier: normalized));
  });

  matchups.sort((a, b) => b.multiplier.compareTo(a.multiplier));
  return matchups;
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
