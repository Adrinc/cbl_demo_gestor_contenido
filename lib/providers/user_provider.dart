/// **DEMO MODE - User Provider Stub**
///
/// Este provider está simplificado para el modo demo 100% offline.
/// Todas las funciones de autenticación y Supabase han sido eliminadas.

import 'package:flutter/material.dart';
import 'package:energy_media/helpers/globals.dart';
import 'package:energy_media/router/router.dart';

class UserState extends ChangeNotifier {
  // Controladores para LoginScreen (mantenidos para compatibilidad)
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool recuerdame = false;

  // Variables para editar perfil (mantenidos para compatibilidad)
  TextEditingController nombrePerfil = TextEditingController();
  TextEditingController apellidosPerfil = TextEditingController();
  TextEditingController telefonoPerfil = TextEditingController();
  TextEditingController extensionPerfil = TextEditingController();
  TextEditingController emailPerfil = TextEditingController();
  TextEditingController contrasenaAnteriorPerfil = TextEditingController();
  TextEditingController confirmarContrasenaPerfil = TextEditingController();
  TextEditingController contrasenaPerfil = TextEditingController();

  int loginAttempts = 0;
  bool userChangedPasswordInLast90Days = true;

  UserState() {
    recuerdame = prefs.getBool('recuerdame') ?? false;
    if (recuerdame == true) {
      emailController.text = prefs.getString('email') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
    }
  }

  Future<void> setEmail() async {
    await prefs.setString('email', emailController.text);
  }

  Future<void> setPassword() async {
    await prefs.setString('password', passwordController.text);
  }

  Future<void> updateRecuerdame() async {
    recuerdame = !recuerdame;
    await prefs.setBool('recuerdame', recuerdame);
    notifyListeners();
  }

  // ========== DEMO MODE STUBS ==========
  // Estas funciones retornan valores mock para mantener compatibilidad

  /// DEMO MODE: Siempre retorna true (sin validación real)
  Future<bool> actualizarContrasena() async => true;

  /// DEMO MODE: Siempre retorna null (sin validación real)
  Future<Map<String, String>?> resetPassword(String email) async => null;

  /// DEMO MODE: Retorna un ID mock
  Future<String?> getUserId(String email) async => 'demo-user-id';

  /// DEMO MODE: Siempre retorna true
  Future<bool> validateAccessCode(String userId, String accessCode) async =>
      true;

  /// DEMO MODE: Siempre retorna true
  Future<bool> sendAccessCode(String userId) async => true;

  /// DEMO MODE: No hace nada
  Future<void> incrementLoginAttempts(String email) async {
    loginAttempts += 1;
    if (loginAttempts >= 3) {
      loginAttempts = 0;
    }
    notifyListeners();
  }

  /// DEMO MODE: No hace nada
  Future<void> registerLogin(String userId) async {}

  /// DEMO MODE: Siempre retorna false (usuario no bloqueado)
  Future<bool> checkIfUserBlocked(String email) async => false;

  /// DEMO MODE: No hace nada
  Future<void> checkIfUserChangedPasswordInLast90Days(String userId) async {
    userChangedPasswordInLast90Days = true;
  }

  /// DEMO MODE: Solo limpia estado y navega al inicio
  Future<void> logout() async {
    currentUser = null;
    await prefs.remove('currentRol');
    router.pushReplacement('/');
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nombrePerfil.dispose();
    emailPerfil.dispose();
    contrasenaPerfil.dispose();
    super.dispose();
  }
}
