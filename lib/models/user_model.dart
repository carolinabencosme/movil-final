import 'package:hive/hive.dart';

class UserModel {
  const UserModel({
    required this.email,
    required this.passwordHash,
  });

  final String email;
  final String passwordHash;

  UserModel copyWith({
    String? email,
    String? passwordHash,
  }) =>
      UserModel(
        email: email ?? this.email,
        passwordHash: passwordHash ?? this.passwordHash,
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'passwordHash': passwordHash,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        email: json['email'] as String,
        passwordHash: json['passwordHash'] as String,
      );
}

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final fieldKey = reader.readByte();
      fields[fieldKey] = reader.read();
    }
    return UserModel(
      email: fields[0] as String,
      passwordHash: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.passwordHash);
  }
}
