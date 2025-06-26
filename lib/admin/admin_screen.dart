import 'package:flutter/material.dart';

// Tela placeholder para o painel de administrador.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Admin"),
      ),
      body: const Center(
        child: Text("Área de Administração"),
      ),
    );
  }
}
