import 'package:hive/hive.dart';

/// Modelo de usuario para almacenamiento local con Hive.
///
/// ⚠️ Seguridad:
/// - `passwordHash` debe ser un hash seguro (p. ej., Argon2/Bcrypt/Scrypt) con salt.
/// - Nunca guardes contraseñas en texto plano.
/// - Considera cifrar la box de Hive o usar `HiveAesCipher` si almacenas datos sensibles.
class UserModel {
  const UserModel({
    required this.email,
    required this.passwordHash,
  });

  /// Correo del usuario. También puede servir como clave única.
  final String email;

  /// Hash de la contraseña (no la contraseña en claro).
  final String passwordHash;

  /// Crea una copia inmutable con cambios puntuales.
  UserModel copyWith({
    String? email,
    String? passwordHash,
  }) =>
      UserModel(
        email: email ?? this.email,
        passwordHash: passwordHash ?? this.passwordHash,
      );

  /// Serializa a JSON (útil para logs, envío a red, backups).
  /// Nota: si serializas fuera del dispositivo, asegúrate de transmitir
  /// y almacenar de forma segura (TLS, cifrado, etc.).
  Map<String, dynamic> toJson() => {
    'email': email,
    'passwordHash': passwordHash,
  };

  /// Crea un `UserModel` desde JSON.
  /// Asume que las claves existen y son `String`. Valida en capa superior si es necesario.
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    email: json['email'] as String,
    passwordHash: json['passwordHash'] as String,
  );
}

/// Adaptador de Hive para leer/escribir `UserModel` en almacenamiento binario.
///
/// - `typeId` debe ser único dentro de tu app.
/// - Si cambias el esquema (agregas/quitas/renombras campos), incrementa
///   el número de campos escritos y ajusta `read` para compatibilidad hacia atrás.
class UserModelAdapter extends TypeAdapter<UserModel> {
  /// Identificador único de tipo para Hive (no lo repitas en otros adapters).
  @override
  final int typeId = 1;

  /// Deserializa desde el formato binario de Hive.
  /// Lee la cantidad de campos y luego un mapa `fieldKey -> valor`.
  /// Los índices (0,1,...) deben coincidir con los usados en `write`.
  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};

    // Lee todos los pares (clave de campo, valor) que fueron escritos.
    for (var i = 0; i < numOfFields; i++) {
      final fieldKey = reader.readByte();
      fields[fieldKey] = reader.read();
    }

    // Reconstruye el modelo usando los índices acordados.
    // Si en el futuro agregas campos, usa `fields[clave] ?? valorPorDefecto`
    // para mantener compatibilidad con registros antiguos.
    return UserModel(
      email: fields[0] as String,
      passwordHash: fields[1] as String,
    );
  }

  /// Serializa el objeto al formato binario de Hive.
  /// El orden y los índices deben permanecer estables para compatibilidad.
  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
    // Cantidad de campos que se escribirán.
      ..writeByte(2)
    // Campo 0: email
      ..writeByte(0)
      ..write(obj.email)
    // Campo 1: passwordHash
      ..writeByte(1)
      ..write(obj.passwordHash);
  }
}
