import 'package:hive/hive.dart';

/// Representa el resultado de una sesión de trivia.
///
/// Guarda el nombre del jugador, la puntuación obtenida, la cantidad de
/// preguntas jugadas y la fecha en la que se registró la sesión.
class TriviaScore {
  const TriviaScore({
    required this.playerName,
    required this.score,
    required this.questionsPlayed,
    required this.playedAt,
  });

  /// Nombre mostrado en el ranking. Puede ser el correo o apodo.
  final String playerName;

  /// Puntuación numérica asociada a la sesión.
  final int score;

  /// Número de preguntas respondidas durante la sesión.
  final int questionsPlayed;

  /// Momento en el que se guardó la sesión.
  final DateTime playedAt;

  TriviaScore copyWith({
    String? playerName,
    int? score,
    int? questionsPlayed,
    DateTime? playedAt,
  }) {
    return TriviaScore(
      playerName: playerName ?? this.playerName,
      score: score ?? this.score,
      questionsPlayed: questionsPlayed ?? this.questionsPlayed,
      playedAt: playedAt ?? this.playedAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'playerName': playerName,
        'score': score,
        'questionsPlayed': questionsPlayed,
        'playedAt': playedAt.toIso8601String(),
      };

  factory TriviaScore.fromJson(Map<String, dynamic> json) => TriviaScore(
        playerName: json['playerName'] as String? ?? 'Jugador',
        score: json['score'] as int? ?? 0,
        questionsPlayed: json['questionsPlayed'] as int? ?? 0,
        playedAt:
            DateTime.tryParse(json['playedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class TriviaScoreAdapter extends TypeAdapter<TriviaScore> {
  @override
  final int typeId = 4;

  @override
  TriviaScore read(BinaryReader reader) {
    final int numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{};

    for (int i = 0; i < numOfFields; i++) {
      final int fieldKey = reader.readByte();
      fields[fieldKey] = reader.read();
    }

    return TriviaScore(
      playerName: fields[0] as String? ?? 'Jugador',
      score: fields[1] as int? ?? 0,
      questionsPlayed: fields[2] as int? ?? 0,
      playedAt: fields[3] as DateTime? ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, TriviaScore obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.playerName)
      ..writeByte(1)
      ..write(obj.score)
      ..writeByte(2)
      ..write(obj.questionsPlayed)
      ..writeByte(3)
      ..write(obj.playedAt);
  }
}
