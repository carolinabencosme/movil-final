class AbilitySummary {
  AbilitySummary({
    required this.id,
    required this.name,
    required this.displayName,
    required this.shortEffect,
    required this.fullEffect,
  });

  final int id;
  final String name;
  final String displayName;
  final String shortEffect;
  final String fullEffect;

  factory AbilitySummary.fromGraphQL(Map<String, dynamic> json) {
    final names = json['pokemon_v2_abilitynames'] as List<dynamic>? ?? <dynamic>[];
    final effects =
        json['pokemon_v2_abilityeffecttexts'] as List<dynamic>? ?? <dynamic>[];

    final localizedName = _pickLocalizedValue(names, fallback: json['name']);
    final effectTexts = _extractEffectTexts(effects);

    return AbilitySummary(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      displayName: localizedName,
      shortEffect: effectTexts.shortEffect,
      fullEffect: effectTexts.fullEffect,
    );
  }

  AbilitySummary copyWith({
    String? fullEffect,
  }) {
    return AbilitySummary(
      id: id,
      name: name,
      displayName: displayName,
      shortEffect: shortEffect,
      fullEffect: fullEffect ?? this.fullEffect,
    );
  }
}

class AbilityDetail extends AbilitySummary {
  AbilityDetail({
    required super.id,
    required super.name,
    required super.displayName,
    required super.shortEffect,
    required super.fullEffect,
    this.pokemon = const <AbilityPokemonRef>[],
  });

  final List<AbilityPokemonRef> pokemon;

  factory AbilityDetail.fromGraphQL(Map<String, dynamic> json) {
    final summary = AbilitySummary.fromGraphQL(json);
    final pokemonEntries =
        json['pokemon_v2_pokemonabilities'] as List<dynamic>? ?? <dynamic>[];

    final pokemon = pokemonEntries
        .map((dynamic entry) {
          final data = entry as Map<String, dynamic>?;
          final pokemonInfo =
              data?['pokemon_v2_pokemon'] as Map<String, dynamic>?;
          if (pokemonInfo == null) {
            return null;
          }
          final id = pokemonInfo['id'];
          final name = pokemonInfo['name'];
          if (id is int && name is String) {
            return AbilityPokemonRef(id: id, name: name);
          }
          return null;
        })
        .whereType<AbilityPokemonRef>()
        .toList();

    return AbilityDetail(
      id: summary.id,
      name: summary.name,
      displayName: summary.displayName,
      shortEffect: summary.shortEffect,
      fullEffect: summary.fullEffect,
      pokemon: pokemon,
    );
  }
}

class AbilityPokemonRef {
  const AbilityPokemonRef({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  String get formattedName {
    if (name.isEmpty) return '';
    return name[0].toUpperCase() + name.substring(1);
  }
}

class _EffectTexts {
  const _EffectTexts({required this.shortEffect, required this.fullEffect});

  final String shortEffect;
  final String fullEffect;
}

String _pickLocalizedValue(List<dynamic> entries, {Object? fallback}) {
  String? chosen;
  String? fallbackEnglish;
  String? fallbackSpanish;

  for (final dynamic entry in entries) {
    final data = entry as Map<String, dynamic>?;
    final languageId = data?['language_id'];
    final name = data?['name'];
    if (languageId is int && name is String) {
      if (languageId == 7 && name.isNotEmpty) {
        fallbackSpanish = name;
      } else if (languageId == 9 && name.isNotEmpty) {
        fallbackEnglish = name;
      }
    }
  }

  chosen = fallbackSpanish ?? fallbackEnglish;

  if (chosen == null || chosen.isEmpty) {
    if (fallback is String && fallback.isNotEmpty) {
      return fallback;
    }
    return '';
  }

  return chosen;
}

_EffectTexts _extractEffectTexts(List<dynamic> entries) {
  String? shortSpanish;
  String? shortEnglish;
  String? fullSpanish;
  String? fullEnglish;

  for (final dynamic entry in entries) {
    final data = entry as Map<String, dynamic>?;
    final languageId = data?['language_id'];
    final shortEffect = data?['short_effect'];
    final effect = data?['effect'];
    if (languageId is! int) continue;

    if (languageId == 7) {
      if (shortEffect is String && shortEffect.isNotEmpty) {
        shortSpanish = shortEffect;
      }
      if (effect is String && effect.isNotEmpty) {
        fullSpanish = effect;
      }
    } else if (languageId == 9) {
      if (shortEffect is String && shortEffect.isNotEmpty) {
        shortEnglish = shortEffect;
      }
      if (effect is String && effect.isNotEmpty) {
        fullEnglish = effect;
      }
    }
  }

  final shortEffect = shortSpanish ?? shortEnglish ?? fullSpanish ?? fullEnglish ?? '';
  final fullEffect = fullSpanish ?? fullEnglish ?? shortEffect;

  return _EffectTexts(
    shortEffect: _cleanEffectText(shortEffect),
    fullEffect: _cleanEffectText(fullEffect),
  );
}

String _cleanEffectText(String value) {
  return value
      .replaceAll('\n', '\n\n')
      .replaceAll('\f', ' ')
      .trim();
}
