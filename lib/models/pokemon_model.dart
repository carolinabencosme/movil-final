import 'dart:convert';

class PokemonListItem {
  PokemonListItem({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final String imageUrl;

  factory PokemonListItem.fromGraphQL(Map<String, dynamic> json) {
    return PokemonListItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      imageUrl: _extractSpriteUrl(json['pokemon_v2_pokemonsprites']),
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

  final firstEntry = sprites.first;
  if (firstEntry is! Map<String, dynamic>) {
    return '';
  }

  final rawSprites = firstEntry['sprites'];
  if (rawSprites is! String || rawSprites.isEmpty) {
    return '';
  }

  try {
    final decoded = json.decode(rawSprites) as Map<String, dynamic>;
    final frontDefault = decoded['front_default'];
    if (frontDefault is String) {
      return frontDefault;
    }
  } catch (_) {
    return '';
  }

  return '';
}
