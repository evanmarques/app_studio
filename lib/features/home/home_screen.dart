// lib/features/home/home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pc_studio_app/features/common/fullscreen_image_viewer.dart';

// O modelo TattooStyle permanece o mesmo.
class TattooStyle {
  final String name;
  final String imageUrl;
  TattooStyle({required this.name, required this.imageUrl});
  factory TattooStyle.fromFirestore(Map<String, dynamic> data) {
    return TattooStyle(
        name: data['name'] ?? 'Sem Nome', imageUrl: data['imageUrl'] ?? '');
  }
}

// A HomeScreen agora é "inteligente" e precisa de gerir estado.
class HomeScreen extends StatefulWidget {
  // 1. NOVA FUNÇÃO DE CALLBACK
  // Para que a HomeScreen possa dizer ao MainNavigator para mudar de aba.
  final Function(int) onNavigateToPage;

  const HomeScreen({super.key, required this.onNavigateToPage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // 2. NOVAS VARIÁVEIS DE ESTADO
  bool _isArtist = false;
  int _pendingAppointmentsCount = 0;
  bool _isLoading =
      true; // Para o carregamento inicial de verificação de 'role'

  @override
  void initState() {
    super.initState();
    _checkUserRoleAndPendingAppointments();
  }

  /// Verifica se o utilizador é um artista e, se for, busca por agendamentos pendentes.
  Future<void> _checkUserRoleAndPendingAppointments() async {
    if (_currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    final studioDoc =
        await _firestore.collection('studios').doc(_currentUser!.uid).get();

    // Se o documento do estúdio existe, o utilizador é um artista.
    if (studioDoc.exists) {
      _isArtist = true;
      // Se for artista, faz uma consulta para contar as pendências.
      final pendingSnapshot = await _firestore
          .collection('appointments')
          .where('artistId', isEqualTo: _currentUser!.uid)
          .where('status', isEqualTo: 'pending')
          .get();

      _pendingAppointmentsCount = pendingSnapshot.docs.length;
    }

    if (mounted) {
      setState(() {
        _isLoading = false; // Termina o carregamento inicial.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Encontre o seu Estilo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 3. WIDGET DE ALERTA CONDICIONAL
          // Só aparece se o utilizador for artista e tiver pendências.
          if (_isArtist && _pendingAppointmentsCount > 0)
            _buildPendingAppointmentsBanner(),

          // Grelha de estilos (agora dentro de um Expanded para preencher o resto do espaço)
          Expanded(
            child: _buildStylesGrid(),
          ),
        ],
      ),
    );
  }

  /// Constrói o banner de alerta para o artista.
  Widget _buildPendingAppointmentsBanner() {
    return GestureDetector(
      // 4. AO CLICAR NO BANNER, CHAMA A FUNÇÃO DE NAVEGAÇÃO
      onTap: () {
        // Pede ao MainNavigator para mudar para a aba de Agenda (índice 2).
        widget.onNavigateToPage(2);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.notification_important, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Você tem $_pendingAppointmentsCount solicitações pendentes!',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  /// Constrói a grelha de estilos (o seu código anterior, agora num widget separado).
  Widget _buildStylesGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('styles').orderBy('name').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Center(child: Text('Ocorreu um erro.'));
        if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const Center(child: Text('Nenhum estilo encontrado.'));

        final styles = snapshot.data!.docs
            .map((doc) =>
                TattooStyle.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: styles.length,
              itemBuilder: (context, index) {
                return _buildStyleCard(context, styles[index]);
              },
            ),
          ),
        );
      },
    );
  }

  // O seu widget de card de estilo, sem alterações.
  Widget _buildStyleCard(BuildContext context, TattooStyle style) {
    return GestureDetector(
      onTap: () {
        if (style.imageUrl.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    FullscreenImageViewer(imageUrl: style.imageUrl)),
          );
        }
      },
      child: Card(
        color: Colors.grey[900],
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'style_image_${style.name}',
                child: Image.network(
                  style.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.white54));
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                style.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
