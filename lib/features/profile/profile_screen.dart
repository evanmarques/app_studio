// lib/features/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pc_studio_app/auth/plan_selection_screen.dart';
import 'package:pc_studio_app/management/artist_dashboard_screen.dart';
import 'package:pc_studio_app/admin/admin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Instâncias dos serviços do Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Função para fazer logout
  Future<void> _signOut() async {
    // Faz o logout do Firebase Authentication
    await _auth.signOut();
    // O nosso AuthGate irá detetar esta alteração e redirecionar para a tela de boas-vindas.
  }

  @override
  Widget build(BuildContext context) {
    // Obtém o utilizador atualmente com sessão iniciada
    final currentUser = _auth.currentUser;

    // Se por alguma razão não houver um utilizador (pouco provável, pois o AuthGate protege esta tela),
    // mostramos uma tela de carregamento para evitar erros.
    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meu Perfil"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Adiciona um botão de "Sair" diretamente na AppBar para um acesso mais fácil
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _signOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- AVATAR DINÂMICO ---
            // Se o utilizador tiver uma foto de perfil (vinda da conta Google), mostramo-la.
            // Senão, mostramos a primeira letra do seu nome.
            CircleAvatar(
              radius: 50,
              backgroundImage: currentUser.photoURL != null
                  ? NetworkImage(currentUser.photoURL!)
                  : null,
              child: currentUser.photoURL == null
                  // LÓGICA CORRIGIDA AQUI:
                  ? Text(
                      // 1. VERIFICA se o nome NÃO é nulo E NÃO está vazio
                      (currentUser.displayName != null &&
                              currentUser.displayName!.isNotEmpty)
                          // Se for verdade, pega na primeira letra do nome
                          ? currentUser.displayName!
                              .substring(0, 1)
                              .toUpperCase()
                          // 2. Se o nome falhar, VERIFICA se o e-mail NÃO é nulo E NÃO está vazio
                          : (currentUser.email != null &&
                                  currentUser.email!.isNotEmpty)
                              // Se for verdade, pega na primeira letra do e-mail
                              ? currentUser.email!.substring(0, 1).toUpperCase()
                              // 3. Se tudo falhar, mostra 'U' de Utilizador como fallback
                              : 'U',
                      style: const TextStyle(fontSize: 40),
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            // --- NOME E E-MAIL DINÂMICOS ---
            // Mostra o nome do utilizador. Se não houver, mostra o e-mail.
            Text(
              currentUser.displayName ??
                  currentUser.email ??
                  'Utilizador Anónimo',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Mostra o e-mail do utilizador
            Text(
              currentUser.email ?? 'Nenhum e-mail',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(), // Ocupa o espaço vazio no meio da tela

            // Este StreamBuilder ouve as mudanças nos dados do utilizador e do estúdio
            // para decidir quais botões mostrar em tempo real. Esta lógica já estava correta.
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
                        // Mostra o botão de admin SE o utilizador for admin.
                        if (isAdmin) _buildAdminButton(),

                        // Mostra os botões de artista SE for artista, senão, mostra o de criar perfil.
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

  // Widget que constrói o botão para criar perfil de estúdio.
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

  // Widget que constrói os botões de gestão para artistas.
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

  // Widget que constrói o botão do painel de administrador.
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
