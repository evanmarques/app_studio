import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pc_studio_app/auth/auth_gate.dart'; // Importa nosso novo "porteiro"
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PC Studio App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      // A tela inicial agora é o AuthGate, que decidirá qual tela mostrar.
      home: const AuthGate(),
    );
  }
}
