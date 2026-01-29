import 'dart:developer';
import 'dart:typed_data';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:energy_media/helpers/globals.dart';
import 'package:energy_media/helpers/supabase/queries.dart';
import 'package:energy_media/router/router.dart';

class UserState extends ChangeNotifier {
  //EMAIL
  Future<void> setEmail() async {
    await prefs.setString('email', emailController.text);
  }

  //Controlador para LoginScreen
  TextEditingController emailController = TextEditingController();

  //PASSWORD

  Future<void> setPassword() async {
    await prefs.setString('password', passwordController.text);
  }

  //Controlador para LoginScreen
  TextEditingController passwordController = TextEditingController();

  bool recuerdame = false;

  //Variables para editar perfil
  TextEditingController nombrePerfil = TextEditingController();
  TextEditingController apellidosPerfil = TextEditingController();
  TextEditingController telefonoPerfil = TextEditingController();
  TextEditingController extensionPerfil = TextEditingController();
  TextEditingController emailPerfil = TextEditingController();
  TextEditingController contrasenaAnteriorPerfil = TextEditingController();
  TextEditingController confirmarContrasenaPerfil = TextEditingController();
  TextEditingController contrasenaPerfil = TextEditingController();

  String? imageName;
  Uint8List? webImage;

  int loginAttempts = 0;

  bool userChangedPasswordInLast90Days = true;

  //Constructor de provider
  UserState() {
    recuerdame = prefs.getBool('recuerdame') ?? false;

    if (recuerdame == true) {
      emailController.text = prefs.getString('email') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
    }
  }

  Future<bool> actualizarContrasena() async {
    try {
      final res = await supabase.rpc('change_user_password', params: {
        'current_plain_password': contrasenaAnteriorPerfil.text,
        'new_plain_password': contrasenaPerfil.text,
      });
      if (res == null) {
        log('Error en actualizarContrasena()');
        return false;
      }
      return true;
    } catch (e) {
      log('Error en actualizarContrasena() - $e');
      return false;
    }
  }

  // void initPerfilUsuario() {
  //   if (currentUser == null) return;
  //   nombrePerfil.text = currentUser!.nombre;
  //   // apellidosPerfil.text = currentUser!.apellidos;
  //   emailPerfil.text = currentUser!.email;
  //   webImage = null;
  //   contrasenaPerfil.clear();
  //   contrasenaAnteriorPerfil.clear();
  //   confirmarContrasenaPerfil.clear();
  // }

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

  Future<bool> editarPerfilDeUsuario() async {
    try {
      await supabase.from('perfil_usuario').update(
        {
          'nombre': nombrePerfil.text,
          'apellidos': apellidosPerfil.text,
          'telefono': telefonoPerfil.text,
          'imagen': imageName,
        },
      ).eq('perfil_usuario_id', currentUser!.id);
      return true;
    } catch (e) {
      log('Error en editarPerfilDeUsuario() - $e');
      return false;
    }
  }

  Future<void> updateRecuerdame() async {
    recuerdame = !recuerdame;
    await prefs.setBool('recuerdame', recuerdame);
    notifyListeners();
  }

  String generateToken(String userId, String email) {
    //Generar token
    final jwt = JWT(
      {
        'user_id': userId,
        'email': email,
        'created': DateTime.now().toUtc().toIso8601String(),
      },
      issuer: 'https://github.com/jonasroussel/dart_jsonwebtoken',
    );

    // Sign it (default with HS256 algorithm)
    return jwt.sign(SecretKey('secret'));
  }

  // Future<bool> sendEmailWithToken(String email, String password, String token, String type) async {
  //   //Mandar correo
  //   final response = await http.post(
  //     Uri.parse(bonitaConnectionUrl),
  //     body: json.encode(
  //       {
  //         "user": "Web",
  //         "action": "bonitaBpmCaseVariables",
  //         'process': 'Alta_de_Usuario',
  //         'data': {
  //           'variables': [
  //             {
  //               'name': 'correo',
  //               'value': email,
  //             },
  //             {
  //               'name': 'password',
  //               'value': password,
  //             },
  //             {
  //               'name': 'token',
  //               'value': token,
  //             },
  //             {
  //               'name': 'type',
  //               'value': type,
  //             },
  //           ]
  //         },
  //       },
  //     ),
  //   );
  //   if (response.statusCode > 204) {
  //     return false;
  //   }

