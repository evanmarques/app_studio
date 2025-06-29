// lib/auth/business_register_screen.dart

import 'dart:io'; // Necessário para trabalhar com ficheiros (File), como a imagem de perfil
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Para guardar ficheiros como imagens
import 'package:cloud_firestore/cloud_firestore.dart'; // A nossa base de dados NoSQL
import 'package:image_picker/image_picker.dart'; // Pacote para escolher imagens da galeria ou câmara
import 'package:pc_studio_app/core/main_navigator.dart';
import 'package:pc_studio_app/models/artist.dart';
import 'package:pc_studio_app/models/plan.dart';

// Esta é a tela final do fluxo de registo de estúdio.
class BusinessRegisterScreen extends StatefulWidget {
  // Ela recebe o plano selecionado da tela anterior.
  final Plan selectedPlan;

  const BusinessRegisterScreen({
    super.key,
    required this.selectedPlan,
  });

  @override
  State<BusinessRegisterScreen> createState() => _BusinessRegisterScreenState();
}

class _BusinessRegisterScreenState extends State<BusinessRegisterScreen> {
  // Controladores para ler os dados dos campos de texto.
  final _studioNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _instagramController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _facebookController = TextEditingController();

  // Variáveis para gerir o estado do ecrã.
  File? _profileImage; // Armazena o ficheiro de imagem selecionado.
  bool _isLoading = false; // Controla a exibição do indicador de carregamento.

  // Instâncias dos serviços do Firebase para comunicação com o backend.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void dispose() {
    // É uma boa prática limpar os controladores quando o ecrã é descartado para libertar memória.
    _studioNameController.dispose();
    _ownerNameController.dispose();
    _specialtyController.dispose();
    _instagramController.dispose();
    _whatsappController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  // Função assíncrona para abrir a galeria e permitir a seleção de uma imagem.
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      // Atualiza o estado do ecrã para exibir a nova imagem selecionada.
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Função principal que orquestra o processo de salvar o perfil do estúdio.
  Future<void> _registerStudio() async {
    final user = _auth.currentUser;
    if (user == null)
      return; // Garante que há um utilizador com sessão iniciada.

    // Validação dos campos obrigatórios.
    if (_studioNameController.text.isEmpty ||
        _ownerNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Por favor, preencha o nome do estúdio e o seu nome.")),
      );
      return;
    }

    // Ativa o estado de carregamento para mostrar a ProgressBar e desabilitar o botão.
    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;
      // 1. Faz o upload da imagem de perfil para o Firebase Storage, se uma foi selecionada.
      if (_profileImage != null) {
        // Define o caminho no Storage: /profile_images/{user_id}.jpg
        final ref =
            _storage.ref().child('profile_images').child('${user.uid}.jpg');
        // Envia o ficheiro
        await ref.putFile(_profileImage!);
        // Pega no URL de download da imagem que acabámos de enviar.
        imageUrl = await ref.getDownloadURL();
      }

      // 2. Cria uma instância do nosso modelo Artist com todos os dados do formulário.
      final newArtist = Artist(
        uid: user.uid,
        studioName: _studioNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        email: user.email!, // Pega no email do utilizador já autenticado.
        plan: widget.selectedPlan.name, // 'free', 'basic', etc.
        profileImageUrl: imageUrl,
        specialties: [_specialtyController.text.trim()],
        instagramUrl: _instagramController.text.trim(),
        whatsappNumber: _whatsappController.text.trim(),
        facebookUrl: _facebookController.text.trim(),
      );

      // 3. Salva o perfil do artista no Firestore.
      // Usamos o UID do utilizador como ID do documento para criar um link direto entre a autenticação e o perfil.
      await _firestore
          .collection("studios")
          .doc(user.uid)
          .set(newArtist.toMap());

      // 4. Se tudo deu certo, exibe uma mensagem de sucesso e navega para a tela principal.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Perfil de estúdio criado com sucesso!")),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigator()),
          (route) => false, // Remove todas as telas anteriores da pilha.
        );
      }
    } catch (e) {
      // Em caso de erro, exibe uma mensagem para o utilizador.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao criar perfil: ${e.toString()}")),
        );
      }
    } finally {
      // O bloco 'finally' garante que o estado de carregamento seja desativado,
      // não importa se o processo deu certo ou errado.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lógica para determinar quais campos devem ser exibidos com base no plano.
    bool showImagePicker = widget.selectedPlan != Plan.free;
    // CORREÇÃO APLICADA AQUI: widget.selectedPlan != Plan.free
    bool showSocialFields = widget.selectedPlan != Plan.free;
    bool showSpecialty = widget.selectedPlan != Plan.free;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registo do Estúdio"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seletor de Imagem de Perfil.
            if (showImagePicker)
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? const Icon(Icons.camera_alt,
                            color: Colors.white, size: 30)
                        : null,
                  ),
                ),
              ),
            if (showImagePicker) const SizedBox(height: 24),

            // Formulário com os campos de texto.
            _buildTextField(
                controller: _studioNameController,
                labelText: "Nome do Estúdio ou Artístico"),
            const SizedBox(height: 16),
            _buildTextField(
                controller: _ownerNameController,
                labelText: "O seu Nome Completo"),
            const SizedBox(height: 16),

            if (showSpecialty)
              _buildTextField(
                  controller: _specialtyController,
                  labelText: "A sua principal especialidade"),
            if (showSpecialty) const SizedBox(height: 16),

            if (showSocialFields)
              _buildTextField(
                  controller: _instagramController,
                  labelText: "URL do Instagram"),
            if (showSocialFields) const SizedBox(height: 16),

            if (showSocialFields)
              _buildTextField(
                  controller: _whatsappController,
                  labelText: "Nº do WhatsApp",
                  keyboardType: TextInputType.phone),
            if (showSocialFields) const SizedBox(height: 16),

            if (showSocialFields)
              _buildTextField(
                  controller: _facebookController,
                  labelText: "URL do Facebook"),
            const SizedBox(height: 32),

            // Botão para finalizar o registo.
            MaterialButton(
              minWidth: double.infinity,
              height: 50,
              // Desabilita o botão durante o carregamento.
              onPressed: _isLoading ? null : _registerStudio,
              color: Colors.purple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text("Finalizar Registo",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para construir os campos de texto, evitando repetição de código.
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
