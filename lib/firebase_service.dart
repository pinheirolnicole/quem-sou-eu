import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<String> criarPartida(
    String jogador,
    String personagem,
  ) async {
    DocumentReference partida =
        await db.collection('partidas').add({
      'jogador1': jogador,
      'jogador2': '',
      'personagem': personagem,
      'pergunta': '',
      'resposta': '',
      'status': 'aguardando',
      'vencedor': '',
      'data': FieldValue.serverTimestamp(),
    });

    return partida.id;
  }

  Future<void> entrarPartida(
    String id,
    String jogador,
  ) async {
    await db.collection('partidas').doc(id).update({
      'jogador2': jogador,
      'status': 'jogando',
    });
  }

  Future<void> enviarPergunta(
    String id,
    String pergunta,
  ) async {
    await db.collection('partidas').doc(id).update({
      'pergunta': pergunta,
      'resposta': '',
    });

    await db
        .collection('partidas')
        .doc(id)
        .collection('perguntas')
        .add({
      'pergunta': pergunta,
      'data': FieldValue.serverTimestamp(),
    });
  }

 
  Future<void> responder(
    String id,
    String resposta,
  ) async {
    await db.collection('partidas').doc(id).update({
      'resposta': resposta,
    });
  }

  Future<bool> tentarAdivinhar(
    String id,
    String palpite,
    String jogador,
  ) async {
    DocumentSnapshot documento =
        await db.collection('partidas').doc(id).get();

    final dados =
        documento.data() as Map<String, dynamic>;

    String personagem =
        dados['personagem'].toString();

    bool acertou =
        personagem.trim().toLowerCase() ==
        palpite.trim().toLowerCase();

    if (acertou) {
      await db.collection('partidas').doc(id).update({
        'status': 'finalizada',
        'vencedor': jogador,
      });
    }

    return acertou;
  }

  Stream<DocumentSnapshot> ouvirPartida(String id) {
    return db
        .collection('partidas')
        .doc(id)
        .snapshots();
  }

  // FILTROS
  Stream<QuerySnapshot> partidasAguardando() {
    return db
        .collection('partidas')
        .where('status', isEqualTo: 'aguardando')
        .snapshots();
  }

  Stream<QuerySnapshot> partidasFinalizadas() {
    return db
        .collection('partidas')
        .where('status', isEqualTo: 'finalizada')
        .snapshots();
  }
}