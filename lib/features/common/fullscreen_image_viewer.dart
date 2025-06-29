// lib/features/common/fullscreen_image_viewer.dart

import 'package:flutter/material.dart';

// Um ecrã simples que recebe a URL de uma imagem e a exibe em tela cheia.
class FullscreenImageViewer extends StatelessWidget {
  // A URL da imagem que queremos exibir.
  final String imageUrl;

  const FullscreenImageViewer({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos um fundo preto para uma melhor experiência de visualização.
      backgroundColor: Colors.black,
      // A AppBar permite-nos ter um botão para fechar e voltar ao ecrã anterior.
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Fundo transparente
        elevation: 0, // Sem sombra
        // O botão de "voltar" já é adicionado automaticamente pelo Flutter.
      ),
      // O corpo do nosso ecrã.
      body: Center(
        // O InteractiveViewer é um widget fantástico do Flutter que adiciona
        // automaticamente as funcionalidades de pinça-para-zoom e arrastar (pan).
        child: InteractiveViewer(
          // Definimos os limites mínimo e máximo de zoom.
          minScale: 1.0,
          maxScale: 4.0,
          // O conteúdo que poderá ser "zoomado".
          child: Image.network(
            imageUrl,
            // Mostra um indicador de progresso enquanto a imagem em alta resolução carrega.
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            // Se houver um erro a carregar a imagem, mostra um ícone de erro.
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 40,
              );
            },
          ),
        ),
      ),
    );
  }
}
