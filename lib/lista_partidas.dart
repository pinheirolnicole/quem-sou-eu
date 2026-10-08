
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_service.dart';
import 'jogar_page.dart';

class ListaPartidasPage extends StatelessWidget {
  final String nomeJogador;
  final bool finalizadas;

  const ListaPartidasPage({
    super.key,
    required this.nomeJogador,
    required this.finalizadas,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService =
        FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          finalizadas
              ? 'Partidas finalizadas'
              : 'Partidas aguardando',
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: finalizadas
            ? firebaseService.partidasFinalizadas()
            : firebaseService.partidasAguardando(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Erro ao consultar partidas.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final partidas = snapshot.data!.docs;

          if (partidas.isEmpty) {
            return const Center(
              child: Text('Nenhuma partida encontrada.'),
            );
          }

          return ListView.builder(
            itemCount: partidas.length,

            itemBuilder: (context, index) {
              final partida = partidas[index];

              final dados =
                  partida.data() as Map<String, dynamic>;

              final jogador1 =
                  dados['jogador1'] ?? '';

              final vencedor =
                  dados['vencedor'] ?? '';

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(
                  title: Text(
                    'Criada por: $jogador1',
                  ),

                  subtitle: Text(
                    finalizadas
                        ? 'Vencedor: $vencedor'
                        : 'Aguardando outro jogador',
                  ),

                  trailing: finalizadas
                      ? const Icon(Icons.emoji_events)
                      : ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    JogarPage(
                                  partidaId: partida.id,
                                  nomeJogador: nomeJogador,
                                  criador: false,
                                ),
                              ),
                            );
                          },
                          child: const Text('Entrar'),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
