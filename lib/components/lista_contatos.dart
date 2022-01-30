import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/usuario.dart';

class ListaContatos extends StatefulWidget {
  const ListaContatos({Key? key}) : super(key: key);

  @override
  _ListaContatosState createState() => _ListaContatosState();
}

class _ListaContatosState extends State<ListaContatos> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String _idUsuarioLogado;

  Future<List<Usuario>> _recuperarContatos() async {
    //usuarioRef recebe a coleção usuarios nomeada no firestore
    final usuarioRef = _firestore.collection("usuarios");

    QuerySnapshot querySnapshot = await usuarioRef.get();
    List<Usuario> listaUsuarios = [];
    for (DocumentSnapshot item in querySnapshot.docs) {
      String idUsuario = item["idUsuario"];
      //Para não lista o proprio usuario logado na aplicação
      if (idUsuario == _idUsuarioLogado) continue;
      //Ca
      Usuario usuario = Usuario(idUsuario, item["nome"], item["email"],
          urlImagem: item["urlImagem"]);
      listaUsuarios.add(usuario);
    }
    return listaUsuarios;
  }

  _recuperarDadosUsuarioLogado() async {
    User? usuarioAtual = _auth.currentUser;
    if (usuarioAtual != null) {
      _idUsuarioLogado = usuarioAtual.uid;
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
      future: _recuperarContatos(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:

          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: const [
                  Text("Carregando contatos"),
                  CircularProgressIndicator()
                ],
              ),
            );

          case ConnectionState.active:

          case ConnectionState.done:
            if (snapshot.hasError) {
              return const Center(child: Text("Erro ao carregar os dados!"));
            } else {
              List<Usuario>? listaUsuario = snapshot.data;
              if (listaUsuario != null) {
                return ListView.separated(
                  separatorBuilder: (context, indice) {
                    return const Divider(
                      color: Colors.grey,
                      thickness: 0.2,
                    );
                  },
                  itemCount: listaUsuario.length,
                  itemBuilder: (context, index) {
                    Usuario usuario = listaUsuario[index];
                    return ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, "/mensagens",
                            arguments: usuario);
                      },
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            CachedNetworkImageProvider(usuario.urlImagem),
                      ),
                      contentPadding: const EdgeInsets.all(8),
                      title: Text(usuario.nome),
                    );
                  },
                );
              }
              return const Center(
                child: Text("Nenhum contato encontrado!"),
              );
            }
        }
      },
    );
  }
}
