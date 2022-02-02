import 'dart:async';
import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/models/mensagem.dart';
import 'package:whatsappweb/models/usuario.dart';
import 'package:whatsappweb/utils/paleta_cores.dart';

class ListaMensagens extends StatefulWidget {
  //Criando os objetos Usuario tanto do remetente quando do destinatario
  final Usuario usuarioRemetente;
  final Usuario usuarioDestinatario;

  const ListaMensagens(
      {required this.usuarioRemetente,
      required this.usuarioDestinatario,
      Key? key})
      : super(key: key);

  @override
  _ListaMensagensState createState() => _ListaMensagensState();
}

class _ListaMensagensState extends State<ListaMensagens> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _controllerMensagem = TextEditingController();
  late Usuario _usuarioRemetente;
  late Usuario _usuarioDestinatario;

  //O strem é responsável por fazer a atualização da tela a cada novo evento que no caso são a atualização das mensagens trocadas pelos usuarios
  final StreamController _streamController =
      StreamController<QuerySnapshot>.broadcast();
  late StreamSubscription _streamMensagens;

  //Para enviar mensagem é necessário possuir o destinatario e o remetente da mensagem
  _enviarMensagens() {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      String idUsuarioRemetente = _usuarioRemetente.idUsuario;
      Mensagem mensagem = Mensagem(
          idUsuarioRemetente, textoMensagem, Timestamp.now().toString());
      //Salvando Mensagem para que o usuario remetente visualize as mensagens ao qual enviou
      String idUsuarioDestinatario = _usuarioDestinatario.idUsuario;
      _salvarMensagem(idUsuarioRemetente, idUsuarioDestinatario, mensagem);

      //Salvando para o usuario destinatario para que esta possa visualizar as mensagens ao qual recebeu
      _salvarMensagem(idUsuarioDestinatario, idUsuarioRemetente, mensagem);
    }
  }

  _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem mensagem) {
    //O remetente possui uma coleção de usuarios ao qual o mesmo mandou mensagens
    _firestore
        .collection("mensagem")
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(mensagem.toMap());
    _controllerMensagem.clear();
  }

  _adicionarListenerMensagens() {
    //Jogando os dados das mensagens trocados pelos usuarios e ordenando pela data dentro do Stream
    final stream = _firestore
        .collection("mensagem")
        .doc(_usuarioRemetente.idUsuario)
        .collection(_usuarioDestinatario.idUsuario)
        .orderBy("data", descending: false)
        .snapshots();
    //Percorrendo o stream e passando para o stremController
    _streamMensagens = stream.listen((dados) {
      _streamController.add(dados);
    });
  }

  _recuperarDadosInicias() {
    _usuarioRemetente = widget.usuarioRemetente;
    _usuarioDestinatario = widget.usuarioDestinatario;
    _adicionarListenerMensagens();
  }

  @override
  void dispose() {
    _streamMensagens.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosInicias();
  }

  @override
  Widget build(BuildContext context) {
    double largura = MediaQuery.of(context).size.width;
    return Container(
      width: largura,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/bg.png"), fit: BoxFit.cover)),
      child: Column(
        children: [
          //Area onde ficaram as mensagens
          StreamBuilder(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:

                  case ConnectionState.waiting:
                    return Expanded(
                      child: Center(
                        child: Column(
                          children: const [
                            Text("Carregando dados"),
                            CircularProgressIndicator()
                          ],
                        ),
                      ),
                    );
                  case ConnectionState.active:

                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text("Erro ao carregar os dados!"));
                    } else {
                      QuerySnapshot querySnapshot =
                          snapshot.data as QuerySnapshot;
                      List<DocumentSnapshot> listaMensagens =
                          querySnapshot.docs.toList();
                      return Expanded(
                          child: ListView.builder(
                              itemCount: querySnapshot.docs.length,
                              itemBuilder: (context, indice) {
                                DocumentSnapshot mensagem =
                                    listaMensagens[indice];
                                Alignment alinhamento = Alignment.bottomLeft;
                                Color cor = Colors.white;
                                if (_usuarioRemetente.idUsuario ==
                                    mensagem["idUsuario"]) {
                                  alinhamento = Alignment.bottomRight;
                                  cor = const Color(0xffd2ffa5);
                                }
                                Size largura =
                                    MediaQuery.of(context).size * 0.8;
                                return Align(
                                  alignment: alinhamento,
                                  child: Container(
                                    constraints: BoxConstraints.loose(largura),
                                    decoration: BoxDecoration(
                                      color: cor,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8)),
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    margin: const EdgeInsets.all(6),
                                    child: Text(mensagem["texto"]),
                                  ),
                                );
                              }));
                    }
                }
              }),
          //Caixa de texto
          Container(
            padding: const EdgeInsets.all(8),
            color: PaletaCores.corFundoBarra,
            child: Row(
              children: [
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_emoticon),
                      const SizedBox(
                        width: 4,
                      ),
                      Expanded(
                          child: TextField(
                        controller: _controllerMensagem,
                        decoration: const InputDecoration(
                            hintText: "Digite uma mensagem",
                            border: InputBorder.none),
                      ))
                    ],
                  ),
                )),
                FloatingActionButton(
                  backgroundColor: PaletaCores.corPrimaria,
                  child: const Icon(Icons.send, color: Colors.white),
                  mini: true,
                  onPressed: () {
                    _enviarMensagens();
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
