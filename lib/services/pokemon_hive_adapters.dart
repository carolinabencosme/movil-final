import 'package:hive/hive.dart';

import '../models/pokemon_model.dart';

const int kPokemonStatTypeId = 2;
const int kPokemonListItemTypeId = 3;

/// Registra los adaptadores de Hive utilizados para almacenar datos de Pokémon.
void registerPokemonHiveAdapters() {
  final PokemonStatAdapter statAdapter = PokemonStatAdapter();
  if (!Hive.isAdapterRegistered(statAdapter.typeId)) {
    Hive.registerAdapter(statAdapter);
  }

  final PokemonListItemAdapter listItemAdapter = PokemonListItemAdapter();
  if (!Hive.isAdapterRegistered(listItemAdapter.typeId)) {
    Hive.registerAdapter(listItemAdapter);
  }
}

class PokemonStatAdapter extends TypeAdapter<PokemonStat> {
  @override
  final int typeId = kPokemonStatTypeId;

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
  final int typeId = kPokemonListItemTypeId;

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
      height: fields[8] as int?,
      weight: fields[9] as int?,
      regionName: fields[10] as String?,
      shapeName: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PokemonListItem obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.isFavorite)
      ..writeByte(8)
      ..write(obj.height)
      ..writeByte(9)
      ..write(obj.weight)
      ..writeByte(10)
      ..write(obj.regionName)
      ..writeByte(11)
      ..write(obj.shapeName);
  }
}
