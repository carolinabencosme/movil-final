/// Modelos para representar habilidades (abilities) de Pokémon,
/// con soporte para nombres y descripciones localizadas (ES/EN)
/// a partir de respuestas de GraphQL.

class AbilitySummary {
  /// Resumen de una habilidad: incluye id, nombre base (API),
  /// nombre para mostrar (localizado), y efectos corto/completo.
  AbilitySummary({
    required this.id,
    required this.name,
    required this.displayName,
    required this.shortEffect,
    required this.fullEffect,
  });
  /// Identificador interno de la habilidad (entero de la API).
  final int id;
  /// Nombre "técnico" de la habilidad tal como viene en la API (en inglés y snake_case).
  final String name;
  /// Nombre listo para mostrar, elegido según idioma disponible (ES → EN → fallback).
  final String displayName;
  /// Descripción corta de la habilidad (localizada si es posible).
  final String shortEffect;
  /// Descripción completa de la habilidad (localizada si es posible).
  final String fullEffect;

  /// Crea un [AbilitySummary] a partir del JSON de GraphQL.
  /// - Busca nombres en `pokemon_v2_abilitynames` y efectos en `pokemon_v2_abilityeffecttexts`.
  /// - Aplica lógica de localización: prioriza español (language_id=7) luego inglés (language_id=9).
  factory AbilitySummary.fromGraphQL(Map<String, dynamic> json) {
    final names = json['pokemon_v2_abilitynames'] as List<dynamic>? ?? <dynamic>[];
    final effects =
        json['pokemon_v2_abilityeffecttexts'] as List<dynamic>? ?? <dynamic>[];

    // Selecciona un nombre localizado; si no hay, cae al nombre base del JSON.
    final localizedName = _pickLocalizedValue(names, fallback: json['name']);

    // Extrae descripciones corta y completa con preferencia ES→EN.
    final effectTexts = _extractEffectTexts(effects);

    return AbilitySummary(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      displayName: localizedName,
      shortEffect: effectTexts.shortEffect,
      fullEffect: effectTexts.fullEffect,
    );
  }

  /// Devuelve una copia con cambios puntuales (inmutable).
  /// Por ahora permite reemplazar solo `fullEffect`.
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

/// Versión extendida de [AbilitySummary] que además lista
/// referencias a Pokémon que poseen la habilidad.
class AbilityDetail extends AbilitySummary {
  AbilityDetail({
    required super.id,
    required super.name,
    required super.displayName,
    required super.shortEffect,
    required super.fullEffect,
    this.pokemon = const <AbilityPokemonRef>[],
  });

  /// Lista de Pokémon (id y name) que tienen esta habilidad.
  final List<AbilityPokemonRef> pokemon;

  /// Crea un [AbilityDetail] a partir del JSON de GraphQL.
  /// - Reutiliza el constructor de resumen para los campos base.
  /// - Mapea `pokemon_v2_pokemonabilities` → `AbilityPokemonRef`.
  factory AbilityDetail.fromGraphQL(Map<String, dynamic> json) {
    // Construye primero el resumen (id/nombres/efectos).
    final summary = AbilitySummary.fromGraphQL(json);

    // Lee entradas de Pokémon con esta habilidad.
    final pokemonEntries =
        json['pokemon_v2_pokemonabilities'] as List<dynamic>? ?? <dynamic>[];

    // Convierte cada entrada en un AbilityPokemonRef válido (si tiene id y name).
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
        // Filtra nulos resultantes de entradas incompletas.
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

/// Referencia mínima a un Pokémon (id y name) para listarlo junto a la habilidad.
class AbilityPokemonRef {
  const AbilityPokemonRef({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  /// Nombre con la primera letra en mayúscula, útil para UI.
  String get formattedName {
    if (name.isEmpty) return '';
    return name[0].toUpperCase() + name.substring(1);
  }
}

/// Contenedor interno para devolver ambas variantes de texto de efecto.
class _EffectTexts {
  const _EffectTexts({required this.shortEffect, required this.fullEffect});

  final String shortEffect;
  final String fullEffect;
}

/// Elige el valor localizado de una lista de entradas con `language_id` y `name`.
/// Prioriza español (id=7); si no hay, inglés (id=9); si no, usa [fallback].
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

// Si no hubo nada localizado, cae al fallback (el `json['name']`).
  if (chosen == null || chosen.isEmpty) {
    if (fallback is String && fallback.isNotEmpty) {
      return fallback;
    }
    return '';
  }

  return chosen;
}

/// Extrae las descripciones corta y completa desde entradas con
/// `language_id`, `short_effect` y `effect`.
/// Orden de preferencia: español → inglés. Si falta alguno, reutiliza el otro
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

    // Guarda la mejor versión disponible por idioma (si no está vacía).
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

// Resuelve valores finales con degradación razonable.
  final shortEffect = shortSpanish ?? shortEnglish ?? fullSpanish ?? fullEnglish ?? '';
  final fullEffect = fullSpanish ?? fullEnglish ?? shortEffect;

  return _EffectTexts(
    shortEffect: _cleanEffectText(shortEffect),
    fullEffect: _cleanEffectText(fullEffect),
  );
}
/// Normaliza el texto de efecto para mejorar la legibilidad en UI:
/// - Convierte saltos de línea `\n` en párrafos (`\n\n`).
/// - Reemplaza `\f` por espacio.
/// - Elimina espacios extra al inicio/fin.
String _cleanEffectText(String value) {
  return value
      .replaceAll('\n', '\n\n')
      .replaceAll('\f', ' ')
      .trim();
}
