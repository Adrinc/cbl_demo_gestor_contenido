import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:random_password_generator/random_password_generator.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:http/http.dart' as http;

import 'package:energy_media/helpers/constants.dart';
import 'package:energy_media/helpers/globals.dart';
import 'package:energy_media/models/models.dart';
import 'package:energy_media/services/api_error_handler.dart';

class UsersProvider extends ChangeNotifier {
  PlutoGridStateManager? stateManager;
  List<PlutoRow> rows = [];

  //CREATE USUARIO
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  Role? selectedRole;

  List<Role> roles = [];
  List<User> users = [];

  String? imageName;
  Uint8List? webImage;

  //PANTALLA USUARIOS
  final busquedaController = TextEditingController();
  String orden = "sequential_id";

  Future<void> updateState() async {
    busquedaController.clear();
    await getRoles(notify: false);
    await getUsers();
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

  void setSelectedRole(String role) async {
    selectedRole = roles.firstWhere((e) => e.name == role);
    notifyListeners();
  }

  Future<void> getRoles({bool notify = true}) async {
    if (roles.isNotEmpty) return;
    final res = await supabase
        .from('role')
        .select()
        .eq('organization_fk', organizationId)
        .order('name', ascending: true);

    roles = (res as List<dynamic>).map((role) => Role.fromMap(role)).toList();

    if (notify) notifyListeners();
  }

  Future<void> getUsers() async {
    try {
      final query =
          supabase.from('users').select().eq('organization_id', organizationId);

      final res = await query
          .like('first_name', '%${busquedaController.text}%')
          .order(orden, ascending: true);

      if (res == null) {
        log('Error in getUsers()');
        return;
      }

      users = (res as List<dynamic>).map((user) => User.fromMap(user)).toList();

      fillPlutoGrid(users);
    } catch (e) {
      log('Error in getUsers() - $e');
    }
  }

  void fillPlutoGrid(List<User> users) {
    rows.clear();
    for (User user in users) {
      rows.add(
        PlutoRow(
          cells: {
            'sequential_id': PlutoCell(value: user.sequentialId),
            'full_name': PlutoCell(value: user.fullName),
            'role': PlutoCell(value: user.role.name),
            'email': PlutoCell(value: user.email),
            'mobile_phone': PlutoCell(value: user.mobilePhone ?? '-'),
            'status': PlutoCell(value: user),
            'actions': PlutoCell(value: user),
          },
        ),
      );
    }
    if (stateManager != null) stateManager!.notifyListeners();
    notifyListeners();
  }

  Future<void> selectImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) return;

    final String fileExtension = p.extension(pickedImage.name);
    const uuid = Uuid();
    final String fileName = uuid.v1();
    imageName = 'avatar-$fileName$fileExtension';

    webImage = await pickedImage.readAsBytes();

