import 'dart:convert';

/// Mapa de IDs de tipos de Pokémon a sus nombres
/// 
/// Usado para resolver nombres de tipos cuando solo se tiene el ID.
/// Incluye todos los 18 tipos principales más tipos especiales (unknown, shadow).
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

/// Modelo de datos para un ítem de Pokémon en la lista/Pokédex
/// 
/// Versión ligera del modelo de Pokémon con solo la información necesaria
/// para mostrar en la lista. Incluye datos básicos como:
/// - ID y nombre
/// - URL de imagen
/// - Tipos
/// - Estadísticas principales (HP, ATK, DEF)
/// - Generación
/// 
/// Este modelo se usa en la pantalla de Pokédex donde se listan muchos Pokémon,
/// por lo que se mantiene ligero para optimizar el rendimiento.
class PokemonListItem {
  PokemonListItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.types = const [],
    this.stats = const [],
    this.generationId,
    this.generationName,
  });

  /// ID numérico único del Pokémon (número de Pokédex Nacional)
  final int id;
  
  /// Nombre del Pokémon en minúsculas (ej: "pikachu", "charizard")
  final String name;
  
  /// URL de la imagen oficial del Pokémon
  final String imageUrl;
  
  /// Lista de tipos del Pokémon (ej: ["electric"], ["fire", "flying"])
  final List<String> types;
  
  /// Lista de estadísticas base (HP, ATK, DEF, etc.)
  final List<PokemonStat> stats;
  
  /// ID de la generación a la que pertenece (1-9)
  final int? generationId;
  
  /// Nombre de la generación (ej: "generation-i", "generation-ii")
  final String? generationName;

  /// Factory constructor que parsea datos desde GraphQL
  /// 
  /// Extrae y valida todos los campos necesarios del JSON de GraphQL,
  /// manejando valores nulos y tipos incorrectos de forma segura.
  ///
  /// Crea una instancia desde el JSON de GraphQL.
  /// - Lee tipos desde `pokemon_v2_pokemontypes`.
  /// - Convierte estadísticas desde `pokemon_v2_pokemonstats`.
  /// - Toma generación desde `pokemon_v2_pokemonspecy`.
   /// - Resuelve la mejor URL de sprite disponible.
  factory PokemonListItem.fromGraphQL(Map<String, dynamic> json) {
    // Tipos: mapea y filtra nulos/formatos inesperados.
    final types = (json['pokemon_v2_pokemontypes'] as List<dynamic>? ?? [])
        .map((dynamic typeEntry) {
          final type = typeEntry as Map<String, dynamic>?;
          final typeInfo = type?['pokemon_v2_type'] as Map<String, dynamic>?;
          final name = typeInfo?['name'];
          return name is String ? name : null;
        })
        .whereType<String>()
        .toList();

    // Stats: crea PokemonStat solo si hay nombre y base_stat válidos.
    final statsEntries = json['pokemon_v2_pokemonstats'] as List<dynamic>? ?? [];
    final stats = statsEntries
        .map((dynamic statEntry) {
          final stat = statEntry as Map<String, dynamic>?;
          final baseStat = stat?['base_stat'];
          final statInfo = stat?['pokemon_v2_stat'] as Map<String, dynamic>?;
          final statName = statInfo?['name'];
          if (baseStat is int && statName is String) {
            return PokemonStat(name: statName, baseStat: baseStat);
          }
          return null;
        })
        .whereType<PokemonStat>()
        .toList();

    // Generación: datos viven dentro de la "species".
    final species = json['pokemon_v2_pokemonspecy'] as Map<String, dynamic>?;
    final generationId = species?['generation_id'];
    int? resolvedGenerationId;
    if (generationId is int) {
      resolvedGenerationId = generationId;
    }

    // Nombre de generación (si existe), cae a species.name como fallback.
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
      stats: stats,
      generationId: resolvedGenerationId,
      generationName: resolvedGenerationName,
    );
  }
}

