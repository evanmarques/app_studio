// lib/auth/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Esta classe vai centralizar toda a lógica de autenticação com o Firebase.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // *** ALTERAÇÃO PRINCIPAL AQUI ***
  // O método agora retorna 'Future<bool>' para indicar sucesso (true) ou falha (false).
  // Isto torna a resposta para a UI muito mais clara e fácil de manusear.
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Se o utilizador fechar o popup sem escolher uma conta, retornamos 'false'.
      if (googleUser == null) {
        return false; // O utilizador cancelou o processo.
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // --- A SUA LÓGICA DE FCM TOKEN FOI TOTALMENTE MANTIDA ---
      // Após o login, pegamos o token FCM do dispositivo.
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final userDocRef =
          _firestore.collection('users').doc(userCredential.user!.uid);

      // Verifica se é um utilizador novo para criar o seu documento no Firestore.
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await userDocRef.set({
          'fullName': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'role': 'user',
          'uid': userCredential.user!.uid,
          'fcmToken': fcmToken, // Salva o token no momento do cadastro
        });
      } else {
        // Se for um utilizador que já existe, apenas atualizamos o seu token.
        await userDocRef.update({'fcmToken': fcmToken});
      }

      // *** ALTERAÇÃO FINAL ***
      // Se todas as etapas foram concluídas com sucesso, retornamos 'true'.
      return true;
    } on FirebaseAuthException catch (e) {
      print('Erro de autenticação com o Firebase: ${e.message}');
      return false; // Retorna 'false' em caso de erro
    } catch (e) {
      print('Ocorreu um erro inesperado: $e');
      return false; // Retorna 'false' em caso de erro
    }
  }
}
