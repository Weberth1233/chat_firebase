import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/rotas.dart';
import 'package:whatsappweb/utils/paleta_cores.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'WhatsAppWeb',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: PaletaCores.corPrimaria,
          appBarTheme:
              const AppBarTheme(backgroundColor: PaletaCores.corPrimaria)),
      initialRoute: "/login",
      onGenerateRoute: Rotas.gerarRota,
    ),
  );
}