  //   return true;
  // }

  // Future<bool> sendEmailWithAccessCode(String email, String id) async {
  //   //Mandar correo
  //   final response = await http.post(
  //     Uri.parse(bonitaConnectionUrl),
  //     body: json.encode(
  //       {
  //         "user": "Web",
  //         "action": "bonitaBpmCaseVariables",
  //         'process': 'DVLogin',
  //         'data': {
  //           'variables': [
  //             {
  //               'name': 'correo',
  //               'value': email,
  //             },
  //             {
  //               'name': 'id',
  //               'value': id,
  //             },
  //           ]
  //         },
  //       },
  //     ),
  //   );
  //   if (response.statusCode > 204) {
  //     return false;
  //   }

  //   return true;
  // }

  Future<Map<String, String>?> resetPassword(String email) async {
    try {
      final res = await supabase.from('users').select('id').eq('email', email);
      if ((res as List).isEmpty) {
        return {'Error': 'El correo no está registrado'};
      }

      final userId = res[0]['id'];

      if (userId == null) return {'Error': 'El correo no está registrado'};

      final token = generateToken(userId, email);

      // Guardar token
      await SupabaseQueries.saveToken(
        userId,
        'token_reset',
        token,
      );

      // final res2 = await sendEmailWithToken(email, '', token, 'reset');

      // if (!res2) return {'Error': 'Error al realizar petición'};

      return null;
    } catch (e) {
      log('Error en resetPassword() - $e');
    }
    return {'Error': 'There was an error after sending request'};
  }

  Future<String?> getUserId(String email) async {
    try {
      final res = await supabase.from('users').select('id').eq('email', email);
      if ((res as List).isNotEmpty) {
        return res[0]['id'];
      }
      return null;
    } catch (e) {
      log('Error en getUserId - $e');
      return null;
    }
  }

  Future<bool> validateAccessCode(String userId, String accessCode) async {
    try {
      final res = await supabase.rpc('validate_access_code', params: {
        'id': userId,
        'access_code_attempt': accessCode,
      });
      return res;
    } catch (e) {
      log('Error en getAccessCode() - $e');
      return false;
    }
  }

  Future<bool> sendAccessCode(String userId) async {
    try {
      final codeSaved = await supabase.rpc(
        'save_access_code',
        params: {'id': userId},
      );
      if (!codeSaved) return false;

      // final emailSent = await sendEmailWithAccessCode(
      //   emailController.text,
      //   userId,
      // );

      // if (!emailSent) return false;
      return true;
    } catch (e) {
      log('Error en sendEmailWithAccessCode() -$e');
      return false;
    }
  }

  Future<void> incrementLoginAttempts(String email) async {
    loginAttempts += 1;
    if (loginAttempts >= 3) {
      try {
        await supabase.rpc('block_user', params: {'email': email});
      } catch (e) {
        log('Error en incrementLoginAttempts() - $e');
      } finally {
        loginAttempts = 0;
      }
    }
    notifyListeners();
  }

  Future<void> registerLogin(String userId) async {
    try {
      await supabase.from('login_historico').insert({'usuario_fk': userId});
    } catch (e) {
      log('registerLogin() - $e');
    }
  }

  Future<bool> checkIfUserBlocked(String email) async {
    try {
      final res = await supabase.rpc('check_if_user_blocked', params: {
        'email': email,
      });

      return res;
    } catch (e) {
      log('Error en checkIfUserIsBlocked() - $e');
      return true;
    }
  }

  Future<void> checkIfUserChangedPasswordInLast90Days(String userId) async {
    try {
      final res = await supabase.rpc('usuario_cambio_contrasena', params: {
        'user_id': userId,
      });

      userChangedPasswordInLast90Days = res;
    } catch (e) {
      log('Error en checkIfUserChangedPasswordInLast90Days() - $e');
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    currentUser = null;
    await prefs.remove('currentRol');
    /* Configuration? conf = await SupabaseQueries.getDefaultTheme();
    AppTheme.initConfiguration(conf); */
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
