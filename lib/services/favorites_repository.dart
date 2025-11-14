import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/pokemon_model.dart';

const int _pokemonStatTypeId = 2;
const int _pokemonListItemTypeId = 3;

/// Repositorio que gestiona la persistencia de favoritos usando Hive.
///
/// Mantiene dos cajas:
/// - Una con los IDs marcados como favoritos.
/// - Otra con un caché de [PokemonListItem] para reconstruir la UI rápidamente.
class FavoritesRepository extends ChangeNotifier {
  FavoritesRepository._(this._favoritesBox, this._pokemonCacheBox)
      : _favoriteIds = _favoritesBox.keys.whereType<int>().toSet();

  static const String _favoritesBoxName = 'favorites_ids_box';
  static const String _pokemonCacheBoxName = 'favorites_pokemon_cache_box';

  final Box<bool> _favoritesBox;
  final Box<PokemonListItem> _pokemonCacheBox;

  final Set<int> _favoriteIds;

  /// Inicializa Hive y abre las cajas necesarias.
  static Future<FavoritesRepository> init() async {
    final PokemonStatAdapter statAdapter = PokemonStatAdapter();
    if (!Hive.isAdapterRegistered(statAdapter.typeId)) {
      Hive.registerAdapter(statAdapter);
    }

    final PokemonListItemAdapter listItemAdapter = PokemonListItemAdapter();
    if (!Hive.isAdapterRegistered(listItemAdapter.typeId)) {
      Hive.registerAdapter(listItemAdapter);
    }

    final Box<bool> favoritesBox = await Hive.openBox<bool>(_favoritesBoxName);
    final Box<PokemonListItem> pokemonCacheBox =
        await Hive.openBox<PokemonListItem>(_pokemonCacheBoxName);

    final FavoritesRepository repository =
        FavoritesRepository._(favoritesBox, pokemonCacheBox);
    await repository._normalizeCachedFavorites();
    return repository;
  }

  /// Lista de IDs favoritos ordenados ascendentemente.
  List<int> get favoriteIds {
    final List<int> ids = _favoriteIds.toList()..sort();
    return List<int>.unmodifiable(ids);
  }

  /// Lista de Pokémon favoritos actualmente almacenados.
  List<PokemonListItem> get favoritePokemons {
    final List<PokemonListItem> favorites = _favoriteIds
        .map(_pokemonCacheBox.get)
        .whereType<PokemonListItem>()
        .map((PokemonListItem pokemon) =>
            pokemon.copyWith(isFavorite: true))
        .toList()
      ..sort((PokemonListItem a, PokemonListItem b) => a.id.compareTo(b.id));
    return List<PokemonListItem>.unmodifiable(favorites);
  }

  /// Obtiene el estado de favorito para un ID determinado.
  bool isFavorite(int pokemonId) => _favoriteIds.contains(pokemonId);

  /// Devuelve el Pokémon en caché (si existe) con el estado de favorito actualizado.
  PokemonListItem? getCachedPokemon(int pokemonId) {
    final PokemonListItem? cached = _pokemonCacheBox.get(pokemonId);
    if (cached == null) {
      return null;
    }
    return _withFavoriteState(cached);
  }

  /// Actualiza el estado de favorito de un Pokémon (lo agrega o lo quita).
  Future<void> toggleFavorite(PokemonListItem pokemon) async {
    final int id = pokemon.id;
    if (id <= 0) {
      return;
    }

    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
      await _favoritesBox.delete(id);
      final PokemonListItem updated = _withFavoriteState(
        pokemon.copyWith(isFavorite: false),
      );
      await _pokemonCacheBox.put(id, updated);
    } else {
      _favoriteIds.add(id);
      await _favoritesBox.put(id, true);
      final PokemonListItem updated = _withFavoriteState(
        pokemon.copyWith(isFavorite: true),
      );
      await _pokemonCacheBox.put(id, updated);
    }

