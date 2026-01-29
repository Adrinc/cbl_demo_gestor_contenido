/// **DEMO MODE - EnergyMedia Content Manager**
///
/// Globals simplificados para modo demo 100% offline.
/// Supabase y conexiones externas han sido eliminadas.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:energy_media/models/models.dart';
import 'package:energy_media/theme/theme.dart';

final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

late final SharedPreferences prefs;

User? currentUser;

/// DEMO MODE: initGlobals simplificado - solo SharedPreferences
Future<void> initGlobals() async {
  prefs = await SharedPreferences.getInstance();
  // DEMO MODE: No hay autenticación real
  currentUser = null;
}

PlutoGridScrollbarConfig plutoGridScrollbarConfig(BuildContext context) {
  return PlutoGridScrollbarConfig(
    isAlwaysShown: true,
    scrollbarThickness: 5,
    hoverWidth: 20,
    scrollBarColor: AppTheme.of(context).primaryColor,
  );
}

PlutoGridStyleConfig plutoGridStyleConfig(BuildContext context,
    {double rowHeight = 125}) {
  return AppTheme.themeMode == ThemeMode.light
      ? PlutoGridStyleConfig(
          menuBackgroundColor: AppTheme.of(context).secondaryBackground,
          gridPopupBorderRadius: BorderRadius.circular(12),
          enableColumnBorderVertical: true,
          enableColumnBorderHorizontal: true,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: true,
          columnHeight: 56,
          columnTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: 'Poppins',
                color: AppTheme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
          cellTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: 'Poppins',
                color: AppTheme.of(context).primaryText,
                fontSize: 13,
              ),
          iconColor: AppTheme.of(context).primaryColor,
          rowColor: AppTheme.of(context).primaryBackground,
          borderColor: AppTheme.of(context).hintText.withOpacity(0.5),
          rowHeight: rowHeight,
          checkedColor: AppTheme.of(context).primaryColor.withOpacity(0.1),
          enableRowColorAnimation: true,
          gridBackgroundColor: AppTheme.of(context).primaryBackground,
          gridBorderColor: Colors.transparent,
          activatedColor: AppTheme.of(context).primaryColor.withOpacity(0.05),
          activatedBorderColor:
              AppTheme.of(context).primaryColor.withOpacity(0.3),
          columnFilterHeight: 48,
          oddRowColor:
              AppTheme.of(context).secondaryBackground.withOpacity(0.5),
          evenRowColor: AppTheme.of(context).primaryBackground,
          gridBorderRadius: BorderRadius.circular(16),
        )
      : PlutoGridStyleConfig.dark(
          menuBackgroundColor: AppTheme.of(context).tertiaryBackground,
          gridPopupBorderRadius: BorderRadius.circular(12),
          enableColumnBorderVertical: true,
          enableColumnBorderHorizontal: true,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: true,
          columnHeight: 56,
          columnTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: 'Poppins',
                color: AppTheme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
          cellTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: 'Poppins',
                color: AppTheme.of(context).primaryText,
                fontSize: 13,
              ),
          iconColor: AppTheme.of(context).primaryColor,
          rowColor: AppTheme.of(context).secondaryBackground,
          borderColor: AppTheme.of(context).hintText.withOpacity(0.3),
          rowHeight: rowHeight,
          checkedColor: AppTheme.of(context).primaryColor.withOpacity(0.15),
          enableRowColorAnimation: true,
          gridBackgroundColor: AppTheme.of(context).secondaryBackground,
          gridBorderColor: Colors.transparent,
          activatedColor: AppTheme.of(context).primaryColor.withOpacity(0.08),
          activatedBorderColor:
              AppTheme.of(context).primaryColor.withOpacity(0.4),
          columnFilterHeight: 48,
          oddRowColor: AppTheme.of(context).tertiaryBackground.withOpacity(0.5),
          evenRowColor: AppTheme.of(context).secondaryBackground,
          gridBorderRadius: BorderRadius.circular(16),
        );
}

