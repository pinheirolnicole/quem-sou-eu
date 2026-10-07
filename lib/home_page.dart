import 'package:flutter/material.dart';

import 'criar_partida.dart';
import 'jogar_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quem Sou Eu?'),
      ),
      body: Center(
        child: SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: abrirCriarPartida,
                    icon: const Icon(Icons.add),
                    label: const Text('Criar partida'),
                  ),
                ),

                const SizedBox(height: 40),

                const Divider(),

                const SizedBox(height: 40),

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}