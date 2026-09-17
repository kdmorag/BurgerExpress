import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

import 'screens/auth_screen.dart';
import 'service/cliente_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseApp = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    debugPrint(
      'Firebase inicializado. Proyecto: ${firebaseApp.options.projectId}',
    );
  }

  runApp(const BurgerExpressApp());
}

class BurgerExpressApp extends StatelessWidget {
  const BurgerExpressApp({
    super.key,
    this.clienteService = const ClienteService(),
  });

  final ClienteService clienteService;

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
      home: AuthScreen(clienteService: clienteService),
    );
  }
}
