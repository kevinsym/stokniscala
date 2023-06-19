import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockniscala/pages/menu/AddNewStock.dart';

class Ingredient {
  final String name;

  Ingredient({required this.name});
}

class InputStockPage extends StatefulWidget {
  @override
  _InputStockPageState createState() => _InputStockPageState();
}

class _InputStockPageState extends State<InputStockPage> {
  final TextEditingController _quantityController = TextEditingController();
  String? selectedStock;
  int? quantity;
  List<Ingredient> ingredientList = [];

  Future<void> _saveStock() async {
    if (selectedStock != null && quantity != null && quantity! > 0) {
      try {
        final CollectionReference ingredientsRef =
        FirebaseFirestore.instance.collection('ingredient');

        final QuerySnapshot snapshot = await ingredientsRef
            .where('name', isEqualTo: selectedStock)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final DocumentSnapshot doc = snapshot.docs.first;
          final String docId = doc.id;
          final int previousQuantity = (doc.data() as Map<String, dynamic>)['quantity'] as int? ?? 0;

          await ingredientsRef.doc(docId).update({
            'quantity': previousQuantity + (quantity ?? 0),
          });
        } else {
          await ingredientsRef.add({
            'name': selectedStock,
            'quantity': quantity,
          });
        }

        _quantityController.clear();
        setState(() {
          quantity = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stock saved successfully!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save stock. Please try again.')),
        );
      }
    }
  }

  Future<void> _fetchIngredients() async {
    try {
      final CollectionReference ingredientsRef =
      FirebaseFirestore.instance.collection('ingredient');

      final QuerySnapshot snapshot = await ingredientsRef.get();

      final List<Ingredient> ingredients = snapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>; // Ubah tipe data menjadi Map<String, dynamic>
        final name = data['name'] as String?; // Gunakan operator [] pada objek data
        return Ingredient(name: name ?? ''); // Jika null, set nilai default ''
      })
          .toList();

      setState(() {
        ingredientList = ingredients;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch ingredients. Please try again.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Stock'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedStock,
              decoration: InputDecoration(
                labelText: 'Select Stock',
              ),
              onChanged: (value) {
                setState(() {
                  selectedStock = value;
                });
              },
              items: ingredientList.map((ingredient) {
                return DropdownMenuItem<String>(
                  value: ingredient.name,
                  child: Text(ingredient.name),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity',
              ),
              onChanged: (value) {
                quantity = int.tryParse(value);
              },
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedStock = null;
                      _quantityController.clear();
                    });
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _saveStock,
                  child: Text('Add'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Navigasi ke halaman tambah bahan baku baru
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddNewStockPage()),
                );
              },
              child: Text('Add New Ingredient'),
            ),
          ],
        ),
      ),
    );
  }
}
