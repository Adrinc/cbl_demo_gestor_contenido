import 'dart:convert';

/// **DEMO MODE - Token Model**
/// Modelo de token simplificado para modo demo.
/// La validación real de tokens está deshabilitada.

class Token {
  Token({
    required this.token,
    required this.userId,
    required this.email,
    required this.created,
  });

  String token;
  String userId;
  String email;
  DateTime created;

  factory Token.fromJson(String str, String token) =>
      Token.fromMap(json.decode(str), token);

  String toJson() => json.encode(toMap());

  factory Token.fromMap(Map<String, dynamic> payload, String token) {
    return Token(
      token: token,
      userId: payload["user_id"],
      email: payload["email"],
      created: DateTime.parse(payload['created']),
    );
  }

  Map<String, dynamic> toMap() => {
        "user_id": userId,
        "email": email,
        "created": created,
      };

  /// DEMO MODE: Siempre retorna true (sin validación real de tokens)
  Future<bool> validate(String type) async => true;
}
