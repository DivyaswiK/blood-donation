import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes/routes.dart';
import 'core/theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Donation App',
      theme: AppTheme.theme, // From core/theme.dart
      initialRoute: Routes.home,
      routes: appRoutes,
      debugShowCheckedModeBanner: false,
    );
  }
}
