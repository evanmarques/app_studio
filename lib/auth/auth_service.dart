// lib/auth/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pc_studio_app/core/notification_service.dart';

/// O AuthService agora é responsável apenas por ações PÓS-autenticação,
/// como criar o documento do usuário no Firestore.
class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lida com as ações necessárias após um login ou cadastro.
  /// Este método é chamado a partir do SignInScreen do firebase_ui_auth.
  Future<void> handlePostSignIn(User user) async {
    final userDocRef = _firestore.collection('users').doc(user.uid);

    // Salva/atualiza o token de notificação.
    await NotificationService().saveTokenToDatabase(null);

    // Verifica se o documento do usuário já existe.
    final doc = await userDocRef.get();

    // Se o documento NÃO existe, significa que é um novo usuário, então criamos seu perfil.
    if (!doc.exists) {
      await userDocRef.set({
        'fullName': user.displayName ?? '', // Adiciona um fallback para o nome
        'email': user.email,
        'role': 'user',
        'uid': user.uid,
      });
    }
  }
}
