class Produto {
  String id;
  String nome;
  String descricao;
  double preco;
  String imagemURL;

  Produto({required this.id, required this.nome, required this.descricao, required this.preco, required this.imagemURL});

  factory Produto.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Produto(
      id: documentId,
      nome: data['nome'] ?? '',
      descricao: data['descricao'] ?? '',
      preco: data['preco'] ?? 0.0,
      imagemURL: data['imagemURL'] ?? '',
    );
  }
}
