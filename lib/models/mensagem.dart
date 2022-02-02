class Mensagem {
  String idUsuario;
  String texto;
  String data;

  Mensagem(this.idUsuario, this.texto, this.data);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idUsuario": idUsuario,
      "texto": texto,
      "data": data,
    };
    return map;
  }
}
