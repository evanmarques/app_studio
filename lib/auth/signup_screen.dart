import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pc_studio_app/core/main_navigator.dart'; // Importa a tela principal

// Converte o widget para StatefulWidget para que possamos gerenciar estados (texto, loading).
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controladores para ler o texto dos campos de entrada.
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Variável para controlar o estado de carregamento.
  bool _isLoading = false;

  // Instâncias dos serviços do Firebase.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    // Limpa os controladores quando o widget é removido para liberar memória.
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Função principal para registrar o usuário.
  Future<void> _signUp() async {
    // Esconde o teclado.
    FocusScope.of(context).unfocus();

    // Validação dos campos.
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As senhas não coincidem.")),
      );
      return;
    }

    // Ativa o indicador de carregamento.
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Cria o usuário no Firebase Authentication.
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Salva os dados adicionais do usuário no Cloud Firestore.
      if (userCredential.user != null) {
        // Cria um mapa com os dados do usuário.
        Map<String, dynamic> userMap = {
          "uid": userCredential.user!.uid,
          "fullName": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "role": "user",
        };

        // Salva o documento na coleção "users" usando o UID do usuário como ID.
        await _firestore
            .collection("users")
            .doc(userCredential.user!.uid)
            .set(userMap);

        // Se tudo deu certo, navega para a tela principal.
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainNavigator()),
            (route) => false, // Remove todas as telas anteriores da pilha.
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Trata erros específicos do Firebase Auth (ex: email já em uso).
      String message = "Ocorreu um erro.";
      if (e.code == 'weak-password') {
        message = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Já existe uma conta para este e-mail.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      // Trata outros erros genéricos.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    // Desativa o indicador de carregamento, mesmo se der erro.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 100,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const Column(
                children: <Widget>[
                  Text(
                    "Cadastrar",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Crie sua conta, é rápido e fácil",
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  // Conecta os campos de texto aos seus controladores.
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        labelText: 'Nome Completo',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: 'Senha',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: 'Confirmar Senha',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ],
              ),
              // Botão de Cadastro agora chama a função _signUp.
              MaterialButton(
                minWidth: double.infinity,
                height: 60,
                onPressed: _isLoading
                    ? null
                    : _signUp, // Desabilita o botão durante o carregamento.
                color: Colors.purple,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white) // Mostra o loading.
                    : const Text(
                        "Criar Conta",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.white),
                      ),
              ),
              // Link para a tela de Login.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Já tem uma conta?"),
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .pop(), // Apenas volta para a tela anterior (Login).
                    child: const Text(
                      " Login",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
