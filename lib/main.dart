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
    User? usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    String? nome = prefs.getString('nome');

    if (nome == null || nome.isEmpty) {
      nome = usuario.email ?? 'Jogador';
    }

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

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return const LoginPage();
          }

          return HomePage(
            nomeJogador: snapshot.data!,
          );
        },
      ),
    );
  }
}