// lib/auth/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Esta classe vai centralizar toda a lógica de autenticação com o Firebase.
class AuthService {
  // Instâncias dos serviços do Firebase que vamos usar.
  // O 'final' significa que estas variáveis não podem ser alteradas depois de inicializadas.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para fazer o login com Google.
  // Retorna um 'UserCredential' se o login for bem-sucedido, ou 'null' se o utilizador cancelar.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Inicia o fluxo de login do Google.
      // O utilizador verá o popup do Google para escolher uma conta.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Se o utilizador fechar o popup sem escolher uma conta, 'googleUser' será nulo.
      if (googleUser == null) {
        // O utilizador cancelou o processo.
        return null;
      }

      // 2. Obtém os detalhes de autenticação da conta Google.
      // Isto inclui um 'idToken' e um 'accessToken' que provam a identidade do utilizador.
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Cria uma credencial do Firebase a partir dos tokens do Google.
      // Esta credencial é o que o Firebase Auth usa para autenticar o utilizador no seu sistema.
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Usa a credencial para fazer o login no Firebase Authentication.
      // Se for a primeira vez que este utilizador faz login, o Firebase cria automaticamente
      // uma nova conta para ele.
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // 5. Verifica se é um utilizador novo para salvar os seus dados no Firestore.
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        // Se for um utilizador novo, guardamos as suas informações na nossa base de dados 'users'.
        // Isto é útil para, por exemplo, atribuir papéis (admin, utilizador) ou guardar outras informações.
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': userCredential
              .user!.displayName, // Nome do utilizador vindo da conta Google
          'email': userCredential.user!.email, // Email vindo da conta Google
          'role':
              'user', // Por defeito, todo o novo utilizador tem o papel 'user'
          'uid':
              userCredential.user!.uid, // O ID único do utilizador no Firebase
        });
      }

      // 6. Retorna as credenciais do utilizador, que contêm todas as informações sobre o login.
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Captura erros específicos do Firebase (ex: conta desativada).
      // Por agora, apenas imprimimos o erro na consola. No futuro, podemos mostrar um alerta ao utilizador.
      print('Erro de autenticação com o Firebase: ${e.message}');
      return null;
    } catch (e) {
      // Captura quaisquer outros erros que possam ocorrer.
      print('Ocorreu um erro inesperado: $e');
      return null;
    }
  }
}
