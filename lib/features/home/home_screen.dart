// lib/features/home/home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Modelo para representar um estilo de tatuagem, agora com um construtor
// de fábrica para converter dados do Firestore em um objeto Dart.
class TattooStyle {
  final String name;
  final String imageUrl; // Alterado de imagePath para imageUrl

  TattooStyle({required this.name, required this.imageUrl});

  // Construtor de fábrica: Cria uma instância de TattooStyle a partir de um snapshot do Firestore.
  // Um "mapa" (Map) é uma estrutura de chave-valor, exatamente como um documento do Firestore.
  factory TattooStyle.fromFirestore(Map<String, dynamic> data) {
    return TattooStyle(
      name:
          data['name'] ??
          'Sem Nome', // Pega o valor do campo 'name', ou usa um padrão
      imageUrl:
          data['imageUrl'] ??
          '', // Pega o valor do campo 'imageUrl', ou usa um padrão
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
  // Instância do Firestore para que possamos fazer consultas.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Encontre seu Estilo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // O StreamBuilder é um widget fantástico que se reconstrói sempre que
      // chegam novos dados do stream (nossa coleção 'styles' do Firestore).
      body: StreamBuilder<QuerySnapshot>(
        // O stream que vamos ouvir: a coleção 'styles' ordenada pelo nome.
        stream: _firestore.collection('styles').orderBy('name').snapshots(),
        // O builder é chamado toda vez que o estado do stream muda (carregando, com dados, com erro).
        builder: (context, snapshot) {
          // 1. Se o snapshot tem um erro (ex: sem permissão de acesso).
          if (snapshot.hasError) {
            return const Center(
              child: Text('Ocorreu um erro ao carregar os dados.'),
            );
          }

          // 2. Se está esperando os dados chegarem.
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mostra uma animação de carregamento no centro da tela.
            return const Center(child: CircularProgressIndicator());
          }

          // 3. Se não tem dados ou a coleção está vazia.
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum estilo encontrado.'));
          }

          // 4. Se tudo deu certo, temos os dados!
          // Mapeamos a lista de documentos (docs) para uma lista de objetos TattooStyle.
          final styles = snapshot.data!.docs.map((doc) {
            // Pega os dados do documento como um Map<String, dynamic>.
            final data = doc.data() as Map<String, dynamic>;
            // Usa nosso construtor de fábrica para criar o objeto.
            return TattooStyle.fromFirestore(data);
          }).toList();

          // Retorna a grade, agora com os dados vindos do Firebase.
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
                itemCount: styles
                    .length, // O total de itens é o tamanho da lista 'styles'.
                itemBuilder: (context, index) {
                  final style = styles[index];
                  // Chama a função que constrói o card para cada item.
                  return _buildStyleCard(context, style);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // O widget que constrói cada card de estilo.
  // Note a mudança de Image.asset para Image.network.
  Widget _buildStyleCard(BuildContext context, TattooStyle style) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Você selecionou: ${style.name}')),
        );
      },
      child: Card(
        color: Colors.grey[900],
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              // Usamos Image.network para carregar a imagem a partir de uma URL da internet.
              child: Image.network(
                style.imageUrl,
                fit: BoxFit.cover,
                // Enquanto a imagem da rede carrega, mostramos uma animação.
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[850],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                // Se der erro ao carregar a imagem da URL.
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                      ),
                    ),
                  );
                },
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
