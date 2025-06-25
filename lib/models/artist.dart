// Define o modelo de dados para um perfil de Artista/Estúdio.
class Artist {
  // Propriedades do modelo.
  final String
      uid; // ID do usuário do Firebase Auth, usado como ID do documento.
  final String studioName; // Nome do estúdio ou nome artístico.
  final String ownerName; // Nome do proprietário.
  final String email; // Email de contato.
  final String plan; // O plano de assinatura (ex: "free", "basic").
  String? profileImageUrl; // URL da imagem de perfil (opcional).
  String? instagramUrl; // URL do Instagram (opcional).
  String? whatsappNumber; // Número do WhatsApp (opcional).
  String? facebookUrl; // URL do Facebook (opcional).
  List<String> specialties; // Lista de especialidades do artista.
  List<String> portfolioImageUrls; // Lista de URLs das imagens do portfólio.

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
    this.specialties = const [], // Inicia como uma lista vazia por padrão.
    this.portfolioImageUrls =
        const [], // Inicia como uma lista vazia por padrão.
  });

  // Método para converter o objeto Artist em um formato (Map) que o Firestore entende.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': studioName, // No Firestore, o campo se chamará 'name'.
      'ownerName': ownerName,
      'email': email,
      'plan': plan,
      'imageUrl': profileImageUrl,
      'instagramUrl': instagramUrl,
      'whatsappNumber': whatsappNumber,
      'facebookUrl': facebookUrl,
      'specialty':
          specialties.join(', '), // Salva a lista como uma única string.
      'portfolioImageUrls': portfolioImageUrls,
    };
  }
}