/// Modelo “full” para la vista de detalle del Pokémon.
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

  /// Construye el detalle a partir del JSON principal del Pokémon.
  ///
  /// - `typeEfficacies` debe traer la tabla de efectividades (damage_factor).
  factory PokemonDetail.fromGraphQL(
    Map<String, dynamic> json, {
    Iterable<dynamic> typeEfficacies = const [],
  }) {
    // Recolecta tipos y sus IDs (IDs necesarios para matchups).
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
// Stats del Pokémon.
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
    // Habilidades con nombre localizado y descripción normalizada.
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
          // Nombre para mostrar: prioriza la primera traducción disponible.
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
        // Descripción: toma short_effect si está; si no, effect.
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

          // Hidden ability flag.
          final isHidden = ability?['is_hidden'];

          // Limpieza de textos (one-liner y espacios).
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

    // Movimientos (ordenados por nivel y luego alfabético).
    final moves = _parsePokemonMoves(
      json['pokemon_v2_pokemonmoves'] as List<dynamic>? ?? const [],
    );

    // Datos de especie (genus/categoría, rate, etc.).
    final species = json['pokemon_v2_pokemonspecy'] as Map<String, dynamic>?;
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

// Características “no de batalla”.
    final baseExperience = json['base_experience'] as int? ?? 0;
    final captureRate = species?['capture_rate'] as int? ?? 0;
    final height = json['height'] as int? ?? 0;
    final weight = json['weight'] as int? ?? 0;

    // Cadena evolutiva (si existe).
    final speciesId = species?['id'] as int?;
    final evolutionChain =
        PokemonEvolutionChain.fromGraphQL(
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

    // Efectividades de tipos (agregadas multiplicativamente).
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
/// Movimiento aprendible por un Pokémon (método, nivel, tipo, etc.).
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
  /// Método de aprendizaje (level-up, machine, tutor, etc.).
  final String method;
  final String? type;
  final int? level;
  final String? versionGroup;

  /// Verdadero si el movimiento se aprende a un nivel específico (>0).
  bool get hasLevel => level != null && level! > 0;
}

/// Representa la cadena evolutiva como niveles (groups) y rutas (paths).
class PokemonEvolutionChain {
  const PokemonEvolutionChain({
    required this.groups,
    required this.paths,
    this.currentSpeciesId,
  });

  /// Grupos por nivel evolutivo (raíces → intermedios → finales).
  final List<List<PokemonEvolutionNode>> groups;
  /// Rutas completas raíz→hoja (útil para dibujar líneas de evolución).
  final List<List<PokemonEvolutionNode>> paths;

  /// Especie actual (para resaltar en UI, si se desea).
  final int? currentSpeciesId;

  bool get isEmpty {
    final hasGroups =
        groups.isNotEmpty && groups.any((group) => group.isNotEmpty);
    final hasPaths = paths.isNotEmpty && paths.any((path) => path.isNotEmpty);
    return !hasGroups && !hasPaths;
  }

  /// Construye la cadena evolutiva a partir del nodo de especie.
  ///
  /// - Agrupa por `evolves_from_species_id`.
  /// - Genera niveles (groups) por BFS y rutas (paths) por DFS.
  static PokemonEvolutionChain? fromGraphQL(
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

    final speciesEntries = chain['pokemon_v2_pokemonspecies'] as List<dynamic>? ?? [];
    if (speciesEntries.isEmpty) {
      return null;
    }

    // Pre-arma nombres/slug por ID para evitar NPE más adelante.
    final Map<int, String> nameById = <int, String>{};
    final Map<int, String> slugById = <int, String>{};

    for (final dynamic entry in speciesEntries) {
      final speciesMap = entry as Map<String, dynamic>?;
      if (speciesMap == null) {
        continue;
      }

      final speciesId = speciesMap['id'] as int?;
      if (speciesId == null) {
        continue;
      }

      final fallbackName = (speciesMap['name'] as String? ?? '').trim();
      nameById[speciesId] = fallbackName;
      slugById[speciesId] = fallbackName;
    }

    if (nameById.isEmpty) {
      return null;
    }

    // Extrae datos mínimos de especie (id, nombre, img, padre).
    final Map<int, _EvolutionSpeciesData> speciesData =
        <int, _EvolutionSpeciesData>{};

    for (final dynamic entry in speciesEntries) {
      final speciesMap = entry as Map<String, dynamic>?;
      if (speciesMap == null) {
        continue;
      }

      final speciesId = speciesMap['id'] as int?;
      if (speciesId == null) {
        continue;
      }

      final fromSpeciesId = speciesMap['evolves_from_species_id'] as int?;

      // Busca un sprite válido de cualquier Pokémon asociado a la especie.
      String imageUrl = '';
      final pokemons = speciesMap['pokemon_v2_pokemons'] as List<dynamic>? ?? [];
      for (final dynamic pokemonEntry in pokemons) {
        final pokemonMap = pokemonEntry as Map<String, dynamic>?;
        if (pokemonMap == null) {
          continue;
        }
        final candidate =
            _extractSpriteUrl(pokemonMap['pokemon_v2_pokemonsprites']);
        if (candidate.isNotEmpty) {
          imageUrl = candidate;
          break;
        }
      }

      speciesData[speciesId] = _EvolutionSpeciesData(
        id: speciesId,
        name: nameById[speciesId] ?? '',
        slug: slugById[speciesId] ?? '',
        order: speciesId,  // Fallback: usa el ID como orden relativo.
        fromSpeciesId: fromSpeciesId,
        imageUrl: imageUrl,
      );
    }

    if (speciesData.isEmpty) {
      return null;
    }

// Construye nodos consumibles por UI.
    final List<PokemonEvolutionNode> nodes = <PokemonEvolutionNode>[];
    speciesData.forEach((int id, _EvolutionSpeciesData data) {
      nodes.add(
        PokemonEvolutionNode(
          speciesId: data.id,
          name: data.name,
          slug: data.slug,
          imageUrl: data.imageUrl,
          order: data.order,
          fromSpeciesId: data.fromSpeciesId,
          conditions: const <String>[],
        ),
      );
    });

    // Agrupa nodos por su padre (id de la especie de la que evolucionan).
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

    // Construye niveles (BFS): raíces → hijos → nietos...
    List<PokemonEvolutionNode> currentLevel =
        List<PokemonEvolutionNode>.from(groupedByParent[null] ?? const []);
    currentLevel.sort((a, b) => a.order.compareTo(b.order));

    final List<List<PokemonEvolutionNode>> groups = <List<PokemonEvolutionNode>>[];

    if (currentLevel.isEmpty) {
      // Si no hay raíces claras, cae a una sola “línea”.
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

    // Construye rutas completas raíz→hoja (útil para diagramas).
    final paths = PokemonEvolutionChain.buildPaths(groupedByParent);

    return PokemonEvolutionChain(
      groups: groups,
      paths: paths,
      currentSpeciesId: currentSpeciesId,
    );
  }

  /// DFS para construir todas las rutas de evolución desde las raíces.
  static List<List<PokemonEvolutionNode>> buildPaths(
    Map<int?, List<PokemonEvolutionNode>> groupedByParent,
  ) {
    final List<List<PokemonEvolutionNode>> paths = <List<PokemonEvolutionNode>>[];

    // Raíces: especies sin padre.
    final List<PokemonEvolutionNode> roots =
        List<PokemonEvolutionNode>.from(groupedByParent[null] ?? const []);

    if (roots.isEmpty) {
      // Fallback: si no hay raíces claras, usar todos en orden ascendente.
      final fallback = groupedByParent.values
          .expand((nodes) => nodes)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      if (fallback.isNotEmpty) {
        paths.add(fallback);
      }
      return paths;
    }

    // DFS para registrar cada camino completo.
    void dfs(PokemonEvolutionNode node, List<PokemonEvolutionNode> current) {
      final List<PokemonEvolutionNode> next =
          List<PokemonEvolutionNode>.from(current)..add(node);
      final List<PokemonEvolutionNode> children =
          List<PokemonEvolutionNode>.from(
        groupedByParent[node.speciesId] ?? const <PokemonEvolutionNode>[],
      )
            ..sort((a, b) => a.order.compareTo(b.order));

      if (children.isEmpty) {
        paths.add(next);
        return;
      }

      for (final child in children) {
        dfs(child, next);
      }
    }

    roots.sort((a, b) => a.order.compareTo(b.order));
    for (final root in roots) {
      dfs(root, const <PokemonEvolutionNode>[]);
    }

    return paths;
  }
}

/// Nodo de una especie dentro de la cadena evolutiva.
class PokemonEvolutionNode {
  const PokemonEvolutionNode({
    required this.speciesId,
    required this.name,
    required this.slug,
    required this.imageUrl,
    required this.order,
    this.fromSpeciesId,
    this.conditions = const <String>[],
  });

  final int speciesId;
  final String name;
  final String slug;
  final String imageUrl;
  /// Orden relativo para ordenar hermanos/lineales (a falta de otro criterio).
  final int order;
  final int? fromSpeciesId;
  /// Texto de condiciones de evolución (si se desea mostrar en UI).
  final List<String> conditions;
}

/// Estructura interna para recolectar datos mínimos de especie.
class _EvolutionSpeciesData {
  const _EvolutionSpeciesData({
    required this.id,
    required this.name,
    required this.slug,
    required this.order,
    this.fromSpeciesId,
    this.imageUrl = '',
  });

  final int id;
  final String name;
  final String slug;
  final int order;
  final int? fromSpeciesId;
  final String imageUrl;
}

/// Modelo de estadística de un Pokémon
/// 
/// Representa una estadística base (HP, Attack, Defense, etc.) con
/// su nombre y valor numérico.
class PokemonStat {
  const PokemonStat({
    required this.name,
    required this.baseStat,
  });

  /// Nombre de la estadística (hp, attack, defense, special-attack, special-defense, speed)
  final String name;
  
  /// Valor base de la estadística (típicamente entre 1-255)
  final int baseStat;
}

/// Modelo de detalle de habilidad de un Pokémon
/// 
/// Contiene información completa sobre una habilidad que el Pokémon puede tener.
class PokemonAbilityDetail {
  const PokemonAbilityDetail({
    required this.name,
    required this.description,
    this.isHidden = false,
  });

  /// Nombre de la habilidad (ej: "overgrow", "blaze")
  final String name;
  
  /// Descripción de lo que hace la habilidad
  final String description;
  
  /// Si es una habilidad oculta (Hidden Ability)
  final bool isHidden;
}

/// Modelo de características físicas y de juego de un Pokémon
/// 
/// Agrupa datos numéricos sobre el Pokémon que no son estadísticas de batalla.
class PokemonCharacteristics {
  const PokemonCharacteristics({
    required this.height,
    required this.weight,
    required this.baseExperience,
    required this.captureRate,
    required this.category,
  });

  /// Altura en decímetros (dividir por 10 para metros)
  final int height;
  
  /// Peso en hectogramos (dividir por 10 para kilogramos)
  final int weight;
  
  /// Experiencia base que se gana al derrotarlo
  final int baseExperience;
  
  /// Tasa de captura (0-255, más alto = más fácil de capturar)
  final int captureRate;
  
  /// Categoría del Pokémon (ej: "Seed Pokémon", "Flame Pokémon")
  final String category;
}

/// Relación de daño para un tipo atacante contra el Pokémon actual.
class TypeMatchup {
  const TypeMatchup({
    required this.type,
    required this.multiplier,
  });

  /// Tipo atacante (ej: "fire").
  final String type;
  /// Multiplicador total (0.5, 2.0, 4.0, etc.).
  final double multiplier;
}

/// Parsea los movimientos aprendibles y evita duplicados.
///
/// La clave de duplicado incluye (id o nombre) + método + versión + nivel.
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
    // ID y nombre localizado del movimiento.
    final int? moveId = moveInfo['id'] as int?;
    final String fallbackName = moveInfo['name'] as String? ?? '';
    final localizedNames =
        moveInfo['pokemon_v2_movenames'] as List<dynamic>? ?? [];
    final resolvedName = _resolveLocalizedName(localizedNames, fallbackName);

    // Método de aprendizaje (level-up/machine/tutor/egg/unknown).
    final methodInfo =
        moveEntry['pokemon_v2_movelearnmethod'] as Map<String, dynamic>?;
    final method = methodInfo?['name'] as String? ?? 'unknown';

    // Grupo de versión (para diferenciar sets por generación/juego).
    final versionGroupInfo =
        moveEntry['pokemon_v2_versiongroup'] as Map<String, dynamic>?;
    final versionGroup = versionGroupInfo?['name'] as String?;

    // Tipo del movimiento (si se desea taggear).
    final typeInfo = moveInfo['pokemon_v2_type'] as Map<String, dynamic>?;
    final type = typeInfo?['name'] as String?;

    // Nivel (solo aplica para level-up; otros métodos suelen ser null/0).
    final levelValue = moveEntry['level'];
    final int? level;
    if (levelValue is int) {
      level = levelValue >= 0 ? levelValue : null;
    } else {
      level = null;
    }

    // Clave única para evitar duplicados en la UI/lista.
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

  // Orden: primero por nivel (los sin nivel al final), luego alfabético.
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

/// Devuelve el primer nombre localizado disponible; si no, usa `fallback`.
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

/// Resuelve un nombre localizado para una entidad genérica (item, tipo, especie).
String _resolveLocalizedEntityName(
  Map<String, dynamic>? entity,
  String namesKey,
) {
  if (entity == null) {
    return '';
  }

  final fallback = entity['name'] as String? ?? '';
  final names = entity[namesKey] as List<dynamic>?;
  return _resolveLocalizedName(names, fallback);
}

/// Construye una descripción legible de condiciones de evolución.
///
/// Nota: muchas condiciones aquí pueden no estar presentes (null),
/// por eso se agregan solo si tienen contenido válido.
String? _describeEvolutionCondition(Map<String, dynamic> evolution) {
  final List<String> details = <String>[];

  final minLevel = evolution['min_level'];
  if (minLevel is int && minLevel > 0) {
    details.add('Nivel $minLevel');
  }

  final minHappiness = evolution['min_happiness'];
  if (minHappiness is int && minHappiness > 0) {
    details.add('Felicidad mínima: $minHappiness');
  }

  final minBeauty = evolution['min_beauty'];
  if (minBeauty is int && minBeauty > 0) {
    details.add('Belleza mínima: $minBeauty');
  }

  final minAffection = evolution['min_affection'];
  if (minAffection is int && minAffection > 0) {
    details.add('Afecto mínimo: $minAffection');
  }

  // Items: uso directo o “sosteniendo” al subir de nivel.
  final itemName = _resolveLocalizedEntityName(
    evolution['item'] as Map<String, dynamic>?,
    'pokemon_v2_itemnames',
  );
  if (itemName.isNotEmpty) {
    details.add('Usar: $itemName');
  }

  final heldItemName = _resolveLocalizedEntityName(
    evolution['held_item'] as Map<String, dynamic>?,
    'pokemon_v2_itemnames',
  );
  if (heldItemName.isNotEmpty) {
    details.add('Subir de nivel sosteniendo $heldItemName');
  }

  // Ubicación específica.
  final locationName = _resolveLocalizedEntityName(
    evolution['location'] as Map<String, dynamic>?,
    'pokemon_v2_locationnames',
  );
  if (locationName.isNotEmpty) {
    details.add('Subir de nivel en $locationName');
  }

  // Requisito de conocer un movimiento concreto o al menos uno de cierto tipo.
  final knownMove = evolution['known_move'] as Map<String, dynamic>?;
  if (knownMove != null) {
    final knownMoveName = _resolveLocalizedEntityName(
      knownMove,
      'pokemon_v2_movenames',
    );
    if (knownMoveName.isNotEmpty) {
      details.add('Debe conocer $knownMoveName');
    } else {
      // Edge case: si existe el movimiento pero sin nombre, intenta mostrar el tipo.
      // Fallback: if move data exists but no specific name is available,
      // try to show the type requirement (edge case, unlikely in practice)
      final knownMoveType = knownMove['pokemon_v2_type'] as Map<String, dynamic>?;
      if (knownMoveType != null) {
        final knownMoveTypeName = _resolveLocalizedEntityName(
          knownMoveType,
          'pokemon_v2_typenames',
        );
        if (knownMoveTypeName.isNotEmpty) {
          details.add('Debe conocer un movimiento de tipo $knownMoveTypeName');
        }
      }
    }
  }
  // Requisitos de party (especie o tipo).
  final partySpeciesName = _resolveLocalizedEntityName(
    evolution['party_species'] as Map<String, dynamic>?,
    'pokemon_v2_pokemonspeciesnames',
  );
  if (partySpeciesName.isNotEmpty) {
    details.add('Tener a $partySpeciesName en el equipo');
  }

  final partyTypeName = _resolveLocalizedEntityName(
    evolution['party_type'] as Map<String, dynamic>?,
    'pokemon_v2_typenames',
  );
  if (partyTypeName.isNotEmpty) {
    details.add('Tener un Pokémon de tipo $partyTypeName en el equipo');
  }

  // Intercambio (con o sin especie concreta).
  final tradeSpeciesName = _resolveLocalizedEntityName(
    evolution['trade_species'] as Map<String, dynamic>?,
    'pokemon_v2_pokemonspeciesnames',
  );
  if (tradeSpeciesName.isNotEmpty) {
    details.add('Intercambiar con $tradeSpeciesName');
  }

  // Condición de clima (lluvia).
  final needsOverworldRain = evolution['needs_overworld_rain'];
  final bool needsRain = (needsOverworldRain is bool && needsOverworldRain) ||
      (needsOverworldRain is int && needsOverworldRain != 0);
  if (needsRain) {
    details.add('Debe llover en el mundo');
  }

  // Relación entre Ataque y Defensa (solo para ciertas especies)
  final relativeStats = evolution['relative_physical_stats'];
  if (relativeStats is int) {
    final relativeDescription = switch (relativeStats) {
      1 => 'El Ataque debe ser mayor que la Defensa',
      -1 => 'El Ataque debe ser menor que la Defensa',
      0 => 'El Ataque y la Defensa deben ser iguales',
      _ => null,
    };
    if (relativeDescription != null) {
      details.add(relativeDescription);
    }
  }

  // Restricción de género.
  final genderId = evolution['gender_id'];
  if (genderId is int) {
    if (genderId == 1) {
      details.add('Debe ser hembra');
    } else if (genderId == 2) {
      details.add('Debe ser macho');
    }
  }

  // Caso especial (Inkay → Malamar).
  final bool? turnUpsideDown = evolution['turn_upside_down'] as bool?;
  if (turnUpsideDown == true) {
    details.add('Girar el dispositivo');
  }

  // Disparador genérico (trade, use-item, etc.).
  final triggerMap =
      evolution['pokemon_v2_evolutiontrigger'] as Map<String, dynamic>?;
  final trigger = triggerMap?['name'] as String?;
  if (trigger != null && trigger.isNotEmpty && trigger != 'level-up') {
    switch (trigger) {
      case 'trade':
        if (tradeSpeciesName.isEmpty) {
          details.add('Intercambiar');
        }
        break;
      case 'use-item':
        // Ya cubierto por el objeto específico.
        break;
      default:
        details.add('Método: ${_formatGraphqlLabel(trigger)}');
    }
  }

  // Momento del día (day/night/dusk...).
  final timeOfDay = evolution['time_of_day'];
  if (timeOfDay is String && timeOfDay.isNotEmpty) {
    details.add('Momento: ${_formatGraphqlLabel(timeOfDay)}');
  }

  return details.isEmpty ? null : details.join(' · ');
}

/// Convierte labels de GraphQL (snake/kebab) a “Title Case”.
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

/// Calcula efectividades por tipo atacante contra la combinación de tipos del Pokémon.
///
/// - Multiplica acumulativamente los `damage_factor/100`.
/// - Omite multiplicadores ~1.0 (neutros) para mostrar solo ventajas/desventajas.

List<TypeMatchup> _buildTypeMatchups(
  Set<int> pokemonTypeIds,
  Iterable<Map<String, dynamic>> typeEfficacies,
) {
  if (pokemonTypeIds.isEmpty) {
    return <TypeMatchup>[];
  }
  // Acumula multiplicadores por tipo atacante.
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

  // Convierte a lista de salida omitiendo ~1.0 (neutro).
  accumulator.forEach((int damageTypeId, double multiplier) {
    final normalized = double.parse(multiplier.toStringAsFixed(4));
    if ((normalized - 1.0).abs() < 0.01) {
      return;
    }

    final typeName =
        _pokemonTypeNamesById[damageTypeId] ?? 'unknown';
    matchups.add(TypeMatchup(type: typeName, multiplier: normalized));
  });
// Ordena de mayor a menor multiplicador (primero las mayores debilidades).
  matchups.sort((a, b) => b.multiplier.compareTo(a.multiplier));
  return matchups;
}
/// Extrae una URL de sprite “mejor disponible”
/// desde la colección de sprites (puede venir en String JSON o Map).
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
// Prioriza official-artwork/home; luego shiny/dream_world; luego front_default.
    final candidate = _selectSpriteFromMap(decoded);
    if (candidate != null) {
      return candidate;
    }
  }

  return '';
}

/// Decodifica la estructura de `sprites`, que a veces llega como String JSON.
///
/// Acepta:
/// - `String` JSON → lo parsea a `Map<String, dynamic>`.
/// - `Map` ya estructurado → lo normaliza a `Map<String, dynamic>`.
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
      // Si falla el decode, retorna null silenciosamente (se intentarán otros sprites).
      return null;
    }

    return null;
  }

  if (rawSprites is Map) {
    // Normaliza a Map<String,dynamic>.
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

/// Selecciona la mejor URL disponible de un mapa de sprites.
///
/// Orden de preferencia:
/// 1) other.official-artwork.front_default
/// 2) other.home.front_default
/// 3) official-artwork/front_shiny, home/front_shiny
/// 4) dream_world.front_default
/// 5) front_default / front_shiny
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

/// Lee un String anidado por ruta de claves; retorna null si falta en cualquier nivel.
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

/// Devuelve `value` si es String no vacío; en otro caso, null.
String? _asNonEmptyString(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return value;
  }
  return null;
}

/// Asegura HTTPS y descarta cadenas vacías.
String? _normalizeSpriteUrl(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.startsWith('http://')) {
    return value.replaceFirst('http://', 'https://');
  }
  return value;
}
