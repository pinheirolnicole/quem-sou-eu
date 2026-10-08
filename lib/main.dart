import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'login_page.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  Future<String?> verificarLogin() async {
    // Verifica se existe um usuário autenticado
    User? usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return null;
    }

    // Recupera o nome salvo no SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String? nome = prefs.getString('nome');

    return nome;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quem Sou Eu?',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      home: FutureBuilder<String?>(
        future: verificarLogin(),
        builder: (context, snapshot) {
          // Enquanto verifica o login
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Se não estiver logado ou não tiver nome salvo
          if (snapshot.hasError ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return const LoginPage();
          }

          // Se estiver logado, abre a página inicial
          return HomePage(
            nomeJogador: snapshot.data!,
          );
        },
      ),
    );
  }
}