    notifyListeners();
  }

  /// Guarda o actualiza un Pokémon individual en el caché.
  Future<void> cachePokemon(PokemonListItem pokemon) async {
    final PokemonListItem normalized = _withFavoriteState(pokemon);
    final PokemonListItem? existing = _pokemonCacheBox.get(normalized.id);
    if (existing != null && _pokemonEquals(existing, normalized)) {
      return;
    }

    await _pokemonCacheBox.put(normalized.id, normalized);
    notifyListeners();
  }

  /// Guarda múltiples Pokémon en el caché minimizando escrituras redundantes.
  Future<void> cachePokemons(Iterable<PokemonListItem> pokemons) async {
    final Map<int, PokemonListItem> updates = <int, PokemonListItem>{};

    for (final PokemonListItem pokemon in pokemons) {
      final PokemonListItem normalized = _withFavoriteState(pokemon);
      final PokemonListItem? existing = _pokemonCacheBox.get(normalized.id);
      if (existing != null && _pokemonEquals(existing, normalized)) {
        continue;
      }
      updates[normalized.id] = normalized;
    }

    if (updates.isEmpty) {
      return;
    }

    await _pokemonCacheBox.putAll(updates);
    notifyListeners();
  }

  /// Devuelve una copia del Pokémon aplicando el estado de favorito almacenado.
  PokemonListItem withFavoriteState(PokemonListItem pokemon) {
    return _withFavoriteState(pokemon);
  }

  /// Aplica el estado de favorito a una lista completa de Pokémon.
  List<PokemonListItem> withFavoriteStateForList(
    Iterable<PokemonListItem> pokemons,
  ) {
    return pokemons.map(_withFavoriteState).toList(growable: false);
  }

  Future<void> _normalizeCachedFavorites() async {
    final List<Future<void>> operations = <Future<void>>[];

    for (final PokemonListItem pokemon in _pokemonCacheBox.values) {
      final PokemonListItem normalized = _withFavoriteState(pokemon);
      if (!_pokemonEquals(pokemon, normalized)) {
        operations.add(_pokemonCacheBox.put(normalized.id, normalized));
      }
    }

    if (operations.isNotEmpty) {
      await Future.wait(operations);
    }
  }

  PokemonListItem _withFavoriteState(PokemonListItem pokemon) {
    final bool shouldBeFavorite = _favoriteIds.contains(pokemon.id);
    if (pokemon.isFavorite == shouldBeFavorite) {
      return pokemon;
    }
    return pokemon.copyWith(isFavorite: shouldBeFavorite);
  }

  bool _pokemonEquals(PokemonListItem a, PokemonListItem b) {
    if (identical(a, b)) {
      return true;
    }

    if (a.id != b.id ||
        a.name != b.name ||
        a.imageUrl != b.imageUrl ||
        a.generationId != b.generationId ||
        a.generationName != b.generationName ||
        a.isFavorite != b.isFavorite) {
      return false;
    }

    if (!listEquals(a.types, b.types)) {
      return false;
    }

    if (a.stats.length != b.stats.length) {
      return false;
    }

    for (int index = 0; index < a.stats.length; index++) {
      if (!a.stats[index].isEquivalentTo(b.stats[index])) {
        return false;
      }
    }

    return true;
  }

  @override
  void dispose() {
    unawaited(_favoritesBox.close());
    unawaited(_pokemonCacheBox.close());
    super.dispose();
  }
}

class PokemonStatAdapter extends TypeAdapter<PokemonStat> {
  @override
  final int typeId = _pokemonStatTypeId;

  @override
  PokemonStat read(BinaryReader reader) {
    final int numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{};

    for (int i = 0; i < numOfFields; i++) {
      final int fieldKey = reader.readByte();
      fields[fieldKey] = reader.read();
    }

    return PokemonStat(
      name: fields[0] as String? ?? '',
      baseStat: fields[1] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, PokemonStat obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.baseStat);
  }
}

class PokemonListItemAdapter extends TypeAdapter<PokemonListItem> {
  @override
  final int typeId = _pokemonListItemTypeId;

  @override
  PokemonListItem read(BinaryReader reader) {
    final int numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{};

    for (int i = 0; i < numOfFields; i++) {
      final int fieldKey = reader.readByte();
      fields[fieldKey] = reader.read();
    }

    return PokemonListItem(
      id: fields[0] as int? ?? 0,
      name: fields[1] as String? ?? '',
      imageUrl: fields[2] as String? ?? '',
      types: (fields[3] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toList(),
      stats: (fields[4] as List<dynamic>? ?? const <dynamic>[])
          .whereType<PokemonStat>()
          .toList(),
      generationId: fields[5] as int?,
      generationName: fields[6] as String?,
      isFavorite: fields[7] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, PokemonListItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.types.toList())
      ..writeByte(4)
      ..write(obj.stats.toList())
      ..writeByte(5)
      ..write(obj.generationId)
      ..writeByte(6)
      ..write(obj.generationName)
      ..writeByte(7)
      ..write(obj.isFavorite);
  }
}
