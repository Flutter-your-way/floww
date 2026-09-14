import 'package:flutter/material.dart';

class NavigationService {
  NavigationService._privateConstructor();
  static final NavigationService _instance =
      NavigationService._privateConstructor();
  static NavigationService get instance => _instance;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  Future<dynamic> push(String routeName, {Object? arguments}) =>
      navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);

  Future<dynamic> pushReplacement(String routeName, {Object? arguments}) =>
      navigatorKey.currentState!.pushReplacementNamed(
        routeName,
        arguments: arguments,
      );

  void pop([Object? result]) => navigatorKey.currentState!.pop(result);

  Future<dynamic> pushAndRemoveUntil(String routeName, {Object? arguments}) =>
      navigatorKey.currentState!.pushNamedAndRemoveUntil(
        routeName,
        (route) => false,
        arguments: arguments,
      );
}
