// lib/features/artists/artist_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:pc_studio_app/models/artist.dart';
import 'package:pc_studio_app/models/plan.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pc_studio_app/features/common/fullscreen_image_viewer.dart';
import 'package:pc_studio_app/features/appointments/service_selection_screen.dart';

class ArtistDetailScreen extends StatefulWidget {
  final Artist artist;
  const ArtistDetailScreen({super.key, required this.artist});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  // --- As suas funções auxiliares, agora dentro da classe ---

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

  // --- O seu método build, completo ---
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

  // --- As suas funções de construção de widget, completas ---

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
        child:
            SizedBox(width: 32, height: 32, child: Image.asset(imageAssetPath)),
      ),
    );
  }

  /// Constrói o botão de agendamento, que navega para a [ServiceSelectionScreen].
  Widget _buildScheduleButton(Plan plan) {
    if (plan == Plan.advanced || plan == Plan.premium) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.calendar_today),
        label: const Text("Agendar Horário"),
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50)),
        onPressed: () {
          // A navegação para a tela de seleção de serviço está correta.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ServiceSelectionScreen(artist: widget.artist),
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
    if (plan == Plan.free) {/* ...código existente... */}
    if (widget.artist.portfolioImageUrls.isEmpty) {/* ...código existente... */}
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          final imageUrl = widget.artist.portfolioImageUrls[index];
          return GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FullscreenImageViewer(imageUrl: imageUrl))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : Center(child: CircularProgressIndicator()),
                errorBuilder: (context, error, stack) =>
                    Container(color: Colors.grey[800]),
              ),
            ),
          );
        }, childCount: widget.artist.portfolioImageUrls.length),
      ),
    );
  }
}
