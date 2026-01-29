import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:energy_media/helpers/globals.dart';
import 'package:energy_media/main.dart';
import 'package:energy_media/models/configuration.dart';

const kThemeModeKey = '__theme_mode__';

void setDarkModeSetting(BuildContext context, ThemeMode themeMode) =>
    MyApp.of(context).setThemeMode(themeMode);

abstract class AppTheme {
  static ThemeMode get themeMode {
    final darkMode = prefs.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.light
        : darkMode
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  static LightModeTheme lightTheme = LightModeTheme();
  static DarkModeTheme darkTheme = DarkModeTheme();

  static void initConfiguration(Configuration? conf) {
    lightTheme = LightModeTheme(mode: conf?.config!.light);
    darkTheme = DarkModeTheme(mode: conf?.config!.dark);
  }

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? prefs.remove(kThemeModeKey)
      : prefs.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static AppTheme of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTheme : lightTheme;
  Color hexToColor(String hexString) {
    // Quita el signo de almohadilla si está presente
    hexString = hexString.toUpperCase().replaceAll("#",
        ""); // Si la cadena tiene 6 caracteres, añade el valor de opacidad completa "FF"
    if (hexString.length == 6) {
      hexString = "FF$hexString";
    } // Si la cadena tiene 8 caracteres, ya incluye la transparencia, así que se deja como está
    else if (hexString.length == 8) {
      hexString = hexString.substring(6, 8) + hexString.substring(0, 6);
    } // Añade el prefijo 0x y convierte la cadena hexadecimal a un entero
    return Color(int.parse("0x$hexString"));
  }

  abstract Color primaryColor;
  abstract Color secondaryColor;
  abstract Color tertiaryColor;
  abstract Color alternate;
  abstract Color primaryBackground;
  abstract Color secondaryBackground;
  abstract Color tertiaryBackground;
  abstract Color transparentBackground;
  abstract Color primaryText;
  abstract Color secondaryText;
  abstract Color tertiaryText;
  abstract Color hintText;
  abstract Color error;
  abstract Color warning;
  abstract Color success;
  abstract Color info;
  abstract Color formBackground;

  Gradient blueGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFF1E40AF), // Azul profundo
      Color(0xFF3B82F6), // Azul brillante
      Color(0xFF0369A1), // Azul medio
      Color(0xFF0F172A), // Azul muy oscuro
    ],
  );

  Gradient primaryGradient = const LinearGradient(
    begin: Alignment(-1.0, -1.0),
    end: Alignment(1.0, 1.0),
    colors: <Color>[
      Color(0xFF4EC9F5), // Cyan
      Color(0xFFFFB733), // Yellow
    ],
  );

  // Nuevo gradiente para elementos modernos
  Gradient modernGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFF6B2F8A), // Purple
      Color(0xFF4EC9F5), // Cyan
      Color(0xFFFFB733), // Yellow
    ],
  );

  // Gradiente para backgrounds oscuros
  Gradient darkBackgroundGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color(0xFF0B0B0D), // Main background
      Color(0xFF121214), // Surface 1
      Color(0xFF1A1A1D), // Surface 2
    ],
  );

  String get title1Family => typography.title1Family;
  TextStyle get title1 => typography.title1;
  String get title2Family => typography.title2Family;
  TextStyle get title2 => typography.title2;
  String get title3Family => typography.title3Family;
  TextStyle get title3 => typography.title3;
  String get subtitle1Family => typography.subtitle1Family;
  TextStyle get subtitle1 => typography.subtitle1;
  String get subtitle2Family => typography.subtitle2Family;
  TextStyle get subtitle2 => typography.subtitle2;
  String get bodyText1Family => typography.bodyText1Family;
  TextStyle get bodyText1 => typography.bodyText1;
  String get bodyText2Family => typography.bodyText2Family;
  TextStyle get bodyText2 => typography.bodyText2;
  String get bodyText3Family => typography.bodyText3Family;
  TextStyle get bodyText3 => typography.bodyText3;
  String get plutoDataTextFamily => typography.plutoDataTextFamily;
  TextStyle get plutoDataText => typography.plutoDataText;
  String get copyRightTextFamily => typography.copyRightTextFamily;
  TextStyle get copyRightText => typography.copyRightText;

  Typography get typography => ThemeTypography(this);
}

