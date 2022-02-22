import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/components/lista_conversas.dart';
import 'package:whatsappweb/components/lista_mensagens.dart';
import 'package:whatsappweb/models/usuario.dart';
import 'package:whatsappweb/provider/conversa_provider.dart';
import 'package:whatsappweb/utils/paleta_cores.dart';
import 'package:whatsappweb/utils/responsivo.dart';

class HomeWeb extends StatefulWidget {
  const HomeWeb({Key? key}) : super(key: key);

  @override
  _HomeWebState createState() => _HomeWebState();
}

class _HomeWebState extends State<HomeWeb> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Usuario _usuarioLogado;

  _recuperarDadosUsuarioLogado() {
    User? usuarioLogado = _auth.currentUser;
    if (usuarioLogado != null) {
      String idUsuario = usuarioLogado.uid;
      String? nome = usuarioLogado.displayName ?? "";
      String? email = usuarioLogado.email ?? "";
      String? urlImagem = usuarioLogado.photoURL ?? "";

      _usuarioLogado = Usuario(idUsuario, nome, email, urlImagem: urlImagem);
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    bool isWeb = Responsivo.isWeb(context);
    double largura = MediaQuery.of(context).size.width;
    double altura = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Container(
      color: PaletaCores.corFundo,
      //Criando stack para dividir a tela com um pequeno container verde
      child: Stack(
        children: [
          Positioned(
              //Sempre definir uma altura dentro da minha stack para meus position, caso não faça isso o tamanho dos elementos vai ficar de acordo com primeiro
              //position criado na tela que no caso é esse abaixo que possui uma altura =  altura *0.2 fazendo com que os filhos do stack se comportem seguindo o mesmo
              //tamanho do primeiro
              top: 0,
              child: Container(
                color: PaletaCores.corPrimaria,
                width: largura,
                height: altura * 0.2,
              )),
          Positioned(
              //Caso seja web é dado um espaçamento de 0.05 caso seja um tablet não há o espaçamento
              top: isWeb ? altura * 0.05 : 0,
              bottom: isWeb ? altura * 0.05 : 0,
              left: isWeb ? largura * 0.05 : 0,
              right: isWeb ? largura * 0.05 : 0,
              child: Row(
                children: [
                  Expanded(
                      flex: 4,
                      child: AreaLateral(
                        usuarioLogado: _usuarioLogado,
                      )),
                  Expanded(
                      flex: 10,
                      child: AreaPrincipal(
                        usuarioLogado: _usuarioLogado,
                      )),
                ],
              ))
        ],
      ),
    ));
  }
}

class AreaLateral extends StatelessWidget {
  final Usuario usuarioLogado;
  const AreaLateral({required this.usuarioLogado, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: PaletaCores.corFundoBarraClara,
          border: Border(
              right: BorderSide(
            color: PaletaCores.corFundo,
            width: 1,
          ))),
      child: Column(
        children: [
          //Barra superior em uma row com a imagem do usuario logado
          //um spacer para dar um espaçamento e os dois iconButton
          Container(
            color: PaletaCores.corFundoBarra,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  backgroundImage:
                      CachedNetworkImageProvider(usuarioLogado.urlImagem),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.message),
                ),
                IconButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
          ),
          //Barra de pesquisa com o campo de texto para pesquisar
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                const Expanded(
                    child: TextField(
                  decoration: InputDecoration.collapsed(
                      hintText: "Pesquisar uma conversa"),
                ))
              ],
            ),
          ),
          Expanded(
              child: Container(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: const ListaConversas(),
          ))
        ],
      ),
    );
  }
}

class AreaPrincipal extends StatelessWidget {
  final Usuario usuarioLogado;

  const AreaPrincipal({Key? key, required this.usuarioLogado})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Usuario? usuarioDest =
        context.watch<ConversaProvider>().usuarioDestinatario;

    double largura = MediaQuery.of(context).size.width;
    double altura = MediaQuery.of(context).size.height;
    return usuarioDest != null
        ? Column(
            children: [
              Container(
                color: PaletaCores.corFundoBarra,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          CachedNetworkImageProvider(usuarioDest.urlImagem),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      usuarioDest.nome,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
              ),
              //Lista Mensagens
              Expanded(
                  child: ListaMensagens(
                usuarioRemetente: usuarioLogado,
                usuarioDestinatario: usuarioDest,
              ))
            ],
          )
        : Container(
            height: altura,
            width: largura,
            color: PaletaCores.corFundoBarraClara,
            child: const Center(
                child: Text("Nenhum usuário selecionado no momento!")),
          );
    /*return Container(
      height: altura,
      width: largura,
      color: PaletaCores.corFundoBarraClara,
      child: Text(
          usuario != null ? usuario.nome : "Usuario ainda não selecionado!"),
    );*/
  }
}
