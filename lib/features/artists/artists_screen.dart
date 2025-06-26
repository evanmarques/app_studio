import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pc_studio_app/features/artists/artist_detail_screen.dart'; // <-- IMPORT ADICIONADO
import 'package:pc_studio_app/features/artists/artist_list_item.dart';
import 'package:pc_studio_app/models/artist.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({super.key});

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  late Future<List<Artist>> _artistsFuture;

  @override
  void initState() {
    super.initState();
    _artistsFuture = _fetchArtists();
  }

  Future<List<Artist>> _fetchArtists() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('studios')
        .orderBy('name')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Artist(
        uid: doc.id,
        studioName: data['name'] ?? '',
        ownerName: data['ownerName'] ?? '',
        email: data['email'] ?? '',
        plan: data['plan'] ?? 'free',
        profileImageUrl: data['imageUrl'],
        specialties: (data['specialty'] as String?)?.split(', ') ?? [],
        instagramUrl: data['instagramUrl'],
        whatsappNumber: data['whatsappNumber'],
        facebookUrl: data['facebookUrl'],
        portfolioImageUrls: List<String>.from(data['portfolioImageUrls'] ?? []),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Artistas e Estúdios"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Artist>>(
        future: _artistsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Ocorreu um erro: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhum artista encontrado."));
          }

          final artists = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final artist = artists[index];
              return ArtistListItem(
                artist: artist,
                onTap: () {
                  // --- LÓGICA DE NAVEGAÇÃO IMPLEMENTADA AQUI ---
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Passa o objeto 'artist' completo para a próxima tela.
                      builder: (context) => ArtistDetailScreen(artist: artist),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
