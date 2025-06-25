// Define um modelo de dados para o objeto User.
class User {
  final String uid; // ID único vindo do Firebase Auth
  final String fullName; // Nome completo do usuário
  final String email; // Email do usuário
  final String role; // Função do usuário (ex: 'user' ou 'admin')

  // Construtor da classe.
  User({
    required this.uid,
    required this.fullName,
    required this.email,
    this.role = 'user', // Define 'user' como o valor padrão.
  });

  // Método para converter o objeto User em um formato (Map) que o Firestore entende.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
    };
  }
}
