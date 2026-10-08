import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  Future<void> entrar() async {
    String nome = nomeController.text.trim();
    String email = emailController.text.trim();
    String senha = senhaController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      mostrarMensagem('Preencha todos os campos!');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nome', nome);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            nomeJogador: nome,
          ),
        ),
      );
    } catch (e) {
      mostrarMensagem('E-mail ou senha incorretos.');
    }
  }

  Future<void> cadastrar() async {
    String email = emailController.text.trim();
    String senha = senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      mostrarMensagem('Digite o e-mail e a senha!');
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      mostrarMensagem('Conta criada com sucesso!');
    } catch (e) {
      mostrarMensagem('Não foi possível criar a conta.');
    }
  }

  void mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.question_mark,
                  size: 80,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Quem Sou Eu?',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Descubra o personagem secreto!',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Seu nome',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: entrar,
                    child: const Text('Entrar'),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: cadastrar,
                    child: const Text('Criar conta'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}