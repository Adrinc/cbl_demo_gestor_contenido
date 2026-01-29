import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:energy_media/providers/visual_state_provider.dart';
import 'package:energy_media/providers/user_provider.dart';
import 'package:energy_media/theme/theme.dart';
import 'package:energy_media/helpers/globals.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class VideosLayout extends StatefulWidget {
  final Widget child;

  const VideosLayout({Key? key, required this.child}) : super(key: key);

  @override
  State<VideosLayout> createState() => _VideosLayoutState();
}

class _VideosLayoutState extends State<VideosLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<MenuItem> _menuItems = [
    MenuItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: '/dashboard',
      subtitle: 'Visualiza métricas y estadísticas globales de tus contenidos',
    ),
    MenuItem(
      title: 'Gestor de Videos',
      icon: Icons.video_library,
      route: '/videos',
      subtitle: 'Administra, edita y organiza tu biblioteca multimedia',
    ),
    MenuItem(
      title: 'Configuración',
      icon: Icons.settings,
      route: '/config',
      subtitle: 'Personaliza las preferencias de tu plataforma',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      drawer: isMobile ? _buildDrawer() : null,
      body: Row(
        children: [
          if (!isMobile) _buildSideMenu(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(isMobile),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final currentMenuItem = _menuItems.firstWhere(
      (item) => item.route == currentLocation,
      orElse: () => _menuItems[0],
    );

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.of(context).primaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (isMobile) ...[
            IconButton(
              icon: const Icon(Icons.menu),
              color: AppTheme.of(context).primaryText,
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            // Logo de EnergyMedia solo en mobile
            Image.asset(
              'assets/images/favicon.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const Spacer(),
            Text(
              currentMenuItem.title,
              style: AppTheme.of(context).bodyText1.override(
                    fontFamily: 'Poppins',
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
          ] else ...[
            // Desktop: título prominente con subtítulo
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF4EC9F5).withOpacity(0.15),
                        const Color(0xFFFFB733).withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.of(context).primaryColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    currentMenuItem.icon,
                    color: AppTheme.of(context).primaryColor,
                    size: 26,
                  ),
                ),
                const Gap(16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentMenuItem.title,
                      style: AppTheme.of(context).title2.override(
                            fontFamily: 'Poppins',
                            color: AppTheme.of(context).primaryText,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            letterSpacing: 0.5,
                          ),
                    ),
                    if (currentMenuItem.subtitle != null) ...[
                      const Gap(4),
                      Text(
                        currentMenuItem.subtitle!,
                        style: AppTheme.of(context).bodyText2.override(
                              fontFamily: 'Poppins',
                              color: AppTheme.of(context).tertiaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSideMenu() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        border: Border(
          right: BorderSide(
            color: AppTheme.of(context).hintText,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header minimalista con logo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.of(context).secondaryBackground,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.of(context).hintText,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Logo con container moderno
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.of(context).primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/favicon.png',
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                ),
                const Gap(16),
                // Título moderno
                Text(
                  'EnergyMedia',
                  style: AppTheme.of(context).subtitle1.override(
                        fontFamily: 'Poppins',
                        color: AppTheme.of(context).primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 0.5,
                      ),
                ),
                const Gap(4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'DEMO MODE',
                    style: AppTheme.of(context).bodyText3.override(
                          fontFamily: 'Poppins',
                          color: AppTheme.of(context).primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                  ),
                ),
              ],
            ),
          ),

          const Gap(16),

          // Sección de usuario compacta
          if (currentUser != null) _buildUserSection(),

          const Gap(8),

          // Menu Items con diseño card minimalista
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _menuItems.map((item) {
                final currentLocation =
                    GoRouterState.of(context).matchedLocation;
                final isSelected = currentLocation == item.route;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildModernMenuItem(
                    icon: item.icon,
                    title: item.title,
                    isSelected: isSelected,
                    onTap: () => context.go(item.route),
                  ),
                );
              }).toList(),
            ),
          ),

          // Theme Toggle minimalista
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppTheme.of(context).tertiaryBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Consumer<VisualStateProvider>(
              builder: (context, visualProvider, _) {
                return _buildThemeToggle(visualProvider);
              },
            ),
          ),

          // Botón de Salir de Demo
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            child: _buildExitDemoButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.of(context).primaryColor.withOpacity(0.1),
            AppTheme.of(context).secondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar con gradiente
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4EC9F5),
                  Color(0xFFFFB733),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4EC9F5).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                (currentUser?.fullName.substring(0, 1) ?? 'U').toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUser?.fullName ?? 'Usuario',
                  style: AppTheme.of(context).bodyText1.override(
                        fontFamily: 'Poppins',
                        color: AppTheme.of(context).primaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4EC9F5),
                        Color(0xFFFFB733),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernMenuItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.of(context).primaryColor.withOpacity(0.5)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.of(context).primaryColor
                        : AppTheme.of(context).tertiaryBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Colors.white
                        : AppTheme.of(context).secondaryText,
                    size: 18,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.of(context).bodyText1.override(
                          fontFamily: 'Poppins',
                          color: isSelected
                              ? AppTheme.of(context).primaryColor
                              : AppTheme.of(context).secondaryText,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumMenuItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF42BCEE),
                    Color(0xFF5865B5),
                    Color(0xFF653093),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4EC9F5).withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFB733).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: AppTheme.of(context).primaryColor.withOpacity(0.2),
            highlightColor: AppTheme.of(context).primaryColor.withOpacity(0.1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  // Icono con background circular
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.25)
                          : AppTheme.of(context).primaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Colors.white.withOpacity(0.4)
                            : AppTheme.of(context)
                                .primaryColor
                                .withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? Colors.white
                          : AppTheme.of(context).primaryColor,
                      size: 22,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTheme.of(context).bodyText1.override(
                            fontFamily: 'Poppins',
                            color: isSelected
                                ? Colors.white
                                : AppTheme.of(context).primaryText,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                            fontSize: 15,
                            letterSpacing: isSelected ? 0.5 : 0,
                          ),
                    ),
                  ),
                  // Indicador animado
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isSelected ? 8 : 0,
                    height: isSelected ? 8 : 0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(VisualStateProvider visualProvider) {
    final isDark = AppTheme.themeMode == ThemeMode.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.of(context).tertiaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildThemeButton(
              icon: Icons.light_mode,
              label: 'Claro',
              isSelected: !isDark,
              onTap: () {
                visualProvider.changeThemeMode(ThemeMode.light, context);
              },
            ),
          ),
          const Gap(4),
          Expanded(
            child: _buildThemeButton(
              icon: Icons.dark_mode,
              label: 'Oscuro',
              isSelected: isDark,
              onTap: () {
                visualProvider.changeThemeMode(ThemeMode.dark, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4EC9F5),
                    const Color(0xFFFFB733),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4EC9F5).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : AppTheme.of(context).secondaryText,
                size: 18,
              ),
            ),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : AppTheme.of(context).secondaryText,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontFamily: 'Poppins',
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.of(context).secondaryBackground,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4EC9F5),
                  const Color(0xFFFFB733),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo de EnergyMedia
                  Image.asset(
                    'assets/images/logo_nh.png',
                    height: 45,
                    fit: BoxFit.contain,
                  ),
                  const Gap(12),
                  Text(
                    'Content Manager',
                    style: AppTheme.of(context).bodyText2.override(
                          fontFamily: 'Poppins',
                          color: const Color(0xFF0B0B0D).withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: _menuItems.map((item) {
                final currentLocation =
                    GoRouterState.of(context).matchedLocation;
                final isSelected = currentLocation == item.route;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildPremiumMenuItem(
                    icon: item.icon,
                    title: item.title,
                    isSelected: isSelected,
                    onTap: () {
                      context.go(item.route);
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Consumer<VisualStateProvider>(
              builder: (context, visualProvider, _) {
                return _buildThemeToggle(visualProvider);
              },
            ),
          ),

          // Botón de Logout en drawer
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _buildLogoutButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final userState = Provider.of<UserState>(context, listen: false);

            // Mostrar diálogo de confirmación
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppTheme.of(context).secondaryBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF2D2D),
                            Color(0xFFFF7A3D),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Text(
                        '¿Cerrar Sesión?',
                        style: AppTheme.of(context).title3.override(
                              fontFamily: 'Poppins',
                              color: AppTheme.of(context).primaryText,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                      ),
                    ),
                  ],
                ),
                content: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '¿Estás seguro de que deseas cerrar sesión?',
                    style: AppTheme.of(context).bodyText1.override(
                          fontFamily: 'Poppins',
                          color: AppTheme.of(context).secondaryText,
                        ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: AppTheme.of(context).secondaryText,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF2D2D),
                          Color(0xFFFF7A3D),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF2D2D).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          Gap(8),
                          Text(
                            'Cerrar Sesión',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              // DEMO MODE: Solo limpiar estado local y navegar
              currentUser = null; // Limpiar usuario global
              userState.logout();

              // Navegar al login
              if (mounted) {
                context.go('/login');
              }
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.of(context).error.withOpacity(0.15),
                  AppTheme.of(context).error.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.of(context).error.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.of(context).error.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).error.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.of(context).error.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: AppTheme.of(context).error,
                    size: 20,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Text(
                    'Cerrar Sesión',
                    style: AppTheme.of(context).bodyText1.override(
                          fontFamily: 'Poppins',
                          color: AppTheme.of(context).error,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.of(context).error,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExitDemoButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Abrir directamente en nueva pestaña sin confirmación
            html.window.open('https://cbluna.com/', '_blank');
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.of(context).primaryColor.withOpacity(0.15),
                  AppTheme.of(context).tertiaryColor.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.of(context).primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.of(context).primaryColor,
                        AppTheme.of(context).tertiaryColor,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppTheme.of(context).primaryColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.exit_to_app_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    'Salir de la Demo',
                    style: AppTheme.of(context).bodyText1.override(
                          fontFamily: 'Poppins',
                          color: AppTheme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                  ),
                ),
                Icon(
                  Icons.open_in_new_rounded,
                  color: AppTheme.of(context).primaryColor,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MenuItem {
  final String title;
  final IconData icon;
  final String route;
  final String? subtitle;

  MenuItem({
    required this.title,
    required this.icon,
    required this.route,
    this.subtitle,
  });
}
