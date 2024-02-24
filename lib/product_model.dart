class ProdutoModel {
  final String nome;
  final int quantidade;

  ProdutoModel({required this.nome, required this.quantidade});

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'quantidade': quantidade,
    };
  }

  factory ProdutoModel.fromMap(Map<String, dynamic> map) {
    return ProdutoModel(
      nome: map['nome'],
      quantidade: map['quantidade'],
    );
  }
}
