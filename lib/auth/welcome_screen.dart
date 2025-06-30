// lib/auth/welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:pc_studio_app/auth/login_screen.dart';
import 'package:pc_studio_app/auth/signup_screen.dart';
import 'package:pc_studio_app/auth/auth_service.dart';
// Importa o pacote FontAwesome para usar os ícones de marcas.
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // Estado para controlar o loading do login com Google.
  bool _isLoading = false;
  // Instância do nosso serviço de autenticação.
  final AuthService _authService = AuthService();

  // Função para lidar com o login do Google.
  void _handleGoogleSignIn() async {
    // Ativa o indicador de progresso e desabilita os botões.
    setState(() {
      _isLoading = true;
    });
    try {
      // Chama o método de login do nosso serviço.
      await _authService.signInWithGoogle();
      // O AuthGate tratará da navegação se o login for bem-sucedido.
    } catch (e) {
      // Se ocorrer um erro, exibe uma mensagem para o usuário.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer login com Google: $e')),
        );
      }
    } finally {
      // Garante que o indicador de progresso seja desativado no final.
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
          // Imagem de fundo.
          Image.asset(
            'assets/images/dragao.png',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.5),
            colorBlendMode: BlendMode.darken,
          ),

          // Indicador de progresso centralizado.
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Conteúdo principal da tela.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Texto de boas-vindas.
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

                  // Botões de ação.
                  Column(
                    children: <Widget>[
                      const Text(
                        "Entre com suas redes sociais",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Usando ícones do pacote FontAwesome para evitar erros de assets não encontrados.
                          _buildSocialButton(
                            icon: FontAwesomeIcons.google,
                            onTap: _isLoading ? () {} : _handleGoogleSignIn,
                          ),
                          const SizedBox(width: 20),
                          _buildSocialButton(
                            icon: FontAwesomeIcons.instagram,
                            onTap: () {
                              // TODO: Implementar login com Instagram
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Login com Instagram a ser implementado.')),
                              );
                            },
                          ),
                          const SizedBox(width: 20),
                          _buildSocialButton(
                            icon: FontAwesomeIcons.facebook,
                            onTap: () {
                              // TODO: Implementar login com Facebook
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Login com Facebook a ser implementado.')),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Botões de login e registro com e-mail.
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

  // Widget auxiliar para criar os botões sociais redondos.
  Widget _buildSocialButton(
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: FaIcon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
