// lib/auth/welcome_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;
import "package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart"
    as ui_apple;
import 'package:firebase_ui_oauth_facebook/firebase_ui_oauth_facebook.dart'
    as ui_facebook;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'
    as ui_google;
import 'package:pc_studio_app/auth/auth_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    // Lista de provedores de autenticação que você quer oferecer.
    final providers = [
      ui.EmailAuthProvider(),
      ui_google.GoogleProvider(
          clientId:
              "552455772523-e3nn1h6bm568ib5971247mqo2p94jeli.apps.googleusercontent.com"),
      ui_facebook.FacebookProvider(
          clientId:
              "SEU_FACEBOOK_APP_ID"), // Substitua pelo seu App ID do Facebook

      // Adiciona o provedor da Apple apenas se a plataforma for iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) ui_apple.AppleProvider(),
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/dragao.png',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.5),
            colorBlendMode: BlendMode.darken,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ui.SignInScreen(
              providers: providers,
              // --- AQUI COMEÇA A CUSTOMIZAÇÃO DA UI ---
              subtitleBuilder: (context, action) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    action == ui.AuthAction.signIn
                        ? 'Faça login para continuar.'
                        : 'Crie sua conta para começar.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              },
              socialAuthButtonBuilder: (context, provider) {
                return _buildSocialButton(context, provider);
              },
              // --- FIM DA CUSTOMIZAÇÃO ---
              headerBuilder: (context, constraints, shrinkOffset) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Bem-vindo",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Encontre, agende e realize a sua próxima tatuagem.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ),
                );
              },
              actions: [
                ui.AuthStateChangeAction<ui.SignedIn>((context, state) {
                  if (state.user != null) {
                    _authService.handlePostSignIn(state.user!);
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget builder para criar os botões sociais customizados.
  Widget _buildSocialButton(BuildContext context, ui.AuthProvider provider) {
    IconData icon;
    // Define o ícone com base no provedor
    if (provider is ui_google.GoogleProvider) {
      icon = FontAwesomeIcons.google;
    } else if (provider is ui_facebook.FacebookProvider) {
      icon = FontAwesomeIcons.facebook;
    } else if (provider is ui_apple.AppleProvider) {
      icon = FontAwesomeIcons.apple;
    } else {
      return const SizedBox.shrink(); // Não mostra botão para outros tipos
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: () {
          // A ação de login é iniciada pelo próprio firebase_ui_auth
          // Nós apenas chamamos o `signIn` do provider,
          // mas antes verificamos se o provider é do tipo OAuthProvider
          if (provider is ui.OAuthProvider) {
            provider.signIn(context);
          } else {
            debugPrint('Provider não suportado: ${provider.runtimeType}');
          }
        },
        borderRadius: BorderRadius.circular(25),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
          ),
          child: Center(
            child: FaIcon(
              icon,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
