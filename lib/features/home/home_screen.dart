// lib/features/home/home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pc_studio_app/features/common/fullscreen_image_viewer.dart';
import 'package:pc_studio_app/models/plan.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// O modelo TattooStyle permanece como está.
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

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateToPage;
  const HomeScreen({super.key, required this.onNavigateToPage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Todas as variáveis de estado e funções de inicialização permanecem as mesmas.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _isArtist = false;
  Plan _artistPlan = Plan.free;
  int _pendingAppointmentsCount = 0;
  bool _isLoading = true;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    _checkUserRoleAndPlan();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    final adUnitId = 'ca-app-pub-3940256099942544/6300978111';
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _isBannerAdLoaded = true),
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  Future<void> _checkUserRoleAndPlan() async {
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
      setState(() {
        _isLoading = false;
      });
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
        // A Column principal que organiza a tela verticalmente.
        children: [
          // Banner de notificação para artistas.
          if (_isArtist && _pendingAppointmentsCount > 0)
            _buildPendingAppointmentsBanner(),

          // Secção de título para os estilos.
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Estilos em Destaque",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // --- ALTERAÇÃO PRINCIPAL AQUI ---
          // A secção de estilos agora é chamada diretamente, SEM o widget Expanded.
          // Isto permite que o SizedBox dentro dela dite a altura.
          _buildStylesSection(),

          // O Spacer ocupa todo o espaço vertical restante, empurrando o anúncio para baixo.
          const Spacer(),

          // O container do anúncio condicional.
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

  Widget _buildPendingAppointmentsBanner() {
    return GestureDetector(
      onTap: () => widget.onNavigateToPage(2),
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
                        color: Colors.white, fontWeight: FontWeight.bold))),
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
          return const SizedBox(
              height: 300, child: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const SizedBox
              .shrink(); // Retorna um widget vazio se não houver estilos

        final styles = snapshot.data!.docs
            .map((doc) =>
                TattooStyle.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList();

        // O carrossel está dentro de um SizedBox para controlar a sua altura.
        return SizedBox(
          height:
              300, // Altura definida para o carrossel. Ajuste este valor conforme necessário.
          width: double.infinity, // Ocupa a largura total.
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: styles.length,
                itemBuilder: (context, index) {
                  return _buildStylePage(context, styles[index]);
                },
              ),
              Positioned(
                left: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                  onPressed: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut),
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white70),
                  onPressed: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut),
                ),
              ),
            ],
          ),
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
