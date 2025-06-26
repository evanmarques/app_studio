import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

// Tela para gerenciar (adicionar/ver) as fotos do portfólio.
class PortfolioManagerScreen extends StatefulWidget {
  const PortfolioManagerScreen({super.key});

  @override
  State<PortfolioManagerScreen> createState() => _PortfolioManagerScreenState();
}

class _PortfolioManagerScreenState extends State<PortfolioManagerScreen> {
  // Instâncias dos serviços do Firebase.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Lista para armazenar as URLs das imagens do portfólio.
  List<String> _imageUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Carrega as imagens do portfólio assim que a tela é iniciada.
    _loadPortfolioImages();
  }

  // Busca as URLs das imagens do documento do artista no Firestore.
  Future<void> _loadPortfolioImages() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final docSnapshot =
          await _firestore.collection('studios').doc(userId).get();
      if (docSnapshot.exists &&
          docSnapshot.data()!.containsKey('portfolioImageUrls')) {
        // Atualiza o estado da tela com a lista de imagens.
        setState(() {
          _imageUrls =
              List<String>.from(docSnapshot.data()!['portfolioImageUrls']);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar portfólio: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Abre a galeria para o usuário selecionar uma nova foto.
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      // Inicia o processo de upload após a seleção.
      _uploadImageToStorage(imageFile);
    }
  }

  // Faz o upload do arquivo para o Firebase Storage.
  Future<void> _uploadImageToStorage(File imageFile) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Cria um nome de arquivo único para a imagem.
      final fileName =
          'portfolio_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('portfolio_images').child(fileName);

      // Envia o arquivo.
      await ref.putFile(imageFile);
      // Pega a URL de download da imagem que acabamos de enviar.
      final imageUrl = await ref.getDownloadURL();

      // Salva a nova URL no documento do artista no Firestore.
      _addImageUrlToFirestore(imageUrl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha no upload: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Adiciona a nova URL à lista 'portfolioImageUrls' no Firestore.
  Future<void> _addImageUrlToFirestore(String imageUrl) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('studios').doc(userId).update({
      'portfolioImageUrls': FieldValue.arrayUnion([imageUrl])
    });

    // Recarrega as imagens para atualizar a tela com a nova foto.
    _loadPortfolioImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Portfólio"),
        backgroundColor: Colors.transparent,
      ),
      // Botão flutuante para adicionar novas fotos.
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadImage,
        child: const Icon(Icons.add_a_photo),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _imageUrls.isEmpty
              ? const Center(
                  child: Text(
                    "Seu portfólio está vazio.\nClique no botão '+' para adicionar sua primeira foto.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              // Se houver imagens, exibe em uma grade.
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 colunas
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _imageUrls.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        _imageUrls[index],
                        fit: BoxFit.cover,
                        // Mostra um indicador de carregamento para cada imagem.
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error, color: Colors.red),
                      ),
                    );
                  },
                ),
    );
  }
}
