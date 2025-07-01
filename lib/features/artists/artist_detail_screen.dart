// lib/features/artists/artist_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:pc_studio_app/models/artist.dart';
import 'package:pc_studio_app/models/plan.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pc_studio_app/features/common/fullscreen_image_viewer.dart';
// 1. IMPORTAMOS O NOSSO NOVO ECRÃ DE AGENDAMENTO
import 'package:pc_studio_app/features/appointments/booking_screen.dart';

class ArtistDetailScreen extends StatefulWidget {
  final Artist artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir o link: $urlString')),
        );
      }
    }
  }

  Plan tryParsePlan(String planString) {
    try {
      return Plan.values.firstWhere((e) => e.name == planString);
    } catch (e) {
      return Plan.free;
    }
  }

  @override
  Widget build(BuildContext context) {
    final artistPlan = tryParsePlan(widget.artist.plan);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.artist.studioName,
                  style: const TextStyle(shadows: [Shadow(blurRadius: 8)])),
              background: widget.artist.profileImageUrl != null &&
                      widget.artist.profileImageUrl!.isNotEmpty
                  ? Image.network(
                      widget.artist.profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey[800]),
                    )
                  : Container(color: Colors.grey[800]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.artist.studioName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.artist.specialties.join(', '),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 16),
                  _buildSocialButtons(),
                  const SizedBox(height: 24),
                  // O botão de agendamento agora leva para a nova tela.
                  _buildScheduleButton(artistPlan),
                  const SizedBox(height: 24),
                  Text(
                    "Portfólio",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
          _buildPortfolioGrid(artistPlan),
        ],
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        if (widget.artist.whatsappNumber != null &&
            widget.artist.whatsappNumber!.isNotEmpty)
          _socialButton(
              'assets/icons/logo_whatsapp.png',
              () =>
                  _launchUrl('https://wa.me/${widget.artist.whatsappNumber}')),
        if (widget.artist.instagramUrl != null &&
            widget.artist.instagramUrl!.isNotEmpty)
          _socialButton('assets/icons/logo_instagram.png',
              () => _launchUrl(widget.artist.instagramUrl!)),
        if (widget.artist.facebookUrl != null &&
            widget.artist.facebookUrl!.isNotEmpty)
          _socialButton('assets/icons/logo_facebook.png',
              () => _launchUrl(widget.artist.facebookUrl!)),
      ],
    );
  }

  Widget _socialButton(String imageAssetPath, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: onPressed,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Image.asset(imageAssetPath),
        ),
      ),
    );
  }

  /// Constrói o botão de agendamento, que agora navega para a [BookingScreen].
  Widget _buildScheduleButton(Plan plan) {
    if (plan == Plan.advanced || plan == Plan.premium) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.calendar_today),
        label: const Text("Agendar Horário"),
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50)),
        onPressed: () {
          // 2. AÇÃO DE NAVEGAÇÃO IMPLEMENTADA AQUI
          Navigator.push(
            context,
            MaterialPageRoute(
              // Passa o objeto 'artist' completo para a tela de agendamento.
              builder: (context) => BookingScreen(artist: widget.artist),
            ),
          );
        },
      );
    } else {
      return Text(
        "Para marcar um horário, entre em contato diretamente através do WhatsApp ou Instagram.",
        style: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic),
      );
    }
  }

  Widget _buildPortfolioGrid(Plan plan) {
    if (plan == Plan.free) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Este artista não possui um portfólio online. Faça upgrade para um plano pago para exibir os seus trabalhos!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      );
    }

    if (widget.artist.portfolioImageUrls.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Portfólio vazio.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final imageUrl = widget.artist.portfolioImageUrls[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FullscreenImageViewer(imageUrl: imageUrl),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[850],
                      child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2.0)),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.broken_image)),
                ),
              ),
            );
          },
          childCount: widget.artist.portfolioImageUrls.length,
        ),
      ),
    );
  }
}
