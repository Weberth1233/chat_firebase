class Usuario {
  String idUsuario;
  String nome;
  String email;
  String urlImagem;
  bool online;

  Usuario(this.idUsuario, this.nome, this.email,
      {this.urlImagem = " ", this.online = false});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idUsuario": idUsuario,
      "nome": nome,
      "email": email,
      "urlImagem": urlImagem,
      "online": online
    };
    return map;
  }
}
