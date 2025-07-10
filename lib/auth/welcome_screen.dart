// lib/auth/welcome_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'
    as ui_google;
import 'package:pc_studio_app/auth/auth_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    // 1. A LISTA AGORA É DECLARADA COM O TIPO EXPLÍCITO E CORRETO
    final List<ui.AuthProvider> providers = [
      ui.EmailAuthProvider(),
      // O GoogleProvider é adicionado aqui. Em plataformas não suportadas
      // como o Windows, o firebase_ui_auth é inteligente o suficiente para
      // simplesmente não renderizar o botão, evitando erros de compilação.
      ui_google.GoogleProvider(
          clientId:
              "552455772523-e3nn1h6bm568ib5971247mqo2p94jeli.apps.googleusercontent.com"),
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
              providers: providers, // Agora a lista tem o tipo correto.
              headerBuilder: (context, constraints, shrinkOffset) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Bem-vindo ao PC Studio",
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
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
}
