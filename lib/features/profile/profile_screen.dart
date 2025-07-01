// lib/features/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pc_studio_app/auth/plan_selection_screen.dart';
import 'package:pc_studio_app/auth/welcome_screen.dart'; // 1. IMPORTAMOS A WELCOME_SCREEN
import 'package:pc_studio_app/management/artist_dashboard_screen.dart';
import 'package:pc_studio_app/admin/admin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 2. FUNÇÃO DE LOGOUT ATUALIZADA PARA SER MAIS ROBUSTA
  Future<void> _signOut() async {
    try {
      // É uma boa prática guardar referências a 'context' antes de uma operação 'await'.
      final navigator = Navigator.of(context);

      // Primeiro, fazemos o logout do Firebase.
      await _auth.signOut();
      await _auth.currentUser?.reload(); // Garante que o estado seja atualizado

      // Depois do logout, navegamos explicitamente para a tela de boas-vindas
      // e removemos todas as telas anteriores da pilha de navegação.
      // Isto força uma reconstrução limpa da UI, evitando o crash.
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (Route<dynamic> route) => false, // Predicado que remove todas as rotas
      );
    } catch (e) {
      // Se houver um erro, mostramos ao utilizador.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao fazer logout: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      // Este é um estado de segurança. Se o utilizador for nulo,
      // mostramos um loading enquanto o AuthGate faz o seu trabalho.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meu Perfil"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _signOut, // Chama a nossa nova função robusta
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: currentUser.photoURL != null
                  ? NetworkImage(currentUser.photoURL!)
                  : null,
              child: currentUser.photoURL == null
                  ? Text(
                      (currentUser.displayName != null &&
                              currentUser.displayName!.isNotEmpty)
                          ? currentUser.displayName!
                              .substring(0, 1)
                              .toUpperCase()
                          : (currentUser.email != null &&
                                  currentUser.email!.isNotEmpty)
                              ? currentUser.email!.substring(0, 1).toUpperCase()
                              : 'U',
                      style: const TextStyle(fontSize: 40),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              currentUser.displayName ??
                  currentUser.email ??
                  'Utilizador Anónimo',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              currentUser.email ?? 'Nenhum e-mail',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(),
            // 3. O RESTO DO CÓDIGO PERMANECE IGUAL
            StreamBuilder<DocumentSnapshot>(
              stream: _db.collection('users').doc(currentUser.uid).snapshots(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userData =
                    userSnapshot.data?.data() as Map<String, dynamic>?;
                final bool isAdmin = userData?['role'] == 'admin';

                return StreamBuilder<DocumentSnapshot>(
                  stream: _db
                      .collection('studios')
                      .doc(currentUser.uid)
                      .snapshots(),
                  builder: (context, studioSnapshot) {
                    if (studioSnapshot.connectionState ==
                            ConnectionState.waiting &&
                        !userSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final bool isArtist =
                        studioSnapshot.hasData && studioSnapshot.data!.exists;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isAdmin) _buildAdminButton(),
                        if (isArtist)
                          _buildArtistManagementButtons()
                        else
                          _buildCreateProfileButton(),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateProfileButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PlanSelectionScreen()));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        "Divulgue o seu trabalho! Registe o seu Estúdio",
        style: TextStyle(fontSize: 16, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildArtistManagementButtons() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.dashboard),
      label: const Text("Painel do Artista"),
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ArtistDashboardScreen()));
      },
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12)),
    );
  }

  Widget _buildAdminButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextButton.icon(
        icon: const Icon(Icons.admin_panel_settings),
        label: const Text("Painel do Administrador"),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AdminScreen()));
        },
      ),
    );
  }
}
