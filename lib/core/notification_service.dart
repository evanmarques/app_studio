// lib/core/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  // Instância principal do Firebase Messaging.
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Inicializa todo o serviço de notificações.
  Future<void> initialize() async {
    // 1. Solicita permissão ao usuário para enviar notificações (essencial para iOS).
    await _firebaseMessaging.requestPermission();

    // 2. Obtém o token FCM único para este dispositivo.
    //    Este token é o "endereço" para onde o Firebase enviará as notificações.
    final fcmToken = await _firebaseMessaging.getToken();
    print("====================================");
    print("FCM Token: $fcmToken");
    print("====================================");

    // 3. Salva o token no Firestore se já houver um usuário logado.
    await _saveTokenToDatabase(fcmToken);

    // 4. Configura um "ouvinte" para quando o token for atualizado
    //    (isso pode acontecer se o usuário reinstalar o app ou limpar os dados).
    _firebaseMessaging.onTokenRefresh.listen(_saveTokenToDatabase);
  }

  /// Salva o token FCM no documento do usuário logado no Firestore.
  Future<void> _saveTokenToDatabase(String? token) async {
    // Garante que temos um token e um usuário logado.
    if (token == null) return;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      try {
        // Usa 'update' para adicionar ou atualizar o campo 'fcmToken' no documento do usuário.
        // O FieldValue.serverTimestamp() é uma boa prática para saber quando o token foi atualizado.
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'fcmToken': token,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Se o documento do usuário ainda não existir ou houver outro erro,
        // o 'update' pode falhar. Usar 'set' com 'merge:true' é mais seguro.
        await FirebaseFirestore.instance.collection('users').doc(userId).set(
            {
              'fcmToken': token,
              'lastUpdated': FieldValue.serverTimestamp(),
            },
            SetOptions(
                merge:
                    true)); // 'merge:true' não apaga os outros dados do usuário.
      }
    }
  }
}
