// lib/models/artist.dart

// Define o modelo de dados para um perfil de Artista/Estúdio.
class Artist {
  // Propriedades do modelo.
  final String
      uid; // ID do utilizador do Firebase Auth, usado como ID do documento.
  final String studioName; // Nome do estúdio ou nome artístico.
  final String ownerName; // Nome do proprietário.
  final String email; // Email de contacto.
  final String plan; // O plano de assinatura (ex: "free", "basic").
  String? profileImageUrl; // URL da imagem de perfil (opcional).
  String? instagramUrl; // URL do Instagram (opcional).
  String? whatsappNumber; // Número do WhatsApp (opcional).
  String? facebookUrl; // URL do Facebook (opcional).
  List<String> specialties; // Lista de especialidades do artista.
  List<String> portfolioImageUrls; // Lista de URLs das imagens do portfólio.

  // NOVOS CAMPOS PARA AGENDAMENTO
  List<String> workingDays; // Lista de dias da semana (ex: 'monday', 'tuesday')
  String? startTime; // Hora de início do trabalho (ex: '09:00')
  String? endTime; // Hora de fim do trabalho (ex: '18:00')

  // Construtor da classe.
  Artist({
    required this.uid,
    required this.studioName,
    required this.ownerName,
    required this.email,
    required this.plan,
    this.profileImageUrl,
    this.instagramUrl,
    this.whatsappNumber,
    this.facebookUrl,
    this.specialties = const [],
    this.portfolioImageUrls = const [],
    // Inicialização dos novos campos
    this.workingDays = const [],
    this.startTime,
    this.endTime,
  });

  // Construtor de fábrica para criar um Artista a partir de um mapa do Firestore.
  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(
      uid: map['uid'] ?? '',
      studioName: map['name'] ?? '',
      ownerName: map['ownerName'] ?? '',
      email: map['email'] ?? '',
      plan: map['plan'] ?? 'free',
      profileImageUrl: map['imageUrl'],
      instagramUrl: map['instagramUrl'],
      whatsappNumber: map['whatsappNumber'],
      facebookUrl: map['facebookUrl'],
      // Converte a string de especialidades de volta para uma lista
      specialties: (map['specialty'] as String?)?.split(', ').toList() ?? [],
      portfolioImageUrls: List<String>.from(map['portfolioImageUrls'] ?? []),
      // Converte os novos campos do Firestore para o nosso modelo
      workingDays: List<String>.from(map['workingDays'] ?? []),
      startTime: map['startTime'],
      endTime: map['endTime'],
    );
  }

  // Método para converter o objeto Artist num formato (Map) que o Firestore entende.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': studioName,
      'ownerName': ownerName,
      'email': email,
      'plan': plan,
      'imageUrl': profileImageUrl,
      'instagramUrl': instagramUrl,
      'whatsappNumber': whatsappNumber,
      'facebookUrl': facebookUrl,
      'specialty': specialties.join(', '),
      'portfolioImageUrls': portfolioImageUrls,
      // Adiciona os novos campos ao mapa para guardar no Firestore
      'workingDays': workingDays,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
