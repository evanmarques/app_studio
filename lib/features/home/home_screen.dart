// lib/features/home/home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// 1. IMPORTAMOS O NOSSO WIDGET REUTILIZÁVEL DE TELA CHEIA
import 'package:pc_studio_app/features/common/fullscreen_image_viewer.dart';

// Modelo para representar um estilo de tatuagem.
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

// A tela principal do aplicativo.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      // O StreamBuilder ouve as mudanças na coleção 'styles' do Firestore.
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('styles').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Ocorreu um erro ao carregar os dados.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum estilo encontrado.'));
          }

          final styles = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return TattooStyle.fromFirestore(data);
          }).toList();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: styles.length,
                itemBuilder: (context, index) {
                  final style = styles[index];
                  // Passamos a chamar o nosso widget de card atualizado.
                  return _buildStyleCard(context, style);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget que constrói cada card de estilo, agora interativo.
  Widget _buildStyleCard(BuildContext context, TattooStyle style) {
    // 2. ENVOLVEMOS O CARD COM UM GESTUREDETECTOR PARA TORNÁ-LO CLICÁVEL
    return GestureDetector(
      onTap: () {
        // 3. AO CLICAR, NAVEGAMOS PARA O NOSSO VISUALIZADOR DE TELA CHEIA
        // Verificamos se a URL da imagem não está vazia antes de navegar.
        if (style.imageUrl.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  FullscreenImageViewer(imageUrl: style.imageUrl),
            ),
          );
        } else {
          // Se não houver imagem, podemos mostrar uma mensagem (opcional).
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imagem não disponível para ${style.name}')),
          );
        }
      },
      child: Card(
        color: Colors.grey[900],
        clipBehavior: Clip
            .antiAlias, // Garante que a imagem não "vaze" para fora das bordas arredondadas
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              // Usamos um Hero para uma animação de transição suave (opcional, mas elegante).
              // A 'tag' deve ser única para cada imagem na tela.
              child: Hero(
                tag: 'style_image_${style.name}',
                child: Image.network(
                  style.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[850],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.white54),
                      ),
                    );
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
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
