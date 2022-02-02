import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/components/lista_mensagens.dart';
import 'package:whatsappweb/models/usuario.dart';

class Mensagens extends StatefulWidget {
  final Usuario usuarioDestinatario;

  const Mensagens(this.usuarioDestinatario, {Key? key}) : super(key: key);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  late Usuario _usuarioDestinatario;
  //O usuario que está logado
  late Usuario _usuarioRemetente;

  FirebaseAuth _auth = FirebaseAuth.instance;

  //Usuario destinatario é aquela ao qual foi clicado para o envio da mensagem nesta tela
  _recuperarDadosInicias() {
    _usuarioDestinatario = widget.usuarioDestinatario;
    User? usuarioLogado = _auth.currentUser;
    if (usuarioLogado != null) {
      String idUsuario = usuarioLogado.uid;
      String? nome = usuarioLogado.displayName ?? "";
      String? email = usuarioLogado.email ?? "";
      String? urlImagem = usuarioLogado.photoURL ?? "";

      _usuarioRemetente = Usuario(idUsuario, nome, email, urlImagem: urlImagem);
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosInicias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey,
              backgroundImage:
                  CachedNetworkImageProvider(_usuarioDestinatario.urlImagem),
            ),
            const SizedBox(
              width: 8,
            ),
            Text(_usuarioDestinatario.nome,
                style: const TextStyle(fontSize: 16, color: Colors.white)),
          ],
        ),
      ),
      body: ListaMensagens(
        usuarioDestinatario: _usuarioDestinatario,
        usuarioRemetente: _usuarioRemetente,
      ),
    );
  }
}
