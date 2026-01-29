import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRoute noTransitionRoute(String path, String name, Widget Function(BuildContext, GoRouterState) builder, {List<GoRoute>? subroutes}) {
  return GoRoute(
    path: path,
    name: name,
    pageBuilder: (context, state) {
      return NoTransitionPage(
        child: builder(context, state),
      );
    },
    routes: subroutes ?? [],
  );
}
