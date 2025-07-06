import 'package:flutter/material.dart';
import 'package:pc_studio_app/auth/login_screen.dart';
import 'package:pc_studio_app/auth/signup_screen.dart';
import 'package:pc_studio_app/auth/auth_service.dart';
import 'package:pc_studio_app/core/main_navigator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  // *** LÓGICA DE LOGIN ATUALIZADA ***
  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    final navigator = Navigator.of(context);

    // Chama o nosso serviço e agora espera uma resposta 'true' ou 'false'.
    final bool success = await _authService.signInWithGoogle();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    // Se o login foi bem-sucedido, navegamos para a tela principal.
    // Esta navegação explícita resolve o problema de "congelamento".
    if (success && mounted) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigator()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/dragao.png', // O nome do seu ficheiro foi corrigido para 'dragao.png'
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.5),
            colorBlendMode: BlendMode.darken,
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
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
                          _buildSocialButton(
                            icon: FontAwesomeIcons.google,
                            // Chama a nossa nova função de login robusta.
                            onTap: _isLoading ? () {} : _handleGoogleSignIn,
                          ),
                          const SizedBox(width: 20),
                          _buildSocialButton(
                            icon: FontAwesomeIcons.instagram,
                            onTap: () {
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

  // O seu widget auxiliar para os botões sociais.
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
