// lib/models/artist.dart

// Define o modelo de dados para um perfil de Artista/Estúdio.
class Artist {
  final String uid;
  final String studioName;
  final String ownerName;
  final String email;
  final String plan;
  String? profileImageUrl;
  String? instagramUrl;
  String? whatsappNumber;
  String? facebookUrl;
  List<String> specialties;
  List<String> portfolioImageUrls;
  List<String> workingDays;
  String? startTime;
  String? endTime;

  // 1. NOVO CAMPO ADICIONADO PARA A DURAÇÃO DA SESSÃO
  int sessionDurationInHours;

  // Construtor atualizado para incluir o novo campo.
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
    this.workingDays = const [],
    this.startTime,
    this.endTime,
    // O valor padrão para a duração da sessão é 1 hora.
    this.sessionDurationInHours = 1,
  });

  /// Constrói um objeto Artist a partir de um mapa do Firestore.
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
      specialties: (map['specialty'] as String?)?.split(', ').toList() ?? [],
      portfolioImageUrls: List<String>.from(map['portfolioImageUrls'] ?? []),
      workingDays: List<String>.from(map['workingDays'] ?? []),
      startTime: map['startTime'],
      endTime: map['endTime'],
      // Carrega a duração da sessão do Firestore, com um fallback para 1.
      sessionDurationInHours: map['sessionDurationInHours'] ?? 1,
    );
  }

  /// Converte o objeto Artist num mapa para guardar no Firestore.
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
      'workingDays': workingDays,
      'startTime': startTime,
      'endTime': endTime,
      // Adiciona o novo campo ao mapa para ser salvo.
      'sessionDurationInHours': sessionDurationInHours,
    };
  }
}
