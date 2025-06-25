import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Convertido para StatefulWidget para que possa ter um estado e buscar dados.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Instância do Firebase Auth para obter o usuário logado.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Função para fazer logout.
  Future<void> _signOut() async {
    await _auth.signOut();
    // A navegação será tratada pelo AuthGate, não precisamos fazer nada aqui.
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold é a estrutura da tela.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meu Perfil"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Exibe o e-mail do usuário logado.
              Text(
                "Logado como: ${_auth.currentUser?.email ?? 'Usuário desconhecido'}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Botão para Cadastrar o Estúdio (a lógica para mostrar/esconder virá depois).
              ElevatedButton(
                onPressed: () {
                  // Navegará para a tela de seleção de planos.
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Divulgue seu trabalho! Cadastre seu Estúdio",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              // Botão de Logout.
              OutlinedButton(
                onPressed: _signOut,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Sair (Logout)",
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
