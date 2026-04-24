import 'package:flutter/material.dart';

class OperationsBody extends StatefulWidget {
  const OperationsBody({super.key});

  @override
  State<OperationsBody> createState() => _OperationsBodyState();
}

class _OperationsBodyState extends State<OperationsBody> {
  final TextEditingController descController = TextEditingController();
  final TextEditingController valorController = TextEditingController();
  bool isReceita = true;
  bool descInvalid = false;
  bool valorInvalid = false;

  void adicionarTransacao() {
    final descricao = descController.text;
    final valor = double.tryParse(valorController.text);

    // Reseta validações
    descInvalid = false;
    valorInvalid = false;

    if (descricao.isEmpty) {
      descInvalid = true;
      setState(() {});
      return;
    } else if (valor == null) {
      valorInvalid = true;
      setState(() {});
      return;
    }

    final novaTransacao = {
      'descricao': descricao,
      'valor': valor,
      'tipo': isReceita ? 'receita' : 'despesa',
      'data': DateTime.now().toString(),
    };

    descController.clear();
    valorController.clear();
    // Navigator.pop(context); // Removido, pois não há navegação
    setState(() {});
  }

  double calcularSaldo() {
    double saldo = 0;

    return saldo;
  }

  void deleteData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir todos os dados?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
      barrierColor: Color.fromARGB(50, 125, 125, 125),
    );
  }

  void _abrirBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateSheet) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Nova Transação',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    labelStyle: TextStyle(
                      color: descInvalid ? Colors.red : Colors.black,
                    ),
                    errorText: descInvalid ? 'Campo obrigatório' : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: valorController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Valor',
                    labelStyle: TextStyle(
                      color: valorInvalid ? Colors.red : Colors.black,
                    ),
                    errorText: valorInvalid ? 'Valor inválido' : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Tipo:'),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: isReceita,
                          onChanged: (value) {
                            setStateSheet(() {
                              isReceita = value!;
                            });
                          },
                        ),
                        const Text('Receita'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<bool>(
                          value: false,
                          groupValue: isReceita,
                          onChanged: (value) {
                            setStateSheet(() {
                              isReceita = value!;
                            });
                          },
                        ),
                        const Text('Despesa'),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        adicionarTransacao();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        minimumSize: const Size(50, 50),
                      ),
                      child: const Text(
                        'Adicionar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //final transacoes;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Saldo: R\$ ${calcularSaldo().toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: SizedBox(width: 40),
                    subtitle: Text('R\$ '),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 14),
              SizedBox(
                width: 60,
                child: ElevatedButton(
                  onPressed: _abrirBottomSheet,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
              SizedBox(
                width: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              SizedBox(
                width: 60,
                child: ElevatedButton(
                  onPressed: () {
                    deleteData();
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
