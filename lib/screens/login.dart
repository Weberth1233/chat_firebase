import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/models/usuario.dart';
import 'package:whatsappweb/utils/paleta_cores.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _visible = false;
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerEmail =
      TextEditingController(text: "weberth20-19@hotmail.com");
  final TextEditingController _controllerSenha =
      TextEditingController(text: "escola11");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Uint8List? _imagemSelecionada;

  _verificarUsuarioLogado() {
    User? usuarioLogado = _auth.currentUser;
    if (usuarioLogado != null) {
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  _selecionarImagem() async {
    //Selecionar Imagem
    FilePickerResult? resultado =
        await FilePicker.platform.pickFiles(type: FileType.image);
    //Recuperar imagem
    setState(() {
      _imagemSelecionada = resultado?.files.single.bytes;
    });
  }

  _uploadImagem(Usuario usuario) {
    Uint8List? imagemSelecionada = _imagemSelecionada;
    if (imagemSelecionada != null) {
      Reference imagemPerfilRef =
          _storage.ref("imagens/perfil/¨${usuario.idUsuario}.jpg");
      UploadTask uploadTask = imagemPerfilRef.putData(imagemSelecionada);

      uploadTask.whenComplete(() async {
        String linkImagem = await uploadTask.snapshot.ref.getDownloadURL();
        //Finalizando a inserção dos dados do usuario inserindo o url de sua imagem salva
        usuario.urlImagem = linkImagem;

        //Criando coleção de usuario no firebase
        final usuariosRef = _firestore.collection("usuarios");
        //.doc identificador do doc
        //.set é necessário criar um map de usuario
        //.then ao finalizar execute isso
        usuariosRef
            .doc(usuario.idUsuario)
            .set(usuario.toMap())
            //Ao finalizar então retorne a route /home
            .then((value) => Navigator.pushReplacementNamed(context, "/home"));
      });
    }
  }

  _validarCampos() async {
    String name = _controllerName.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    //Cadastro
    if (_visible) {
      if (name.isNotEmpty &&
          name.length >= 3 &&
          email.isNotEmpty &&
          email.contains("@") &&
          senha.isNotEmpty &&
          senha.length >= 6 &&
          _imagemSelecionada != null) {
        await _auth
            .createUserWithEmailAndPassword(email: email, password: senha)
            .then((auth) {
          //Recuparando o id do usuário cadastrado no banco
          String? idUser = auth.user?.uid;
          if (idUser != null) {
            Usuario usuario = Usuario(idUser, name, email);
            _uploadImagem(usuario);
          }
        });
      } else {
        print("Algum dado incorreto!");
      }
    } //Login
    else if (email.isNotEmpty &&
        email.contains("@") &&
        senha.isNotEmpty &&
        senha.length >= 6) {
      //Logando usuario
      await _auth
          .signInWithEmailAndPassword(email: email, password: senha)
          .then((auth) {
        //Retornando tela de home
        Navigator.pushReplacementNamed(context, "/home");
      });
    } else {
      print("Algum dado incorreto!");
    }
  }

  @override
  void initState() {
    super.initState();
    _verificarUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        color: PaletaCores.corFundo,
        child: Stack(
          children: [
            Container(
              color: PaletaCores.corPrimaria,
              width: screenWidth,
              height: screenHeight * 0.4,
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      width: 500,
                      color: Colors.white,
                      child: Column(
                        children: [
                          Visibility(
                            visible: _visible,
                            child: ClipOval(
                              child: _imagemSelecionada != null
                                  ? Image.memory(
                                      _imagemSelecionada!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      "images/perfil.png",
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Visibility(
                            visible: _visible,
                            child: OutlinedButton(
                                onPressed: _selecionarImagem,
                                child: const Text("Selecionar foto")),
                          ),
                          Visibility(
                            visible: _visible,
                            child: TextField(
                              controller: _controllerName,
                              keyboardType: TextInputType.name,
                              decoration: const InputDecoration(
                                  labelText: 'Nome',
                                  suffixIcon: Icon(Icons.person_add)),
                            ),
                          ),
                          TextField(
                            controller: _controllerEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                                labelText: 'Email',
                                suffixIcon: Icon(Icons.mail_outline)),
                          ),
                          TextField(
                            controller: _controllerSenha,
                            obscureText: true,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                                labelText: 'Senha',
                                suffixIcon: Icon(Icons.lock_outline)),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: PaletaCores.corPrimaria),
                                onPressed: () {
                                  _validarCampos();
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: _visible
                                      ? const Text('Cadastrar')
                                      : const Text("Logar"),
                                )),
                          ),
                          Row(
                            children: [
                              const Text('Login'),
                              Switch(
                                  value: _visible,
                                  onChanged: (bool valor) {
                                    setState(() {
                                      _visible = valor;
                                    });
                                  }),
                              const Text('Cadastro'),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
