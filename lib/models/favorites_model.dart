import 'package:hive/hive.dart';

/// Modelo que representa un Pokémon favorito guardado localmente
class FavoritePokemon {
  const FavoritePokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
  });

  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoritePokemon && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Adaptador de Hive para leer/escribir `FavoritePokemon` en almacenamiento binario.
class FavoritePokemonAdapter extends TypeAdapter<FavoritePokemon> {
  /// Identificador único de tipo para Hive (diferente del UserModelAdapter).
  @override
  final int typeId = 2;

  /// Deserializa desde el formato binario de Hive.
  @override
  FavoritePokemon read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};

    for (var i = 0; i < numOfFields; i++) {
      final fieldKey = reader.readByte();
      fields[fieldKey] = reader.read();
    }

    return FavoritePokemon(
      id: fields[0] as int,
      name: fields[1] as String,
      imageUrl: fields[2] as String,
      types: (fields[3] as List).cast<String>(),
    );
  }

  /// Serializa el objeto al formato binario de Hive.
  @override
  void write(BinaryWriter writer, FavoritePokemon obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.types);
  }
}
