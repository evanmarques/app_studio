// lib/auth/welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:pc_studio_app/auth/login_screen.dart';
import 'package:pc_studio_app/auth/signup_screen.dart';
import 'package:pc_studio_app/auth/auth_service.dart'; // 1. IMPORTAMOS O NOSSO NOVO SERVIÇO

// 2. CONVERTEMOS PARA STATEFULWIDGET PARA GERIR O ESTADO DE "A CARREGAR"
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // Variável para controlar a exibição do indicador de progresso
  bool _isLoading = false;
  // Instância do nosso serviço de autenticação
  final AuthService _authService = AuthService();

  // Função para lidar com o clique no botão de login com Google
  void _handleGoogleSignIn() async {
    // Ativa o estado de "a carregar" e redesenha o ecrã
    setState(() {
      _isLoading = true;
    });

    try {
      // Chama o método de login com Google do nosso serviço
      await _authService.signInWithGoogle();

      // Se o login for bem-sucedido, o AuthGate (que está a "ouvir" as alterações de login)
      // irá automaticamente navegar para a tela principal. Não precisamos de fazer mais nada aqui.
    } catch (e) {
      // Se ocorrer um erro, mostra uma mensagem na parte inferior do ecrã
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer login com Google: $e')),
        );
      }
    } finally {
      // O bloco 'finally' é sempre executado, quer o login tenha sucesso ou falhe.
      // Garante que o indicador de "a carregar" seja sempre desativado.
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
      body: SafeArea(
        // Se estiver a carregar, mostra um indicador de progresso, senão, mostra o conteúdo da página
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                width: double.infinity,
                height: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Column(
                      children: <Widget>[
                        Text(
                          "Bem-vindo",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Encontre, agende e realize a sua próxima tatuagem. Tudo num só lugar.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 3,
                      decoration: const BoxDecoration(
                          // image: DecorationImage(image: AssetImage("assets/welcome.png")),
                          ),
                    ),
                    Column(
                      children: <Widget>[
                        // --- 3. BOTÃO DE LOGIN COM GOOGLE ADICIONADO ---
                        MaterialButton(
                          minWidth: double.infinity,
                          height: 60,
                          onPressed:
                              _handleGoogleSignIn, // Chama a nossa nova função
                          color: Colors.red.shade700, // Cor do Google
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Ícone do Google (exemplo, precisa de um asset de imagem ou pacote de ícones)
                              // Por agora, vamos usar um ícone padrão
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
                        // ---------------------------------------------
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
                            "Login com E-mail", // Texto alterado para maior clareza
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
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
                            "Cadastrar",
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
    );
  }
}
