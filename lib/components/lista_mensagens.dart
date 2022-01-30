import 'package:flutter/material.dart';
import 'package:whatsappweb/utils/paleta_cores.dart';

class ListaMensagens extends StatelessWidget {
  const ListaMensagens({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double largura = MediaQuery.of(context).size.width;
    return Container(
      width: largura,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/bg.png"), fit: BoxFit.cover)),
      child: Column(
        children: [
          //Area onde ficaram as mensagens
          Expanded(
              child: Container(
                  width: largura, child: const Text("Lista mensagens"))),
          //Caixa de texto
          Container(
            padding: const EdgeInsets.all(8),
            color: PaletaCores.corFundoBarra,
            child: Row(
              children: [
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.insert_emoticon),
                      SizedBox(
                        width: 4,
                      ),
                      Expanded(
                          child: TextField(
                        decoration: InputDecoration(
                            hintText: "Digite uma mensagem",
                            border: InputBorder.none),
                      ))
                    ],
                  ),
                )),
                FloatingActionButton(
                  backgroundColor: PaletaCores.corPrimaria,
                  child: const Icon(Icons.send, color: Colors.white),
                  mini: true,
                  onPressed: () {},
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
