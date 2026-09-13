import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseApp = await Firebase.initializeApp();

  if (kDebugMode) {
    debugPrint(
      'Firebase inicializado. Proyecto: ${firebaseApp.options.projectId}',
    );
  }

  runApp(const BurgerExpressApp());
}

class BurgerExpressApp extends StatelessWidget {
  const BurgerExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BurgerExpress',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
      // Definición inicial de la ruta
      home: const AuthScreen(),
    );
  }
}
