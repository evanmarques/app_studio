import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pc_studio_app/auth/plan_selection_screen.dart';
import 'package:pc_studio_app/management/artist_dashboard_screen.dart'; // <-- Caminho corrigido
import 'package:pc_studio_app/admin/admin_screen.dart'; // <-- Caminho corrigido

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> _signOut() async {
    await _auth.signOut();
    // O AuthGate cuidará do redirecionamento
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meu Perfil"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 16),
            Text(
              currentUser?.displayName ?? currentUser?.email ?? 'Usuário',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              currentUser?.email ?? 'Nenhum e-mail',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(), // Ocupa o espaço vazio

            // Este StreamBuilder ouve as mudanças nos dados do usuário e do estúdio
            // para decidir quais botões mostrar em tempo real.
            StreamBuilder<DocumentSnapshot>(
              stream: _db.collection('users').doc(currentUser?.uid).snapshots(),
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
                      .doc(currentUser?.uid)
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
                        // Mostra o botão de admin SE o usuário for admin.
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
            _buildLogoutButton(),
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
        "Divulgue seu trabalho! Cadastre seu Estúdio",
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  // Widget que constrói os botões de gerenciamento para artistas.
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

  // Widget que constrói o botão de logout.
  Widget _buildLogoutButton() {
    return OutlinedButton(
      onPressed: _signOut,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        "Sair (Logout)",
        style: TextStyle(fontSize: 16, color: Colors.red),
      ),
    );
  }
}
