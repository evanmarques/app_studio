// lib/auth/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // <-- 1. IMPORT ADICIONADO

// Esta classe vai centralizar toda a lógica de autenticação com o Firebase.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para fazer o login com Google.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // O utilizador cancelou o processo.
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // --- LÓGICA ATUALIZADA AQUI ---
      // 2. Após o login (seja novo ou existente), pegamos o token FCM do dispositivo.
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final userDocRef =
          _firestore.collection('users').doc(userCredential.user!.uid);

      // 3. Verifica se é um utilizador novo para criar o seu documento no Firestore.
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await userDocRef.set({
          'fullName': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'role': 'user',
          'uid': userCredential.user!.uid,
          'fcmToken': fcmToken, // <-- Salva o token no momento do cadastro
        });
      } else {
        // 4. Se for um utilizador que já existe, apenas atualizamos o seu token.
        //    Isso é importante caso ele tenha trocado de telemóvel ou reinstalado o app.
        await userDocRef.update({'fcmToken': fcmToken});
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Erro de autenticação com o Firebase: ${e.message}');
      return null;
    } catch (e) {
      print('Ocorreu um erro inesperado: $e');
      return null;
    }
  }
}
