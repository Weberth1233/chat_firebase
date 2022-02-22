import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/models/usuario.dart';
import 'package:whatsappweb/provider/conversa_provider.dart';
import 'package:whatsappweb/utils/responsivo.dart';
import 'package:provider/provider.dart';

class ListaConversas extends StatefulWidget {
  const ListaConversas({Key? key}) : super(key: key);

  @override
  _ListaConversasState createState() => _ListaConversasState();
}

class _ListaConversasState extends State<ListaConversas> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Usuario _usuarioRemetente;

  final StreamController _streamController =
      StreamController<QuerySnapshot>.broadcast();
  late StreamSubscription _streamConversas;

  _adicionarListenerMensagens() {
    //Jogando os dados das mensagens trocados pelos usuarios e ordenando pela data dentro do Stream
    final stream = _firestore
        .collection("conversas")
        .doc(_usuarioRemetente.idUsuario)
        .collection('ultimas_mensagens')
        .snapshots();
    //Percorrendo o stream e passando para o stremController
    _streamConversas = stream.listen((dados) {
      _streamController.add(dados);
    });
  }

  _recuperarDadosInicias() {
    User? usuarioLogado = _auth.currentUser;
    if (usuarioLogado != null) {
      String idUsuario = usuarioLogado.uid;
      String? nome = usuarioLogado.displayName ?? "";
      String? email = usuarioLogado.email ?? "";
      String? urlImagem = usuarioLogado.photoURL ?? "";

      _usuarioRemetente = Usuario(idUsuario, nome, email, urlImagem: urlImagem);
    }
    _adicionarListenerMensagens();
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosInicias();
  }

  @override
  void dispose() {
    _streamConversas.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isWeb = Responsivo.isWeb(context);

    return StreamBuilder(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:

            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: const [
                    Text("Carregando conversas"),
                    CircularProgressIndicator()
                  ],
                ),
              );
            case ConnectionState.active:

            case ConnectionState.done:
              if (snapshot.hasError) {
                return const Center(
                    child: Text("Erro ao carregar as conversas!"));
              } else {
                QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                List<DocumentSnapshot> listaConversas =
                    querySnapshot.docs.toList();

                return ListView.separated(
                  separatorBuilder: (context, indice) {
                    return const Divider(
                      color: Colors.grey,
                      thickness: 0.2,
                    );
                  },
                  itemCount: listaConversas.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot conversas = listaConversas[index];

                    String idDestinatario = conversas['idDestinatario'];
                    String ultimaMensagem = conversas['ultimaMensagem'];
                    String nomeDestinatario = conversas['nomeDestinatario'];
                    String emailDestinatario = conversas['emailDestinatario'];
                    String urlImagemDestinatario =
                        conversas['urlImagemDestinatario'];

                    Usuario usuario = Usuario(
                        idDestinatario, nomeDestinatario, emailDestinatario,
                        urlImagem: urlImagemDestinatario);

                    return ListTile(
                      onTap: () {
                        //Caso seja web utilizar o provider
                        if (isWeb) {
                          context.read<ConversaProvider>().usuarioDestinatario =
                              usuario;
                        } //Se for mobile exibir uma nova tela para mensagens
                        else {
                          Navigator.pushNamed(context, "/mensagens",
                              arguments: usuario);
                        }
                      },
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            CachedNetworkImageProvider(usuario.urlImagem),
                      ),
                      title: Text(usuario.nome),
                      subtitle: Text(
                        ultimaMensagem,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      contentPadding: const EdgeInsets.all(8),
                    );
                  },
                );
              }
          }
        });
  }
}
