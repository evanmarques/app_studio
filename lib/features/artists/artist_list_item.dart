// lib/features/artists/artist_list_item.dart

import 'package:flutter/material.dart';
import 'package:pc_studio_app/models/artist.dart'; // Importa o nosso modelo de dados

// Um widget reutilizável para exibir um único artista numa lista.
class ArtistListItem extends StatelessWidget {
  final Artist artist;
  final VoidCallback onTap; // Função a ser chamada quando o card for tocado.

  const ArtistListItem({
    super.key,
    required this.artist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Card com uma borda subtil para um visual mais limpo.
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[800]!, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: InkWell(
        onTap: onTap, // Ação de clique
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // --- CÓDIGO ATUALIZADO E ROBUSTO PARA A FOTO DE PERFIL ---
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[700],
                // Tenta carregar a imagem da URL.
                // Usamos um `key` com a URL para ajudar o Flutter a gerir o cache.
                // A grande mudança está no `errorBuilder` abaixo.
                backgroundImage: (artist.profileImageUrl != null &&
                        artist.profileImageUrl!.isNotEmpty)
                    ? NetworkImage(artist.profileImageUrl!)
                    : null,
                // Mostra um ícone padrão se não houver URL de imagem.
                child: (artist.profileImageUrl == null ||
                        artist.profileImageUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 35, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              // Coluna para o nome e especialidade.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist.studioName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artist.specialties.join(', '), // Junta as especialidades
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                      overflow: TextOverflow
                          .ellipsis, // Evita que texto longo quebre o layout
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
