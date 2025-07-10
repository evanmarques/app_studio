// lib/core/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    if (kIsWeb) return;

    await _firebaseMessaging.requestPermission();
    _firebaseMessaging.onTokenRefresh.listen(saveTokenToDatabase);
    await saveTokenToDatabase(await _firebaseMessaging.getToken());
  }

  /// Salva ou atualiza o token FCM no documento do usuário logado.
  /// A função agora é PÚBLICA (sem o '_') e pode ser chamada de outros arquivos.
  Future<void> saveTokenToDatabase(String? token) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final String? fcmToken = token ?? await _firebaseMessaging.getToken();
    if (fcmToken == null) return;

    try {
      debugPrint("====================================");
      debugPrint("Salvando FCM Token: $fcmToken para o usuário: $userId");
      debugPrint("====================================");

      await _firestore.collection('users').doc(userId).set({
        'fcmToken': fcmToken,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Erro ao salvar o token FCM no Firestore: $e");
    }
  }

  /// Remove o token FCM do banco de dados (também precisa ser pública).
  Future<void> removeTokenFromDatabase() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
      });
    } catch (e) {
      debugPrint("Erro ao remover o token FCM: $e");
    }
  }
}