    notifyListeners();
  }

  void clearImage() {
    webImage = null;
    imageName = null;
    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if (webImage != null && imageName != null) {
      await supabase.storage.from('avatars').uploadBinary(
            imageName!,
            webImage!,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      return imageName;
    }
    return null;
  }

  Future<void> validateImage(String? imagen) async {
    if (imagen == null) {
      if (webImage != null) {
        //usuario no tiene imagen y se agrego => se sube imagen
        final res = await uploadImage();
        if (res == null) {
          ApiErrorHandler.callToast('Error uploading image');
        }
      }
      //usuario no tiene imagen y no se agrego => no hace nada
    } else {
      //usuario tiene imagen y se borro => se borra en bd
      if (webImage == null && imageName == null) {
        await supabase.storage.from('avatars').remove([imagen]);
      }
      //usuario tiene imagen y no se modifico => no se hace nada

      //usuario tiene imagen y se cambio => se borra en bd y se sube la nueva
      if (webImage != null && imageName != imagen) {
        await supabase.storage.from('avatars').remove([imagen]);
        final res2 = await uploadImage();
        if (res2 == null) {
          ApiErrorHandler.callToast('Error uploading image');
        }
      }
    }
  }

  Future<Map<String, String>?> registerUser() async {
    try {
      //Generar contrasena aleatoria
      // final password = generatePassword();

      //Registrar al usuario con una contraseña temporal
      var response = await http.post(
        Uri.parse('$supabaseUrl/auth/v1/signup'),
        headers: {'Content-Type': 'application/json', 'apiKey': anonKey},
        body: json.encode(
          {
            "email": emailController.text,
            "password": 'default',
          },
        ),
      );
      if (response.statusCode > 204)
        return {'Error': 'The user already exists'};

      final String? userId = jsonDecode(response.body)['user']['id'];

      if (userId == null) return {'Error': 'Could not register user'};

      // final token = generateToken(userId, correoController.text);

      // final bool tokenSaved = await SupabaseQueries.saveToken(userId, 'token_ingreso', token);

      // if (!tokenSaved) return {'Error': 'Error al guardar token'};

      // final bool emailSent = await sendEmail(correoController.text, password, token, 'alta');

      // if (!emailSent) return {'Error': 'Error al mandar email'};

      //retornar el id del usuario
      return {'userId': userId};
    } catch (e) {
      log('Error en registerUser() - $e');
      return {'Error': 'Could not register user'};
    }
  }

  Future<bool> createUserProfile(String userId) async {
    if (selectedRole == null) {
      return false;
    }

    try {
      await supabase.from('user_profile').insert(
        {
          'user_profile_id': userId,
          'first_name': nameController.text,
          'last_name': lastNameController.text,
          'mobile_phone': phoneController.text,
          'role_fk': selectedRole!.roleId,
          'image': imageName,
          'organization_fk': organizationId,
        },
      );
      return true;
    } catch (e) {
      log('Error in createUserProfile() - $e');
      return false;
    }
  }

  Future<bool> editUserProfile(String userId) async {
    try {
      await supabase.from('user_profile').update(
        {
          'first_name': nameController.text,
          'last_name': lastNameController.text,
          'mobile_phone': phoneController.text,
          'role_fk': selectedRole!.roleId,
          'image': imageName,
        },
      ).eq('user_profile_id', userId);
      return true;
    } catch (e) {
      log('Error in editUserProfile() - $e');
      return false;
    }
  }

  Future<void> initEditUser(User user) async {
    nameController.text = user.firstName;
    lastNameController.text = user.lastName;
    emailController.text = user.email;
    phoneController.text = user.mobilePhone ?? '';
    selectedRole = user.role;
    imageName = user.image;
    webImage = null;
  }

  // Future<bool> updateActivado(User usuario, bool value, int rowIndex) async {
  //   try {
  //     //actualizar usuario
  //     await supabase.from('perfil_usuario').update({'activo': value}).eq('perfil_usuario_id', usuario.id);
  //     rows[rowIndex].cells['activo']?.value = usuario.estatus;
  //     if (stateManager != null) stateManager!.notifyListeners();
  //     return true;
  //   } catch (e) {
  //     log('Error en updateActivado() - $e');
  //     return false;
  //   }
  // }

  String generatePassword() {
    //Generar contrasena aleatoria
    final passwordGenerator = RandomPasswordGenerator();
    return passwordGenerator.randomPassword(
      letters: true,
      uppercase: true,
      numbers: true,
      specialChar: true,
      passwordLength: 8,
    );
  }

  Future<bool> sendEmail(
      String email, String? password, String token, String type) async {
    //Mandar correo
    // final response = await http.post(
    //   Uri.parse(bonitaConnectionUrl),
    //   body: json.encode(
    //     {
    //       "user": "Web",
    //       "action": "bonitaBpmCaseVariables",
    //       'process': 'Alta_de_Usuario',
    //       'data': {
    //         'variables': [
    //           {
    //             'name': 'correo',
    //             'value': email,
    //           },
    //           {
    //             'name': 'password',
    //             'value': password,
    //           },
    //           {
    //             'name': 'token',
    //             'value': token,
    //           },
    //           {
    //             'name': 'type',
    //             'value': type,
    //           },
    //         ]
    //       },
    //     },
    //   ),
    // );
    // if (response.statusCode > 204) {
    //   return false;
    // }

    return true;
  }

  Future<bool> borrarUsuario(String userId) async {
    try {
      final res = await supabase.rpc('borrar_usuario_id', params: {
        'user_id': userId,
      });
      users.removeWhere((user) => user.id == userId);
      fillPlutoGrid(users);
      return res;
    } catch (e) {
      log('Error en borrarUsuario() - $e');
      return false;
    }
  }

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
