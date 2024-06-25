import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hr_platform/src/auth/is_authenticated.dart';

import '../screens/auth/login/login_page.dart';
import '../screens/home/home_page.dart';

class AppRoutes {
  static RouterConfig<Object> routes() {
    return GoRouter(
      routes: <RouteBase>[
        GoRoute(
          name: "/login",
          path: "/login",
          builder: (context, state) {
            return const LoginPage();
          },
        ),
        GoRoute(
          name: '/home',
          path: '/home',
          builder: (context, state) {
            return const HomePage();
          },
        ),
      ],
      redirect: (context, state) {
        if (isAuthenticated()) {
          return state.topRoute != null ? state.topRoute!.path : "/home";
        } else {
          return '/login';
        }
      },
    );
  }
}
