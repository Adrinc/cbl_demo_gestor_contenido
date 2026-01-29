import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:energy_media/pages/videos/videos_layout.dart';
import 'package:energy_media/pages/videos/premium_dashboard_page.dart';
import 'package:energy_media/pages/videos/gestor_videos_page.dart';
import 'package:energy_media/pages/videos/config_page.dart';
import 'package:energy_media/pages/pages.dart';
import 'package:energy_media/services/navigation_service.dart';

/// The route configuration.
/// DEMO MODE: Sin autenticación, acceso directo al dashboard
final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  navigatorKey: NavigationService.navigatorKey,
  initialLocation: '/dashboard',
  errorBuilder: (context, state) => const PageNotFoundPage(),
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) {
        return VideosLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) => '/dashboard',
        ),
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const PremiumDashboardPage(),
          ),
        ),
        GoRoute(
          path: '/videos',
          name: 'videos',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const GestorVideosPage(),
          ),
        ),
        GoRoute(
          path: '/config',
          name: 'config',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const ConfigPage(),
          ),
        ),
      ],
    ),
  ],
);
