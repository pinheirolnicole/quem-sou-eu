import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_service.dart';

class JogarPage extends StatefulWidget {
  final String partidaId;
  final String nomeJogador;
  final bool criador;

  const JogarPage({
    super.key,
    required this.partidaId,
    required this.nomeJogador,
    required this.criador,
  });

  @override
  State<JogarPage> createState() => _JogarPageState();
}

class _JogarPageState extends State<JogarPage> {
  final FirebaseService firebaseService =
      FirebaseService();

  final TextEditingController perguntaController =
      TextEditingController();

  final TextEditingController palpiteController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    if (!widget.criador) {
      entrar();
    }
  }

  Future<void> entrar() async {
    try {
      await firebaseService.entrarPartida(
        widget.partidaId,
        widget.nomeJogador,
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível entrar: $erro',
          ),
        ),
      );
    }
  }

  Future<void> enviarPergunta() async {
    String pergunta =
        perguntaController.text.trim();

    if (pergunta.isEmpty) {
      return;
    }

    await firebaseService.enviarPergunta(
      widget.partidaId,
      pergunta,
    );

    perguntaController.clear();
  }

  Future<void> responder(String resposta) async {
    await firebaseService.responder(
      widget.partidaId,
      resposta,
    );
  }

  Future<void> tentarAdivinhar() async {
    String palpite =
        palpiteController.text.trim();

    if (palpite.isEmpty) {
      return;
    }

    bool acertou =
        await firebaseService.tentarAdivinhar(
      widget.partidaId,
      palpite,
      widget.nomeJogador,
    );

    if (!mounted) return;

    if (!acertou) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Errou! Continue tentando.',
          ),
        ),
      );

      palpiteController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quem Sou Eu?'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firebaseService.ouvirPartida(
          widget.partidaId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro: ${snapshot.error}',
              ),
            );
          }

          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Partida não encontrada.',
              ),
            );
          }

          final dados =
              snapshot.data!.data()
                  as Map<String, dynamic>;

          String jogador1 =
              dados['jogador1'] ?? '';

          String jogador2 =
              dados['jogador2'] ?? '';

          String personagem =
              dados['personagem'] ?? '';

          String pergunta =
              dados['pergunta'] ?? '';

          String resposta =
              dados['resposta'] ?? '';

          String status =
              dados['status'] ?? '';

          String vencedor =
              dados['vencedor'] ?? '';

          // PARTIDA TERMINOU
          if (status == 'finalizada') {
            return telaFinal(
              personagem,
              vencedor,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: SizedBox(
                width: 600,
                child: Column(
                  children: [
                    const Text(
                      'Código da partida',
                    ),

                    SelectableText(
                      widget.partidaId,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'Jogador 1: $jogador1',
                            ),
                            const SizedBox(height: 5),
                            Text(
                              jogador2.isEmpty
                                  ? 'Aguardando jogador 2...'
                                  : 'Jogador 2: $jogador2',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    if (widget.criador)
                      telaCriador(
                        personagem,
                        pergunta,
                        resposta,
                        jogador2,
                      )
                    else
                      telaJogador(
                        pergunta,
                        resposta,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget telaCriador(
    String personagem,
    String pergunta,
    String resposta,
    String jogador2,
  ) {
    return Column(
      children: [
        const Text(
          'Seu personagem secreto é:',
          style: TextStyle(fontSize: 18),
        ),

        const SizedBox(height: 10),

        Text(
          personagem,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 40),

        if (jogador2.isEmpty)
          const Text(
            'Aguardando outro jogador entrar...',
          )
        else if (pergunta.isEmpty)
          const Text(
            'Aguardando uma pergunta...',
            style: TextStyle(fontSize: 18),
          )
        else ...[
          const Text(
            'Pergunta recebida:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            pergunta,
            style: const TextStyle(
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  responder('SIM');
                },
                child: const Text('SIM'),
              ),

              const SizedBox(width: 20),

              ElevatedButton(
                onPressed: () {
                  responder('NÃO');
                },
                child: const Text('NÃO'),
              ),
            ],
          ),

          if (resposta.isNotEmpty) ...[
            const SizedBox(height: 20),

            Text(
              'Você respondeu: $resposta',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget telaJogador(
    String pergunta,
    String resposta,
  ) {
    return Column(
      children: [
        const Text(
          'Descubra o personagem!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 30),

        TextField(
          controller: perguntaController,
          decoration: const InputDecoration(
            labelText: 'Faça uma pergunta',
            hintText: 'Ex: É um super-herói?',
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 15),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: enviarPergunta,
            child: const Text(
              'Enviar pergunta',
            ),
          ),
        ),

        const SizedBox(height: 30),

        if (pergunta.isNotEmpty) ...[
          const Text(
            'Última pergunta:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            pergunta,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),

          const SizedBox(height: 10),

          if (resposta.isEmpty)
            const Text(
              'Aguardando resposta...',
            )
          else
            Text(
              'Resposta: $resposta',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],

        const SizedBox(height: 40),
        const Divider(),
        const SizedBox(height: 30),

        const Text(
          'Já sabe quem é?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        TextField(
          controller: palpiteController,
          decoration: const InputDecoration(
            labelText: 'Digite seu palpite',
            hintText: 'Ex: Batman',
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 15),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: tentarAdivinhar,
            child: const Text(
              'ADIVINHAR',
            ),
          ),
        ),
      ],
    );
  }

  Widget telaFinal(
    String personagem,
    String vencedor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 100,
            ),

            const SizedBox(height: 20),

            const Text(
              'FIM DE JOGO!',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Text(
              '$vencedor acertou!',
              style: const TextStyle(
                fontSize: 26,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'O personagem era:',
            ),

            const SizedBox(height: 5),

            Text(
              personagem,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(
                  context,
                  (route) => route.isFirst,
                );
              },
              child: const Text(
                'Voltar ao início',
              ),
            ),
          ],
        ),
      ),
    );
  }
}