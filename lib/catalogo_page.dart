import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Produtos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CatalogoPage(),
    );
  }
}

class CatalogoPage extends StatefulWidget {
  @override
  _CatalogoPageState createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  Future<void> _saveProduct(String? id) async {
  final nome = _nomeController.text;
  final valorText = _valorController.text;
  final descricao = _descricaoController.text;

  // Verifica se o valor é numérico
  final valor = double.tryParse(valorText);
  if (valor == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Por favor, insira um valor numérico válido.')),
    );
    return; // Sai da função sem salvar
  }

  if (nome.isEmpty || valor <= 0 || descricao.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Todos os campos devem ser preenchidos.')),
    );
    return; // Sai da função sem salvar
  }

  if (id == null) {
    // Adiciona novo produto
    await _firestore.collection('produtos').add({
      'nome': nome,
      'valor': valor,
      'descricao': descricao,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Produto adicionado com sucesso!')),
    );
  } else {
    // Atualiza produto existente
    await _firestore.collection('produtos').doc(id).update({
      'nome': nome,
      'valor': valor,
      'descricao': descricao,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Produto atualizado com sucesso!')),
    );
  }

  _nomeController.clear();
  _valorController.clear();
  _descricaoController.clear();
  Navigator.of(context).pop();
}

  Future<void> _deleteProduct(String id) async {
    await _firestore.collection('produtos').doc(id).delete();
    // Mensagem ao excluir produto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Produto excluído com sucesso!')),
    );
  }

  void _showProductForm({String? id, String? nome, double? valor, String? descricao}) {
    if (id != null) {
      _nomeController.text = nome ?? '';
      _valorController.text = valor?.toString() ?? '';
      _descricaoController.text = descricao ?? '';
    } else {
      _nomeController.clear();
      _valorController.clear();
      _descricaoController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              top: 16,
              left: 16,
              right: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id == null ? 'Adicionar Produto' : 'Editar Produto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _nomeController,
                  decoration: InputDecoration(labelText: 'Nome do Produto'),
                ),
                TextField(
                  controller: _valorController,
                  decoration: InputDecoration(labelText: 'Valor do Produto'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _descricaoController,
                  decoration: InputDecoration(labelText: 'Descrição do Produto'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _saveProduct(id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: Size(double.infinity, 40),
                  ),
                  child: Text(id == null ? 'Adicionar' : 'Atualizar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Stream<List<Map<String, dynamic>>> _getProducts() {
    return _firestore.collection('produtos').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'nome': doc['nome'],
          'valor': doc['valor'],
          'descricao': doc['descricao'],
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo de Produtos'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar os produtos'));
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return Center(child: Text('Nenhum produto encontrado.'));
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                margin: EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  title: Text(
                    product['nome'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6),
                      Text(
                        'R\$ ${product['valor'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        product['descricao'],
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () {
                          _showProductForm(
                            id: product['id'],
                            nome: product['nome'],
                            valor: product['valor'],
                            descricao: product['descricao'],
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          _deleteProduct(product['id']);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showProductForm();
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
      ),
    );
  }
}
