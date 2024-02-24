import 'package:exemplo_sqflite/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ProdutoModel> produtos = [];
  late Database database;

  @override
  void initState() {
    super.initState();
    abrirBancoDeDados().then((_) => atualizarListaProdutos());
  }

  Future<void> abrirBancoDeDados() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'produto_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE produtos(id INTEGER PRIMARY KEY, nome TEXT, quantidade INTEGER)',
        );
      },
      version: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controllerNomeController = TextEditingController();
    TextEditingController controllerQuantidadeController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Exemplo sqflite')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: controllerNomeController,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: controllerQuantidadeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),
            ElevatedButton(
              onPressed: () async {
                await adicionarProdutos(ProdutoModel(
                  nome: controllerNomeController.text,
                  quantidade: int.parse(controllerQuantidadeController.text),
                ));
                controllerNomeController.clear();
                controllerQuantidadeController.clear();
              },
              child: const Text('Adicionar'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: produtos.length,
                itemBuilder: (context, index) {
                  final item = produtos[index];
                  return Row(
                    children: [
                      IconButton(
                        onPressed: () async => await deletarProdutos(index),
                        icon: const Icon(Icons.delete),
                      ),
                      Text('${item.quantidade} - ${item.nome}'),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> adicionarProdutos(ProdutoModel produto) async {
    await database.insert('produtos', produto.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    atualizarListaProdutos();
  }

  Future<void> deletarProdutos(int index) async {
    await database.delete(
      'produtos',
      where: 'nome = ?',
      whereArgs: [produtos[index].nome],
    );
    atualizarListaProdutos();
  }

  Future<void> atualizarListaProdutos() async {
    final List<ProdutoModel> listaProdutos = await pegarProdutos();
    setState(() => produtos = listaProdutos);
  }

  Future<List<ProdutoModel>> pegarProdutos() async {
    final List<Map<String, dynamic>> maps = await database.query('produtos');
    return List.generate(
      maps.length,
      (index) {
        return ProdutoModel(
          nome: maps[index]['nome'],
          quantidade: maps[index]['quantidade'],
        );
      },
    );
  }
}
