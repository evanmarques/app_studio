import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Importa o arquivo gerado pelo FlutterFire

// A função 'main' é o ponto de entrada de todo aplicativo Flutter.
Future<void> main() async {
  // Garante que todos os "bindings" do Flutter estejam prontos antes de rodar o app.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase para a plataforma correta usando o arquivo gerado.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicia a execução da interface do usuário do aplicativo.
  runApp(const MyApp());
}

// MyApp é o widget raiz do seu aplicativo.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PC Studio App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      // Por enquanto, a tela inicial será um simples placeholder.
      home: const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Projeto Flutter Conectado ao Firebase!',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