PlutoGridStyleConfig plutoGridBigStyleConfig(BuildContext context) {
  return AppTheme.themeMode == ThemeMode.light
      ? PlutoGridStyleConfig(
          menuBackgroundColor: AppTheme.of(context).secondaryColor,
          gridPopupBorderRadius: BorderRadius.circular(16),
          enableColumnBorderVertical: false,
          enableColumnBorderHorizontal: false,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: true,
          columnTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: 'Quicksand',
                color: AppTheme.of(context).hintText,
              ),
          cellTextStyle: AppTheme.of(context).bodyText3,
          iconColor: AppTheme.of(context).tertiaryColor,
          rowColor: Colors.transparent,
          borderColor: Colors.transparent,
          rowHeight: 50,
          checkedColor: AppTheme.themeMode == ThemeMode.light
              ? AppTheme.of(context).secondaryColor
              : const Color(0XFF4B4B4B),
          enableRowColorAnimation: true,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          activatedColor: AppTheme.of(context).primaryBackground,
          activatedBorderColor: AppTheme.of(context).tertiaryColor,
          columnHeight: 100,
          gridBorderRadius: BorderRadius.circular(16),
        )
      : PlutoGridStyleConfig.dark(
          menuBackgroundColor: AppTheme.of(context).secondaryColor,
          gridPopupBorderRadius: BorderRadius.circular(16),
          enableColumnBorderVertical: false,
          enableColumnBorderHorizontal: false,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: true,
          columnTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: 'Quicksand',
                color: AppTheme.of(context).alternate,
              ),
          cellTextStyle: AppTheme.of(context).bodyText3,
          iconColor: AppTheme.of(context).tertiaryColor,
          rowColor: Colors.transparent,
          borderColor: const Color(0xFFF1F4FA),
          rowHeight: 50,
          checkedColor: AppTheme.themeMode == ThemeMode.light
              ? AppTheme.of(context).secondaryColor
              : const Color(0XFF4B4B4B),
          enableRowColorAnimation: true,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          activatedColor: AppTheme.of(context).primaryBackground,
          activatedBorderColor: AppTheme.of(context).tertiaryColor,
          columnHeight: 100,
          gridBorderRadius: BorderRadius.circular(16),
        );
}

PlutoGridStyleConfig plutoGridDashboardStyleConfig(BuildContext context) {
  return AppTheme.themeMode == ThemeMode.light
      ? PlutoGridStyleConfig(
          menuBackgroundColor: AppTheme.of(context).secondaryColor,
          gridPopupBorderRadius: BorderRadius.circular(16),
          enableColumnBorderVertical: false,
          enableColumnBorderHorizontal: false,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: true,
          columnTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: 'Quicksand',
                color: AppTheme.of(context).hintText,
              ),
          cellTextStyle: AppTheme.of(context).bodyText3,
          iconColor: AppTheme.of(context).tertiaryColor,
          rowColor: Colors.transparent,
          borderColor: const Color(0xFFF1F4FA),
          rowHeight: 50,
          checkedColor: AppTheme.themeMode == ThemeMode.light
              ? AppTheme.of(context).secondaryColor
              : const Color(0XFF4B4B4B),
          enableRowColorAnimation: true,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          activatedColor: AppTheme.of(context).primaryBackground,
          activatedBorderColor: AppTheme.of(context).tertiaryColor,
        )
      : PlutoGridStyleConfig.dark(
          menuBackgroundColor: AppTheme.of(context).secondaryColor,
          gridPopupBorderRadius: BorderRadius.circular(16),
          enableColumnBorderVertical: false,
          enableColumnBorderHorizontal: false,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: true,
          columnTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: 'Quicksand',
                color: AppTheme.of(context).alternate,
              ),
          cellTextStyle: AppTheme.of(context).bodyText3,
          iconColor: AppTheme.of(context).tertiaryColor,
          rowColor: Colors.transparent,
          borderColor: const Color(0xFFF1F4FA),
          rowHeight: 50,
          checkedColor: AppTheme.themeMode == ThemeMode.light
              ? AppTheme.of(context).secondaryColor
              : const Color(0XFF4B4B4B),
          enableRowColorAnimation: true,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          activatedColor: AppTheme.of(context).primaryBackground,
          activatedBorderColor: AppTheme.of(context).tertiaryColor,
        );
}

double rowHeight = 60;

