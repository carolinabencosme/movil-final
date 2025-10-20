import 'dart:convert';

class PokemonListItem {
  PokemonListItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.types = const [],
  });

  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

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

    return PokemonListItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      imageUrl: _extractSpriteUrl(json['pokemon_v2_pokemonsprites']),
      types: types,
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
  });

  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final List<PokemonAbilityDetail> abilities;
  final List<PokemonStat> stats;
  final PokemonCharacteristics characteristics;
  final List<TypeMatchup> typeMatchups;

  factory PokemonDetail.fromGraphQL(Map<String, dynamic> json) {
    final typeEntries = json['pokemon_v2_pokemontypes'] as List<dynamic>? ?? [];
    final List<String> types = <String>[];
    final Map<String, double> matchupAccumulator = <String, double>{};

    for (final dynamic entry in typeEntries) {
      final type = entry as Map<String, dynamic>?;
      final typeInfo = type?['pokemon_v2_type'] as Map<String, dynamic>?;
      if (typeInfo == null) continue;

      final typeName = typeInfo['name'];
      if (typeName is String) {
        types.add(typeName);
      }

      final efficacies =
          typeInfo['pokemon_v2_typeefficacies'] as List<dynamic>? ?? [];

      for (final dynamic efficacyEntry in efficacies) {
        final efficacy = efficacyEntry as Map<String, dynamic>?;
        final damageTypeInfo = efficacy?['pokemon_v2_typeByDamageType']
            as Map<String, dynamic>?;
        final damageTypeName = damageTypeInfo?['name'];
        final damageFactor = efficacy?['damage_factor'];

        if (damageTypeName is String && damageFactor is int) {
          final normalized = damageFactor / 100.0;
          final previous = matchupAccumulator[damageTypeName] ?? 1.0;
          matchupAccumulator[damageTypeName] = previous * normalized;
        }
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

    final characteristics = PokemonCharacteristics(
      height: height,
      weight: weight,
      baseExperience: baseExperience,
      captureRate: captureRate,
      category: category,
    );

    final List<TypeMatchup> typeMatchups = <TypeMatchup>[];
    matchupAccumulator.forEach((String typeName, double multiplier) {
      final normalized = double.parse(multiplier.toStringAsFixed(4));
      if ((normalized - 1.0).abs() < 0.01) {
        return;
      }
      typeMatchups.add(TypeMatchup(type: typeName, multiplier: normalized));
    });

    typeMatchups.sort((a, b) => b.multiplier.compareTo(a.multiplier));

    return PokemonDetail(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      imageUrl: _extractSpriteUrl(json['pokemon_v2_pokemonsprites']),
      types: types,
      abilities: abilities,
      stats: stats,
      characteristics: characteristics,
      typeMatchups: typeMatchups,
    );
  }
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
