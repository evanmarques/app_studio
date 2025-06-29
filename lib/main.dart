// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pc_studio_app/auth/auth_gate.dart'; // Importa nosso novo "porteiro"
import 'firebase_options.dart';

// A função 'main' é o ponto de partida de todo aplicativo Flutter.
Future<void> main() async {
  // Garante que todos os 'bindings' do Flutter foram inicializados antes de rodar o app.
  // Essencial para usar o Firebase antes do runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase usando as configurações do arquivo firebase_options.dart.
  // O 'await' pausa a execução aqui até que o Firebase esteja pronto.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Roda o aplicativo.
  runApp(const MyApp());
}

// O widget principal do seu aplicativo.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PC Studio App',
      // Remove a faixa de "Debug" no canto superior direito.
      debugShowCheckedModeBanner: false,

      // Define o tema geral do aplicativo.
      theme: ThemeData(
        brightness: Brightness.dark, // Tema escuro.
        primarySwatch: Colors.purple, // Cor primária para componentes.
        scaffoldBackgroundColor: Colors.black, // Cor de fundo padrão.
        useMaterial3: true, // Usa o design mais recente do Material.
      ),

      // A tela inicial agora é o AuthGate, que decidirá qual tela mostrar (Boas-Vindas ou Principal).
      home: const AuthGate(),
    );
  }
}
