import 'package:flutter/material.dart';

import 'firebase_service.dart';
import 'jogar_page.dart';

class CriarPartidaPage extends StatefulWidget {
  final String nomeJogador;

  const CriarPartidaPage({
    super.key,
    required this.nomeJogador,
  });

  @override
  State<CriarPartidaPage> createState() =>
      _CriarPartidaPageState();
}

class _CriarPartidaPageState
    extends State<CriarPartidaPage> {
  final TextEditingController personagemController =
      TextEditingController();

  final FirebaseService firebaseService =
      FirebaseService();

  bool carregando = false;

  Future<void> criarPartida() async {
    String personagem =
        personagemController.text.trim();

    if (personagem.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Digite o personagem secreto!',
          ),
        ),
      );
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      String id =
          await firebaseService.criarPartida(
        widget.nomeJogador,
        personagem,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => JogarPage(
            partidaId: id,
            nomeJogador: widget.nomeJogador,
            criador: true,
          ),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      setState(() {
        carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao criar partida: $erro',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar partida'),
      ),
      body: Center(
        child: SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Text(
                  'Escolha o personagem secreto',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'O outro jogador terá que descobrir quem é.',
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: personagemController,
                  decoration: const InputDecoration(
                    labelText: 'Personagem',
                    hintText: 'Ex: Homem-Aranha',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        carregando ? null : criarPartida,
                    child: Text(
                      carregando
                          ? 'Criando...'
                          : 'Criar partida',
                    ),
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