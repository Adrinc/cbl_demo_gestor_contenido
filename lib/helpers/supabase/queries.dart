import 'dart:convert';
import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:energy_media/helpers/globals.dart';
import 'package:energy_media/models/models.dart';

class SupabaseQueries {
  static Future<User?> getCurrentUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final PostgrestFilterBuilder query =
          supabase.from('users').select().eq('user_profile_id', user.id);

      final res = await query;

      final userProfile = res[0];
      userProfile['id'] = user.id;
      userProfile['email'] = user.email!;

      final usuario = User.fromMap(userProfile);

      return usuario;
    } catch (e) {
      log('Error en getCurrentUserData() - $e');
      return null;
    }
  }

  static Future<Configuration?> getDefaultTheme() async {
    try {
      final res = await supabase.from('theme').select().eq('id', 1);
      return Configuration.fromJson(jsonEncode(res[0]));
    } catch (e) {
      log('Error en getDefaultTheme() - $e');
      return null;
    }
  }

  static Future<Configuration?> getUserTheme() async {
    try {
      if (currentUser == null) return null;
      final res = await supabase.from('users').select('config').eq(
          'sequential_id',
          currentUser!
              .sequentialId); //final res = await supabase.from('theme').select().eq('id', 2);
      return Configuration.fromJson(jsonEncode(res[0]));
    } catch (e) {
      log('Error en getUserTheme() - $e');
      return null;
    }
  }

  static Future<bool> tokenChangePassword(String id, String newPassword) async {
    try {
      final res = await supabase.rpc('token_change_password', params: {
        'user_id': id,
        'new_password': newPassword,
      });

      if (res['data'] == true) {
        return true;
      }
    } catch (e) {
      log('Error en tokenChangePassword() - $e');
    }
    return false;
  }

  static Future<bool> saveToken(
    String userId,
    String tokenType,
    String token,
  ) async {
    try {
      await supabase
          .from('token')
          .upsert({'user_id': userId, tokenType: token});
      return true;
    } catch (e) {
      log('Error en saveToken() - $e');
    }
    return false;
  }
}
