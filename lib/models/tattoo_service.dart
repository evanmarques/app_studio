// lib/models/tattoo_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Import necessário para o @override

/// Representa um serviço específico oferecido por um artista, com sua duração.
/// Ex: "Tatuagem Pequena - Fineline" -> 2 horas.
@immutable // Anotação que indica que objetos desta classe são imutáveis.
class TattooService {
  final String id;
  final String style;
  final String size;
  final int durationInHours;

  const TattooService({
    required this.id,
    required this.style,
    required this.size,
    required this.durationInHours,
  });

  /// Constrói um objeto [TattooService] a partir de um documento do Firestore.
  factory TattooService.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TattooService(
      id: doc.id,
      style: data['style'] ?? '',
      size: data['size'] ?? '',
      durationInHours: data['durationInHours'] ?? 1,
    );
  }

  /// Converte este objeto [TattooService] num mapa para ser salvo no Firestore.
  Map<String, dynamic> toMap() {
    return {
      'style': style,
      'size': size,
      'durationInHours': durationInHours,
    };
  }

  // --- CÓDIGO DE COMPARAÇÃO ADICIONADO ---
  // A sobreposição destes dois métodos ensina ao Dart como comparar dois objetos TattooService.
  // Agora, dois serviços são considerados "iguais" se os seus IDs forem iguais.
  // Isto é essencial para o RadioListTile saber qual item está selecionado.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TattooService && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
  // --- FIM DO CÓDIGO DE COMPARAÇÃO ---
}
