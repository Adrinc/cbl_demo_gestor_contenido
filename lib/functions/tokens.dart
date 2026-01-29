import 'dart:convert';
import 'dart:developer';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:energy_media/models/models.dart';

Token? parseToken(String token) {
  try {
    // Verify a token
    final jwt = JWT.verify(token, SecretKey('secret'));
    return Token.fromJson(json.encode(jwt.payload), token);
  } on JWTExpiredException {
    log('JWT expirada');
  } on JWTException catch (ex) {
    log('Error en checkToken - $ex');
  } on Exception {
    return null;
  }
  return null;
}
