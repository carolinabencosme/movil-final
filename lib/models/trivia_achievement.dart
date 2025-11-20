import 'package:hive/hive.dart';

/// Representa un logro del modo trivia.
///
/// Cada logro almacena su identificador, textos descriptivos, el nombre de un
/// ícono y la fecha en la que fue desbloqueado. Cuando [unlockedAt] es `null`,
/// el logro aún no ha sido conseguido.
class TriviaAchievement {
  const TriviaAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    this.unlockedAt,
  });

  final String id;
  final String title;
  final String description;
  final String iconName;
  final DateTime? unlockedAt;

  bool get isUnlocked => unlockedAt != null;

  TriviaAchievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    DateTime? unlockedAt,
  }) {
    return TriviaAchievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

class TriviaAchievementAdapter extends TypeAdapter<TriviaAchievement> {
  @override
  final int typeId = 5;

  @override
  TriviaAchievement read(BinaryReader reader) {
    final int numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{};

    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return TriviaAchievement(
      id: fields[0] as String? ?? '',
      title: fields[1] as String? ?? '',
      description: fields[2] as String? ?? '',
      iconName: fields[3] as String? ?? 'military_tech',
      unlockedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TriviaAchievement obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconName)
      ..writeByte(4)
      ..write(obj.unlockedAt);
  }
}
