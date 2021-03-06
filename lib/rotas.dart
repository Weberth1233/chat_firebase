import 'package:flutter/material.dart';
import 'package:whatsappweb/models/usuario.dart';
import 'package:whatsappweb/screens/home.dart';
import 'package:whatsappweb/screens/login.dart';
import 'package:whatsappweb/screens/mensagens.dart';

class Rotas {
  static Route<dynamic> gerarRota(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => const Login());
      case "/login":
        return MaterialPageRoute(builder: (_) => const Login());
      case "/home":
        return MaterialPageRoute(builder: (_) => const Home());
      case "/mensagens":
        return MaterialPageRoute(builder: (_) => Mensagens(args as Usuario));
    }
    return _errorRota();
  }

  static Route<dynamic> _errorRota() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Tela não encontrada!"),
        ),
        body: const Center(
          child: Text("Tela não encontrada!"),
        ),
      );
    });
  }
}