class LightModeTheme extends AppTheme {
  @override
  Color primaryColor = const Color(0xFF4EC9F5); // Cyan primary
  @override
  Color secondaryColor = const Color(0xFFFFB733); // Yellow secondary
  @override
  Color tertiaryColor = const Color(0xFF6B2F8A); // Purple accent
  @override
  Color alternate = const Color(0xFFFF7A3D); // Orange accent
  @override
  Color primaryBackground = const Color(0xFFFFFFFF); // Main background (white)
  @override
  Color secondaryBackground = const Color(0xFFF7F7F7); // Card/Surface 1
  @override
  Color tertiaryBackground = const Color(0xFFEFEFEF); // Card/Surface 2
  @override
  Color transparentBackground =
      const Color(0xFFFFFFFF).withOpacity(.1); // Transparent background
  @override
  Color primaryText = const Color(0xFF111111); // Primary text
  @override
  Color secondaryText = const Color(0xFF2B2B2B); // Secondary text
  @override
  Color tertiaryText = const Color(0xFFB5B7BA); // Disabled/Muted
  @override
  Color hintText = const Color(0xFFE1E1E1); // Border/Divider
  @override
  Color error = const Color(0xFFFF2D2D); // Red accent
  @override
  Color warning = const Color(0xFFFFB733); // Yellow accent
  @override
  Color success = const Color(0xFF4EC9F5); // Cyan accent
  @override
  Color info = const Color(0xFF3B82F6); // Blue info
  @override
  Color formBackground =
      const Color(0xFF10B981).withOpacity(.05); // Fondo de formularios

  LightModeTheme({Mode? mode}) {
    if (mode != null) {
      primaryColor = hexToColor(mode.primaryColor!);
      secondaryColor = hexToColor(mode.secondaryColor!);
      tertiaryColor = hexToColor(mode.tertiaryColor!);
      primaryText = hexToColor(mode.primaryText!);
      primaryBackground = hexToColor(mode.primaryBackground!);
    }
  }
}

class DarkModeTheme extends AppTheme {
  @override
  Color primaryColor = const Color(0xFF4EC9F5); // Cyan primary
  @override
  Color secondaryColor = const Color(0xFFFFB733); // Yellow secondary
  @override
  Color tertiaryColor = const Color(0xFF6B2F8A); // Purple accent
  @override
  Color alternate = const Color(0xFFFF7A3D); // Orange accent
  @override
  Color primaryBackground = const Color(0xFF0B0B0D); // Main background (dark)
  @override
  Color secondaryBackground = const Color(0xFF121214); // Card/Surface 1
  @override
  Color tertiaryBackground = const Color(0xFF1A1A1D); // Card/Surface 2
  @override
  Color transparentBackground =
      const Color(0xFF0B0B0D).withOpacity(.3); // Transparent background
  @override
  Color primaryText = const Color(0xFFFFFFFF); // Primary text (white)
  @override
  Color secondaryText = const Color(0xFFEAEAEA); // Secondary text
  @override
  Color tertiaryText = const Color(0xFF6D6E73); // Muted/Disabled
  @override
  Color hintText = const Color(0xFF2A2A2E); // Border/Divider
  @override
  Color error = const Color(0xFFFF2D2D); // Red accent
  @override
  Color warning = const Color(0xFFFFB733); // Yellow accent
  @override
  Color success = const Color(0xFF4EC9F5); // Cyan accent
  @override
  Color info = const Color(0xFF3B82F6); // Blue info
  @override
  Color formBackground =
      const Color(0xFF10B981).withOpacity(.1); // Fondo de formularios

