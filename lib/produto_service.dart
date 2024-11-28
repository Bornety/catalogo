import 'package:cloud_firestore/cloud_firestore.dart';
import 'produto_model.dart';

class ProdutoService {
  final CollectionReference produtosCollection = FirebaseFirestore.instance.collection('produtos');

  Future<List<Produto>> getProdutos() async {
    QuerySnapshot querySnapshot = await produtosCollection.get();
    return querySnapshot.docs.map((doc) {
      return Produto.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }
}
