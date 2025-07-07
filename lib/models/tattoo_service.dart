// lib/models/tattoo_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa um serviço específico oferecido por um artista, com sua duração.
/// Ex: "Tatuagem Pequena - Fineline" -> 2 horas.
class TattooService {
  final String id;
  final String style; // Ex: "Fineline", "Blackwork", "Old School"
  final String size; // Ex: "Pequeno", "Médio", "Grande"
  final int durationInHours; // Duração do serviço em horas

  TattooService({
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
}
