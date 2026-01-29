import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';

import 'package:energy_media/theme/theme.dart';

class VisualStateProvider extends ChangeNotifier {
  List<bool> isTaped = [
    true, //Administrador contenido lu 0
    false, //CRM 1
    false, //Customers 2
    false, //QR 3
    false, //Usuarios 4
    false, //Administrador contenido videos 5
    false, //Administrador cupones 6
    false //Inventario 7
  ];

  //THEME
  late Color primaryColorLight;
  late Color secondaryColorLight;
  late Color tertiaryColorLight;
  late Color primaryTextColorLight;
  late Color primaryBackgroundColorLight;

  late Color primaryColorDark;
  late Color secondaryColorDark;
  late Color tertiaryColorDark;
  late Color primaryTextColorDark;
  late Color primaryBackgroundColorDark;

  late TextEditingController primaryColorLightController;
  late TextEditingController secondaryColorLightController;
  late TextEditingController tertiaryColorLightController;
  late TextEditingController primaryTextLightController;
  late TextEditingController primaryBackgroundLightController;

  late TextEditingController primaryColorDarkController;
  late TextEditingController secondaryColorDarkController;
  late TextEditingController tertiaryColorDarkController;
  late TextEditingController primaryTextDarkController;
  late TextEditingController primaryBackgroundDarkController;

  //nombreTema
  TextEditingController nombreTema = TextEditingController();

  //SideMenu
  SideMenuController sideMenuController = SideMenuController();

  VisualStateProvider(BuildContext context) {
    final lightTheme = AppTheme.lightTheme;
    final darkTheme = AppTheme.darkTheme;

    primaryColorLight = lightTheme.primaryColor;
    secondaryColorLight = lightTheme.secondaryColor;
    tertiaryColorLight = lightTheme.tertiaryColor;
    primaryTextColorLight = lightTheme.primaryText;
    primaryBackgroundColorLight = lightTheme.primaryBackground;

    primaryColorDark = darkTheme.primaryColor;
    secondaryColorDark = darkTheme.secondaryColor;
    tertiaryColorDark = darkTheme.tertiaryColor;
    primaryTextColorDark = darkTheme.primaryText;
    primaryBackgroundColorDark = darkTheme.primaryBackground;

    primaryColorLightController = TextEditingController(
        text: primaryColorLight.value.toRadixString(16).toUpperCase());
    secondaryColorLightController = TextEditingController(
        text: secondaryColorLight.value.toRadixString(16).toUpperCase());
    tertiaryColorLightController = TextEditingController(
        text: tertiaryColorLight.value.toRadixString(16).toUpperCase());
    primaryTextLightController = TextEditingController(
        text: primaryTextColorLight.value.toRadixString(16).toUpperCase());
    primaryBackgroundLightController = TextEditingController(
        text:
            primaryBackgroundColorLight.value.toRadixString(16).toUpperCase());

    primaryColorDarkController = TextEditingController(
        text: primaryColorDark.value.toRadixString(16).toUpperCase());
    secondaryColorDarkController = TextEditingController(
        text: secondaryColorDark.value.toRadixString(16).toUpperCase());
    tertiaryColorDarkController = TextEditingController(
        text: tertiaryColorDark.value.toRadixString(16).toUpperCase());
    primaryTextDarkController = TextEditingController(
        text: primaryTextColorDark.value.toRadixString(16).toUpperCase());
    primaryBackgroundDarkController = TextEditingController(
        text: primaryBackgroundColorDark.value.toRadixString(16).toUpperCase());
  }

  void setPrimaryColorLight(Color color) {
    primaryColorLight = color;
    primaryColorLightController.text =
        color.value.toRadixString(16).toUpperCase();
    notifyListeners();
  }

  void setSecondaryColorLight(Color color) {
    secondaryColorLight = color;
    secondaryColorLightController.text =
        color.value.toRadixString(16).toUpperCase();
    notifyListeners();
  }

  void setTerciaryColorLight(Color color) {
    tertiaryColorLight = color;
    tertiaryColorLightController.text =
        color.value.toRadixString(16).toUpperCase();
    notifyListeners();
  }

  void setPrimaryTextColorLight(Color color) {
    primaryTextColorLight = color;
    primaryTextLightController.text =
        color.value.toRadixString(16).toUpperCase();
    notifyListeners();
  }

  void setPrimaryBackgroundColorLight(Color color) {
    primaryBackgroundColorLight = color;
    primaryBackgroundLightController.text =
        color.value.toRadixString(16).toUpperCase();
    notifyListeners();
  }

  void setPrimaryColorDark(Color color) {
    primaryColorDark = color;
    primaryColorDarkController.text =
        color.value.toRadixString(16).toUpperCase();
    notifyListeners();
  }

  void setSecondaryColorDark(Color color) {
    secondaryColorDark = color;
    secondaryColorDarkController.text =
        color.value.toRadixString(16).toUpperCase();
    notifyListeners();
  }

  void setTerciaryColorDark(Color color) {
    tertiaryColorDark = color;
    tertiaryColorDarkController.text =
        color.value.toRadixString(16).toUpperCase();
    notifyListeners();
  }

  void setPrimaryTextColorDark(Color color) {
    primaryTextColorDark = color;
    primaryTextDarkController.text =
        color.value.toRadixString(16).toUpperCase();
    notifyListeners();
  }

  void setPrimaryBackgroundColorDark(Color color) {
    primaryBackgroundColorDark = color;
    primaryBackgroundDarkController.text =
        color.value.toRadixString(16).toUpperCase();
    notifyListeners();
  }

  void toggleSideMenu() {
    sideMenuController.toggle();
  }

  void setTapedOption(int index) {
    for (var i = 0; i < isTaped.length; i++) {
      isTaped[i] = false;
    }
    isTaped[index] = true;
  }

  void changeThemeMode(ThemeMode mode, BuildContext context) {
    AppTheme.saveThemeMode(mode);
    setDarkModeSetting(context, mode);
    notifyListeners();
  }

  @override
  void dispose() {
    primaryColorLightController.dispose();
    secondaryColorLightController.dispose();
    tertiaryColorLightController.dispose();
    primaryTextLightController.dispose();
    primaryBackgroundLightController.dispose();
    primaryColorDarkController.dispose();
    secondaryColorDarkController.dispose();
    tertiaryColorDarkController.dispose();
    primaryTextDarkController.dispose();
    primaryBackgroundDarkController.dispose();
    super.dispose();
  }
}
