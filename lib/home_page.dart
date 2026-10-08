
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'criar_partida.dart';
import 'jogar_page.dart';
import 'lista_partidas.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final String nomeJogador;

  const HomePage({
    super.key,
    required this.nomeJogador,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController codigoController =
      TextEditingController();

  void abrirCriarPartida() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CriarPartidaPage(
          nomeJogador: widget.nomeJogador,
        ),
      ),
    );
  }

  void entrarPartida() {
    String codigo = codigoController.text.trim();

    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite o código da partida!'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JogarPage(
          partidaId: codigo,
          nomeJogador: widget.nomeJogador,
          criador: false,
        ),
      ),
    );
  }

  void abrirLista(bool finalizadas) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaPartidasPage(
          nomeJogador: widget.nomeJogador,
          finalizadas: finalizadas,
        ),
      ),
    );
  }

  Future<void> sairDaConta() async {
    try {
      await FirebaseAuth.instance.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('nome');

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
        (route) => false,
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao sair da conta: $erro'),
        ),
      );
    }
  }

  @override
  void dispose() {
    codigoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quem Sou Eu?'),
        actions: [
          IconButton(
            onPressed: sairDaConta,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair da conta',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 450,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Olá, ${widget.nomeJogador}!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Crie uma partida ou entre em uma existente.',
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: abrirCriarPartida,
                      icon: const Icon(Icons.add),
                      label: const Text('Criar partida'),
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Divider(),
                  const SizedBox(height: 25),

                  TextField(
                    controller: codigoController,
                    decoration: const InputDecoration(
                      labelText: 'Código da partida',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: entrarPartida,
                      icon: const Icon(Icons.login),
                      label: const Text('Entrar na partida'),
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Divider(),
                  const SizedBox(height: 15),

                  const Text(
                    'Consultar partidas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => abrirLista(false),
                      child: const Text(
                        'Ver partidas aguardando',
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => abrirLista(true),
                      child: const Text(
                        'Ver partidas finalizadas',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
