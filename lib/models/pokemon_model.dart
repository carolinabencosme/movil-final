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
    required this.height,
    required this.weight,
    required this.imageUrl,
    required this.types,
    required this.abilities,
    required this.stats,
  });

  final int id;
  final String name;
  final int height;
  final int weight;
  final String imageUrl;
  final List<String> types;
  final List<String> abilities;
  final List<PokemonStat> stats;

  factory PokemonDetail.fromGraphQL(Map<String, dynamic> json) {
    final types = (json['pokemon_v2_pokemontypes'] as List<dynamic>? ?? [])
        .map((dynamic typeEntry) {
          final type = typeEntry as Map<String, dynamic>?;
          final typeInfo = type?['pokemon_v2_type'] as Map<String, dynamic>?;
          final name = typeInfo?['name'];
          return name is String ? name : null;
        })
        .whereType<String>()
        .toList();

    final abilities =
        (json['pokemon_v2_pokemonabilities'] as List<dynamic>? ?? [])
            .map((dynamic abilityEntry) {
              final ability = abilityEntry as Map<String, dynamic>?;
              final abilityInfo =
                  ability?['pokemon_v2_ability'] as Map<String, dynamic>?;
              final name = abilityInfo?['name'];
              return name is String ? name : null;
            })
            .whereType<String>()
            .toList();

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

    return PokemonDetail(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      height: json['height'] as int? ?? 0,
      weight: json['weight'] as int? ?? 0,
      imageUrl: _extractSpriteUrl(json['pokemon_v2_pokemonsprites']),
      types: types,
      abilities: abilities,
      stats: stats,
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

String _extractSpriteUrl(dynamic spriteEntries) {
  final sprites = spriteEntries as List<dynamic>?;
  if (sprites == null || sprites.isEmpty) {
    return '';
  }

  for (final entry in sprites) {
    if (entry is! Map<String, dynamic>) {
      continue;
    }

    final rawSprites = entry['sprites'];
    if (rawSprites is! String || rawSprites.isEmpty) {
      continue;
    }

    Map<String, dynamic>? decoded;
    try {
      final parsed = json.decode(rawSprites);
      if (parsed is Map<String, dynamic>) {
        decoded = parsed;
      }
    } catch (_) {
      continue;
    }

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

String? _selectSpriteFromMap(Map<String, dynamic> decoded) {
  final candidates = <String?>[
    _asNonEmptyString(decoded['front_default']),
    _getNestedString(decoded, ['other', 'official-artwork', 'front_default']),
    _getNestedString(decoded, ['other', 'home', 'front_default']),
    _getNestedString(decoded, ['other', 'dream_world', 'front_default']),
    _asNonEmptyString(decoded['front_shiny']),
    _getNestedString(decoded, ['other', 'official-artwork', 'front_shiny']),
    _getNestedString(decoded, ['other', 'home', 'front_shiny']),
  ];

  for (final candidate in candidates) {
    if (candidate != null) {
      return candidate;
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
