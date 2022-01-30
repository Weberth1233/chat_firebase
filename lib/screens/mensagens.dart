import 'package:cached_network_image/cached_network_image.dart';
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

  _recuperarDadosUsuarioDestinatario() {
    _usuarioDestinatario = widget.usuarioDestinatario;
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuarioDestinatario();
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
      body: const ListaMensagens(),
    );
  }
}
