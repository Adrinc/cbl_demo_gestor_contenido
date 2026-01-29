/// **DEMO MODE - Users Provider Stub**
///
/// Este provider está simplificado para el modo demo 100% offline.
/// Todas las funciones de usuarios y Supabase han sido eliminadas.
/// La gestión de usuarios NO está disponible en este demo.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

// import 'package:energy_media/helpers/constants.dart'; // DEMO MODE: No usado
import 'package:energy_media/models/models.dart';

class UsersProvider extends ChangeNotifier {
  PlutoGridStateManager? stateManager;
  List<PlutoRow> rows = [];

  // Controladores (mantenidos para compatibilidad)
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  Role? selectedRole;

  List<Role> roles = [];
  List<User> users = [];

  String? imageName;
  Uint8List? webImage;

  final busquedaController = TextEditingController();
  String orden = "sequential_id";

  // ========== DEMO MODE STUBS ==========
  // Funciones vacías para mantener compatibilidad

  Future<void> updateState() async {
    busquedaController.clear();
    // DEMO MODE: No hay usuarios reales
    notifyListeners();
  }

  void clearControllers({bool clearEmail = true, bool notify = true}) {
    nameController.clear();
    if (clearEmail) emailController.clear();
    lastNameController.clear();
    phoneController.clear();
    selectedRole = null;
    imageName = null;
    webImage = null;
    if (notify) notifyListeners();
  }

  void setSelectedRole(String role) {
    // DEMO MODE: No hace nada
    notifyListeners();
  }

  Future<void> getRoles({bool notify = true}) async {
    // DEMO MODE: Lista vacía de roles
    roles = [];
    if (notify) notifyListeners();
  }

  Future<void> getUsers() async {
    // DEMO MODE: Lista vacía de usuarios
    users = [];
    fillPlutoGrid(users);
  }

  void fillPlutoGrid(List<User> users) {
    rows.clear();
    // DEMO MODE: Grid vacío
    if (stateManager != null) stateManager!.notifyListeners();
    notifyListeners();
  }

  Future<void> selectImage() async {
    // DEMO MODE: No hace nada
    notifyListeners();
  }

  void clearImage() {
    webImage = null;
    imageName = null;
    notifyListeners();
  }

  Future<String?> uploadImage() async => null;

  Future<void> validateImage(String? imagen) async {}

  Future<Map<String, String>?> registerUser() async {
    return {'Error': 'Demo mode - User registration disabled'};
  }

  Future<bool> createUserProfile(String userId) async => false;

  Future<bool> editUserProfile(String userId) async => false;

  Future<void> initEditUser(User user) async {
    nameController.text = user.firstName;
    lastNameController.text = user.lastName;
    emailController.text = user.email;
    phoneController.text = user.mobilePhone ?? '';
    selectedRole = user.role;
    imageName = user.image;
    webImage = null;
  }

  String generatePassword() => 'demo-password';

  Future<bool> sendEmail(
          String email, String? password, String token, String type) async =>
      true;

  Future<bool> borrarUsuario(String userId) async => false;

  @override
  void dispose() {
    busquedaController.dispose();
    nameController.dispose();
    emailController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
