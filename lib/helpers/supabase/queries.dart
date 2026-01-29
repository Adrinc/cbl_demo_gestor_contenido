/// **DEMO MODE - Queries Stub**
///
/// Este archivo está vacío porque el modo demo no usa Supabase.
/// Se mantiene para evitar errores de importación en código legacy.

import 'package:energy_media/models/models.dart';

class SupabaseQueries {
  /// DEMO MODE: Siempre retorna null (sin autenticación real)
  static Future<User?> getCurrentUserData() async => null;

  /// DEMO MODE: Retorna null (sin temas de BD)
  static Future<Configuration?> getDefaultTheme() async => null;

  /// DEMO MODE: Retorna null (sin temas de usuario)
  static Future<Configuration?> getUserTheme() async => null;

  /// DEMO MODE: Siempre retorna false
  static Future<bool> tokenChangePassword(
          String id, String newPassword) async =>
      false;

  /// DEMO MODE: Siempre retorna false
  static Future<bool> saveToken(
          String userId, String tokenType, String token) async =>
      false;
}