  // Nuevos gradientes modernos
  LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor,
          secondaryColor,
        ],
      );

  LinearGradient get modernGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          tertiaryColor,
          primaryColor,
        ],
      );

  LinearGradient get darkBackgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryBackground,
          secondaryBackground,
        ],
      );

  DarkModeTheme({Mode? mode}) {
    if (mode != null) {
      primaryColor = hexToColor(mode.primaryColor!);
      secondaryColor = hexToColor(mode.secondaryColor!);
      tertiaryColor = hexToColor(mode.tertiaryColor!);
      primaryText = hexToColor(mode.primaryText!);
      primaryBackground = hexToColor(mode.primaryBackground!);
    }
  }
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    required String fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    bool useGoogleFonts = true,
    TextDecoration? decoration,
    TextDecorationStyle? decorationStyle,
    double? lineHeight,
  }) =>
      useGoogleFonts
          ? GoogleFonts.getFont(
              fontFamily,
              color: color ?? this.color,
              fontSize: fontSize ?? this.fontSize,
              fontWeight: fontWeight ?? this.fontWeight,
              fontStyle: fontStyle ?? this.fontStyle,
              letterSpacing: letterSpacing ?? this.letterSpacing,
              decoration: decoration,
              decorationStyle: decorationStyle,
              height: lineHeight,
            )
          : copyWith(
              fontFamily: fontFamily,
              color: color,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              fontStyle: fontStyle,
              decoration: decoration,
              decorationStyle: decorationStyle,
              height: lineHeight,
            );
}

abstract class Typography {
  String get title1Family;
  TextStyle get title1;
  String get title2Family;
  TextStyle get title2;
  String get title3Family;
  TextStyle get title3;
  String get subtitle1Family;
  TextStyle get subtitle1;
  String get subtitle2Family;
  TextStyle get subtitle2;
  String get bodyText1Family;
  TextStyle get bodyText1;
  String get bodyText2Family;
  TextStyle get bodyText2;
  String get bodyText3Family;
  TextStyle get bodyText3;
  String get plutoDataTextFamily;
  TextStyle get plutoDataText;
  String get copyRightTextFamily;
  TextStyle get copyRightText;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final AppTheme theme;

  @override
  String get title1Family => 'Poppins';
  @override
  TextStyle get title1 => GoogleFonts.poppins(
        fontSize: 70,
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
      );
  @override
  String get title2Family => 'Poppins';
  @override
  TextStyle get title2 => GoogleFonts.poppins(
        fontSize: 65,
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
      );
  @override
  String get title3Family => 'Poppins';
  @override
  TextStyle get title3 => GoogleFonts.poppins(
        fontSize: 48,
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
      );

  @override
  String get subtitle1Family => 'Poppins';
  @override
  TextStyle get subtitle1 => GoogleFonts.poppins(
        fontSize: 28,
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
      );
  @override
  String get subtitle2Family => 'Poppins';
  @override
  TextStyle get subtitle2 => GoogleFonts.poppins(
        fontSize: 24,
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
      );

  @override
  String get bodyText1Family => 'Poppins';
  @override
  TextStyle get bodyText1 => GoogleFonts.poppins(
        fontSize: 20,
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
      );
  @override
  String get bodyText2Family => 'Poppins';
  @override
  TextStyle get bodyText2 => GoogleFonts.poppins(
        fontSize: 18,
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
      );
  @override
  String get bodyText3Family => 'Poppins';
  @override
  TextStyle get bodyText3 => GoogleFonts.poppins(
        fontSize: 14,
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
      );
  @override
  String get plutoDataTextFamily => 'Poppins';
  @override
  TextStyle get plutoDataText => GoogleFonts.poppins(
        fontSize: 12,
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
      );
  @override
  String get copyRightTextFamily => 'Poppins';
  @override
  TextStyle get copyRightText => GoogleFonts.poppins(
        fontSize: 12,
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
      );
}
