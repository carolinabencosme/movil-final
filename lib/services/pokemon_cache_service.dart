import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/pokemon_model.dart';
import 'pokemon_hive_adapters.dart';

class PokemonCacheService {
  PokemonCacheService._(this._box);

  static const String _boxName = 'pokemon_cache_box';
  static PokemonCacheService? _instance;

  final Box<PokemonListItem> _box;

  static Future<PokemonCacheService> init() async {
    registerPokemonHiveAdapters();
    final Box<PokemonListItem> box = await Hive.openBox<PokemonListItem>(_boxName);
    _instance ??= PokemonCacheService._(box);
    return _instance!;
  }

  static PokemonCacheService get instance {
    final PokemonCacheService? service = _instance;
    if (service == null) {
      throw StateError(
        'PokemonCacheService.init() must be called before accessing the instance.',
      );
    }
    return service;
  }

  Box<PokemonListItem> get box => _box;

  Future<void> cachePokemon(PokemonListItem pokemon) async {
    final PokemonListItem? existing = _box.get(pokemon.id);
    if (existing != null && _equals(existing, pokemon)) {
      return;
    }
    await _box.put(pokemon.id, pokemon);
  }

  Future<void> cachePokemons(Iterable<PokemonListItem> pokemons) async {
    final Map<int, PokemonListItem> updates = <int, PokemonListItem>{};
    for (final PokemonListItem pokemon in pokemons) {
      final PokemonListItem? existing = _box.get(pokemon.id);
      if (existing != null && _equals(existing, pokemon)) {
        continue;
      }
      updates[pokemon.id] = pokemon;
    }

    if (updates.isEmpty) {
      return;
    }

    await _box.putAll(updates);
  }

  PokemonListItem? getPokemon(int id) {
    return _box.get(id);
  }

  PokemonListItem? findByName(String name) {
    final String normalized = name.toLowerCase().trim();
    for (final PokemonListItem pokemon in _box.values) {
      if (pokemon.name.toLowerCase() == normalized) {
        return pokemon;
      }
    }
    return null;
  }

  List<PokemonListItem> getAll({bool sorted = true}) {
    final List<PokemonListItem> items = _box.values.toList();
    if (sorted) {
      items.sort((a, b) => a.id.compareTo(b.id));
    }
    return items;
  }

  bool get isEmpty => _box.isEmpty;

  Future<void> close() async {
    await _box.close();
  }

  bool _equals(PokemonListItem a, PokemonListItem b) {
    if (identical(a, b)) {
      return true;
    }

    if (a.id != b.id ||
        a.name != b.name ||
        a.imageUrl != b.imageUrl ||
        a.generationId != b.generationId ||
        a.generationName != b.generationName ||
        a.height != b.height ||
        a.weight != b.weight ||
        a.regionName != b.regionName ||
        a.shapeName != b.shapeName ||
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
}
