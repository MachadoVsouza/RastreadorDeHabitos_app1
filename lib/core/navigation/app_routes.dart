import 'package:flutter/material.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String habitsManager = '/habits-manager';
  static const String habitForm = '/habit-form';
  static const String habitEdit = '/habit-edit';
  static const String statistics = '/statistics';
  static const String heatmap = '/heatmap';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(),
          settings: settings,
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(),
          settings: settings,
        );
      case habitsManager:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Rota não encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
