// lib/models/appointment.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa um único agendamento no sistema.
///
/// Contém informações sobre o artista, o cliente, a data/hora e o status.
class Appointment {
  final String id; // ID do documento do agendamento no Firestore.
  final String artistId; // UID do artista.
  final String artistName; // Nome do artista/estúdio.
  final String clientId; // UID do cliente.
  final String clientName; // Nome do cliente.
  final DateTime dateTime; // Data e hora exatas do agendamento.
  final String
      status; // Status do agendamento, ex: 'pending', 'confirmed', 'cancelled'.

  Appointment({
    required this.id,
    required this.artistId,
    required this.artistName,
    required this.clientId,
    required this.clientName,
    required this.dateTime,
    this.status = 'pending', // O status padrão ao criar é 'pendente'.
  });

  /// Constrói um objeto [Appointment] a partir de um [DocumentSnapshot] do Firestore.
  ///
  /// Este método de fábrica é usado para converter os dados lidos do banco de dados
  /// para um objeto Dart que nosso aplicativo pode usar.
  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    // Pega o mapa de dados do documento.
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Appointment(
      id: doc.id,
      artistId: data['artistId'] ?? '',
      artistName: data['artistName'] ?? '',
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? '',
      // O Firestore armazena datas como 'Timestamp'. Precisamos convertê-las para 'DateTime'.
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }

  /// Converte este objeto [Appointment] em um mapa [Map<String, dynamic>].
  ///
  /// Este método é usado para converter nosso objeto Dart em um formato que o Firestore
  /// entende, para que possamos salvar ou atualizar dados no banco de dados.
  Map<String, dynamic> toMap() {
    return {
      'artistId': artistId,
      'artistName': artistName,
      'clientId': clientId,
      'clientName': clientName,
      // Convertendo 'DateTime' de volta para 'Timestamp' para armazenamento.
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status,
    };
  }
}
