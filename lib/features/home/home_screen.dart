// lib/features/home/home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pc_studio_app/features/common/fullscreen_image_viewer.dart';
import 'package:pc_studio_app/models/plan.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Modelo de dados para representar um Estilo de Tatuagem.
/// Reintroduzido neste ficheiro para manter a lógica da HomeScreen autónoma.
class TattooStyle {
  final String name;
  final String imageUrl;

  TattooStyle({required this.name, required this.imageUrl});

  factory TattooStyle.fromFirestore(Map<String, dynamic> data) {
    return TattooStyle(
      name: data['name'] ?? 'Sem Nome',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}

/// A tela principal da aplicação.
/// Agora exibe um carrossel de estilos e alertas condicionais para artistas.
class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateToPage;
  const HomeScreen({super.key, required this.onNavigateToPage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Variáveis de Estado ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  bool _isArtist = false;
  Plan _artistPlan = Plan.free;
  int _pendingAppointmentsCount = 0;
  bool _isLoading = true;

  // Variáveis para o anúncio
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  // Controlador para o PageView (o nosso carrossel)
  // viewportFraction: 0.85 faz com que um pouco da página seguinte e anterior apareça nos lados.
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    _checkUserRoleAndPendingAppointments();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _pageController
        .dispose(); // É crucial limpar o controlador para libertar memória.
    super.dispose();
  }

  /// Carrega um banner de anúncio do AdMob.
  void _loadBannerAd() {
    final adUnitId = 'ca-app-pub-3940256099942544/6300978111';
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _isBannerAdLoaded = true),
        onAdFailedToLoad: (ad, err) {
          print('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  /// Verifica se o utilizador é um artista, qual o seu plano, e conta os agendamentos pendentes.
  Future<void> _checkUserRoleAndPendingAppointments() async {
    if (_currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    final studioDoc =
        await _firestore.collection('studios').doc(_currentUser!.uid).get();

    if (studioDoc.exists) {
      _isArtist = true;
      final data = studioDoc.data()!;
      _artistPlan = Plan.values.firstWhere(
          (e) => e.name == (data['plan'] ?? 'free'),
          orElse: () => Plan.free);
      final pendingSnapshot = await _firestore
          .collection('appointments')
          .where('artistId', isEqualTo: _currentUser!.uid)
          .where('status', isEqualTo: 'pending')
          .get();
      _pendingAppointmentsCount = pendingSnapshot.docs.length;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowAd = !_isArtist || _artistPlan == Plan.free;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PC Studio',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Banner de notificação para artistas.
          if (_isArtist && _pendingAppointmentsCount > 0)
            _buildPendingAppointmentsBanner(),

          // Secção principal, que agora é o nosso carrossel de estilos.
          Expanded(
            child: _buildStylesSection(),
          ),

          // Container do anúncio condicional na parte inferior.
          if (_isBannerAdLoaded && shouldShowAd)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  /// Constrói o banner de alerta para o artista.
  Widget _buildPendingAppointmentsBanner() {
    return GestureDetector(
      onTap: () => widget.onNavigateToPage(2), // Navega para a aba "Agenda"
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12)),
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

  /// Constrói a secção completa do carrossel de estilos.
  Widget _buildStylesSection() {
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

        // Um Stack é usado para sobrepor as setas de navegação ao carrossel.
        return Stack(
          alignment: Alignment.center,
          children: [
            // O PageView é o widget que cria o efeito de carrossel.
            PageView.builder(
              controller: _pageController,
              itemCount: styles.length,
              itemBuilder: (context, index) {
                // Cada item do PageView é construído pela nossa função auxiliar.
                return _buildStylePage(context, styles[index]);
              },
            ),
            // Botão de seta para a esquerda.
            Positioned(
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                onPressed: () {
                  _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                },
              ),
            ),
            // Botão de seta para a direita.
            Positioned(
              right: 0,
              child: IconButton(
                icon:
                    const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                onPressed: () {
                  _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Constrói uma única página (um card de estilo) para o carrossel.
  Widget _buildStylePage(BuildContext context, TattooStyle style) {
    return GestureDetector(
      onTap: () {
        if (style.imageUrl.isNotEmpty) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      FullscreenImageViewer(imageUrl: style.imageUrl)));
        }
      },
      child: Container(
        // Margens para criar o efeito de "espreitar" as outras páginas.
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                style.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator()),
                errorBuilder: (context, error, stack) =>
                    const Center(child: Icon(Icons.image_not_supported)),
              ),
              // Gradiente escuro na parte inferior para garantir a legibilidade do texto.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
              // Nome do estilo posicionado na parte inferior.
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Text(
                  style.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black)]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
