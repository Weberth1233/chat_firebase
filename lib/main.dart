import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/rotas.dart';
import 'package:whatsappweb/utils/paleta_cores.dart';

void main() {
  String rota = "/";
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? usuarioLogado = FirebaseAuth.instance.currentUser;

  if (usuarioLogado != null) {
    rota = "/home";
  }

  runApp(
    MaterialApp(
      title: 'WhatsAppWeb',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: PaletaCores.corPrimaria,
          appBarTheme:
              const AppBarTheme(backgroundColor: PaletaCores.corPrimaria)),
      initialRoute: rota,
      onGenerateRoute: Rotas.gerarRota,
    ),
  );
}