PlutoGridStyleConfig plutoGridPopUpStyleConfig(BuildContext context) {
  return AppTheme.themeMode == ThemeMode.light
      ? PlutoGridStyleConfig(
          menuBackgroundColor: AppTheme.of(context).secondaryBackground,
          gridPopupBorderRadius: BorderRadius.circular(16),
          //
          enableColumnBorderVertical: false,
          columnTextStyle: AppTheme.of(context).bodyText3,
          iconColor: AppTheme.of(context).tertiaryColor,
          borderColor: Colors.transparent,
          //
          rowHeight: 40,
          rowColor: Colors.transparent,
          cellTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: AppTheme.of(context).bodyText3Family,
                color: AppTheme.of(context).primaryText,
              ),
          enableColumnBorderHorizontal: false,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: false,
          checkedColor: Colors.transparent,
          enableRowColorAnimation: false,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          //
          activatedColor: AppTheme.of(context).primaryBackground,
          activatedBorderColor: AppTheme.of(context).tertiaryColor,
        )
      : PlutoGridStyleConfig.dark(
          menuBackgroundColor: Colors.transparent,
          //
          enableColumnBorderVertical: false,
          columnTextStyle: AppTheme.of(context).copyRightText,
          iconColor: AppTheme.of(context).tertiaryColor,
          borderColor: Colors.transparent,
          //
          rowHeight: 40,
          rowColor: Colors.transparent,
          cellTextStyle: AppTheme.of(context).copyRightText,
          enableColumnBorderHorizontal: false,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: false,
          checkedColor: Colors.transparent,
          enableRowColorAnimation: false,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          //
          activatedColor: AppTheme.of(context).primaryBackground,
          activatedBorderColor: AppTheme.of(context).tertiaryColor,
        );
}

PlutoGridStyleConfig plutoGridStyleConfigContentManager(BuildContext context,
    {double rowHeight = 50}) {
  return AppTheme.themeMode == ThemeMode.light
      ? PlutoGridStyleConfig(
          menuBackgroundColor: AppTheme.of(context).secondaryColor,
          gridPopupBorderRadius: BorderRadius.circular(16),
          enableColumnBorderVertical: true,
          enableColumnBorderHorizontal: true,
          enableCellBorderVertical: true,
          enableCellBorderHorizontal: true,
          columnHeight: 100,
          columnTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: AppTheme.of(context).bodyText3Family,
                color: AppTheme.of(context).primaryColor,
              ),
          cellTextStyle: AppTheme.of(context).bodyText3,
          iconColor: AppTheme.of(context).tertiaryColor,
          rowColor: Colors.transparent,
          borderColor: const Color(0xFFF1F4FA),
          rowHeight: rowHeight,
          checkedColor: AppTheme.themeMode == ThemeMode.light
              ? AppTheme.of(context).secondaryColor
              : const Color(0XFF4B4B4B),
          enableRowColorAnimation: true,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          activatedColor: AppTheme.of(context).primaryBackground,
          activatedBorderColor: AppTheme.of(context).tertiaryColor,
          gridBorderRadius: BorderRadius.circular(16),
        )
      : PlutoGridStyleConfig.dark(
          menuBackgroundColor: AppTheme.of(context).secondaryColor,
          gridPopupBorderRadius: BorderRadius.circular(16),
          enableColumnBorderVertical: true,
          enableColumnBorderHorizontal: true,
          enableCellBorderVertical: true,
          enableCellBorderHorizontal: true,
          columnHeight: 100,
          columnTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: 'Quicksand',
                color: AppTheme.of(context).alternate,
              ),
          cellTextStyle: AppTheme.of(context).bodyText3,
          iconColor: AppTheme.of(context).tertiaryColor,
          rowColor: Colors.transparent,
          borderColor: const Color(0xFFF1F4FA),
          rowHeight: rowHeight,
          checkedColor: AppTheme.themeMode == ThemeMode.light
              ? AppTheme.of(context).secondaryColor
              : const Color(0XFF4B4B4B),
          enableRowColorAnimation: true,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          activatedColor: AppTheme.of(context).primaryBackground,
          activatedBorderColor: AppTheme.of(context).tertiaryColor,
        );
}
