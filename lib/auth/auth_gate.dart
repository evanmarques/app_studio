import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// --- CAMINHOS DE IMPORT CORRIGIDOS ---
import 'package:pc_studio_app/core/main_navigator.dart';
import 'package:pc_studio_app/auth/welcome_screen.dart';

// AuthGate é um widget que ouve as mudanças de estado da autenticação.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder é um widget que se reconstrói toda vez que recebe novos dados.
    return StreamBuilder<User?>(
      // Estamos "ouvindo" o stream authStateChanges() do Firebase.
      // Ele emite um objeto User se alguém está logado, ou null se ninguém está.
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Se o usuário estiver logado (snapshot tem dados), mostra a tela principal.
        if (snapshot.hasData) {
          return const MainNavigator();
        }

        // Se não, mostra a tela de boas-vindas para fazer login/cadastro.
        return const WelcomeScreen();
      },
    );
  }
}
