import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNewStockPage extends StatefulWidget {
  @override
  _AddNewStockPageState createState() => _AddNewStockPageState();
}

class _AddNewStockPageState extends State<AddNewStockPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  Future<void> _addStock() async {
    final String name = _nameController.text.trim();
    final int quantity = int.tryParse(_quantityController.text.trim()) ?? 0;

    if (name.isNotEmpty && quantity > 0) {
      try {
        final CollectionReference ingredientsRef =
        FirebaseFirestore.instance.collection('ingredient');

        final QuerySnapshot querySnapshot = await ingredientsRef
            .where('name', isEqualTo: name)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Stock with the same name already exists. Please choose a different name.')),
          );
          return;
        }

        await ingredientsRef.add({
          'name': name,
          'quantity': quantity,
        });

        _nameController.clear();
        _quantityController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stock added successfully!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add stock. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Stock'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity',
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Kembali ke halaman sebelumnya
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _addStock,
                  child: Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
