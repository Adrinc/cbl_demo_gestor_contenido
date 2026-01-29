import 'dart:convert';
import 'dart:developer';

import 'package:energy_media/helpers/globals.dart';

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

  Future<bool> validate(String type) async {
    int timeLimit = 5;

    try {
      final minutesPassed =
          DateTime.now().toUtc().difference(created).inMinutes;
      if (minutesPassed < timeLimit) {
        final res = await supabase
            .from('token')
            .select('token_$type')
            .eq('user_id', userId);
        final validatedToken = res[0]['token_$type'];
        if (token == validatedToken) return true;
      }
    } catch (e) {
      log('Error en validateToken - $e');
      return false;
    }

    return false;
  }
}
