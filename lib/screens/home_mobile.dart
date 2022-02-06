import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/components/lista_contatos.dart';
import 'package:whatsappweb/components/lista_conversas.dart';

class HomeMobile extends StatefulWidget {
  const HomeMobile({Key? key}) : super(key: key);

  @override
  _HomeMobileState createState() => _HomeMobileState();
}

class _HomeMobileState extends State<HomeMobile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: const Text("WhatsApp"),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
              const SizedBox(
                width: 4.0,
              ),
              IconButton(
                  onPressed: () async {
                    await _auth.signOut();
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                  icon: const Icon(Icons.logout)),
            ],
            bottom: const TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 4,
              labelStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                Padding(padding: EdgeInsets.all(8), child: Text('Conversas')),
                Padding(padding: EdgeInsets.all(8), child: Text('Contatos')),
              ],
            ),
          ),
          body: const SafeArea(
              child: TabBarView(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ListaConversas(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ListaContatos(),
              )
            ],
          ))),
    );
  }
}
