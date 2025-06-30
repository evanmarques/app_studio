// lib/auth/login_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pc_studio_app/auth/signup_screen.dart';
import 'package:pc_studio_app/core/main_navigator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para ler o texto dos campos de entrada.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variável para controlar o estado de carregamento.
  bool _isLoading = false;

  // Instância do Firebase Auth.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    // Limpa os controladores quando o widget é removido para liberar memória.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Função principal para fazer o login do usuário.
  Future<void> _signIn() async {
    // Esconde o teclado.
    FocusScope.of(context).unfocus();

    // Validação básica para não fazer chamadas vazias ao Firebase.
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha e-mail e senha.')),
      );
      return;
    }

    // Ativa o indicador de carregamento.
    setState(() {
      _isLoading = true;
    });

    try {
      // Usa o Firebase Auth para fazer login com e-mail e senha.
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Se o login for bem-sucedido e o widget ainda estiver na tela...
      if (mounted) {
        // Navega para a tela principal e remove todas as telas anteriores.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigator()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      // Trata erros específicos do Firebase Auth (ex: usuário não encontrado, senha errada).
      String message = "Ocorreu um erro.";
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'E-mail ou senha incorretos.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      // Trata outros erros genéricos.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ocorreu um erro: ${e.toString()}")),
      );
    }

    // Desativa o indicador de carregamento, mesmo se der erro.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para a recuperação de senha.
  void _forgotPassword() {
    // TODO: Implementar a lógica de recuperação de senha.
    // Ex: Mostrar um dialog para inserir o email e enviar o link de reset.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Funcionalidade de recuperar senha a ser implementada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Evita que os widgets sejam redimensionados quando o teclado aparece.
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
        ),
      ),
      // Corpo da tela envolto por um Stack para adicionar a imagem de fundo.
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- 1. IMAGEM DE FUNDO ---
          Image.asset(
            'assets/images/dragao.png', // Caminho da imagem de fundo
            fit: BoxFit.cover,
            // Aplica um filtro escuro para melhorar a legibilidade do conteúdo.
            color: Colors.black.withOpacity(0.6),
            colorBlendMode: BlendMode.darken,
          ),
          // SingleChildScrollView permite que o conteúdo role se não couber na tela (com teclado aberto).
          SingleChildScrollView(
            child: SizedBox(
              // Define a altura para ocupar a tela inteira.
              height: MediaQuery.of(context).size.height -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.top,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // Coluna para o título da tela.
                  const Column(
                    children: <Widget>[
                      Text("Login",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      Text("Faça login na sua conta",
                          style: TextStyle(fontSize: 15, color: Colors.grey)),
                    ],
                  ),
                  // Padding para os campos de entrada e botão.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: <Widget>[
                        // Campo de Email.
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Campo de Senha.
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // --- 2. BOTÃO "ESQUECI A SENHA" ---
                        // Alinhado à direita para seguir o padrão de design.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _isLoading ? null : _forgotPassword,
                              child: const Text(
                                "Esqueci a senha?",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Botão de Entrar.
                        MaterialButton(
                          minWidth: double.infinity,
                          height: 60,
                          onPressed: _isLoading ? null : _signIn,
                          color: Colors.purple,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          // Mostra o indicador de loading dentro do botão.
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  "Entrar",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Colors.white),
                                ),
                        ),
                      ],
                    ),
                  ),
                  // Link para a tela de Cadastro.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Não tem uma conta?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupScreen()),
                          );
                        },
                        child: const Text(
                          " Cadastrar",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
