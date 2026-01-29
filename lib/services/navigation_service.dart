import 'package:flutter/material.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static navigateTo(String routeName) async {
    return await navigatorKey.currentState!.pushNamed(routeName);
  }

  static replaceTo(String routeName) async {
    return await navigatorKey.currentState!.pushReplacementNamed(routeName);
  }

  static removeTo(String newRoute) async {
    return await navigatorKey.currentState!
        .pushNamedAndRemoveUntil(newRoute, (_) => false);
  }
}
