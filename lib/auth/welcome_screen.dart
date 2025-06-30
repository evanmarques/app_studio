// lib/auth/welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:pc_studio_app/auth/login_screen.dart';
import 'package:pc_studio_app/auth/signup_screen.dart';
import 'package:pc_studio_app/auth/auth_service.dart';

// Versão FINAL e COMPLETA
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer login com Google: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // IMAGEM DE FUNDO
          Image.asset(
            'assets/images/dragon.png', // O caminho para a imagem
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.5),
            colorBlendMode: BlendMode.darken,
          ),

          // INDICADOR DE PROGRESSO
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // CONTEÚDO PRINCIPAL
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Título
                  const Column(
                    children: <Widget>[
                      Text(
                        "Bem-vindo",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 5, color: Colors.black)
                            ]),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Encontre, agende e realize a sua próxima tatuagem. Tudo num só lugar.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Botões
                  Column(
                    children: <Widget>[
                      // BOTÃO DE LOGIN COM GOOGLE
                      MaterialButton(
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        color: const Color(0xFFDB4437),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.g_mobiledata,
                                color: Colors.white, size: 30),
                            SizedBox(width: 10),
                            Text(
                              "Entrar com Google",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // BOTÃO DE LOGIN COM E-MAIL
                      MaterialButton(
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Text(
                          "Login com E-mail",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // BOTÃO DE REGISTAR
                      MaterialButton(
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupScreen()),
                          );
                        },
                        color: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Text(
                          "Registar",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
