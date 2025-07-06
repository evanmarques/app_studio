// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pc_studio_app/auth/auth_gate.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importações para formatação de data/hora em português
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pc_studio_app/core/notification_service.dart';

// A função 'main' é o ponto de partida de todo aplicativo Flutter.
Future<void> main() async {
  // 1. Garante que o Flutter está pronto para rodar código antes de exibir a UI.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa o Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. INICIALIZA A LOCALIZAÇÃO GLOBALMENTE (A CORREÇÃO DO ERRO!)
  // Carrega os dados de formatação para Português (Brasil) para TODO o app.
  await initializeDateFormatting('pt_BR', null);

  // --- LINHA ADICIONADA ---
  // Inicializa o nosso serviço de notificações assim que o app inicia.
  // Isso pedirá permissão e obterá o token.
  await NotificationService().initialize();

  // 4. Roda o aplicativo, agora com tudo preparado.
  runApp(const MyApp());
}

// O widget principal do seu aplicativo.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studio App',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),

      // --- CONFIGURAÇÃO DE LOCALIZAÇÃO DO APP ---
      // Informa ao Flutter para usar as regras de localização que carregamos.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Define os idiomas que o seu aplicativo suporta.
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      // Define o português do Brasil como o idioma padrão.
      locale: const Locale('pt', 'BR'),

      home: const AuthGate(),
    );
  }
}
