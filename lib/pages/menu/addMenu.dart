import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMenuPage extends StatefulWidget {
  const AddMenuPage({Key? key}) : super(key: key);

  @override
  _AddMenuPageState createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  late String _selectedIngredient;
  List<String> _ingredients = [];
  List<Map<String, dynamic>> _selectedIngredients = [];
  TextEditingController _nameController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _selectedIngredient = '';
    fetchIngredients();
  }

  Future<void> fetchIngredients() async {
    final QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('ingredient').get();

    setState(() {
      _ingredients = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String)
          .toList();
    });
  }

  void _addIngredient() {
    String name = _selectedIngredient;
    String quantityString = _quantityController.text.trim();
    int quantity = int.tryParse(quantityString) ?? 0;

    if (name.isNotEmpty && quantity > 0) {
      Map<String, dynamic> ingredient = {
        'ingredientName': name,
        'quantity': quantity,
      };
      setState(() {
        _selectedIngredients.add(ingredient);
        _selectedIngredient = '';
        _quantityController.clear();
        _errorMessage = '';
      });
    } else {
      setState(() {
        _errorMessage = 'Nama dan Kuantitas harus diisi.';
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _selectedIngredients.removeAt(index);
    });
  }

  void _saveMenu() {
    String name = _nameController.text.trim();

    if (name.isNotEmpty && _selectedIngredients.isNotEmpty) {
      FirebaseFirestore.instance.collection('menus').add({
        'name': name,
        'ingredients': _selectedIngredients,
      }).then((value) {
        // Penyimpanan berhasil
        print('Menu berhasil disimpan!');
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }).catchError((error) {
        // Penyimpanan gagal
        print('Gagal menyimpan menu: $error');
        // Tambahkan logika penanganan kesalahan sesuai kebutuhan
      });
    } else {
      setState(() {
        _errorMessage = 'Nama menu dan setidaknya satu bahan harus diisi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Menu"),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedIngredient,
              onChanged: (String? value) {
                setState(() {
                  _selectedIngredient = value!;
                });
              },
              items: [
                ..._ingredients.map((String ingredient) {
                  return DropdownMenuItem<String>(
                    value: ingredient,
                    child: Text(ingredient),
                  );
                }),
                DropdownMenuItem<String>(
                  value: '', // Nilai kosong
                  child: const Text('None'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: "Ingredient",
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity",
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addIngredient,
              style: ElevatedButton.styleFrom(
                primary: Colors.brown, // Warna coklat
              ),
              child: const Text("Tambah Ingredient"),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveMenu,
              style: ElevatedButton.styleFrom(
                primary: Colors.brown, // Warna coklat
              ),
              child: const Text("Simpan"),
            ),
            const SizedBox(height: 16.0),
            const Text(
              "Selected Ingredients:",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedIngredients.length,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic> ingredient = _selectedIngredients[index];
                  String name = ingredient['ingredientName'];
                  int quantity = ingredient['quantity'];

                  return ListTile(
                    title: Text('$name - $quantity'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _removeIngredient(index);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
