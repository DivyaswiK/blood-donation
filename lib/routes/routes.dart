import 'package:flutter/material.dart';

// Screens
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/home/home_screen.dart';
import '../features/donate/donate_blood_screen.dart';


class Routes {
  static const home = '/';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const donateBlood = '/donate-blood'; // 
}


final Map<String, WidgetBuilder> appRoutes = {
  Routes.home: (_) => const HomeScreen(),
  Routes.login: (_) => const LoginScreen(),
  Routes.register: (_) => const RegisterScreen(),
  Routes.dashboard: (_) => const DashboardScreen(),
  Routes.donateBlood: (context) {
  final args = ModalRoute.of(context)!.settings.arguments as String;
  return DonateBloodScreen(username: args);
},

};
